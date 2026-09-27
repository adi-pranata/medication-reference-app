import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_locale_store.dart';
import 'core/network/dio_client.dart';
import 'features/favorites/data/favorites_local_data_source.dart';
import 'features/favorites/data/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/medications/data/datasources/medication_remote_data_source.dart';
import 'features/medications/data/repositories/medication_repository_impl.dart';
import 'features/medications/domain/repositories/medication_repository.dart';
import 'features/medications/presentation/cubit/medication_list_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) return;

  final preferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(preferences);
  getIt.registerLazySingleton<AppLocaleStore>(() => AppLocaleStore(getIt()));
  getIt.registerLazySingleton<Dio>(createDioClient);
  getIt.registerLazySingleton<MedicationRemoteDataSource>(
    () => MedicationRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSource(getIt()),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt()),
  );
  getIt.registerFactory<MedicationListCubit>(
    () => MedicationListCubit(getIt()),
  );
  getIt.registerFactory<FavoritesCubit>(() => FavoritesCubit(getIt()));
}
