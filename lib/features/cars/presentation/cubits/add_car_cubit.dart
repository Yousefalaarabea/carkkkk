// add_car_cubit.dart
import 'package:flutter/material.dart'; // Import for GlobalKey, if still needed
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart'; // Ensure this cubit is for other home screen filters
import 'package:intl/intl.dart'; // Added for date formatting

import '../../../../core/api_service.dart';
import '../../../../core/car_service.dart'; // Ensure this is the correct path for CarService
import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

// Assuming this GlobalKey is used for context outside a widget build method,
// otherwise, consider using BlocProvider.of(context) directly.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AddCarCubit extends Cubit<AddCarState> {
  final CarService _carService = CarService();
  List<CarBundle> _cars = []; // This list holds the currently loaded cars

  AddCarCubit() : super(AddCarInitial());

  List<CarBundle> getCars() => _cars;

  /// Fetch all available cars for home screen with optional filters.
  /// This method now directly interacts with CarService which constructs the URL.
  Future<void> fetchAllCars({
    DateTime? availableFrom,
    DateTime? availableTo,
    String rentalType = 'both', // Default to 'both'
    String? carBrand, // Optional car brand
  }) async {
    emit(AddCarLoading()); // Indicate loading state
    try {
      print('🔄 AddCarCubit: Fetching all available cars with filters...');

      // Call the CarService with the new parameters
      final carBundlesRaw = await _carService.fetchAllCars(
        availableFrom: availableFrom,
        availableTo: availableTo,
        rentalType: rentalType,
        carBrand: carBrand,
      );

      print('✅ AddCarCubit: Raw data received: ${carBundlesRaw.length} cars');

      final carBundles = carBundlesRaw.map((e) {
        final car = e['car'] as CarModel;
        final rentalOptions = e['rentalOptions'] as CarRentalOptions?;
        final usagePolicy = e['usagePolicy'] as CarUsagePolicy?;

        return CarBundle(
          car: car,
          rentalOptions: rentalOptions,
          usagePolicy: usagePolicy,
        );
      }).toList();

      _cars = carBundles; // Update the internal list
      print('✅ AddCarCubit: Created ${carBundles.length} CarBundles and emitting AddCarFetchedSuccessfully');
      emit(AddCarFetchedSuccessfully(cars: carBundles)); // Emit success state with fetched cars
    } catch (e) {
      print('❌ AddCarCubit: Error fetching all available cars with filters: $e');
      emit(AddCarError(message: 'Error loading cars: $e')); // Emit error state
    }
  }

  // Existing fetchCarsFromServer - this is likely for "my-cars" (owner's cars)
  // It should also emit a state like AddCarFetchedSuccessfully
  Future<void> fetchCarsFromServer() async {
    emit(AddCarLoading());
    try {
      final carBundlesRaw = await _carService.fetchUserCars();
      final carBundles = carBundlesRaw.map((e) => CarBundle(
        car: e['car'],
        rentalOptions: e['rentalOptions'],
        usagePolicy: e['usagePolicy'],
      )).toList();
      _cars = carBundles;
      emit(AddCarFetchedSuccessfully(cars: carBundles));
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> addCar({
    required CarModel car,
    required CarRentalOptions rentalOptions,
    required CarUsagePolicy usagePolicy,
  }) async {
    emit(AddCarLoading());
    try {
      // Correctly pass Map<String, dynamic> from models
      final success = await _carService.addCar(
        carData: car.toJson(),
        rentalOptionsData: rentalOptions.toJson(),
        usagePolicyData: usagePolicy.toJson(),
      );
      if (success) {
        await fetchCarsFromServer(); // Refresh the list of user's cars
        if (_cars.isNotEmpty) {
          emit(AddCarSuccess(carBundle: _cars.last));
        } else {
          // If no cars after fetch (e.g., this was the first car), emit a general success
          emit(const AddCarSuccess(carBundle: null)); // Consider adjusting AddCarSuccess to allow null
        }
      } else {
        emit(const AddCarError(message: 'Failed to add car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> updateCar({
    required String carId,
    required CarModel car,
    required CarRentalOptions rentalOptions,
    required CarUsagePolicy usagePolicy,
  }) async {
    emit(AddCarLoading());
    try {
      final success = await _carService.updateCar(
        carId: carId,
        carData: car.toJson(),
        rentalOptionsData: rentalOptions.toJson(),
        usagePolicyData: usagePolicy.toJson(),
      );
      if (success) {
        await fetchCarsFromServer();
        final updated = _cars.firstWhere((b) => b.car.id.toString() == carId, orElse: () => CarBundle(car: car));
        emit(AddCarSuccess(carBundle: updated));
      } else {
        emit(const AddCarError(message: 'Failed to update car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> deleteCar(String carId) async {
    emit(AddCarLoading());
    try {
      final success = await _carService.deleteCar(carId);
      if (success) {
        _cars.removeWhere((b) => b.car.id.toString() == carId);
        emit(AddCarFetchedSuccessfully(cars: _cars));
      } else {
        emit(const AddCarError(message: 'Failed to delete car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<CarBundle?> fetchCarById(String carId) async {
    try {
      final data = await _carService.getCarDetails(carId);
      if (data != null) {
        final bundle = CarBundle(
          car: data['car'],
          rentalOptions: data['rentalOptions'],
          usagePolicy: data['usagePolicy'],
        );
        return bundle;
      }
      return null;
    } catch (e) {
      emit(AddCarError(message: e.toString()));
      return null;
    }
  }

  void reset() {
    emit(AddCarInitial());
  }

  void refreshCars() {
    emit(AddCarInitial());
  }
}