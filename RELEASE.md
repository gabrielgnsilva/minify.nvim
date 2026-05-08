<!-- @format -->

# Release checklist

## Before release

- [ ] Review `git diff` and confirm the change set is intentional and minimal.
- [ ] Run `make test` from the plugin root.
- [ ] Open Neovim with the plugin and smoke test:
  - [ ] `:Minify` minifies the full buffer.
  - [ ] `:'<,'>Minify` minifies only the selected range.
  - [ ] the configured keymap works in normal and visual mode.
  - [ ] custom minifier overrides are honored.
- [ ] Verify README and help docs match the current behavior.
- [ ] Confirm no local-only paths, debug logs, or temporary code remain.

## Tagging strategy

- Use semantic versioning: `vMAJOR.MINOR.PATCH`.
- Bump `PATCH` for fixes, refactors, docs, or test-only releases with no API break.
- Bump `MINOR` for backward-compatible features or new configuration options.
- Bump `MAJOR` for breaking command, keymap, config, or minifier behavior changes.

## Release steps

1. Update docs if behavior changed.
2. Run `make test`.
3. Create a conventional commit.
4. Tag the release, for example:

```bash
git tag -a v1.0.0 -m "v1.0.0"
```

5. Push commit and tag:

```bash
git push && git push --tags
```

## Post-release

- [ ] Install from a clean Neovim setup or test profile.
- [ ] Verify lazy-loading still works with `cmd` and `keys` triggers.
- [ ] Note any minifier-specific follow-up fixes for the next patch release.
