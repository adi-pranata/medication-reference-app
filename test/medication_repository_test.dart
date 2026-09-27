import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medication_reference/core/error/failure.dart';
import 'package:medication_reference/features/medications/data/datasources/medication_remote_data_source.dart';
import 'package:medication_reference/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';

class _MockDio extends Mock implements Dio {}

class _MockRemoteDataSource extends Mock
    implements MedicationRemoteDataSource {}

void main() {
  group('MedicationRemoteDataSource', () {
    late Dio dio;
    late MedicationRemoteDataSource dataSource;

    setUp(() {
      dio = _MockDio();
      dataSource = MedicationRemoteDataSource(dio);
    });

    test(
      'maps a successful response into normalized medication data',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: ''),
            data: {
              'meta': {
                'results': {'total': 1},
              },
              'results': [
                {
                  'id': 'med-1',
                  'openfda': {
                    'brand_name': ['Example Brand'],
                    'generic_name': ['Example Generic'],
                    'manufacturer_name': ['Example Manufacturer'],
                  },
                  'indications_and_usage': ['For technical testing'],
                },
              ],
            },
          ),
        );

        final result = await dataSource.getMedications(skip: 0, limit: 20);

        expect(result.items, hasLength(1));
        expect(result.items.single.primaryBrandName, 'Example Brand');
        expect(result.items.single.primaryGenericName, 'Example Generic');
        expect(result.items.single.primaryManufacturer, 'Example Manufacturer');
        expect(result.items.single.purpose, ['For technical testing']);
        expect(result.hasMore, isFalse);
      },
    );

    test('omits unnamed labels and counts every fetched API record', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {
            'meta': {
              'results': {'total': 5},
            },
            'results': [
              {'id': 'unnamed-1'},
              {
                'id': 'generic-only',
                'openfda': {
                  'generic_name': ['Example Generic'],
                },
              },
              {
                'id': 'unnamed-2',
                'openfda': {
                  'manufacturer_name': ['Example Manufacturer'],
                },
              },
              {
                'id': 'brand-from-openfda',
                'brand_name': [],
                'openfda': {
                  'brand_name': ['Example Brand'],
                },
              },
            ],
          },
        ),
      );

      final page = await dataSource.getMedications(skip: 0, limit: 20);

      expect(page.items.map((item) => item.id), [
        'generic-only',
        'brand-from-openfda',
      ]);
      expect(page.items.first.primaryGenericName, 'Example Generic');
      expect(page.items.last.primaryBrandName, 'Example Brand');
      expect(page.consumedCount, 4);
      expect(page.hasMore, isTrue);
    });

    test('searches brand and generic names with openFDA field paths', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {'results': <Map<String, dynamic>>[]},
        ),
      );

      await dataSource.getMedications(skip: 0, limit: 20, query: 'Betadine');

      verify(
        () => dio.get<Map<String, dynamic>>(
          '',
          queryParameters: {
            'skip': 0,
            'limit': 20,
            'search':
                'openfda.brand_name:"Betadine" OR '
                'openfda.generic_name:"Betadine"',
          },
        ),
      ).called(1);
    });

    test('maps a server response into a safe failure', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response<dynamic>(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(
        () => dataSource.getMedications(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having(
            (failure) => failure.type,
            'type',
            FailureType.server,
          ),
        ),
      );
    });

    test('maps HTTP 429 into a rate-limited failure', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response<dynamic>(
            statusCode: 429,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(
        () => dataSource.getMedications(skip: 0, limit: 20),
        throwsA(
          isA<Failure>().having(
            (failure) => failure.type,
            'type',
            FailureType.rateLimited,
          ),
        ),
      );
    });

    test('treats openFDA search no-match response as an empty page', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response<dynamic>(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
            data: {
              'error': {'code': 'NOT_FOUND', 'message': 'No matches found!'},
            },
          ),
        ),
      );

      final page = await dataSource.getMedications(
        skip: 0,
        limit: 20,
        query: 'missing',
      );
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test(
      'maps a named label with only purpose content to the detail',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: ''),
            data: {
              'results': [
                {
                  'id': 'purpose-only',
                  'openfda': {
                    'generic_name': ['Example Generic'],
                  },
                  'purpose': ['Example purpose'],
                },
              ],
            },
          ),
        );

        final page = await dataSource.getMedications(skip: 0, limit: 20);
        expect(page.items.single.purpose, ['Example purpose']);
      },
    );
  });

  test('retries rate-limited requests with bounded backoff', () async {
    final remoteDataSource = _MockRemoteDataSource();
    var calls = 0;
    final delays = <Duration>[];
    const page = MedicationPage(items: [], hasMore: false);

    when(
      () => remoteDataSource.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) async {
      calls++;
      if (calls < 3) throw const Failure(FailureType.rateLimited);
      return page;
    });

    final repository = MedicationRepositoryImpl(
      remoteDataSource,
      delay: (duration) async => delays.add(duration),
    );
    final result = await repository.getMedications(skip: 0, limit: 20);

    expect(result, page);
    expect(calls, 3);
    expect(delays, [
      const Duration(milliseconds: 250),
      const Duration(milliseconds: 500),
    ]);
  });
}
