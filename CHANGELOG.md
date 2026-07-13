# Changelog

## Unreleased

- chore: fix Dependabot config (W-23336104)

## v1.2.1
- Fixes a bug in the `jq` query that was selecting the incorrect version, when the `.heroku-cli-version` file specified `alpha` or `beta`

## v1.2.0
- Adds support for a `.heroku-cli-version` file for pinning to a specific version of the Heroku CLI.

## v1.1.0
- Update CLI install path to v8 default path

## v1
- Adds user agent to curl/wget (https://github.com/heroku/heroku-buildpack-cli/pull/9)
