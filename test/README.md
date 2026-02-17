# Heroku CLI Buildpack Tests

This directory contains tests for the Heroku CLI buildpack.

## Running Tests

Use the Makefile in the root directory to run tests:

```bash
# Run all tests (mock tests + version check)
make test

# Run mock tests with local registry fixture (fast, no downloads)
make test-mock

# Run version check test
make test-version

# View all available test targets
make help
```

## Test Files

### `compile_test.sh`

Mock tests that verify the `.heroku-cli-version` file handling and version resolution logic using a local registry fixture (`fixtures/registry.json`). These tests:

- Use `file://` URL to override `HEROKU_CLI_VERSIONS_URL` with the local registry
- Test version resolution without downloading the actual CLI (uses `timeout` to stop before download completes)
- Validate all version scenarios with real version data

**Test scenarios:**
- No `.heroku-cli-version` file present
- Invalid/unknown version in the file
- Empty `.heroku-cli-version` file
- `alpha` version specified (resolves to latest alpha from fixture)
- `beta` version specified (resolves to latest beta from fixture)
- Specific version numbers (e.g., `10.17.0`, `9.5.1`)
- Registry fixture validity (JSON parsing, contains expected versions)

### `version_test.sh`

Simple smoke test that verifies the Heroku CLI can be executed and reports its version.

## Fixtures

### `fixtures/registry.json`

A snapshot of the Heroku CLI version registry containing version-to-URL mappings. This file enables the mock tests to run without network calls by providing realistic version data locally.

The fixture includes:
- Stable releases (e.g., `10.17.0`, `9.5.1`)
- Beta releases (e.g., `10.17.0-beta.0`)
- Alpha releases (e.g., `11.0.0-alpha.29`)

To update this fixture with the latest versions:

```bash
curl -o test/fixtures/registry.json https://cli-assets.heroku.com/versions/heroku-linux-x64-tar-xz.json
```

## Test Scenarios Covered

The test suite covers the following scenarios for `.heroku-cli-version` functionality:

1. **No version file** - Should install stable version by default
2. **Invalid version** - Should show error message and fall back to stable version
3. **Empty file** - Should install stable version
4. **Alpha channel** - Should resolve and fetch latest alpha release
5. **Beta channel** - Should resolve and fetch latest beta release
6. **Specific version** - Should resolve and fetch the exact version specified

## Implementation Details

### How the Mock Tests Work

The mock tests work by:

1. Setting `HEROKU_CLI_VERSIONS_URL` to `file://path/to/fixtures/registry.json`
2. Running the compile script normally (it reads the local file as if it were a network resource)
3. Using `timeout 1s` to stop execution after version resolution but before CLI download completes
4. Examining the output to verify correct version resolution logic

This approach tests the actual compile script logic without requiring network calls or long download times.

### Limitations

- Mock tests stop before the CLI tarball extraction, so they don't verify the full installation process
- Mock tests assume the registry fixture is up-to-date and matches the production registry format

## Adding New Tests

To add new tests:

1. Add test functions to `compile_test_mock.sh` (for quick mock tests)
3. Call the test function in the "Run all tests" section of the script
4. Update this README with the new test scenario
