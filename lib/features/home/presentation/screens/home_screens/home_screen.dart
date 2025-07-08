// import 'dart:async';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:test_cark/core/utils/assets_manager.dart';
// import '../../../../../config/routes/screens_name.dart';
// import '../../../../auth/presentation/screens/profile/profile_screen.dart';
// import '../../widgets/home_widgets/brand_section_widget.dart';
// import '../../widgets/home_widgets/view_cars_section_widget.dart';
// import '../../widgets/home_widgets/notification_badge_widget.dart';
// import '../../widgets/rental_widgets/filter_button.dart';
// import '../../widgets/rental_widgets/rental_summary_card.dart';
// import '../booking_screens/booking_history_screen.dart';
// import '../booking_screens/payment_methods_screen.dart';
// import '../booking_screens/payment_screen.dart';
// import '../booking_screens/rental_search_screen.dart';
// import 'contact_help_screen.dart';
// import 'feedback_screen.dart';
// import 'notification_test_screen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../auth/presentation/cubits/auth_cubit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   File? _selectedImage;
//   bool _isUploading = false;
//   String? _brandResult;
//
//   void _navigateAndCloseDrawer(BuildContext context, Widget screen) {
//     Navigator.pop(context); // Close the drawer
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => screen),
//     );
//   }
//
//   void _logout(BuildContext context) {
//     final authCubit = context.read<AuthCubit>();
//     // Use the new logout method from AuthCubit
//     authCubit.logout();
//     Navigator.pop(context); // Close drawer
//     Navigator.pushReplacementNamed(context, ScreensName.login);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Logged out successfully')),
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//       await _uploadImage(_selectedImage!);
//     }
//   }
//
//   Future<void> _uploadImage(File imageFile) async {
//     setState(() {
//       _isUploading = true;
//       _brandResult = null;
//     });
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/classify-car/'));
//       request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         final respStr = await response.stream.bytesToString();
//         setState(() {
//           _brandResult = respStr;
//         });
//         _showBrandDialog(respStr);
//       } else {
//         _showBrandDialog('Error uploading');
//       }
//     } catch (e) {
//       _showBrandDialog('Server Problem');
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }
//
//   void _showBrandDialog(String brand) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Result'),
//         content: Text(brand),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Ok'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showImageSourceSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('التقاط صورة بالكاميرا'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('اختيار صورة من المعرض'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     Timer? _timer;
//     _timer = Timer.periodic(const Duration(minutes:5), (timer) => print("#####New Refresh####"));
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           leading: Builder(
//             builder: (context) =>
//                 IconButton(
//                   icon: const Icon(Icons.menu),
//                   onPressed: () => Scaffold.of(context).openDrawer(),
//                 ),
//           ),
//           actions: [
//             // Camera icon
//             IconButton(
//               icon: const Icon(Icons.camera_alt),
//               onPressed: _isUploading ? null : _showImageSourceSheet,
//               tooltip: 'التقاط أو رفع صورة',
//             ),
//             // Notification icon with badge
//             NotificationBadgeWidget(
//               onTap: () {
//                 final authCubit = context.read<AuthCubit>();
//                 final user = authCubit.userModel;
//                 Navigator.pushNamed(
//                     context, ScreensName.newnotifytest);
//               },
//             ),
//           ],
//         ),
//         drawer: BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, state) {
//             final authCubit = context.read<AuthCubit>();
//             final user = authCubit.userModel;
//             return Drawer(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   DrawerHeader(
//                     decoration: BoxDecoration(
//                       color: Theme
//                           .of(context)
//                           .primaryColor,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image(
//                           image: const AssetImage(AssetsManager.carLogo),
//                           width: 0.15.sw,
//                         ),
//                         SizedBox(height: 0.01.sh),
//                         if (user != null)
//                           Text(
//                             '${user.firstName} ${user.lastName}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         if (user != null)
//                           Text(
//                             user.role == 'owner' ? 'Car Owner' : 'Renter',
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.home),
//                     title: const Text('Home'),
//                     onTap: () => Navigator.pop(context),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.person),
//                     title: const Text('Profile'),
//                     onTap: () =>
//                         _navigateAndCloseDrawer(context, const ProfileScreen()),
//                   ),
//                   const Divider(),
//                   // Switch to Owner
//                   ListTile(
//                     leading: const Icon(Icons.directions_car),
//                     title: const Text('Switch to Owner'),
//                     onTap: () async {
//                       final authCubit = context.read<AuthCubit>();
//                       await authCubit.switchToOwner();
//                       Navigator.pop(context); // Close drawer
//
//                       // Navigate to OwnerHomeScreen
//                       Navigator.pushReplacementNamed(
//                           context, ScreensName.ownerHomeScreen);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Switched to Owner mode')),
//                       );
//                     },
//                   ),
//                   // Switch to Renter (only show if user is owner)
//                   if (user?.role == 'owner')
//                     ListTile(
//                       leading: const Icon(Icons.switch_account),
//                       title: const Text('Switch to Renter'),
//                       onTap: () async {
//                         final authCubit = context.read<AuthCubit>();
//                         await authCubit.switchToRenter();
//                         Navigator.pop(context); // Close drawer
//                         Navigator.pushReplacementNamed(
//                             context, ScreensName.homeScreen);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text(
//                               'Switched to Renter mode')),
//                         );
//                       },
//                     ),
//                   ListTile(
//                     leading: const Icon(Icons.history),
//                     title: const Text('Booking History'),
//                     onTap: () =>
//                         _navigateAndCloseDrawer(
//                             context, const BookingHistoryScreen()),
//                   ),
//                   // Booking Requests (only for renters)
//                   if (user?.role == 'renter')
//                     ListTile(
//                       leading: const Icon(Icons.pending_actions),
//                       title: const Text('Booking Requests'),
//                       onTap: () {
//                         Navigator.pop(context); // Close drawer
//                         Navigator.pushNamed(
//                             context, ScreensName.bookingRequestScreen);
//                       },
//                     ),
//                   // ListTile(
//                   //   leading: const Icon(Icons.credit_card),
//                   //   title: const Text('Payment Methods'),
//                   //   onTap: () => _navigateAndCloseDrawer(
//                   //       context, PaymentMethodsScreen(car: , totalPrice: /* provide totalPrice */)),
//                   // ),
//                   ListTile(
//                     leading: const Icon(Icons.contact_support),
//                     title: const Text('Contact & Help'),
//                     onTap: () =>
//                         _navigateAndCloseDrawer(context, const ContactHelpScreen()),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.feedback),
//                     title: const Text('Feedback'),
//                     onTap: () =>
//                         _navigateAndCloseDrawer(context, const FeedbackScreen()),
//                   ),
//                   // Test Notifications (for development)
//                   ListTile(
//                     leading: const Icon(Icons.notifications_active),
//                     title: const Text('Test Notifications'),
//                     onTap: () =>
//                         _navigateAndCloseDrawer(
//                             context, const NotificationTestScreen()),
//                   ),
//                   // Test Login API (for development)
//                   ListTile(
//                     leading: const Icon(Icons.login),
//                     title: const Text('Test Login API'),
//                     onTap: () {
//                       Navigator.pop(context); // Close drawer
//                       Navigator.pushNamed(context, '/test-login');
//                     },
//                   ),
//                   // Test Booking API (for development)
//                   ListTile(
//                     leading: const Icon(Icons.book_online),
//                     title: const Text('Test Booking API'),
//                     onTap: () {
//                       Navigator.pop(context); // Close drawer
//                       Navigator.pushNamed(context, '/test-booking-api');
//                     },
//                   ),
//                   // Test Rental Flow (for development)
//                   ListTile(
//                     leading: const Icon(Icons.route),
//                     title: const Text('Test Rental Flow'),
//                     onTap: () {
//                       Navigator.pop(context); // Close drawer
//                       Navigator.pushNamed(context, '/rental-flow-test');
//                     },
//                   ),
//                   const Divider(),
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: const Text('Logout'),
//                     onTap: () => _logout(context),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(0.03.sw),
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // SizedBox(height: 0.02.sh),
//
//                   // Search Bar
//                   // const CustomSearchBar(),
//                   const RentalSummaryCard(),
//                   SizedBox(height: 0.02.sh),
//
//                   // Filter Button
//                   const FilterButton(),
//                   SizedBox(height: 0.02.sh),
//
//                   // All brands in general
//                   const BrandSectionWidget(),
//
//                   // View Cars Section
//                   ViewCarsSectionWidget(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// removed from ui:
// //Column(
// //                       children: [
// //                         Text("Location",
// //                             style: TextStyle(
// //                                 fontSize: 0.04.sw,
// //                                 fontWeight: FontWeight.w500)),
// //                         const Row(
// //                           children: [
// //                             Icon(Icons.location_on, color: Colors.red),
// //                             Text("Alex, Egypt") //
// //                           ],
// //                         )
// //                       ],
// //                     ),
// /// car section
// // const Cars(
// //     title: 'Top Rated Cars',
// //     imagePath: 'assets/images/home/car1(home).png'),
// // const Cars(
// //     title: 'Most Popular Cars',
// //     imagePath: 'assets/images/home/car1(home).png'),
// /// Rent a Car anytime text
// // Text(TextManager.rentCarText.tr(),
// //     style: TextStyle(
// //         fontSize: 0.02.sh, fontWeight: FontWeight.bold),),
// // SizedBox(height: 0.02.sh),


// home_screen.dart
import 'dart:async';
import 'dart:convert'; // Added for json.decode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/core/utils/assets_manager.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../auth/presentation/screens/profile/profile_screen.dart';
import '../../widgets/home_widgets/brand_section_widget.dart'; // Correct import
import '../../widgets/home_widgets/view_cars_section_widget.dart';
import '../../widgets/home_widgets/notification_badge_widget.dart';
import '../../widgets/rental_widgets/filter_button.dart';
import '../../widgets/rental_widgets/rental_summary_card.dart';
import '../booking_screens/booking_history_screen.dart';
import 'contact_help_screen.dart';
import 'feedback_screen.dart';
import 'notification_test_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// Import the cubit that contains fetchAllCars
import 'package:test_cark/features/cars/presentation/cubits/add_car_cubit.dart';
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart'; // Ensure AddCarState is imported

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _identifiedCarBrand;

  void _navigateAndCloseDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _logout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacementNamed(context, ScreensName.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _identifiedCarBrand = null; // Clear previous result
      });
      await _uploadImage(_selectedImage!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://brandon-moderators-thorough-strict.trycloudflare.com/api/classify-car/')); // Use your API service base URL + endpoint
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_access_token') ?? prefs.getString('access_token'); // Try admin token first, then user token
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        print('Warning: No token found for image upload.');
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        try {
          final Map<String, dynamic> data = json.decode(respStr);
          final String brand = data['brand']; // Assuming the API returns {'brand': 'CarBrand'}
          setState(() {
            _identifiedCarBrand = brand;
          });
          _showBrandDialog(brand);
        } catch (e) {
          print('Error parsing classify-car response: $e');
          _showBrandDialog('Failed to parse response. Please try again.');
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Error uploading image: Status ${response.statusCode}, Body: $errorBody');
        _showBrandDialog('Error uploading image: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during image upload: $e');
      _showBrandDialog('Network or server problem. Please try again.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showBrandDialog(String brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Car Identification Result'),
        content: Text('Identified Car Brand: ${brand == 'Error uploading' || brand == 'Network or server problem. Please try again.' || brand == 'Failed to parse response. Please try again.' ? 'Unknown' : brand}'),
        actions: [
          if (brand != 'Error uploading' && brand != 'Network or server problem. Please try again.' && brand != 'Failed to parse response. Please try again.')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadCarsWithBrand(brand);
              },
              child: const Text('View Cars of this Brand'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // This function is correctly defined within the _HomeScreenState class
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار صورة من المعرض'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _loadCarsWithBrand(String brand) {
    // Call fetchAllCars with the identified brand
    context.read<AddCarCubit>().fetchAllCars(carBrand: brand);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loading cars for brand: $brand')),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initial load of cars for the home screen
    // This will fetch all available cars without any brand filter initially
    context.read<AddCarCubit>().fetchAllCars();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              // Fix 1: Properly display loading indicator within IconButton's icon property
              icon: _isUploading
                  ? SizedBox( // Wrap CircularProgressIndicator in a SizedBox to control its size
                width: 24.0, // Example size, adjust as needed
                height: 24.0, // Example size, adjust as needed
                child: const CircularProgressIndicator.adaptive(strokeWidth: 2.0), // Smaller stroke for better fit
              )
                  : const Icon(Icons.camera_alt),
              onPressed: _isUploading ? null : _showImageSourceSheet, // Disable button when uploading
              tooltip: 'Capture or Upload Image',
            ),
            NotificationBadgeWidget(
              onTap: () {
                Navigator.pushNamed(context, ScreensName.newnotifytest);
              },
            ),
          ],
        ),
        drawer: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user = authCubit.userModel;
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(AssetsManager.carLogo),
                          width: 0.15.sw,
                        ),
                        SizedBox(height: 0.01.sh),
                        if (user != null)
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (user != null)
                          Text(
                            user.role == 'owner' ? 'Car Owner' : 'Renter',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.read<AddCarCubit>().fetchAllCars(); // Reset filter when navigating home
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () => _navigateAndCloseDrawer(context, const ProfileScreen()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Switch to Owner'),
                    onTap: () async {
                      final authCubit = context.read<AuthCubit>();
                      await authCubit.switchToOwner();
                      Navigator.pop(context); // Close drawer
                      Navigator.pushReplacementNamed(context, ScreensName.ownerHomeScreen);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Switched to Owner mode')),
                      );
                    },
                  ),
                  if (user?.role == 'owner')
                    ListTile(
                      leading: const Icon(Icons.switch_account),
                      title: const Text('Switch to Renter'),
                      onTap: () async {
                        final authCubit = context.read<AuthCubit>();
                        await authCubit.switchToRenter();
                        Navigator.pop(context); // Close drawer
                        Navigator.pushReplacementNamed(context, ScreensName.homeScreen);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Switched to Renter mode')),
                        );
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Booking History'),
                    onTap: () => _navigateAndCloseDrawer(context, const BookingHistoryScreen()),
                  ),
                  if (user?.role == 'renter')
                    ListTile(
                      leading: const Icon(Icons.pending_actions),
                      title: const Text('Booking Requests'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.pushNamed(context, ScreensName.bookingRequestScreen);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.contact_support),
                    title: const Text('Contact & Help'),
                    onTap: () => _navigateAndCloseDrawer(context, const ContactHelpScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Feedback'),
                    onTap: () => _navigateAndCloseDrawer(context, const FeedbackScreen()),
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.notifications_active),
                  //   title: const Text('Test Notifications'),
                  //   onTap: () => _navigateAndCloseDrawer(context, const NotificationTestScreen()),
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.login),
                  //   title: const Text('Test Login API'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //     Navigator.pushNamed(context, '/test-login');
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.book_online),
                  //   title: const Text('Test Booking API'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //     Navigator.pushNamed(context, '/test-booking-api');
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.route),
                  //   title: const Text('Test Rental Flow'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //     Navigator.pushNamed(context, '/rental-flow-test');
                  //   },
                  // ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            );
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(0.03.sw),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RentalSummaryCard(),
                  SizedBox(height: 0.02.sh),
                  const FilterButton(),
                  SizedBox(height: 0.02.sh),
                  const BrandSectionWidget(),
                  ViewCarsSectionWidget(), // This widget will now react to AddCarCubit's state
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}