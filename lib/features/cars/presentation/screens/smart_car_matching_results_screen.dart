import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubits/smart_car_matching_cubit.dart';
import '../../../../core/smart_car_matching_service.dart';
import '../../../../config/themes/app_colors.dart';

class SmartCarMatchingResultsScreen extends StatelessWidget {
  const SmartCarMatchingResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج تحليل السيارة'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SmartCarMatchingCubit, SmartCarMatchingState>(
        builder: (context, state) {
          if (state is SmartCarMatchingLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SmartCarMatchingSuccess) {
            return _buildResultsList(context, state);
          } else if (state is SmartCarMatchingFailure) {
            return _buildErrorWidget(context, state.error);
          } else {
            return const Center(
              child: Text('لا توجد نتائج لعرضها'),
            );
          }
        },
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, SmartCarMatchingSuccess state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cluster Information Header
          _buildClusterInfoSection(context, state.cluster),
          SizedBox(height: 24.h),

          // Cars in Cluster Section
          if (state.carsInCluster.isNotEmpty) ...[
            Text(
              'السيارات في هذا النوع: ${state.carsInCluster.length}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            // Cars List
            ...state.carsInCluster.map((car) => _buildCarCard(context, car)),
          ] else ...[
            _buildNoCarsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildClusterInfoSection(BuildContext context, CarCluster cluster) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getConfidenceColor(cluster.confidence).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getConfidenceColor(cluster.confidence),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category,
                color: _getConfidenceColor(cluster.confidence),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'نوع السيارة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(cluster.confidence),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            cluster.clusterName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'مستوى الثقة: ${cluster.confidenceText}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _getConfidenceColor(cluster.confidence),
            ),
          ),
          if (cluster.description != null && cluster.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              cluster.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          _buildConfidenceBadge(cluster),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(CarCluster cluster) {
    String badgeText;
    Color badgeColor;
    
    if (cluster.isVeryHighConfidence) {
      badgeText = 'ثقة عالية جداً';
      badgeColor = Colors.green;
    } else if (cluster.isHighConfidence) {
      badgeText = 'ثقة عالية';
      badgeColor = Colors.orange;
    } else {
      badgeText = 'ثقة متوسطة';
      badgeColor = Colors.yellow[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, CarDetails car) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image (if available)
          if (car.firstImageUrl != null) ...[
            Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: NetworkImage(car.firstImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Car Details
          _buildCarDetailsSection(context, car),

          SizedBox(height: 12.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewCarDetails(context, car),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rentCar(context, car),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'استئجار السيارة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCarsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.car_rental,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد سيارات متاحة في هذا النوع حالياً',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'يمكنك البحث عن سيارات أخرى أو المحاولة مرة أخرى لاحقاً',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetailsSection(BuildContext context, CarDetails car) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${car.brand} ${car.model} (${car.year})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildDetailChip('اللون', car.color),
            SizedBox(width: 8.w),
            _buildDetailChip('ناقل الحركة', car.transmissionType),
            SizedBox(width: 8.w),
            _buildDetailChip('الوقود', car.fuelType),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildDetailChip('المقاعد', '${car.seatingCapacity}'),
            SizedBox(width: 8.w),
            _buildDetailChip('التقييم', '${car.avgRating} ⭐'),
            SizedBox(width: 8.w),
            _buildDetailChip('المراجعات', '${car.totalReviews}'),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'المالك: ${car.ownerName} (${car.ownerRating} ⭐)',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'خطأ',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.7) return Colors.orange;
    if (confidence >= 0.5) return Colors.yellow[700]!;
    return Colors.red;
  }

  void _viewCarDetails(BuildContext context, CarDetails car) {
    // Navigate to car details screen
    // You can implement this based on your navigation structure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('عرض تفاصيل ${car.brand} ${car.model}'),
      ),
    );
  }

  void _rentCar(BuildContext context, CarDetails car) {
    // Navigate to rental screen
    // You can implement this based on your navigation structure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('استئجار ${car.brand} ${car.model}'),
      ),
    );
  }
} 