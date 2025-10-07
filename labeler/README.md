# GitHub action to manage PR/issue labels

## Usage

### Add label

Adds label `bug` to PR/issue no. 1 in `owner/repo` repository.

```yaml
steps:
  - name: Add PR label
    uses: MetOffice/reusable-workflows/labeler  # @v1
    with:
      token: ${{ secrets.MY_TOKEN }}
      repository: owner/repo
      issue: 1
      label: bug
      action: add
```

### Remove label

Removes label `bug` from PR/issue no. 1 in `owner/repo` repository.

```yaml
steps:
  - name: Remove PR label
    uses: MetOffice/reusable-workflows/labeler  # @v1
    with:
      token: ${{ secrets.MY_TOKEN }}
      repository: owner/repo
      issue: 1
      label: bug
      action: remove
```
