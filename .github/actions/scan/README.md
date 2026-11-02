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

Inputs, defaults, and supported events are defined in
[action.yml](./action.yml). [plan.sh](./plan.sh) selects the scan range; a
manual dispatch or missing ancestor scans full history. Dispatch Verify after
a scanner upgrade to check history again.

Callers pin the action by full commit SHA with its release tag as a comment.
[renovate.json](../../../renovate.json) tracks scanner images and caller pins
follow new action tags. A finding fails Verify; GitHub's failed-run email is
the notification.

Compatibility: removing an input, adding a required input, or changing a
default that alters caller behavior ships as a new major tag.
