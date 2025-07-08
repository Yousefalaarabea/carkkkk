import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CarCardWidget extends StatefulWidget {
  final CarModel car;
  final CarRentalOptions? rentalOptions;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCardWidget({
    super.key,
    required this.car,
    required this.rentalOptions,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CarCardWidget> createState() => _CarCardWidgetState();
}

class _CarCardWidgetState extends State<CarCardWidget> {
  String? carImageUrl;
  double? carPrice;
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCarImageAndPrice();
  }

  Future<void> _loadCarImageAndPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final response = await _apiService.getWithToken(
          'cars/${widget.car.id}/image-and-pricing/',
          token,
        );

        if (response.statusCode == 200) {
          setState(() {
            carImageUrl = response.data['image_url'];
            carPrice = response.data['daily_price_without_driver']?.toDouble();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading car image and price: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate price - show API price if available, otherwise fallback to rental options
    double? price;
    if (carPrice != null) {
      price = carPrice;
    } else if (widget.rentalOptions != null) {
      price = widget.rentalOptions!.availableWithDriver
          ? widget.rentalOptions!.dailyRentalPriceWithDriver
          : widget.rentalOptions!.dailyRentalPrice;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 280.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: _getCarImageProvider(),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section with car info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car brand and model
                        Text(
                          '${widget.car.brand}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          widget.car.model,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Car type and category
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                widget.car.carType,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.car.carCategory,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom section with details and price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car specifications
                        Row(
                          children: [
                            _buildSpecChip(
                              icon: Icons.person_outline,
                              text: '${widget.car.seatingCapacity} seats',
                            ),
                            SizedBox(width: 12.w),
                            _buildSpecChip(
                              icon: Icons.settings_input_component_outlined,
                              text: widget.car.transmissionType,
                            ),
                            SizedBox(width: 12.w),
                            _buildSpecChip(
                              icon: Icons.local_gas_station_outlined,
                              text: widget.car.fuelType,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Price and year
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                if (isLoading)
                                  Container(
                                    width: 80.w,
                                    height: 20.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )
                                else
                                  Text(
                                    '${(price ?? 0).toStringAsFixed(0)} EGP/day',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (price == null && !isLoading)
                                  Text(
                                    'Price estimate',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${widget.car.year}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit and Delete icons (top right) - only for owners
              if (widget.onEdit != null || widget.onDelete != null)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      if (widget.onEdit != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white, size: 20.sp),
                            onPressed: widget.onEdit,
                            tooltip: 'Edit',
                          ),
                        ),
                      if (widget.onDelete != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                            onPressed: widget.onDelete,
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getCarImageProvider() {
    // Use API image if available
    if (carImageUrl != null && carImageUrl!.isNotEmpty) {
      return NetworkImage(carImageUrl!);
    }

    // Fallback to existing logic
    if (widget.car.imageUrl != null && widget.car.imageUrl!.isNotEmpty) {
      if (widget.car.imageUrl!.startsWith('http')) {
        return NetworkImage(widget.car.imageUrl!);
      } else {
        return FileImage(File(widget.car.imageUrl!));
      }
    } else {
      // Use a default car image based on brand
      return AssetImage('assets/images/home/5.jpg');
    }
  }
}

// while select without driver it does not filter correctly