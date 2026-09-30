"""Wait for tmux's terminal palette before Codex caches its startup probe."""

import os
import re
import select
import subprocess
import sys
import termios
import time
import tty


COLOR_REPLY = re.compile(
    rb"\x1b\](10|11);rgb:[0-9a-fA-F]{1,4}/[0-9a-fA-F]{1,4}/[0-9a-fA-F]{1,4}(?:\x07|\x1b\\)"
)


def wait_palette(fd, timeout=5.0):
    """Return readiness and input to replay; never substitute a fixed palette."""
    original = termios.tcgetattr(fd)
    pending = b""
    found = set()
    deadline = time.monotonic() + timeout
    next_query = 0.0
    try:
        # TCSANOW matters: tty.setraw's default TCSAFLUSH loses type-ahead.
        tty.setraw(fd, termios.TCSANOW)
        while len(found) < 2:
            now = time.monotonic()
            if now >= deadline:
                break
            if now >= next_query:
                for slot in (b"10", b"11"):
                    if slot not in found:
                        os.write(fd, b"\x1b]" + slot + b";?\x1b\\")
                next_query = now + 0.1
            if not select.select([fd], [], [], min(next_query, deadline) - now)[0]:
                continue
            data = os.read(fd, 4096)
            if not data:
                break
            pending += data
            for reply in COLOR_REPLY.finditer(pending):
                found.add(reply[1])
            pending = COLOR_REPLY.sub(b"", pending)
    finally:
        termios.tcsetattr(fd, termios.TCSANOW, original)
    return len(found) == 2, pending


def main():
    fd = os.open("/dev/tty", os.O_RDWR | os.O_NOCTTY)
    try:
        ready, pending = wait_palette(fd)
    finally:
        os.close(fd)
    # The probe shares Codex's tty. Return early keystrokes to the pane instead
    # of swallowing them as terminal replies; -H preserves the original bytes.
    for offset in range(0, len(pending), 256):
        subprocess.run(
            [sys.argv[1], "send-keys", "-t", os.environ["TMUX_PANE"], "-H"]
            + [f"{byte:02x}" for byte in pending[offset : offset + 256]],
            check=True,
        )
    return 0 if ready else 1


if __name__ == "__main__":
    sys.exit(main())
