QA Quick Checklist

- Run `flutter analyze` and fix issues.
- Run `flutter test` and ensure all tests pass.
- Run widget tests separately with `scripts/run_widget_tests.ps1`.
- Verify CI workflow (.github/workflows/flutter-ci.yml) runs on PRs.
- Confirm no tests perform real network calls; use `test/test_helpers.dart`.
- Check any image/asset usages in tests are stubbed with files under `test/assets/`.
- Create issues for flaky tests and mark them with `@Skip` while investigating.
