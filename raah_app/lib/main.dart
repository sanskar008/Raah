import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/property_repository.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/coin_repository.dart';
import 'data/repositories/rental_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'presentation/auth/viewmodels/auth_viewmodel.dart';
import 'presentation/customer/viewmodels/home_viewmodel.dart';
import 'presentation/customer/viewmodels/property_detail_viewmodel.dart';
import 'presentation/customer/viewmodels/coin_wallet_viewmodel.dart';
import 'presentation/customer/viewmodels/coin_store_viewmodel.dart';
import 'presentation/customer/viewmodels/chat_viewmodel.dart';
import 'presentation/broker/viewmodels/broker_viewmodel.dart';
import 'presentation/owner/viewmodels/owner_viewmodel.dart';
import 'presentation/owner/viewmodels/rental_viewmodel.dart';

/// App entry point.
/// Sets up dependency injection via Provider and initializes auth state.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent mobile-first experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Initialize core services ──
  final secureStorage = SecureStorageService();
  final apiService = ApiService(storage: secureStorage);

  // ── Initialize repositories ──
  final authRepository = AuthRepository(
    apiService: apiService,
    storage: secureStorage,
  );
  final propertyRepository = PropertyRepository(apiService: apiService);
  final appointmentRepository = AppointmentRepository(apiService: apiService);
  final walletRepository = WalletRepository(apiService: apiService);
  final coinRepository = CoinRepository(apiService: apiService);
  final rentalRepository = RentalRepository(apiService: apiService);
  final chatRepository = ChatRepository(apiService: apiService);

  // ── Create ViewModels ──
  final authViewModel = AuthViewModel(authRepository: authRepository);

  // Initialize auth (check for persisted login)
  await authViewModel.initialize();

  runApp(
    /// MultiProvider at the root — provides all ViewModels to the widget tree.
    /// This is the MVVM "glue" with Provider as the DI mechanism.
    MultiProvider(
      providers: [
        // Auth ViewModel — global, used everywhere
        ChangeNotifierProvider.value(value: authViewModel),

        // Customer home feed ViewModel
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(propertyRepository: propertyRepository),
        ),

        // Broker ViewModel
        ChangeNotifierProvider(
          create: (_) => BrokerViewModel(
            propertyRepository: propertyRepository,
            walletRepository: walletRepository,
          ),
        ),

        // Owner ViewModel
        ChangeNotifierProvider(
          create: (_) => OwnerViewModel(
            propertyRepository: propertyRepository,
            appointmentRepository: appointmentRepository,
          ),
        ),

        // Customer Coin ViewModels
        ChangeNotifierProvider(
          create: (_) => CoinWalletViewModel(coinRepository: coinRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinStoreViewModel(coinRepository: coinRepository),
        ),

        // Property Detail ViewModel (with coin repository for customers)
        ChangeNotifierProvider(
          create: (_) => PropertyDetailViewModel(
            propertyRepository: propertyRepository,
            appointmentRepository: appointmentRepository,
            coinRepository: coinRepository,
          ),
        ),

        // Owner Rental ViewModel
        ChangeNotifierProvider(
          create: (_) => RentalViewModel(rentalRepository: rentalRepository),
        ),

        // Chat ViewModel
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(chatRepository: chatRepository),
        ),
      ],
      child: const RaahApp(),
    ),
  );
}
