.PHONY: test test-mock test-version clean help

# Default target
.DEFAULT_GOAL := help

## help: Display this help message
help:
	@echo "Heroku CLI Buildpack - Available Targets:"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /' | column -t -s ':'

## test: Run all tests (mock and version check)
test: test-mock test-version
	@echo ""
	@echo "✓ All tests completed successfully!"

## test-mock: Run mock tests with local registry fixture (no downloads)
test-mock:
	@echo "Running mock tests with local registry fixture..."
	@./test/compile_test.sh

## test-version: Run simple version check test
test-version:
	@echo "Running version check test..."
	@./test/version_test.sh

## clean: Remove temporary test files and artifacts
clean:
	@echo "Cleaning up test artifacts..."
	@rm -rf /tmp/heroku-buildpack-test-*
	@echo "Clean complete!"
