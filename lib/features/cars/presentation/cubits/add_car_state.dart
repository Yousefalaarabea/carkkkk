// // add_car_state.dart
// import 'package:equatable/equatable.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
// import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
// import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';
//
// // Ensure CarBundle is correctly defined and accessible.
// // Moving it here or a common models file is a good practice.
// class CarBundle extends Equatable {
//   final CarModel car;
//   final CarRentalOptions? rentalOptions;
//   final CarUsagePolicy? usagePolicy;
//
//   const CarBundle({required this.car, this.rentalOptions, this.usagePolicy});
//
//   @override
//   List<Object?> get props => [car, rentalOptions, usagePolicy];
// }
//
// abstract class AddCarState extends Equatable {
//   const AddCarState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class AddCarInitial extends AddCarState {}
//
// class AddCarLoading extends AddCarState {}
//
// class AddCarSuccess extends AddCarState {
//   final CarBundle? carBundle; // Made nullable as it might be a general success (e.g., after addCar)
//
//   const AddCarSuccess({this.carBundle}); // Allow null carBundle
//
//   @override
//   List<Object?> get props => [carBundle];
// }
//
// class AddCarError extends AddCarState {
//   final String message;
//
//   const AddCarError({required this.message});
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class AddCarFetchedSuccessfully extends AddCarState {
//   final List<CarBundle> cars;
//
//   const AddCarFetchedSuccessfully({required this.cars});
//
//   @override
//   List<Object?> get props => [cars];
// }

// add_car_state.dart
import 'package:equatable/equatable.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

// Ensure CarBundle is correctly defined and accessible.
// Moving it here or a common models file is a good practice.
class CarBundle extends Equatable {
  final CarModel car;
  final CarRentalOptions? rentalOptions;
  final CarUsagePolicy? usagePolicy;

  const CarBundle({required this.car, this.rentalOptions, this.usagePolicy});

  @override
  List<Object?> get props => [car, rentalOptions, usagePolicy];
}

abstract class AddCarState extends Equatable {
  const AddCarState();

  @override
  List<Object?> get props => [];
}

class AddCarInitial extends AddCarState {}

class AddCarLoading extends AddCarState {}

class AddCarSuccess extends AddCarState {
  final CarBundle? carBundle; // Made nullable as it might be a general success (e.g., after addCar)

  const AddCarSuccess({this.carBundle}); // Allow null carBundle

  @override
  List<Object?> get props => [carBundle];
}

class AddCarError extends AddCarState {
  final String message;

  const AddCarError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddCarFetchedSuccessfully extends AddCarState {
  final List<CarBundle> cars;

  const AddCarFetchedSuccessfully({required this.cars});

  @override
  List<Object?> get props => [cars];
}