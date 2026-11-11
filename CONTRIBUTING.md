# Contributing to CypherModel

Thank you for helping. Issues and pull requests are welcome on GitHub.

## Where things happen

- **Issues**: [github.com/BiBzz/cyphermodel/issues](https://github.com/BiBzz/cyphermodel/issues).
- **Pull requests**: on [GitHub](https://github.com/BiBzz/cyphermodel/pulls), against `development`.
- **Source of truth**: [gitlab.com/businessagile/libraries/cyphermodel](https://gitlab.com/businessagile/libraries/cyphermodel). The final review, the CI and the merge happen there, and GitLab mirrors `development` to GitHub.

A GitHub pull request is carried over to GitLab by a maintainer, who links back to it. You keep the authorship of your commits. When it lands, GitHub shows the pull request as merged, or a maintainer closes it with a link to the commit if it had to be rebased.

## What we ask

- One topic per pull request, with tests for code and a page for user facing changes.
- Commit messages in English, in the [Conventional Commits](https://www.conventionalcommits.org/) form (`feat:`, `fix:`, `docs:`).

Your commits do not need to be signed. Maintainers sign their commits and tags.

## Working locally

```console
$ uv sync --group docs
$ uv run zensical serve
```

The documentation is then served on http://localhost:8000.

## Releasing

Maintainers only. The version in `pyproject.toml` is changed through a merge request; once it is merged:

```console
$ git switch development && git pull
$ scripts/release.sh
```

It checks the tree matches `origin` and the commit is signed, builds the package, signs the `v<version>` tag and pushes it after asking. The GitLab mirror carries the tag to GitHub, whose Release workflow publishes to PyPI once a maintainer approves the `pypi` environment.
