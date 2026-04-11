## Release AddFonts 1.0.0

### Coverage improvement sprint (pre-release)

- [ ] Run `covr::package_coverage()` and identify all files below 80% coverage
- [ ] Run `covr::report()` for an interactive HTML breakdown
- [ ] Write missing tests for under-covered functions and edge cases
- [ ] Re-run `covr::package_coverage()` until overall coverage meets target (≥ 80%)
- [ ] Verify CI is uploading reports to Codecov (check `.woodpecker/` or equivalent CI config)
- [ ] Check Codecov dashboard to confirm coverage is tracked and badge reflects current state
- [ ] Add or update the Codecov badge in `README.md` if not present

### Preparation

- [ ] Update `Version:` in `DESCRIPTION` from `0.2.0` to `1.0.0`
- [ ] Update `NEWS.md`: rename the `0.2.0` section to `1.0.0` and document all changes
- [ ] Confirm `R (>= 4.1.0)` minimum version is correct in `DESCRIPTION`
- [ ] Run `devtools::document()` to regenerate documentation and `NAMESPACE`
- [ ] Run `devtools::check()` — must pass with 0 errors, 0 warnings, 0 notes

### Testing

- [ ] Run `devtools::test()` — all tests must pass
- [ ] Test `add_font()` end-to-end against the live Bunny Fonts API

### Documentation

- [ ] Review all exported function `@description` and `@examples` for accuracy
- [ ] Check `README.md` is up to date (install instructions, usage examples)
- [ ] Run `urlchecker::url_check()` — no broken links
- [ ] Run `spelling::spell_check_package()` — no typos

### Final checks

- [ ] Run `devtools::build()` and inspect the tarball contents
- [ ] Verify `woff2` system dependency note in `DESCRIPTION` / `README` is accurate

### Release

- [ ] Bump version in `DESCRIPTION` to `1.0.0`
- [ ] Commit: `Release AddFonts 1.0.0`
- [ ] Tag: `git tag -a v1.0.0 -m "AddFonts 1.0.0"`
- [ ] Push branch and tag to Codeberg: `git push origin release/1.0.0 --tags`
- [ ] Open a pull/merge request on [Codeberg](https://codeberg.org/gnoblet/AddFonts) to merge `release/1.0.0` → `main`
- [ ] Create a Codeberg release from tag `v1.0.0` with the `NEWS.md` 1.0.0 section as release notes
- [ ] Bump `Version:` in `DESCRIPTION` to `1.0.0.9000` on `main` for next dev cycle
