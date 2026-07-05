"""Tests for scripts/link.py — the single $HOME-mirror walk."""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'scripts'))

import link


def build_fixture(root: Path) -> Path:
    """
    Build a fake system root with a host manifest shaped like $HOME:

        system_root/
          dotfiles/
            .config/nvim/init.lua
            prettier.config.ts
          ai/skills/commit/SKILL.md
          hosts/testhost/
            .config/nvim -> ../../../dotfiles/.config/nvim   (dir symlink)
            prettier.config.ts -> ../../dotfiles/prettier.config.ts
            .npmrc                                            (real file)
            .claude/skills/commit -> ../../../../ai/skills/commit
            .DS_Store                                         (ignored)
            homedir/settings.txt   (real dir named homedir — no special-casing)
    """
    (root / 'dotfiles' / '.config' / 'nvim').mkdir(parents=True)
    (root / 'dotfiles' / '.config' / 'nvim' / 'init.lua').write_text('-- nvim')
    (root / 'dotfiles' / 'prettier.config.ts').write_text('export default {}')
    (root / 'ai' / 'skills' / 'commit').mkdir(parents=True)
    (root / 'ai' / 'skills' / 'commit' / 'SKILL.md').write_text('# commit')

    host_dir = root / 'hosts' / 'testhost'
    (host_dir / '.config').mkdir(parents=True)
    (host_dir / '.config' / 'nvim').symlink_to('../../../dotfiles/.config/nvim')
    (host_dir / 'prettier.config.ts').symlink_to('../../dotfiles/prettier.config.ts')
    (host_dir / '.npmrc').write_text('registry=https://example.test')
    (host_dir / '.claude' / 'skills').mkdir(parents=True)
    (host_dir / '.claude' / 'skills' / 'commit').symlink_to('../../../../ai/skills/commit')
    (host_dir / '.DS_Store').write_text('')
    (host_dir / 'homedir').mkdir()
    (host_dir / 'homedir' / 'settings.txt').write_text('plain')
    return host_dir


class WalkTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name).resolve()
        self.host_dir = build_fixture(self.root)
        self.home = self.root / 'home'
        self.home.mkdir()

    def tearDown(self):
        self.tmp.cleanup()

    def test_maps_every_entry_to_home_by_identity(self):
        mapping = link.walk(self.host_dir, self.home, self.root)
        self.assertEqual(mapping, {
            # symlinked dir is a leaf: linked whole, not recursed into
            str(self.home / '.config' / 'nvim'):
                str(self.root / 'dotfiles' / '.config' / 'nvim'),
            # top-level dotfile symlink resolves to absolute target
            str(self.home / 'prettier.config.ts'):
                str(self.root / 'dotfiles' / 'prettier.config.ts'),
            # real file in the host dir is linked to directly
            str(self.home / '.npmrc'):
                str(self.host_dir / '.npmrc'),
            # nested symlink lands at the mirrored depth
            str(self.home / '.claude' / 'skills' / 'commit'):
                str(self.root / 'ai' / 'skills' / 'commit'),
            # 'homedir' is just a real dir now — walked like anything else
            str(self.home / 'homedir' / 'settings.txt'):
                str(self.host_dir / 'homedir' / 'settings.txt'),
        })

    def test_missing_host_dir_yields_empty_mapping(self):
        mapping = link.walk(self.root / 'hosts' / 'no-such-host',
                            self.home, self.root)
        self.assertEqual(mapping, {})

    def test_created_links_resolve_inside_tmp_home(self):
        mapping = link.walk(self.host_dir, self.home, self.root)
        for link_path, target in mapping.items():
            self.assertTrue(link.create_symlink(Path(link_path), Path(target)))
        nvim = self.home / '.config' / 'nvim'
        self.assertTrue(nvim.is_symlink())
        self.assertEqual(nvim.resolve(),
                         self.root / 'dotfiles' / '.config' / 'nvim')
        self.assertEqual((nvim / 'init.lua').read_text(), '-- nvim')


if __name__ == '__main__':
    unittest.main()
