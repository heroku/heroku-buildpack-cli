#!/usr/bin/env bash
# Mock test suite for bin/compile script - tests version resolution logic without downloads

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get buildpack directory
BUILDPACK_DIR=$(cd "$(dirname "$0")/.." && pwd)
FIXTURE_DIR="$BUILDPACK_DIR/test/fixtures"

# Setup test environment
setup_test() {
  TEST_NAME=$1
  echo -e "\n${YELLOW}Test: ${TEST_NAME}${NC}"

  # Create temporary directories
  export TEST_BUILD_DIR=$(mktemp -d)
  export TEST_CACHE_DIR=$(mktemp -d)
  export TEST_OUTPUT=$(mktemp)

  # Setup basic structure
  mkdir -p "$TEST_BUILD_DIR/.heroku"

  TESTS_RUN=$((TESTS_RUN + 1))
}

# Teardown test environment
teardown_test() {
  rm -rf "$TEST_BUILD_DIR"
  rm -rf "$TEST_CACHE_DIR"
  rm -f "$TEST_OUTPUT"
}

# Pass/Fail functions
pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  if [ -f "$TEST_OUTPUT" ] && [ -s "$TEST_OUTPUT" ]; then
    echo "Output:"
    cat "$TEST_OUTPUT"
  fi
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test version resolution logic by running compile script until it tries to download
# We'll use timeout to stop it before actual download happens
run_compile_until_download() {
  local buildpack_dir=$(cd "$(dirname "$0")/.." && pwd)

  # Override the versions URL to use local fixture
  export HEROKU_CLI_VERSIONS_URL="file://$FIXTURE_DIR/registry.json"

  # Run compile but timeout after 1 second (just enough to see version resolution)
  # Capture output up to the download attempt
  timeout 2s "$buildpack_dir/bin/compile" "$TEST_BUILD_DIR" "$TEST_CACHE_DIR" 2>&1 | tee "$TEST_OUTPUT" || true
}

###############################################################################
# Test 1: No .heroku-cli-version file present
###############################################################################
test_no_version_file() {
  setup_test "No .heroku-cli-version file present"

  # Don't create the version file
  run_compile_until_download

  # Should see the fetching message but no version-specific messages
  if grep -q "Fetching and vendoring Heroku CLI into slug" "$TEST_OUTPUT"; then
    pass "Uses default stable version when no version file present"
  else
    fail "Should show fetching message"
  fi

  # Should NOT see any version-specific messages
  if ! grep -q "Finding latest alpha release" "$TEST_OUTPUT" && \
     ! grep -q "Finding latest beta release" "$TEST_OUTPUT" && \
     ! grep -q "Finding v[0-9]" "$TEST_OUTPUT"; then
    pass "No version-specific messages (as expected)"
  else
    fail "Should not show version-specific messages"
  fi

  teardown_test
}

###############################################################################
# Test 2: .heroku-cli-version file with invalid/unknown version
###############################################################################
test_invalid_version() {
  setup_test ".heroku-cli-version with invalid version"

  # Create version file with invalid version
  echo "invalid-version-xyz" > "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should show message about fetching the version
  if grep -q "Finding vinvalid-version-xyz release" "$TEST_OUTPUT"; then
    pass "Attempts to fetch invalid version"
  else
    fail "Should show version fetch message"
  fi

  # Should show fallback message when version not found
  if grep -q "Version invalid-version-xyz does not exist. Using stable" "$TEST_OUTPUT"; then
    pass "Falls back to stable for invalid version"
  else
    fail "Should fall back to stable"
  fi

  teardown_test
}

###############################################################################
# Test 3: Empty .heroku-cli-version file
###############################################################################
test_empty_version_file() {
  setup_test "Empty .heroku-cli-version file"

  # Create empty version file
  touch "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should use default behavior when file is empty
  if grep -q "Fetching and vendoring Heroku CLI into slug" "$TEST_OUTPUT"; then
    pass "Uses default stable version for empty file"
  else
    fail "Should use default version"
  fi

  # Should NOT see version-specific messages
  if ! grep -q "Finding v" "$TEST_OUTPUT"; then
    pass "No version-specific messages for empty file"
  else
    fail "Should not show version messages for empty file"
  fi

  teardown_test
}

###############################################################################
# Test 4: .heroku-cli-version with "alpha"
###############################################################################
test_alpha_version() {
  setup_test ".heroku-cli-version with alpha"

  # Create version file with alpha
  echo "alpha" > "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should show alpha-specific message
  if grep -q "Finding latest alpha release" "$TEST_OUTPUT"; then
    pass "Detects alpha version request"
  else
    fail "Should show alpha release message"
  fi

  teardown_test
}

###############################################################################
# Test 5: .heroku-cli-version with "beta"
###############################################################################
test_beta_version() {
  setup_test ".heroku-cli-version with beta"

  # Create version file with beta
  echo "beta" > "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should show beta-specific message
  echo "--------------------------------"
  cat "$TEST_OUTPUT"
  echo "--------------------------------"
  if grep -q "Finding latest beta release" "$TEST_OUTPUT"; then
    pass "Detects beta version request"
  else
    fail "Should show beta release message"
  fi

  teardown_test
}

###############################################################################
# Test 6: .heroku-cli-version with specific valid version (10.17.0)
###############################################################################
test_specific_version_10_17_0() {
  setup_test ".heroku-cli-version with version 10.17.0"

  # Create version file with specific version that exists in fixture
  echo "10.17.0" > "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should show specific version message
  if grep -q "Finding v10.17.0 release" "$TEST_OUTPUT"; then
    pass "Detects specific version 10.17.0"
  else
    fail "Should show v10.17.0 message"
  fi

  # Should NOT show "does not exist" message since version is valid
  if ! grep -q "does not exist" "$TEST_OUTPUT"; then
    pass "Does not show 'does not exist' for valid version"
  else
    fail "Should not show 'does not exist' for valid version"
  fi

  teardown_test
}

###############################################################################
# Test 7: .heroku-cli-version with specific valid version (9.5.1)
###############################################################################
test_specific_version_9_5_1() {
  setup_test ".heroku-cli-version with version 9.5.1"

  # Create version file with another valid version from fixture
  echo "9.5.1" > "$TEST_BUILD_DIR/.heroku-cli-version"

  run_compile_until_download

  # Should show specific version message
  if grep -q "Finding v9.5.1 release" "$TEST_OUTPUT"; then
    pass "Detects specific version 9.5.1"
  else
    fail "Should show v9.5.1 message"
  fi

  teardown_test
}

###############################################################################
# Test 8: Verify registry fixture can be loaded
###############################################################################
test_registry_fixture_loads() {
  setup_test "Registry fixture file loads correctly"

  # Try to load and parse the fixture with jq
  if jq empty "$FIXTURE_DIR/registry.json" 2>/dev/null; then
    pass "Registry fixture is valid JSON"
  else
    fail "Registry fixture should be valid JSON"
  fi

  # Check that fixture contains expected versions
  if jq -e '.["10.17.0"]' "$FIXTURE_DIR/registry.json" >/dev/null 2>&1; then
    pass "Registry contains version 10.17.0"
  else
    fail "Registry should contain version 10.17.0"
  fi

  # Check for alpha versions
  if jq -e 'to_entries | map(select(.key | contains("alpha"))) | length > 0' "$FIXTURE_DIR/registry.json" >/dev/null 2>&1; then
    pass "Registry contains alpha versions"
  else
    fail "Registry should contain alpha versions"
  fi

  # Check for beta versions
  if jq -e 'to_entries | map(select(.key | contains("beta"))) | length > 0' "$FIXTURE_DIR/registry.json" >/dev/null 2>&1; then
    pass "Registry contains beta versions"
  else
    fail "Registry should contain beta versions"
  fi

  teardown_test
}

###############################################################################
# Run all tests
###############################################################################
echo "========================================"
echo "Heroku CLI Buildpack - Mock Tests"
echo "========================================"
echo "(Using local registry fixture)"

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}Error: jq is required for these tests${NC}"
  exit 1
fi

if ! command -v timeout >/dev/null 2>&1; then
  echo -e "${YELLOW}Warning: timeout command not available, tests may hang${NC}"
fi

# Run tests
test_registry_fixture_loads
test_no_version_file
test_empty_version_file
test_invalid_version
test_alpha_version
test_beta_version
test_specific_version_10_17_0
test_specific_version_9_5_1

# Print summary
echo ""
echo "========================================"
echo "Test Results Summary"
echo "========================================"
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
fi
