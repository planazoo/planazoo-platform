import 'package:firebase_storage/firebase_storage.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_io.dart'
    if (dart.library.html) 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_web.dart'
    as plan_file_picker;

class PlanFileService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _plansFolder = 'plan_files';
  static const int _maxFileSize = 8 * 1024 * 1024; // 8MB
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  static Future<PickedPlanFile?> pickAttachment() async {
    return plan_file_picker.pickPlanAttachment(_allowedExtensions);
  }

  static String? validateAttachment(PickedPlanFile file) {
    if (file.size <= 0) return 'Archivo no válido.';
    if (file.size > _maxFileSize) return 'El archivo supera 8MB.';
    final ext = _extensionOf(file.name);
    if (!_allowedExtensions.contains(ext)) {
      return 'Formato no permitido. Solo PDF/JPG/PNG.';
    }
    if (file.bytes.isEmpty) {
      return 'No se pudieron leer los datos del archivo.';
    }
    return null;
  }

  static Future<PlanAttachment> uploadAttachment({
    required String planId,
    required PickedPlanFile file,
    /// Prefijo opcional (`evt`, `acc`, etc.) para distinguir archivos en el mismo bucket de plan.
    String filenamePrefix = '',
  }) async {
    final validationError = validateAttachment(file);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final bytes = file.bytes;
    final extension = _extensionOf(file.name);
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final prefix = filenamePrefix.isEmpty ? '' : '${filenamePrefix}_';
    final fileName = '$prefix${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final storagePath = '$_plansFolder/$planId/$fileName';

    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(
      contentType: _contentTypeForExtension(extension),
      customMetadata: {
        'originalName': file.name,
        'planId': planId,
      },
    );

    final snapshot = await ref.putData(bytes, metadata);
    final url = await snapshot.ref.getDownloadURL();
    return PlanAttachment(
      name: file.name,
      url: url,
      type: metadata.contentType ?? 'application/octet-stream',
      size: file.size,
      uploadedAt: DateTime.now(),
    );
  }

  static Future<void> deleteAttachment(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }

  static String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  static String _extensionOf(String fileName) {
    final idx = fileName.lastIndexOf('.');
    if (idx < 0 || idx == fileName.length - 1) return '';
    return fileName.substring(idx + 1).toLowerCase();
  }
}
