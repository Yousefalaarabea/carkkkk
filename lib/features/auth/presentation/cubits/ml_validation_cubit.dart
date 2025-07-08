import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../../core/ml_service.dart';

part 'ml_validation_state.dart';

class MLValidationCubit extends Cubit<MLValidationState> {
  final MLService _mlService = MLService();

  MLValidationCubit() : super(MLValidationInitial());

  /// Validate a single ID document
  Future<void> validateIDDocument(File imageFile, {bool testMode = false, bool debugMode = false}) async {
    try {
      emit(MLValidationLoading());
      
      final result = await _mlService.validateIDDocument(imageFile, testMode: testMode, debugMode: debugMode);
      
      if (result['isValid'] == true) {
        emit(MLValidationSuccess(
          isValid: true,
          confidence: result['confidence'] ?? 0.0,
          message: result['message'] ?? 'Document is valid',
        ));
      } else {
        emit(MLValidationFailure(
          isValid: false,
          confidence: result['confidence'] ?? 0.0,
          message: result['message'] ?? 'Document is invalid',
        ));
      }
    } catch (e) {
      emit(MLValidationError(e.toString()));
    }
  }

  /// Validate both ID front and back documents
  Future<void> validateIDDocuments({
    required File frontImage,
    required File backImage,
  }) async {
    try {
      emit(MLValidationLoading());
      
      final result = await _mlService.validateIDDocuments(
        frontImage: frontImage,
        backImage: backImage,
      );
      
      if (result['isValid'] == true) {
        emit(MLValidationSuccess(
          isValid: true,
          confidence: result['confidence'] ?? 0.0,
          message: result['message'] ?? 'Both documents are valid',
          frontResult: result['frontResult'],
          backResult: result['backResult'],
        ));
      } else {
        emit(MLValidationFailure(
          isValid: false,
          confidence: result['confidence'] ?? 0.0,
          message: result['message'] ?? 'Documents are invalid',
          frontResult: result['frontResult'],
          backResult: result['backResult'],
        ));
      }
    } catch (e) {
      emit(MLValidationError(e.toString()));
    }
  }

  /// Reset validation state
  void reset() {
    emit(MLValidationInitial());
  }
} 