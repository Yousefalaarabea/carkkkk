// import 'dart:io';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../../config/themes/app_colors.dart';
// import '../../../../../core/utils/assets_manager.dart';
// import '../../../../../core/utils/text_manager.dart';
// import '../../../../home/presentation/widgets/search_widgets/camera_preview_box.dart';
// import '../../widgets/documents/document_stepper.dart';
// import '../../widgets/documents/dotted_instruction_box.dart';
// import '../../widgets/profile_custom_widgets/document_upload_flow.dart';
// import '../../cubits/document_cubit.dart';
// import '../../cubits/document_state.dart';
//
// ///DONE
// class DocumentUploadScreen extends StatefulWidget {
//   final DocumentType documentType;
//   final void Function(DocumentType, File) onNext;
//
//   const DocumentUploadScreen({
//     super.key,
//     required this.documentType,
//     required this.onNext,
//   });
//
//   @override
//   State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
// }
//
// class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
//   @override
//   void didUpdateWidget(covariant DocumentUploadScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.documentType != widget.documentType) {
//       context.read<DocumentCubit>().clearSelectedFile();
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.camera);
//     if (picked != null) {
//       final file = File(picked.path);
//       context.read<DocumentCubit>().pickImage(file);
//     }
//   }
//
//   void _uploadDocument(BuildContext context) {
//     final selectedFile = context.read<DocumentCubit>().selectedFile;
//     if (selectedFile != null) {
//       context
//           .read<DocumentCubit>()
//           .uploadDocument(widget.documentType, selectedFile);
//     }
//   }
//
//   String _getLabelForType(DocumentType type) {
//     switch (type) {
//       case DocumentType.idFront:
//         return TextManager.idFront.tr();
//       case DocumentType.idBack:
//         return TextManager.idBack.tr();
//       case DocumentType.driverLicense:
//         return TextManager.driverLicense.tr();
//       case DocumentType.drugsTest:
//         return TextManager.drugsTest.tr();
//       case DocumentType.criminalRecord:
//         return TextManager.criminalRecord.tr();
//       case DocumentType.drivingViolations:
//         return TextManager.drivingViolations.tr();
//       case DocumentType.profilePhoto:
//         return TextManager.profilePhoto.tr();
//       case DocumentType.carPhoto:
//         return TextManager.carPhoto.tr();
//       case DocumentType.carLicense:
//         return TextManager.carLicense.tr();
//       case DocumentType.vehicleViolations:
//         return TextManager.vehicleViolations.tr();
//       case DocumentType.insurance:
//         return TextManager.insurance.tr();
//       case DocumentType.carTest:
//         return TextManager.carTest.tr();
//     }
//   }
//
//   String _getInstructionsForType(DocumentType type) {
//     switch (type) {
//       case DocumentType.idFront:
//         return TextManager.instructionIdFront.tr();
//       case DocumentType.idBack:
//         return TextManager.instructionIdBack.tr();
//       case DocumentType.driverLicense:
//         return TextManager.instructionDriverLicense.tr();
//       case DocumentType.drugsTest:
//         return TextManager.instructionDrugsTest.tr();
//       case DocumentType.criminalRecord:
//         return TextManager.instructionCriminalRecord.tr();
//       case DocumentType.drivingViolations:
//         return TextManager.instructionDrivingViolations.tr();
//       case DocumentType.profilePhoto:
//         return TextManager.instructionProfilePhoto.tr();
//       case DocumentType.carPhoto:
//         return TextManager.instructionCarPhoto.tr();
//       case DocumentType.carLicense:
//         return TextManager.instructionCarLicense.tr();
//       case DocumentType.vehicleViolations:
//         return TextManager.instructionVehicleViolations.tr();
//       case DocumentType.insurance:
//         return TextManager.instructionInsurance.tr();
//       case DocumentType.carTest:
//         return TextManager.instructionCarTest.tr();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final label = _getLabelForType(widget.documentType);
//     final instructions = _getInstructionsForType(widget.documentType);
//     final theme = Theme.of(context);
//     final documentType = widget.documentType;
//
//     return BlocConsumer<DocumentCubit, DocumentState>(
//       listener: (context, state) {
//         if (state is DocumentSuccess && state.message.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//
//           final uploadedFile = state.documents[documentType];
//           // Go to the next step and pass the uploaded file
//           if (uploadedFile != null) {
//             widget.onNext(documentType, uploadedFile);
//           }
//         } else if (state is DocumentFailure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.error)),
//           );
//         }
//       },
//
//       builder: (context, state) {
//         final file = state.documents[documentType];
//         final selectedFile = context.watch<DocumentCubit>().selectedFile;
//         final isLoading = state is DocumentLoading;
//
//         return Scaffold(
//           backgroundColor: theme.colorScheme.onPrimary,
//           appBar: AppBar(
//             backgroundColor: theme.colorScheme.onPrimary,
//             elevation: 0,
//             iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
//             title: Text(
//               label,
//               style: TextStyle(color: theme.colorScheme.onSurface),
//             ),
//           ),
//           body: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 0.09.sh),
//
//                   // Document Stepper
//                   DocumentStepper(
//                     totalSteps: DocumentType.values.length,
//                     currentStep: DocumentType.values.indexOf(documentType),
//                     theme: theme,
//                   ),
//                   SizedBox(height: 0.07.sh),
//
//                   // Dotted Instruction Box
//                   DottedInstructionBox(text: instructions, theme: theme),
//                   SizedBox(height: 0.05.sh),
//
//                   // Camera Preview Box
//                   CameraPreviewBox(
//                     onTap: isLoading ? () {} : _pickImage,
//                     imageProvider: selectedFile != null
//                         ? FileImage(selectedFile)
//                         : (file != null
//                             ? FileImage(file)
//                             : const AssetImage(AssetsManager.camera)),
//                   ),
//                   SizedBox(height: 0.2.sh),
//
//                   // Upload Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 0.07.sh,
//                     child: ElevatedButton.icon(
//                       icon: isLoading
//                           ? SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: theme.colorScheme.onPrimary,
//                               ),
//                             )
//                           : Icon(Icons.upload,
//                               color: theme.colorScheme.onPrimary),
//                       label: Text(
//                         isLoading
//                             ? TextManager.uploading.tr()
//                             : TextManager.uploadButton.tr(),
//                         style: TextStyle(
//                           color: theme.colorScheme.onPrimary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onPressed: (!isLoading && selectedFile != null)
//                           ? () => _uploadDocument(context)
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 0.04.sh),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../home/presentation/widgets/search_widgets/camera_preview_box.dart';
import '../../widgets/documents/document_stepper.dart';
import '../../widgets/documents/dotted_instruction_box.dart';
import '../../widgets/profile_custom_widgets/document_upload_flow.dart';
import '../../cubits/document_cubit.dart';
import '../../cubits/document_state.dart';
import '../../cubits/ml_validation_cubit.dart';

///DONE
class DocumentUploadScreen extends StatefulWidget {
  final DocumentType documentType;
  final void Function(DocumentType, File) onNext;
  final bool signupMode;

  const DocumentUploadScreen({
    super.key,
    required this.documentType,
    required this.onNext,
    this.signupMode = false,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  @override
  void didUpdateWidget(covariant DocumentUploadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentType != widget.documentType) {
      context.read<DocumentCubit>().clearSelectedFile();
      context.read<MLValidationCubit>().reset();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      context.read<DocumentCubit>().pickImage(file);

      // Auto-validate ID documents in signup mode
      if (widget.signupMode &&
          (widget.documentType == DocumentType.idFront ||
              widget.documentType == DocumentType.idBack)) {
        context.read<MLValidationCubit>().validateIDDocument(file);
      }
    }
  }

  void _uploadDocument(BuildContext context) {
    final selectedFile = context.read<DocumentCubit>().selectedFile;
    if (selectedFile != null) {
      // For signup mode with mandatory documents, check ML validation first
      if (widget.signupMode &&
          (widget.documentType == DocumentType.idFront || widget.documentType == DocumentType.idBack)) {

        final mlState = context.read<MLValidationCubit>().state;

        // If ML validation is still loading, show message
        if (mlState is MLValidationLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait for document validation to complete'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // If ML validation failed, show confirmation dialog
        if (mlState is MLValidationFailure) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Document Validation Failed'),
              content: Text('The document validation failed: ${mlState.message}\n\nDo you want to proceed anyway?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _proceedWithUpload(selectedFile);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Proceed Anyway'),
                ),
              ],
            ),
          );
          return;
        }

        // If ML validation had an error, show error
        if (mlState is MLValidationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Validation error: ${mlState.error}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // If ML validation is successful or not started, proceed with upload
        _proceedWithUpload(selectedFile);
      } else {
        // For non-mandatory documents or non-signup mode, upload directly
        _proceedWithUpload(selectedFile);
      }
    }
  }

  void _proceedWithUpload(File selectedFile) {
    print('📤 Uploading document: ${widget.documentType}');
    context
        .read<DocumentCubit>()
        .uploadDocument(widget.documentType, selectedFile);
  }

  String _getLabelForType(DocumentType type) {
    switch (type) {
      case DocumentType.idFront:
        return TextManager.idFront.tr();
      case DocumentType.idBack:
        return TextManager.idBack.tr();
      case DocumentType.driverLicense:
        return TextManager.driverLicense.tr();
      case DocumentType.drugsTest:
        return TextManager.drugsTest.tr();
      case DocumentType.criminalRecord:
        return TextManager.criminalRecord.tr();
      case DocumentType.drivingViolations:
        return TextManager.drivingViolations.tr();
      case DocumentType.profilePhoto:
        return TextManager.profilePhoto.tr();
      case DocumentType.carPhoto:
        return TextManager.carPhoto.tr();
      case DocumentType.carLicense:
        return TextManager.carLicense.tr();
      case DocumentType.vehicleViolations:
        return TextManager.vehicleViolations.tr();
      case DocumentType.insurance:
        return TextManager.insurance.tr();
      case DocumentType.carTest:
        return TextManager.carTest.tr();
    }
  }

  String _getInstructionsForType(DocumentType type) {
    switch (type) {
      case DocumentType.idFront:
        return TextManager.instructionIdFront.tr();
      case DocumentType.idBack:
        return TextManager.instructionIdBack.tr();
      case DocumentType.driverLicense:
        return TextManager.instructionDriverLicense.tr();
      case DocumentType.drugsTest:
        return TextManager.instructionDrugsTest.tr();
      case DocumentType.criminalRecord:
        return TextManager.instructionCriminalRecord.tr();
      case DocumentType.drivingViolations:
        return TextManager.instructionDrivingViolations.tr();
      case DocumentType.profilePhoto:
        return TextManager.instructionProfilePhoto.tr();
      case DocumentType.carPhoto:
        return TextManager.instructionCarPhoto.tr();
      case DocumentType.carLicense:
        return TextManager.instructionCarLicense.tr();
      case DocumentType.vehicleViolations:
        return TextManager.instructionVehicleViolations.tr();
      case DocumentType.insurance:
        return TextManager.instructionInsurance.tr();
      case DocumentType.carTest:
        return TextManager.instructionCarTest.tr();
    }
  }

  Widget
  _buildMLValidationResult(MLValidationState state) {
    if (state is MLValidationLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Validating document with AI...',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is MLValidationSuccess) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document is valid',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    'Confidence: ${state.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (state is MLValidationFailure) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document validation failed',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (state is MLValidationError) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Validation error: ${state.error}',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final label = _getLabelForType(widget.documentType);
    final instructions = _getInstructionsForType(widget.documentType);
    final theme = Theme.of(context);
    final documentType = widget.documentType;
    final isMandatoryDocument = widget.signupMode &&
        (documentType == DocumentType.idFront || documentType == DocumentType.idBack);

    return BlocListener<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentSuccess && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          final uploadedFile = state.documents[documentType];
          // Go to the next step and pass the uploaded file
          if (uploadedFile != null) {
            widget.onNext(documentType, uploadedFile);
          }
        } else if (state is DocumentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },

      child: BlocBuilder<MLValidationCubit, MLValidationState>(
        builder: (context, mlState) {
          return BlocBuilder<DocumentCubit, DocumentState>(
            builder: (context, state) {
              final file = state.documents[documentType];
              final selectedFile = context.watch<DocumentCubit>().selectedFile;
              final isLoading = state is DocumentLoading;

              return Scaffold(
                backgroundColor: theme.colorScheme.onPrimary,
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                  title: Text(
                    label,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.09.sh),

                        // Document Stepper
                        DocumentStepper(
                          totalSteps: DocumentType.values.length,
                          currentStep: DocumentType.values.indexOf(documentType),
                          theme: theme,
                        ),
                        SizedBox(height: 0.07.sh),

                        // Mandatory Document Indicator
                        if (isMandatoryDocument)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'This document is mandatory for signup',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isMandatoryDocument) SizedBox(height: 0.03.sh),

                        // ML Validation Result
                        if (isMandatoryDocument) _buildMLValidationResult(mlState),

                        // Success message for ML validation
                        if (isMandatoryDocument && mlState is MLValidationSuccess)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Document validated successfully! You can now proceed.',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Loading message for ML validation
                        if (isMandatoryDocument && mlState is MLValidationLoading)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Please wait for validation to complete before proceeding.',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Failure message for ML validation
                        if (isMandatoryDocument && mlState is MLValidationFailure)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Document validation failed. You can retry or proceed anyway.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Error message for ML validation
                        if (isMandatoryDocument && mlState is MLValidationError)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Validation service error. Please try again later.',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Initial state message for ML validation
                        if (isMandatoryDocument && mlState is MLValidationInitial)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.grey, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Document will be validated automatically after upload.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isMandatoryDocument)
                          SizedBox(height: 0.03.sh),

                        // Dotted Instruction Box
                        DottedInstructionBox(text: instructions, theme: theme),
                        SizedBox(height: 0.05.sh),

                        // Camera Preview Box
                        CameraPreviewBox(
                          onTap: isLoading ? () {} : _pickImage,
                          imageProvider: selectedFile != null
                              ? FileImage(selectedFile)
                              : (file != null
                              ? FileImage(file)
                              : const AssetImage(AssetsManager.camera)),
                        ),
                        SizedBox(height: 0.2.sh),

                        // Upload/Accept Button
                        SizedBox(
                          width: double.infinity,
                          height: 0.07.sh,
                          child: ElevatedButton.icon(
                            icon: isLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                                : (isMandatoryDocument && mlState is MLValidationSuccess)
                                ? Icon(Icons.check_circle, color: theme.colorScheme.onPrimary)
                                : Icon(Icons.upload, color: theme.colorScheme.onPrimary),
                            label: Text(
                              isLoading
                                  ? TextManager.uploading.tr()
                                  : (isMandatoryDocument && mlState is MLValidationSuccess)
                                  ? 'Accept & Continue'
                                  : TextManager.uploadButton.tr(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: (!isLoading && selectedFile != null)
                                ? () => _uploadDocument(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (isMandatoryDocument && mlState is MLValidationSuccess)
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.02.sh),

                        // Manual Validation Button (for failed ML validation)
                        if (isMandatoryDocument &&
                            mlState is MLValidationFailure &&
                            selectedFile != null)
                          SizedBox(
                            width: double.infinity,
                            height: 0.05.sh,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.refresh, color: Colors.orange),
                              label: Text(
                                'Retry Validation',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                context.read<MLValidationCubit>().validateIDDocument(selectedFile);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.orange),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),

                        // Manual Proceed Button (for failed ML validation)
                        if (isMandatoryDocument &&
                            mlState is MLValidationFailure &&
                            selectedFile != null)
                          SizedBox(
                            width: double.infinity,
                            height: 0.05.sh,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.warning, color: Colors.white),
                              label: Text(
                                'Proceed Anyway',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Proceed with Invalid Document?'),
                                    content: Text('The document validation failed. Are you sure you want to proceed?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _uploadDocument(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: Text('Proceed'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),

                        // Continue Button (for successful ML validation)
                        if (isMandatoryDocument &&
                            mlState is MLValidationSuccess &&
                            selectedFile != null)
                          SizedBox(
                            width: double.infinity,
                            height: 0.05.sh,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.arrow_forward, color: Colors.white),
                              label: Text(
                                'Continue to Next Document',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                _uploadDocument(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),

                        // Test ML Validation Button (for debugging)
                        if (isMandatoryDocument && selectedFile != null)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 0.05.sh,
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.bug_report, color: Colors.purple),
                                  label: Text(
                                    'Test ML Validation',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<MLValidationCubit>().validateIDDocument(selectedFile);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.purple),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.01.sh),
                              SizedBox(
                                width: double.infinity,
                                height: 0.05.sh,
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.science, color: Colors.green),
                                  label: Text(
                                    'Test Mode (Always Valid)',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<MLValidationCubit>().validateIDDocument(selectedFile, testMode: true);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.01.sh),
                              SizedBox(
                                width: double.infinity,
                                height: 0.05.sh,
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.api, color: Colors.orange),
                                  label: Text(
                                    'Test API Response',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Test with mock validation_result response
                                    print('🧪 Testing API response format...');
                                    context.read<MLValidationCubit>().validateIDDocument(selectedFile, debugMode: true);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.orange),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.01.sh),
                              SizedBox(
                                width: double.infinity,
                                height: 0.05.sh,
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.skip_next, color: Colors.blue),
                                  label: Text(
                                    'Skip ML Validation',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Skip ML validation and proceed directly
                                    _uploadDocument(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 0.04.sh),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
