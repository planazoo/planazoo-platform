import 'package:firebase_storage/firebase_storage.dart';
import 'package:unp_calendario/features/calendar/domain/models/communication_attachment.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_io.dart'
    if (dart.library.html) 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_web.dart'
    as plan_file_picker;

export 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart'
    show PickedPlanFile, PlanFilePickReadException;

class CommunicationFileService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String folder = 'communication_files';
  static const int maxFileSize = 8 * 1024 * 1024;
  static const int maxFiles = 8;
  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'ics',
  ];

  static Future<PickedPlanFile?> pick() {
    return plan_file_picker.pickPlanAttachment(allowedExtensions);
  }

  static String? validate(PickedPlanFile file) {
    if (file.size <= 0) return 'Archivo no válido.';
    if (file.size > maxFileSize) return 'El archivo supera 8MB.';
    final ext = _extensionOf(file.name);
    if (!allowedExtensions.contains(ext)) {
      return 'Formato no permitido.';
    }
    if (file.bytes.isEmpty) {
      return 'No se pudieron leer los datos del archivo.';
    }
    return null;
  }

  static Future<CommunicationAttachment> upload({
    required String userId,
    required String docId,
    required PickedPlanFile file,
  }) async {
    final err = validate(file);
    if (err != null) throw Exception(err);
    final ext = _extensionOf(file.name);
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final path = '$folder/$userId/$docId/$fileName';
    final ref = _storage.ref(path);
    final contentType = _contentTypeForExtension(ext);
    final snapshot = await ref.putData(
      file.bytes,
      SettableMetadata(
        contentType: contentType,
        customMetadata: {'originalName': file.name, 'userId': userId},
      ),
    );
    final url = await snapshot.ref.getDownloadURL();
    return CommunicationAttachment(
      name: file.name,
      url: url,
      type: contentType,
      size: file.size,
    );
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
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'ics':
        return 'text/calendar';
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
