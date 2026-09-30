"""Run with: python3 -m unittest discover -s tests -p 'test_agent_deck_*.py'."""

import importlib.util
import os
from pathlib import Path
import pty
import select
import termios
import threading
import time
import unittest


spec = importlib.util.spec_from_file_location(
    "palette", Path(__file__).resolve().parents[1] / "modules/home/agent-deck-wait-palette.py"
)
palette = importlib.util.module_from_spec(spec)
spec.loader.exec_module(palette)


class PaletteTests(unittest.TestCase):
    def probe(self, reply, timeout=0.6, delay=0.15):
        master, slave = pty.openpty()
        original = termios.tcgetattr(slave)
        result = []
        errors = []

        def run():
            try:
                result.append(palette.wait_palette(slave, timeout))
            except BaseException as error:
                errors.append(error)

        worker = threading.Thread(target=run)
        try:
            worker.start()
            self.assertTrue(select.select([master], [], [], 1)[0])
            self.assertIn(b"\x1b]10;?", os.read(master, 4096))
            time.sleep(delay)
            # Model replies split across SSH/PTY reads, including their ESC.
            for byte in reply:
                os.write(master, bytes([byte]))
                time.sleep(0.001)
            worker.join(2)
            self.assertFalse(worker.is_alive())
            self.assertFalse(errors, errors)
            restored = termios.tcgetattr(slave)
            # macOS sets the kernel-maintained PENDIN bit when canonical input
            # is restored; the application-controlled tty settings must match.
            restored[3] &= ~getattr(termios, "PENDIN", 0)
            original[3] &= ~getattr(termios, "PENDIN", 0)
            self.assertEqual(restored, original)
            return result[0]
        finally:
            worker.join(2)
            os.close(master)
            os.close(slave)

    def test_delayed_fragmented_replies_and_typeahead(self):
        self.assertEqual(
            self.probe(b"hello\x1b[A\x1b]11;rgb:10/20/30\x07\x1b]10;rgb:aaaa/bbbb/cccc\x1b\\"),
            (True, b"hello\x1b[A"),
        )

    def test_requires_both_colors(self):
        self.assertEqual(self.probe(b"\x1b]11;rgb:10/20/30\x07"), (False, b""))

    def test_unsupported_terminal_times_out(self):
        self.assertEqual(self.probe(b"", timeout=0.2, delay=0), (False, b""))

    def test_malformed_reply_does_not_mark_ready(self):
        reply = b"\x1b]11;rgb:invalid\x07"
        self.assertEqual(self.probe(reply, timeout=0.2, delay=0), (False, reply))


if __name__ == "__main__":
    unittest.main()
