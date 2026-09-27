import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/medication.dart';
import '../models/medication_model.dart';

class MedicationRemoteDataSource {
  const MedicationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MedicationPage> getMedications({
    required int skip,
    required int limit,
    String? query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (query != null && query.trim().isNotEmpty)
            'search': _searchQuery(query),
        },
      );

      final data = response.data;
      final rawResults = data?['results'];
      if (rawResults is! List) {
        throw const Failure(FailureType.invalidData);
      }

      final items = rawResults
          .whereType<Map<String, dynamic>>()
          .map(MedicationModel.fromJson)
          .where(
            (medication) =>
                medication.id.trim().isNotEmpty &&
                medication.displayName.isNotEmpty,
          )
          .toList();

      final metadata = data?['meta'];
      final resultsMetadata = metadata is Map<String, dynamic>
          ? metadata['results']
          : null;
      final total = resultsMetadata is Map<String, dynamic>
          ? resultsMetadata['total']
          : null;
      final hasMore = total is num
          ? skip + rawResults.length < total
          : rawResults.length >= limit;

      return MedicationPage(
        items: items,
        hasMore: hasMore,
        fetchedCount: rawResults.length,
      );
    } on Failure {
      rethrow;
    } on DioException catch (error) {
      if (query != null && query.trim().isNotEmpty && _isNoMatches(error)) {
        return const MedicationPage(items: [], hasMore: false);
      }
      throw _mapDioFailure(error);
    } on FormatException catch (error) {
      throw Failure(FailureType.invalidData, cause: error);
    } catch (error) {
      throw Failure(FailureType.unknown, cause: error);
    }
  }

  bool _isNoMatches(DioException error) {
    if (error.response?.statusCode != 404) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    final details = data['error'];
    return details is Map &&
        details['code'] == 'NOT_FOUND' &&
        details['message'] == 'No matches found!';
  }

  String _searchQuery(String query) {
    final safeQuery = query.replaceAll('"', '').trim();
    return 'openfda.brand_name:"$safeQuery" OR '
        'openfda.generic_name:"$safeQuery"';
  }

  Failure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 429) {
      return Failure(FailureType.rateLimited, cause: error);
    }
    if (statusCode != null && statusCode >= 500) {
      return Failure(FailureType.server, cause: error);
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Failure(FailureType.network, cause: error);
    }
    return Failure(FailureType.server, cause: error);
  }
}
