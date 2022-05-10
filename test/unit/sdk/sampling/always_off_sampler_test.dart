@TestOn('vm')
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/sdk/trace/span.dart';
import 'package:test/test.dart';

void main() {
  test('Context contains a Span', () {
    final traceId = api.TraceId([1, 2, 3]);
    final traceState = sdk.TraceState.fromString('test=onetwo');
    final testSpan = Span(
        'foo',
        sdk.SpanContext(
            traceId, api.SpanId([7, 8, 9]), api.TraceFlags.none, traceState),
        api.SpanId([4, 5, 6]),
        [],
        sdk.DateTimeTimeProvider(),
        sdk.Resource([]),
        sdk.InstrumentationLibrary(
            'always_off_sampler_test', 'sampler_test_version'));
    final testContext = api.Context.current.withSpan(testSpan);

    final result = sdk.AlwaysOffSampler().shouldSample(
        testContext, traceId, testSpan.name, api.SpanKind.internal, [], []);

    expect(result.decision, equals(sdk.Decision.drop));
    expect(result.spanAttributes, equals([]));
    expect(result.traceState, same(traceState));
  });
  test('Context does not contain a Span', () {
    final traceId = api.TraceId([1, 2, 3]);
    final attributesList = [
      api.Attribute.fromBoolean('boolTest', true),
      api.Attribute.fromDouble('double', 0.3)
    ];
    final testSpan = Span(
        'foo',
        sdk.SpanContext(traceId, api.SpanId([7, 8, 9]), api.TraceFlags.none,
            sdk.TraceState.empty()),
        api.SpanId([4, 5, 6]),
        [],
        sdk.DateTimeTimeProvider(),
        sdk.Resource([]),
        sdk.InstrumentationLibrary(
            'always_off_sampler_test', 'sampler_test_version'),
        attributes: attributesList);

    final result = sdk.AlwaysOffSampler().shouldSample(api.Context.root,
        traceId, testSpan.name, api.SpanKind.internal, attributesList, []);

    expect(result.decision, equals(sdk.Decision.drop));
    expect(result.spanAttributes, attributesList);
    expect(result.traceState.isEmpty, isTrue);
  });
}