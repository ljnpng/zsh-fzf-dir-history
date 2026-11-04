import os
from pathlib import Path
import pty
import select
import shlex
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class HistoryDeletionTest(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.history = Path(self.temporary_directory.name) / "history"
        self.environment = dict(
            os.environ, ZFH_HISTORY_FILE=str(self.history), TERM="xterm-256color"
        )

    def list_history(self):
        return subprocess.check_output(
            [ROOT / "bin/fzf-hist-list"], env=self.environment
        )

    def delete_in_picker(self, entry):
        master, slave = pty.openpty()
        delete_command = shlex.quote(str(ROOT / "bin/fzf-hist-delete"))
        binding = f"start:execute-silent({delete_command} {{3}} {{1}} {{4}})+abort"
        process = subprocess.Popen(
            [
                "fzf", "--ansi", "--delimiter=\t", "--with-nth=2",
                "--nth=1", "--sync", "--bind", binding,
            ],
            stdin=subprocess.PIPE, stdout=slave, stderr=slave, env=self.environment,
        )
        os.close(slave)
        try:
            process.stdin.write(entry + b"\n")
            process.stdin.close()
            while process.poll() is None:
                if not select.select([master], [], [], 5)[0]:
                    self.fail("fzf did not finish deleting the entry")
                try:
                    os.read(master, 65536)
                except OSError:
                    break
            process.wait(timeout=5)
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
            os.close(master)

    def test_deleted_commands_stay_deleted_when_reopening(self):
        commands = [
            b"git branch",
            b"echo 'quoted' \\ path",
            "echo 中文".encode(),
            b"echo broken \x80\xaf",
            b"echo \x1b[31mcolored\x1b[0m",
        ]
        survivor = b"/other/repo\techo keep\n"
        for command in commands:
            with self.subTest(command=command):
                self.history.write_bytes(
                    survivor + b"/test/repo\t" + command + b"\n"
                )
                entry = self.list_history().splitlines()[0]
                self.delete_in_picker(entry)
                self.assertEqual(self.history.read_bytes(), survivor)
                self.assertNotIn(command.hex().encode(), self.list_history())

    def test_missing_entry_reports_failure_and_preserves_history(self):
        original = b"/test/repo\techo keep\n"
        self.history.write_bytes(original)
        result = subprocess.run(
            [ROOT / "bin/fzf-hist-delete", "/test/repo", "missing"],
            env=self.environment,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.history.read_bytes(), original)

    def test_cd_insert_uses_directory_field_with_encoded_record(self):
        directory = self.temporary_directory.name
        self.history.write_text(f"{directory}\techo selected\n")
        entry = self.list_history().decode().rstrip("\n")
        environment = dict(self.environment, PICKER_ENTRY=entry)
        result = subprocess.check_output(
            [
                "zsh", "-f", "-c", '''
                source "$1/zsh-fzf-dir-history.plugin.zsh"
                fzf() { cat >/dev/null; printf '%s\n' ctrl-j "$PICKER_ENTRY"; }
                zle() { :; }
                fzf-dir-history-widget
                printf '%s\n' "$PWD" "$LBUFFER"
                ''', "test", str(ROOT),
            ],
            env=environment,
        )
        self.assertEqual(result.decode().splitlines(), [directory, "echo selected"])


if __name__ == "__main__":
    unittest.main()
