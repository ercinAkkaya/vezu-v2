import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vezu/core/base/base_firebase_storage_service.dart';
import 'package:vezu/core/base/base_gpt_service.dart';
import 'package:vezu/core/base/base_location_service.dart';
import 'package:vezu/core/navigation/app_router.dart';
import 'package:vezu/core/services/firebase_storage_service.dart';
import 'package:vezu/core/services/gpt_service.dart';
import 'package:vezu/core/theme/app_theme.dart';
import 'package:vezu/core/utils/app_constants.dart';
import 'package:vezu/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vezu/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vezu/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vezu/features/auth/domain/repositories/auth_repository.dart';
import 'package:vezu/features/auth/domain/usecases/get_cached_user_id.dart';
import 'package:vezu/features/auth/domain/usecases/get_current_user.dart';
import 'package:vezu/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:vezu/features/auth/domain/usecases/sign_out.dart';
import 'package:vezu/features/auth/domain/usecases/update_user_profile.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/combine/data/repositories/combination_repository_impl.dart';
import 'package:vezu/features/combine/domain/repositories/combination_repository.dart';
import 'package:vezu/features/combine/domain/usecases/generate_combination.dart';
import 'package:vezu/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:vezu/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:vezu/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:vezu/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:vezu/features/onboarding/domain/usecases/is_onboarding_completed.dart';
import 'package:vezu/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:vezu/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:vezu/features/weather/domain/repositories/weather_repository.dart';
import 'package:vezu/features/weather/domain/usecases/get_weather.dart';
import 'package:vezu/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:vezu/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:vezu/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:vezu/features/wardrobe/domain/usecases/add_clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/usecases/delete_clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart';
import 'firebase_options.dart';
import 'package:vezu/core/services/location_service.dart';
import 'package:vezu/core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Background notification handler'ı çağır
  await firebaseMessagingBackgroundHandler(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _initializePushNotifications();

    await NotificationService.instance.initialize();
  }
  await EasyLocalization.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  const revenueCatApiKey ='goog_ifBWZzvGcsbWBsIhLAcWaOHhgAG'; // Production anahtarı (release build için gerekli)
  
  debugPrint('[RevenueCat] API Key: ${revenueCatApiKey.substring(0, 10)}... (${kDebugMode ? "DEBUG" : "RELEASE"} mod)');
  debugPrint('[RevenueCat] API Key Type: ${revenueCatApiKey.startsWith('test_') ? "TEST/SANDBOX" : "PRODUCTION"}');
  
  // RevenueCat yapılandırması - hata yakalama ile
  try {
    await Purchases.configure(
      PurchasesConfiguration(revenueCatApiKey),
    );
    await Purchases.setLogLevel(LogLevel.debug);
    debugPrint('[RevenueCat] ✅ Başarıyla yapılandırıldı. Mod: ${kDebugMode ? "DEBUG" : "RELEASE"}');
    debugPrint('[RevenueCat] API Key Type: ${revenueCatApiKey.startsWith('test_') ? "TEST/SANDBOX - Sandbox offerings gerekiyor!" : "PRODUCTION - Google Play License Testing gerekiyor!"}');
  } catch (e, stackTrace) {
    // RevenueCat yapılandırması başarısız olsa bile uygulama çalışmaya devam etmeli
    debugPrint('[RevenueCat] ❌ Yapılandırma hatası: $e');
    debugPrint('[RevenueCat] Stack trace: $stackTrace');
    debugPrint('[RevenueCat] Uygulama RevenueCat olmadan devam edecek. Abonelik özellikleri çalışmayabilir.');
  }

  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
    localDataSource: AuthLocalDataSourceImpl(sharedPreferences),
    messaging: FirebaseMessaging.instance,
  );

  final OnboardingRepository onboardingRepository = OnboardingRepositoryImpl(
    OnboardingLocalDataSourceImpl(sharedPreferences),
  );

  final signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final getCachedUserIdUseCase = GetCachedUserIdUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final updateUserProfileUseCase = UpdateUserProfileUseCase(authRepository);
  final isOnboardingCompletedUseCase =
      IsOnboardingCompletedUseCase(onboardingRepository);
  final completeOnboardingUseCase =
      CompleteOnboardingUseCase(onboardingRepository);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final WeatherRemoteDataSource weatherRemoteDataSource =
      WeatherRemoteDataSourceImpl(dio);
  final WeatherRepository weatherRepository =
      WeatherRepositoryImpl(remoteDataSource: weatherRemoteDataSource);
  final getWeatherUseCase = GetWeatherUseCase(weatherRepository);
  final BaseLocationService locationService = LocationService();
  final BaseFirebaseStorageService firebaseStorageService =
      FirebaseStorageService(storage: FirebaseStorage.instance);
  final BaseGptService gptService = GptService(dio: Dio());
  final WardrobeRemoteDataSource wardrobeRemoteDataSource =
      WardrobeRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    storageService: firebaseStorageService,
    gptService: gptService,
  );
  final WardrobeRepository wardrobeRepository =
      WardrobeRepositoryImpl(remoteDataSource: wardrobeRemoteDataSource);
  final CombinationRepository combinationRepository =
      CombinationRepositoryImpl(gptService: gptService);
  final addClothingItemUseCase = AddClothingItemUseCase(wardrobeRepository);
  final watchWardrobeItemsUseCase =
      WatchWardrobeItemsUseCase(wardrobeRepository);
  final deleteClothingItemUseCase =
      DeleteClothingItemUseCase(wardrobeRepository);
  final generateCombinationUseCase =
      GenerateCombinationUseCase(combinationRepository);

  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: AppConstants.translationsPath,
      fallbackLocale: AppConstants.defaultLocale,
      startLocale: AppConstants.defaultLocale,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<OnboardingRepository>.value(
            value: onboardingRepository,
          ),
          RepositoryProvider<SignInWithGoogleUseCase>.value(
            value: signInWithGoogleUseCase,
          ),
          RepositoryProvider<GetCurrentUserUseCase>.value(
            value: getCurrentUserUseCase,
          ),
          RepositoryProvider<GetCachedUserIdUseCase>.value(
            value: getCachedUserIdUseCase,
          ),
          RepositoryProvider<SignOutUseCase>.value(value: signOutUseCase),
          RepositoryProvider<UpdateUserProfileUseCase>.value(
            value: updateUserProfileUseCase,
          ),
          RepositoryProvider<IsOnboardingCompletedUseCase>.value(
            value: isOnboardingCompletedUseCase,
          ),
          RepositoryProvider<CompleteOnboardingUseCase>.value(
            value: completeOnboardingUseCase,
          ),
          RepositoryProvider<WeatherRepository>.value(
            value: weatherRepository,
          ),
          RepositoryProvider<GetWeatherUseCase>.value(
            value: getWeatherUseCase,
          ),
          RepositoryProvider<BaseLocationService>.value(
            value: locationService,
          ),
          RepositoryProvider<WardrobeRepository>.value(
            value: wardrobeRepository,
          ),
          RepositoryProvider<AddClothingItemUseCase>.value(
            value: addClothingItemUseCase,
          ),
          RepositoryProvider<WatchWardrobeItemsUseCase>.value(
            value: watchWardrobeItemsUseCase,
          ),
          RepositoryProvider<DeleteClothingItemUseCase>.value(
            value: deleteClothingItemUseCase,
          ),
          RepositoryProvider<CombinationRepository>.value(
            value: combinationRepository,
          ),
          RepositoryProvider<GenerateCombinationUseCase>.value(
            value: generateCombinationUseCase,
          ),
        ],
        child: BlocProvider(
          create: (context) => AuthCubit(
            signInWithGoogleUseCase: signInWithGoogleUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            getCachedUserIdUseCase: getCachedUserIdUseCase,
            signOutUseCase: signOutUseCase,
            updateUserProfileUseCase: updateUserProfileUseCase,
          )..checkAuthStatus(),
          child: const AIOutfitCombinerApp(),
        ),
      ),
    ),
  );
}

Future<void> _initializePushNotifications() async {
  if (kIsWeb) {
    return;
  }
  final messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

class AIOutfitCombinerApp extends StatelessWidget {
  const AIOutfitCombinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      onGenerateTitle: (context) => 'appTitle'.tr(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
