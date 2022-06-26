dart pub global activate coverage
dart pub global run coverage:test_with_coverage
genhtml -o ./coverage/report ./coverage/lcov.info