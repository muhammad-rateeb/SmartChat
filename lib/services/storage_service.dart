// SmartChat - Storage Service
//
// Handles file upload/download operations using Firebase Cloud Storage.
// Supports profile images, chat media, and audio attachments.

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Maximum file size: 5MB
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  // ─── Image Picking ────────────────────────────────────

  /// Opens the device camera to capture a photo.
  /// Returns the selected [XFile] or null if cancelled.
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
    } catch (e) {
      throw Exception('Failed to access camera: $e');
    }
  }

  /// Opens the device gallery to select a photo.
  /// Returns the selected [XFile] or null if cancelled.
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
    } catch (e) {
      throw Exception('Failed to access gallery: $e');
    }
  }

  // ─── Upload Operations ────────────────────────────────

  /// Uploads a profile image for [userId] and returns the download URL.
  Future<String> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    final file = File(imageFile.path);

    if (!await file.exists()) {
      throw Exception('Selected image file not found.');
    }

    final fileSize = await file.length();
    if (fileSize > _maxFileSizeBytes) {
      throw Exception('Image is too large. Please select an image under 5MB.');
    }

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_profile.jpg';
      final ref = _storage.ref().child('profile_images/$userId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Uploads a chat image for [chatRoomId] and returns the download URL.
  Future<String> uploadChatImage({
    required String chatRoomId,
    required String messageId,
    required XFile imageFile,
  }) async {
    final file = File(imageFile.path);

    if (!await file.exists()) {
      throw Exception('Selected image file not found.');
    }

    final fileSize = await file.length();
    if (fileSize > _maxFileSizeBytes) {
      throw Exception('Image is too large. Please select an image under 5MB.');
    }

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$messageId.jpg';
      final ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  /// Uploads an audio message for [chatRoomId] and returns the download URL.
  Future<String> uploadAudioMessage({
    required String chatRoomId,
    required String filePath,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Selected audio file not found.');
    }

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = _storage.ref().child('chat_audio/$chatRoomId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload audio message: $e');
    }
  }

  // ─── Delete Operations ────────────────────────────────

  /// Deletes the profile image for [userId].
  Future<void> deleteProfileImage(String userId) async {
    // No-op until Firebase Storage is enabled.
    return;
  }
}
