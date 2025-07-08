part of 'ml_validation_cubit.dart';

@immutable
abstract class MLValidationState {}

class MLValidationInitial extends MLValidationState {}

class MLValidationLoading extends MLValidationState {}

class MLValidationSuccess extends MLValidationState {
  final bool isValid;
  final double confidence;
  final String message;
  final Map<String, dynamic>? frontResult;
  final Map<String, dynamic>? backResult;

  MLValidationSuccess({
    required this.isValid,
    required this.confidence,
    required this.message,
    this.frontResult,
    this.backResult,
  });
}

class MLValidationFailure extends MLValidationState {
  final bool isValid;
  final double confidence;
  final String message;
  final Map<String, dynamic>? frontResult;
  final Map<String, dynamic>? backResult;

  MLValidationFailure({
    required this.isValid,
    required this.confidence,
    required this.message,
    this.frontResult,
    this.backResult,
  });
}

class MLValidationError extends MLValidationState {
  final String error;

  MLValidationError(this.error);
} 