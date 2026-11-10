# Contributing to CypherModel

Thank you for helping. You can contribute from GitHub or from GitLab, whichever you use.

## Where things happen

- **Issues**: [github.com/BiBzz/cyphermodel/issues](https://github.com/BiBzz/cyphermodel/issues).
- **Pull requests**: on [GitHub](https://github.com/BiBzz/cyphermodel/pulls) or as merge requests on [GitLab](https://gitlab.com/businessagile/libraries/cyphermodel/-/merge_requests), against `development`.
- **Source of truth**: [gitlab.com/businessagile/libraries/cyphermodel](https://gitlab.com/businessagile/libraries/cyphermodel). The final review, the CI and the merge happen there, and GitLab mirrors `development` to GitHub.

A GitHub pull request is carried over to GitLab by a maintainer, who links back to it. You keep the authorship of your commits. When it lands, GitHub shows the pull request as merged, or a maintainer closes it with a link to the commit if it had to be rebased.

## What we ask

- Sign your commits (`git commit -S`): unsigned commits cannot be merged.
- One topic per pull request, with tests for code and a page for user facing changes.
- Commit messages in English, in the [Conventional Commits](https://www.conventionalcommits.org/) form (`feat:`, `fix:`, `docs:`).

## Working locally

```console
$ uv sync --group docs
$ uv run zensical serve
```

The documentation is then served on http://localhost:8000.
