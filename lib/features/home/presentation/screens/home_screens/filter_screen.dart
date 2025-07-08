import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import '../../../../cars/presentation/cubits/smart_car_matching_cubit.dart';
import '../../../../cars/presentation/screens/smart_car_matching_results_screen.dart';
import '../../cubit/car_cubit.dart';
import '../../widgets/filter_widgets/car_filters.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = pickedFile;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = pickedFile;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _performSmartMatching() async {
    if (_selectedImage != null) {
      try {
        final file = File(_selectedImage!.path);
        context.read<SmartCarMatchingCubit>().getCarCluster(file);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carCubit = context.read<CarCubit>();

    return BlocListener<SmartCarMatchingCubit, SmartCarMatchingState>(
      listener: (context, state) {
        if (state is SmartCarMatchingSuccess) {
          // Navigate to results screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SmartCarMatchingResultsScreen(),
            ),
          );
        } else if (state is SmartCarMatchingFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: _buildFilterScreen(context, carCubit),
    );
  }

  Widget _buildFilterScreen(BuildContext context, CarCubit carCubit) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.04.sw, vertical: 0.02.sh),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Close, Title, Clear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSecondary),
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        ScreensName.mainNavigationScreen,
                            (route) => false,
                      ),
                    ),
                    Text(
                      TextManager.filter.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        carCubit.resetFilters();
                      },
                      child: Text(TextManager.clear.tr()),
                    ),
                  ],
                ),

                SizedBox(height: 0.02.sh),

                // Car Filters Section
                const CarFilters(),

                SizedBox(height: 0.03.sh),

                // Smart Car Analysis Title
                Text(
                  'You want your favourite car?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 8.h),

                // Camera/Gallery Section
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('camera'),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Smart Matching Button
                if (_selectedImage != null) ...[
                  SizedBox(height: 16.h),
                  BlocBuilder<SmartCarMatchingCubit, SmartCarMatchingState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state is SmartCarMatchingLoading
                              ? null
                              : () => _performSmartMatching(),
                          icon: state is SmartCarMatchingLoading
                              ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Icon(Icons.search, color: Colors.white),
                          label: Text(
                            state is SmartCarMatchingLoading
                                ? 'It will be here soon'
                                : 'Get my car',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                SizedBox(height: 0.06.sh),

                // Apply Filters Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      carCubit.setFilters(
                        carType: carCubit.state.carType,
                        category: carCubit.state.category,
                        transmission: carCubit.state.transmission,
                        fuel: carCubit.state.fuel,
                        withDriver: carCubit.state.withDriver,
                        withoutDriver: carCubit.state.withoutDriver,
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        ScreensName.mainNavigationScreen,
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      TextManager.applyButton.tr(),
                      style: Theme.of(context).elevatedButtonTheme.style!.textStyle!.resolve({}),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
