"""Tests for scripts/use.py — linking sources into host manifest dirs."""

import io
import json
import os
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'scripts'))

import use


def build_fixture(root: Path) -> None:
    """
    Build a fake system root:

        system_root/
          dotfiles/
            .config/nvim/init.lua
            .config/tmux/tmux.conf
            .npmrc
          ai/
            links.json      ({CLAUDE.md -> .claude/CLAUDE.md, skills/* -> .claude/skills/})
            CLAUDE.md
            skills/a/SKILL.md
            skills/b/SKILL.md
          hosts/
    """
    (root / 'dotfiles' / '.config' / 'nvim').mkdir(parents=True)
    (root / 'dotfiles' / '.config' / 'nvim' / 'init.lua').write_text('-- nvim')
    (root / 'dotfiles' / '.config' / 'tmux').mkdir()
    (root / 'dotfiles' / '.config' / 'tmux' / 'tmux.conf').write_text('# tmux')
    (root / 'dotfiles' / '.npmrc').write_text('registry=https://example.test')

    (root / 'ai' / 'skills' / 'a').mkdir(parents=True)
    (root / 'ai' / 'skills' / 'a' / 'SKILL.md').write_text('# a')
    (root / 'ai' / 'skills' / 'b').mkdir()
    (root / 'ai' / 'skills' / 'b' / 'SKILL.md').write_text('# b')
    (root / 'ai' / 'CLAUDE.md').write_text('# claude')
    (root / 'ai' / 'links.json').write_text(json.dumps({
        'links': [
            {'src': 'CLAUDE.md', 'dest': '.claude/CLAUDE.md'},
            {'src': 'skills/*', 'dest': '.claude/skills/'},
        ],
    }))

    (root / 'hosts').mkdir()


class UseTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name).resolve()
        build_fixture(self.root)
        self.hosts_root = self.root / 'hosts'
        self.host_dir = self.hosts_root / 'testhost'

    def tearDown(self):
        self.tmp.cleanup()

    def run_use(self, src, dry_run=False, force=False):
        """Run use.use against the fixture, capturing output."""
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            ok = use.use(src, ['testhost'], self.root, self.hosts_root,
                         dry_run=dry_run, force=force)
        return ok, out.getvalue(), err.getvalue()

    def test_identity_dir_links_at_mirrored_depth(self):
        ok, _, _ = self.run_use('dotfiles/.config/nvim')
        link = self.host_dir / '.config' / 'nvim'
        self.assertTrue(ok)
        self.assertEqual(os.readlink(link), '../../../dotfiles/.config/nvim')
        self.assertEqual(link.resolve(), self.root / 'dotfiles' / '.config' / 'nvim')

    def test_identity_top_level_file(self):
        ok, _, _ = self.run_use('dotfiles/.npmrc')
        self.assertTrue(ok)
        self.assertEqual(os.readlink(self.host_dir / '.npmrc'),
                         '../../dotfiles/.npmrc')

    def test_identity_glob_links_each_match(self):
        ok, _, _ = self.run_use('dotfiles/.config/*')
        self.assertTrue(ok)
        self.assertEqual(os.readlink(self.host_dir / '.config' / 'nvim'),
                         '../../../dotfiles/.config/nvim')
        self.assertEqual(os.readlink(self.host_dir / '.config' / 'tmux'),
                         '../../../dotfiles/.config/tmux')

    def test_manifest_single_link_and_per_item_glob(self):
        ok, _, _ = self.run_use('ai')
        self.assertTrue(ok)
        claude = self.host_dir / '.claude' / 'CLAUDE.md'
        skills = self.host_dir / '.claude' / 'skills'
        self.assertEqual(os.readlink(claude), '../../../ai/CLAUDE.md')
        # skills/ stays a real dir populated by per-item links
        self.assertTrue(skills.is_dir() and not skills.is_symlink())
        self.assertEqual(os.readlink(skills / 'a'), '../../../../ai/skills/a')
        self.assertEqual(os.readlink(skills / 'b'), '../../../../ai/skills/b')

    def test_rerun_is_idempotent(self):
        self.run_use('dotfiles/.config/nvim')
        ok, out, _ = self.run_use('dotfiles/.config/nvim')
        self.assertTrue(ok)
        self.assertIn('Exists:', out)
        self.assertEqual(os.readlink(self.host_dir / '.config' / 'nvim'),
                         '../../../dotfiles/.config/nvim')

    def test_dry_run_creates_nothing(self):
        ok, out, _ = self.run_use('ai', dry_run=True)
        self.assertTrue(ok)
        self.assertIn('Would link:', out)
        self.assertEqual(list(self.hosts_root.iterdir()), [])

    def test_wrong_target_fails_without_force(self):
        (self.host_dir / '.config').mkdir(parents=True)
        (self.host_dir / '.config' / 'nvim').symlink_to('../../../dotfiles/.npmrc')
        ok, _, err = self.run_use('dotfiles/.config/nvim')
        self.assertFalse(ok)
        self.assertIn('points elsewhere', err)

    def test_force_replaces_wrong_target(self):
        (self.host_dir / '.config').mkdir(parents=True)
        (self.host_dir / '.config' / 'nvim').symlink_to('../../../dotfiles/.npmrc')
        ok, _, _ = self.run_use('dotfiles/.config/nvim', force=True)
        self.assertTrue(ok)
        self.assertEqual(os.readlink(self.host_dir / '.config' / 'nvim'),
                         '../../../dotfiles/.config/nvim')

    def test_missing_src_errors(self):
        ok, _, err = self.run_use('dotfiles/.config/nope')
        self.assertFalse(ok)
        self.assertIn('does not exist', err)

    def test_src_outside_dotfiles_without_manifest_errors(self):
        ok, _, err = self.run_use('ai/CLAUDE.md')
        self.assertFalse(ok)
        self.assertIn('not under dotfiles/', err)


if __name__ == '__main__':
    unittest.main()
