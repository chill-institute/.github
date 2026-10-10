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

Policy: weekly window (Monday 00:00–06:00 UTC), one-day minimum release
age (releases without a registry timestamp, such as GHCR images, are not held),
no hourly PR limit, rebases only on conflict, patch and minor grouped per manager, majors separate, digest pinning for
Actions and images, `ci` prefix for Actions and `deps` for everything else,
OpenTofu registry for providers. Non-major updates automerge by squash once
every check on the pull request passes; repositories with no checks and all
majors stay manual; majors require dashboard approval. Go, Node, and pnpm toolchain
updates remain grouped across manifests, with non-major updates eligible for
automerge. Version variables in YAML or `mise.toml` opt in with a
`# renovate: datasource=… depName=…` comment above the key.

## Verify

```sh
mise install
mise run verify
```

`verify` installs the locked Renovate version, runs
`renovate-config-validator --strict --no-global` on `renovate-config.json` and
`renovate.json`, and audits workflows and actions with `actionlint` and
`zizmor`. The [Verify workflow](./.github/workflows/verify.yml) runs the same
task on pull requests and pushes to `main`. The validator checks option names,
types, and required migrations; it does not resolve preset names or every
allowed value, so a misspelled preset still passes.
