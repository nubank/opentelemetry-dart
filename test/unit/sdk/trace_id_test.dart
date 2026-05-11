// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

@TestOn('vm')
import 'package:opentelemetry/api.dart' as api;
import 'package:test/test.dart';

class MockIdGenerator implements api.IdGenerator {
  @override
  List<int> generateTraceId() {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  }

  @override
  List<int> generateSpanId() {
    throw UnimplementedError();
  }
}

void main() {
  test('create with int list', () {
    final testTraceId = api.TraceId([1, 2, 3]);

    expect(testTraceId.get(), equals([1, 2, 3]));
    expect(testTraceId.isValid, isTrue);
    expect(testTraceId.toString(), equals('010203'));
  });

  test('create from id generator', () {
    final testTraceId = api.TraceId.fromIdGenerator(MockIdGenerator());

    expect(testTraceId.get(),
        equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]));
    expect(testTraceId.isValid, isTrue);
    expect(testTraceId.toString(), equals('0102030405060708090a0b0c0d0e0f'));
  });

  test('create from string', () {
    final testTraceId = api.TraceId.fromString('010203');

    expect(testTraceId.get(),
        equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]));
    expect(testTraceId.isValid, isTrue);
    expect(testTraceId.toString(), equals('00000000000000000000000000010203'));
  });

  test('create invalid id', () {
    final testTraceId = api.TraceId.invalid();

    expect(testTraceId.get(),
        equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
    expect(testTraceId.isValid, isFalse);
    expect(testTraceId.toString(), equals('00000000000000000000000000000000'));
  });

  test('create from oversized string truncates to rightmost 32 chars', () {
    // Simulates a non-compliant 48-char trace ID produced by a buggy Envoy build
    // (RT-806: 24-byte trace ID encoded as 48 hex chars instead of the required 16 bytes / 32 chars).
    // The rightmost 32 chars are kept to preserve the most-significant random bits
    // that were intended as the 16-byte trace ID.
    const oversized = 'f38ef66b9eda7b5df8e7971cdfd7b5ddbd5cef7775d7977b'; // 48 chars
    final testTraceId = api.TraceId.fromString(oversized);

    expect(testTraceId.toString(), equals('f8e7971cdfd7b5ddbd5cef7775d7977b'));
    expect(testTraceId.toString().length, equals(32));
    expect(testTraceId.get().length, equals(16));
    expect(testTraceId.isValid, isTrue);
  });
}
