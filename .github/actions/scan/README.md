# Scan

The push-time secret and workflow scan for chill-institute repositories. Each
repository adds it as the last step of its existing `verify` job, after a
checkout with `persist-credentials: false`:

```yaml
- if: ${{ !cancelled() }}
  uses: chill-institute/.github/.github/actions/scan@<sha> # vX.Y.Z
```

The `!cancelled()` guard scans the range even when an earlier step failed;
otherwise the next push would start after it and never scan it.

It runs on `push` and `workflow_dispatch` and passes through every other
event.

- Gitleaks scans the pushed range of private repositories. Public
  repositories rely on GitHub secret scanning and push protection; pass
  `gitleaks: true` to scan them too.
- Actionlint and Zizmor run when the range changes `.github/`, an
  `action.yml`, Zizmor configuration, or ShellCheck configuration.
- Manual dispatch, a new branch, or a previous head that is not an ancestor
  of the pushed head scans full history and always lints.
- The action deepens a shallow checkout with the job token until the
  previous head resolves.
- A Gitleaks error reading the range fails the step instead of passing.

A finding fails the pushed commit's `verify` run, and GitHub's failed-run
email is the notification. Dispatch `verify` for a full-history scan after a
scanner upgrade.

The scanners run as digest-pinned container images on Linux runners;
[`renovate.json`](../../../renovate.json) tracks them. Callers pin the action
by full commit SHA with its release tag as the version comment, and Renovate
moves the pin when a new tag is pushed.

Inputs:

| Input | Default | Meaning |
| --- | --- | --- |
| `gitleaks` | `auto` | `auto` scans private repositories only; `true` or `false` forces it. |
| `token` | `github.token` | Deepens the checkout and serves Zizmor's online audits. |

Compatibility: removing an input, adding a required input, or changing a
default that alters caller behavior ships as a new major tag.
