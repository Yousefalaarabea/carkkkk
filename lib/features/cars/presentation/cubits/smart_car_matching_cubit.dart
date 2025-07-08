import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/smart_car_matching_service.dart';

// Events
abstract class SmartCarMatchingEvent extends Equatable {
  const SmartCarMatchingEvent();

  @override
  List<Object?> get props => [];
}

class GetCarCluster extends SmartCarMatchingEvent {
  final File imageFile;

  const GetCarCluster(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class LoadCarsByCluster extends SmartCarMatchingEvent {
  final String clusterName;

  const LoadCarsByCluster(this.clusterName);

  @override
  List<Object?> get props => [clusterName];
}

class ResetSmartCarMatching extends SmartCarMatchingEvent {}

// States
abstract class SmartCarMatchingState extends Equatable {
  const SmartCarMatchingState();

  @override
  List<Object?> get props => [];
}

class SmartCarMatchingInitial extends SmartCarMatchingState {}

class SmartCarMatchingLoading extends SmartCarMatchingState {}

class SmartCarMatchingSuccess extends SmartCarMatchingState {
  final CarCluster cluster;
  final List<CarDetails> carsInCluster;

  const SmartCarMatchingSuccess({
    required this.cluster,
    required this.carsInCluster,
  });

  @override
  List<Object?> get props => [cluster, carsInCluster];

  SmartCarMatchingSuccess copyWith({
    CarCluster? cluster,
    List<CarDetails>? carsInCluster,
  }) {
    return SmartCarMatchingSuccess(
      cluster: cluster ?? this.cluster,
      carsInCluster: carsInCluster ?? this.carsInCluster,
    );
  }
}

class SmartCarMatchingFailure extends SmartCarMatchingState {
  final String error;

  const SmartCarMatchingFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Cubit
class SmartCarMatchingCubit extends Cubit<SmartCarMatchingState> {
  final SmartCarMatchingService _service = SmartCarMatchingService();

  SmartCarMatchingCubit() : super(SmartCarMatchingInitial());

  Future<void> getCarCluster(File imageFile) async {
    try {
      emit(SmartCarMatchingLoading());
      
      // Get the car cluster
      CarCluster cluster = await _service.getCarCluster(imageFile);
      
      // If cluster has cars, use them, otherwise try to load cars by cluster name
      List<CarDetails> carsInCluster = cluster.carsInCluster ?? [];
      
      if (carsInCluster.isEmpty && cluster.clusterName.isNotEmpty) {
        carsInCluster = await _service.getCarsByCluster(cluster.clusterName);
      }
      
      emit(SmartCarMatchingSuccess(
        cluster: cluster,
        carsInCluster: carsInCluster,
      ));
    } catch (e) {
      emit(SmartCarMatchingFailure(e.toString()));
    }
  }

  Future<void> loadCarsByCluster(String clusterName) async {
    try {
      emit(SmartCarMatchingLoading());
      
      List<CarDetails> carsInCluster = await _service.getCarsByCluster(clusterName);
      
      if (state is SmartCarMatchingSuccess) {
        final currentState = state as SmartCarMatchingSuccess;
        emit(currentState.copyWith(carsInCluster: carsInCluster));
      } else {
        // Create a new cluster with the loaded cars
        final cluster = CarCluster(
          clusterName: clusterName,
          confidence: 1.0,
          carsInCluster: carsInCluster,
        );
        emit(SmartCarMatchingSuccess(
          cluster: cluster,
          carsInCluster: carsInCluster,
        ));
      }
    } catch (e) {
      emit(SmartCarMatchingFailure(e.toString()));
    }
  }

  void reset() {
    emit(SmartCarMatchingInitial());
  }

  /// Get the cluster information
  CarCluster? get cluster {
    if (state is SmartCarMatchingSuccess) {
      final currentState = state as SmartCarMatchingSuccess;
      return currentState.cluster;
    }
    return null;
  }

  /// Get cars in the cluster
  List<CarDetails> get carsInCluster {
    if (state is SmartCarMatchingSuccess) {
      final currentState = state as SmartCarMatchingSuccess;
      return currentState.carsInCluster;
    }
    return [];
  }

  /// Check if cluster has high confidence
  bool get isHighConfidence {
    final clusterData = cluster;
    return clusterData?.isHighConfidence ?? false;
  }

  /// Check if cluster has very high confidence
  bool get isVeryHighConfidence {
    final clusterData = cluster;
    return clusterData?.isVeryHighConfidence ?? false;
  }

  /// Get cluster name
  String get clusterName {
    final clusterData = cluster;
    return clusterData?.clusterName ?? '';
  }

  /// Get confidence percentage
  String get confidenceText {
    final clusterData = cluster;
    return clusterData?.confidenceText ?? '0%';
  }
} 