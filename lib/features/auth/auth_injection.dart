import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/router/app_router.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/data/session_writer.dart';

/// The Java session: encrypted token store, the Java client, sign-in /
/// restore / sign-out. Additive - no existing registration changes.
void registerAuthModule(GetIt sl) {
  sl.registerLazySingleton<SessionTokenStore>(() => SessionTokenStore(const PlatformSecureKeyValueStore()));
  sl.registerLazySingleton<JavaApiClient>(() => JavaApiClient(sl<SessionTokenStore>()));
  sl.registerLazySingleton<MobileAuthApi>(() => MobileAuthApi(sl<JavaApiClient>()));
  sl.registerLazySingleton<SessionWriter>(() => SessionWriter(sl<SessionTokenStore>()));
  sl.registerLazySingleton<SessionService>(() {
    final service = SessionService(
      api: sl<MobileAuthApi>(),
      tokens: sl<SessionTokenStore>(),
      writer: sl<SessionWriter>(),
    );
    // a Java call whose session cannot be refreshed any more ends at the login page
    service.attachTo(sl<JavaApiClient>(), onSessionEnded: () => appRouter.go('/login'));
    return service;
  });
}
