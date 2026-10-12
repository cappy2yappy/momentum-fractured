# Pending native-platform CI

The proposed workflow is retained as parity-playtest-build.proposed.yml because current GitHub OAuth authentication cannot create/update workflows without workflow scope. It has not been installed or executed for this recovery branch.

A maintainer with workflow-capable repository authentication should copy the proposal to .github/workflows/parity-playtest-build.yml and commit it on the recovery branch. It triggers for recovery source pushes, validates source with official Godot 4.6.1, exports both platforms, and runs native Windows/macOS source suites and packaged startup. Review the resulting job logs/artifacts before changing TEST_RESULTS.md; workflow installation or dispatch alone is not a passing result.

Use a supported browser/device/keychain authentication flow; credentials need not be supplied in chat. Existing source commits and development branches require no history rewrite.
