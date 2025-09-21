import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _plansFolder = 'plan_images';
  static const int _maxFileSize = 2 * 1024 * 1024; // 2MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Selecciona una imagen de la galería
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
      print('Error picking image: $e');
      return null;
    }
  }

  /// Valida una imagen antes de subirla
  static Future<String?> validateImage(XFile image) async {
    try {
      // Validar tamaño del archivo
      final file = File(image.path);
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        return 'La imagen es demasiado grande. Máximo 2MB permitido.';
      }

      // Validar extensión
      final extension = path.extension(image.path).toLowerCase().substring(1);
      if (!_allowedExtensions.contains(extension)) {
        return 'Formato no válido. Solo se permiten JPG, PNG y WEBP.';
      }

      return null; // Sin errores
    } catch (e) {
      return 'Error al validar la imagen: $e';
    }
  }

  /// Sube una imagen a Firebase Storage
  static Future<String?> uploadPlanImage(XFile imageFile, String planId) async {
    try {
      // Validar imagen
      final validationError = await validateImage(imageFile);
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Crear referencia al archivo
      final String fileName = '${planId}_${DateTime.now().millisecondsSinceEpoch}';
      final String extension = path.extension(imageFile.path);
      final Reference ref = _storage.ref('$_plansFolder/$fileName$extension');

      // Subir archivo
      final UploadTask uploadTask = ref.putFile(File(imageFile.path));
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Elimina una imagen de Firebase Storage
  static Future<bool> deletePlanImage(String imageUrl) async {
    try {
      // Extraer la referencia del archivo desde la URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Comprime una imagen si es necesario
  static Future<Uint8List?> compressImage(XFile imageFile) async {
    try {
      // Para simplificar, por ahora solo validamos
      // En el futuro se puede añadir compresión real con packages como flutter_image_compress
      final bytes = await imageFile.readAsBytes();
      
      if (bytes.length > _maxFileSize) {
        throw Exception('La imagen es demasiado grande. Máximo 2MB permitido.');
      }
      
      return bytes;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Obtiene la URL de una imagen por defecto
  static String getDefaultImageUrl() {
    // Por ahora retornamos una URL vacía, en el futuro se puede usar una imagen por defecto
    return '';
  }

  /// Verifica si una URL es una imagen válida
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final lowercaseUrl = url.toLowerCase();
    
    return validExtensions.any((ext) => lowercaseUrl.contains(ext));
  }
}
