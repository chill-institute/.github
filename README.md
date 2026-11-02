# .github

Organization profile, shared community files, the shared
[scan action](./.github/actions/scan), and the shared Renovate preset for
`chill-institute` repositories.

## Renovate preset

Extend [`renovate-config.json`](./renovate-config.json) from a repository's
`renovate.json`:

```json
{ "$schema": "https://docs.renovatebot.com/renovate-schema.json", "extends": ["github>chill-institute/.github:renovate-config"] }
```

The schedule, grouping, release-age, automerge, and pinning rules live in
[renovate-config.json](./renovate-config.json). Annotated version variables
opt in through the `customManagers` patterns in that file.

## Verify

```sh
mise install
mise run verify
```

The [verify task](./mise.toml) installs locked dependencies and validates the
preset and workflows. The validator does not resolve preset names or every
allowed value, so a misspelled preset can still pass.
