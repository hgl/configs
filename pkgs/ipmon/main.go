package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/netip"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"time"

	"github.com/godbus/dbus/v5"
	"github.com/hgl/golib/fileutil"
	"github.com/hgl/golib/ordered"
	"github.com/hgl/golib/set"
)

func main() {
	slog.SetLogLoggerLevel(slog.LevelDebug)
	err := Listen(os.Args[1])
	if err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}
}

func Listen(dir string) error {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return err
	}
	defer conn.Close()

	ifaces, err := LoadInterfaces(dir, conn)
	if err != nil {
		return err
	}

	return ifaces.Listen()
}

type Interfaces struct {
	conn      *dbus.Conn
	rawByPath map[dbus.ObjectPath]*rawInterface
	rawByName map[string]*rawInterface
	m         map[dbus.ObjectPath]*Interface
	scripts   map[string][]script
}
type rawInterface struct {
	Index int
	Name  string
	Path  dbus.ObjectPath
}

const (
	keyIPv6 = "IPV6_ADDRS"
	keyIPv4 = "IPV4_ADDRS"
	keyPD   = "PD_ADDRS"
)

type Interface struct {
	raw        *rawInterface
	parent     *Interfaces
	properties map[string]string
	scripts    []script
}

type script struct {
	Path       string
	Properties *scriptProperties
}

type scriptProperties struct {
	Interfaces []string
	Watch      *set.Set[string]
}

func LoadInterfaces(dir string, conn *dbus.Conn) (*Interfaces, error) {
	files, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	var scripts ordered.Map[string, script]
outer:
	for _, file := range files {
		path := filepath.Join(dir, file.Name())
		info, err := os.Stat(path)
		if err != nil {
			return nil, err
		}
		mode := info.Mode()
		if !mode.IsRegular() {
			continue
		}
		if mode&0100 != 0 {
			slog.Debug("reading executable", "file", path)
			script, _ := scripts.Get(path)
			script.Path = path
			scripts.Set(path, script)
		} else {
			ext := filepath.Ext(file.Name())
			if ext != ".json" {
				continue
			}
			slog.Debug("reading json", "file", path)
			var props scriptProperties
			err := fileutil.ReadJSON(path, &props)
			if err != nil {
				return nil, err
			}
			if props.Watch.Len() == 0 {
				slog.Warn("nothing to watch, ignored", "file", path)
				continue
			}
			for val := range props.Watch.All() {
				switch val {
				case keyIPv6, keyIPv4, keyPD:
				default:
					slog.Error("invalid watch value", "value", val, "file", path)
					continue outer
				}
			}
			slog.Debug("read json file", "props", props)
			path = strings.TrimSuffix(path, ".json")
			script, _ := scripts.Get(path)
			script.Properties = &props
			scripts.Set(path, script)
		}
	}
	if scripts.Len() == 0 {
		return nil, errors.New("no interface is specified to be watched")
	}
	ifaces := &Interfaces{
		conn:    conn,
		scripts: make(map[string][]script),
		m:       make(map[dbus.ObjectPath]*Interface),
	}
	for path, script := range scripts.All() {
		if script.Path == "" {
			slog.Warn("no corresponding executable file, ignored", "file", path+".json")
			continue
		}
		if script.Properties == nil {
			slog.Warn("no corresponding json file, ignored", "file", path)
			continue
		}
		if len(script.Properties.Interfaces) == 0 {
			slog.Warn("no interfaces specified, ignored", "file", path)
			continue
		}
		for _, ifname := range script.Properties.Interfaces {
			ifaces.scripts[ifname] = append(ifaces.scripts[ifname], script)
		}
	}
	return ifaces, nil
}

func (ifaces *Interfaces) Listen() error {
	err := ifaces.conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchSender("org.freedesktop.network1"),
		dbus.WithMatchPathNamespace("/org/freedesktop/network1/link"),
	)
	if err != nil {
		return err
	}

	err = ifaces.loadRaw()
	if err != nil {
		return err
	}
	for ifname := range ifaces.scripts {
		raw := ifaces.rawByName[ifname]
		if raw == nil {
			continue
		}

		iface, err := ifaces.getByPath(raw.Path)
		if err != nil {
			return err
		}
		if iface == nil {
			continue
		}
		err = iface.runScriptsIfChanged()
		if err != nil {
			return err
		}
	}

	signals := make(chan *dbus.Signal)
	ifaces.conn.Signal(signals)

	for signal := range signals {
		pc, err := parsePropertiesChanged(signal.Body)
		if err != nil {
			slog.Error(err.Error())
			continue
		}
		ipChanged, err := pc.ipChanged()
		if err != nil {
			slog.Error(err.Error())
			continue
		}
		if !ipChanged {
			continue
		}
		iface, err := ifaces.getByPath(signal.Path)
		if err != nil {
			slog.Error(err.Error())
			continue
		}
		if iface == nil {
			continue
		}
		err = iface.runScriptsIfChanged()
		if err != nil {
			slog.Error(err.Error())
		}
	}
	return nil
}

func (ifaces *Interfaces) getByPath(path dbus.ObjectPath) (*Interface, error) {
	iface := ifaces.m[path]
	if iface != nil {
		return iface, nil
	}

	raw, ok := ifaces.rawByPath[path]
	if !ok {
		ifaces.loadRaw()
		raw, ok = ifaces.rawByPath[path]
		if !ok {
			return nil, errors.New("unable to find interface with path: " + string(path))
		}
	}
	scripts, ok := ifaces.scripts[raw.Name]
	if !ok {
		return nil, nil
	}
	wildcardScripts, ok := ifaces.scripts[""]
	if ok {
		scripts = append(scripts, wildcardScripts...)
	}
	iface = &Interface{
		parent:     ifaces,
		raw:        raw,
		scripts:    scripts,
		properties: make(map[string]string),
	}
	ifaces.m[path] = iface
	return iface, nil
}

func (ifaces *Interfaces) loadRaw() error {
	obj := ifaces.conn.Object("org.freedesktop.network1", "/org/freedesktop/network1")
	call := obj.Call("org.freedesktop.network1.Manager.ListLinks", 0)
	var v []*rawInterface
	err := call.Store(&v)
	if err != nil {
		return err
	}
	ifaces.rawByPath = make(map[dbus.ObjectPath]*rawInterface)
	ifaces.rawByName = make(map[string]*rawInterface)
	for _, iface := range v {
		ifaces.rawByPath[iface.Path] = iface
		ifaces.rawByName[iface.Name] = iface
	}
	return nil
}

func (iface *Interface) runScriptsIfChanged() error {
	obj := iface.parent.conn.Object("org.freedesktop.network1", "/org/freedesktop/network1")
	call := obj.Call("org.freedesktop.network1.Manager.DescribeLink", 0, iface.raw.Index)
	var s string
	call.Store(&s)
	var v struct {
		Addresses []struct {
			Address      []byte
			PrefixLength int
		}
		DHCPv6Client struct {
			Prefixes []struct {
				Prefix       []byte
				PrefixLength int
			}
		}
	}
	err := json.Unmarshal([]byte(s), &v)
	if err != nil {
		return err
	}
	var ipv6Set ordered.Set[string]
	var ipv4Set ordered.Set[string]
	for _, rawAddr := range v.Addresses {
		addr, ok := netip.AddrFromSlice(rawAddr.Address)
		if !ok {
			return fmt.Errorf("invalid IP address from dbus: %s", rawAddr.Address)
		}
		if addr.IsPrivate() || !addr.IsGlobalUnicast() {
			continue
		}
		prefix := netip.PrefixFrom(addr, rawAddr.PrefixLength)
		if prefix.Bits() == -1 {
			return fmt.Errorf("invalid PrefixLength from dbus: %d", rawAddr.PrefixLength)
		}
		if addr.Is6() {
			ipv6Set.Add(prefix.String())
		} else {
			ipv4Set.Add(prefix.String())
		}
	}
	var pdSet ordered.Set[string]
	for _, rawPrefix := range v.DHCPv6Client.Prefixes {
		addr, ok := netip.AddrFromSlice(rawPrefix.Prefix)
		if !ok {
			return fmt.Errorf("invalid PD prefix from dbus: %s", rawPrefix.Prefix)
		}
		prefix := netip.PrefixFrom(addr, rawPrefix.PrefixLength)
		if prefix.Bits() == -1 {
			return fmt.Errorf("invalid PrefixLength from dbus: %d", rawPrefix.PrefixLength)
		}
		pdSet.Add(prefix.String())
	}
	var envs ordered.Map[string, []string]
	ipv6 := strings.Join(slices.Collect(ipv6Set.All()), " ")
	if old, hasOld := iface.properties[keyIPv6]; !hasOld || old != ipv6 {
		iface.properties[keyIPv6] = ipv6
		for _, script := range iface.scripts {
			if script.Properties.Watch.Contains(keyIPv6) {
				env, _ := envs.Get(script.Path)
				if hasOld {
					env = append(env, "OLD_"+keyIPv6+"="+old)
				}
				env = append(env, keyIPv6+"="+ipv6)
				envs.Set(script.Path, env)
			}
		}
	}
	ipv4 := strings.Join(slices.Collect(ipv4Set.All()), " ")
	if old, hasOld := iface.properties[keyIPv4]; !hasOld || old != ipv4 {
		iface.properties[keyIPv4] = ipv4
		for _, script := range iface.scripts {
			if script.Properties.Watch.Contains(keyIPv4) {
				env, _ := envs.Get(script.Path)
				if hasOld {
					env = append(env, "OLD_"+keyIPv4+"="+old)
				}
				env = append(env, keyIPv4+"="+ipv4)
				envs.Set(script.Path, env)
			}
		}
	}
	pd := strings.Join(slices.Collect(pdSet.All()), " ")
	if old, hasOld := iface.properties[keyPD]; !hasOld || old != pd {
		iface.properties[keyPD] = pd
		for _, script := range iface.scripts {
			if script.Properties.Watch.Contains(keyPD) {
				env, _ := envs.Get(script.Path)
				if hasOld {
					env = append(env, "OLD_"+keyPD+"="+old)
				}
				env = append(env, keyPD+"="+pd)
				envs.Set(script.Path, env)
			}
		}
	}

	for path, env := range envs.All() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
		cmd := exec.CommandContext(ctx, path)
		cmd.Env = append(cmd.Env, env...)
		stdout := new(bytes.Buffer)
		stderr := new(bytes.Buffer)
		cmd.Stdout = stdout
		cmd.Stderr = stderr
		slog.Debug("runing script", "env", env, "path", path)
		err := cmd.Run()
		if err != nil {
			slog.Error("script failed to run", "env", env, "path", path, "stdout", stdout.String(), "stderr", stderr.String())
		}
		cancel()
	}
	return nil
}

type propertiesChanged struct {
	Interface             string
	Changes               map[string]dbus.Variant
	InvalidatedProperties []string
}

func parsePropertiesChanged(body []any) (propertiesChanged, error) {
	var pc propertiesChanged

	if len(body) != 3 {
		return pc, dbus.InvalidMessageError("invalid body length for PropertiesChanged")
	}

	iface, ok := body[0].(string)
	if !ok {
		return pc, dbus.InvalidMessageError("invalid interface_name from PropertiesChanged signal")
	}

	changes, ok := body[1].(map[string]dbus.Variant)
	if !ok {
		return pc, dbus.InvalidMessageError("invalid changed_properties from PropertiesChanged signal")
	}

	ips, ok := body[2].([]string)
	if !ok {
		return pc, dbus.InvalidMessageError("invallid invalidated_properties from PropertiesChanged signal")
	}
	pc.Interface = iface
	pc.Changes = changes
	pc.InvalidatedProperties = ips
	return pc, nil
}
func (pc propertiesChanged) ipChanged() (bool, error) {
	switch pc.Interface {
	case "org.freedesktop.network1.Link":
		for prop := range pc.Changes {
			switch prop {
			case "IPv4AddressState", "IPv6AddressState":
				slog.Debug("property changed", "property", prop, "interface", pc.Interface)
				return true, nil
			default:
				slog.Debug("ignoring property change", "property", prop)
			}
		}
	case "org.freedesktop.network1.DHCPv6Client":
		for prop, value := range pc.Changes {
			switch prop {
			case "State":
				val := value.Value()
				s, ok := val.(string)
				if !ok {
					slog.Warn("unknown property value", "property", prop, "value", val, "interface", pc.Interface)
					continue
				}
				switch s {
				case "bound", "stopped":
					slog.Debug("property changed", "property", prop, "value", val, "interface", pc.Interface)
					return true, nil
				default:
					slog.Debug("ignoring property change", "property", prop, "value", val)
				}
			default:
				slog.Debug("ignoring property change", "property", prop, "interface", pc.Interface)
			}
		}
	default:
		for prop := range pc.Changes {
			switch prop {
			default:
				slog.Debug("ignoring property change", "property", prop, "interface", pc.Interface)
			}
		}
	}
	return false, nil
}
