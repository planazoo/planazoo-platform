import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../../shared/services/logger_service.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _plansFolder = 'plan_images';
  static const int _maxFileSize = 2 * 1024 * 1024; // 2MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Selecciona una imagen (galería o explorador de archivos en web).
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      LoggerService.error('Error picking image from gallery', context: 'IMAGE_SERVICE', error: e);
      return null;
    }
  }

  /// Obtiene la extensión del archivo de forma compatible con web (XFile.name o path).
  static String _getExtension(XFile image) {
    final name = image.name;
    final pathStr = name ?? image.path;
    final ext = path.extension(pathStr).toLowerCase().replaceFirst('.', '');
    if (ext.isNotEmpty) return ext;
    final mime = image.mimeType?.toLowerCase() ?? '';
    if (mime.contains('jpeg') || mime.contains('jpg')) return 'jpg';
    if (mime.contains('png')) return 'png';
    if (mime.contains('webp')) return 'webp';
    return 'jpg';
  }

  /// Content-Type para Firebase Storage según extensión.
  static String _contentTypeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Valida una imagen antes de subirla (compatible con web: usa bytes, no File).
  static Future<String?> validateImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      if (bytes.length > _maxFileSize) {
        return 'La imagen es demasiado grande. Máximo 2MB permitido.';
      }
      final extension = _getExtension(image);
      if (!_allowedExtensions.contains(extension)) {
        return 'Formato no válido. Solo se permiten JPG, PNG y WEBP.';
      }
      return null;
    } catch (e) {
      LoggerService.error('Error validating image', context: 'IMAGE_SERVICE', error: e);
      return 'Error al validar la imagen: $e';
    }
  }

  /// Sube una imagen a Firebase Storage (web y móvil: usa putData con bytes).
  /// Lanza excepción si falla (permisos, red, etc.) para que la UI muestre el error.
  static Future<String> uploadPlanImage(XFile imageFile, String planId) async {
    final validationError = await validateImage(imageFile);
    if (validationError != null) throw Exception(validationError);

    try {
      final bytes = await imageFile.readAsBytes();
      final extension = _getExtension(imageFile);
      final fileName = '${planId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = '$_plansFolder/$fileName';
      final Reference ref = _storage.ref(path);

      final metadata = SettableMetadata(
        contentType: _contentTypeFromExtension(extension),
      );
      final TaskSnapshot snapshot = await ref.putData(bytes, metadata);
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      LoggerService.error('Error uploading plan image', context: 'IMAGE_SERVICE', error: e);
      rethrow;
    }
  }

  /// Elimina una imagen de Firebase Storage
  static Future<bool> deletePlanImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      LoggerService.error('Error deleting plan image', context: 'IMAGE_SERVICE', error: e);
      return false;
    }
  }

  /// Comprime una imagen si es necesario
  static Future<Uint8List?> compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes.length > _maxFileSize) {
        throw Exception('La imagen es demasiado grande. Máximo 2MB permitido.');
      }
      return bytes;
    } catch (e) {
      LoggerService.error('Error compressing image', context: 'IMAGE_SERVICE', error: e);
      return null;
    }
  }

  static String getDefaultImageUrl() => '';

  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    const validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final lowercaseUrl = url.toLowerCase();
    return validExtensions.any((ext) => lowercaseUrl.contains(ext));
  }
}
