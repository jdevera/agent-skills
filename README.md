# agent-skills

My published agent skills. Anyone with the
[`skills`](https://github.com/vercel-labs/add-skill) CLI can install
from here:

```bash
npx skills add jdevera/agent-skills                   # all
npx skills add jdevera/agent-skills --skill <name>    # one
npx skills add jdevera/agent-skills --list            # browse
```

Two kinds of content live here:

- **Authored**: skills I wrote.
- **Forked**: skills I took from upstream and modified, often because
  the upstream doesn't follow the
  [Agent Skills spec](https://agentskills.io/specification) or I
  wanted local changes.

## Skills

<!-- BEGIN SKILLS -->

| Skill | Kind | Source |
|-------|------|--------|
| `typescript-code-review` | fork | [`Exploration-labs/typescript-code-review`](https://github.com/Exploration-labs/typescript-code-review) |

<!-- END SKILLS -->

The table above is generated from `manifest.json` by
[`scripts/render-skills-list.sh`](scripts/render-skills-list.sh) and
kept in sync by a pre-commit hook.

## Layout

```
manifest.json                   Inventory of every skill + its source
schema/manifest.schema.json     JSON Schema for manifest.json
scripts/check-manifest-sync.sh  Bidirectional skills/ vs manifest.json check
.pre-commit-config.yaml         Runs the schema and sync checks locally
.github/workflows/check.yml     CI runs the same pre-commit hooks
skills/<name>/                  Per-skill content (Agent Skills spec layout)
```

## Manifest

Every skill is registered in [`manifest.json`](manifest.json). Each
entry has a `source` discriminated by `kind`:

- `local`: I authored it here.
- `fork`: I took it from upstream and (usually) modified it.

```json
{
  "$schema": "./schema/manifest.schema.json",
  "version": 1,
  "skills": {
    "my-authored-skill": {
      "source": { "kind": "local" }
    },
    "typescript-code-review": {
      "source": {
        "kind": "fork",
        "repo": "Exploration-labs/typescript-code-review",
        "path": ".",
        "ref": "main",
        "commit": "<sha>",
        "forked_at": "YYYY-MM-DD"
      }
    }
  }
}
```

`fork` source fields:

| Field       | Required | Meaning                                                                |
|-------------|----------|------------------------------------------------------------------------|
| `repo`      | yes      | GitHub `owner/repo` shorthand or any full git URL.                     |
| `ref`       | yes      | Branch, tag, or ref.                                                   |
| `commit`    | yes      | Full SHA pinned at fork time.                                          |
| `forked_at` | yes      | `YYYY-MM-DD`.                                                          |
| `path`      | no       | Directory inside the source repo. Default `skills/<name>/`; use `"."` for a single-skill repo with `SKILL.md` at the root. |
| `name`      | no       | Original upstream name if I renamed it locally.                        |

The full schema is
[`schema/manifest.schema.json`](schema/manifest.schema.json).

### Updating a fork

Fetch upstream, diff against the recorded `commit`, re-apply local
edits, bump `commit` and `forked_at` in `manifest.json`. Local edits
since the fork show up as `git diff` against the initial vendoring
commit.

## Validation

Validation runs through
[pre-commit](https://pre-commit.com/), and the same hooks run in CI
via [`pre-commit/action`](https://github.com/pre-commit/action) on
every push and PR (see
[`.github/workflows/check.yml`](.github/workflows/check.yml)).

Locally:

```bash
pre-commit install              # one-time, wires the hooks into git
pre-commit run --all-files
```

The hooks themselves live in
[`.pre-commit-config.yaml`](.pre-commit-config.yaml).

## See also

- [Agent Skills spec](https://agentskills.io/specification)
- [`skills` CLI](https://github.com/vercel-labs/add-skill)
- Sibling repo: [`jdevera/dotagents`](https://github.com/jdevera/dotagents) (install destination + personal config)
