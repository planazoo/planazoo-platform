import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart';

/// Abre el selector nativo. `null` = cancelación del usuario (no es error).
Future<PickedPlanFile?> pickPlanAttachment(List<String> allowedExtensions) async {
  // iOS: presentar UIDocumentPicker mientras el teclado/diálogo aún anima
  // suele acabar en documentPickerWasCancelled sin selección real.
  FocusManager.instance.primaryFocus?.unfocus();
  await Future<void>.delayed(const Duration(milliseconds: 350));

  final FilePickerResult? result;
  try {
    result = await FilePicker.platform.pickFiles(
      // Evitar FileType.custom: en builds iOS desalineados falla el method "custom".
      // La extensión se valida en PlanFileService.
      type: FileType.any,
      // En iOS, withData:true es frágil con PDF grandes; leemos por path.
      withData: false,
      allowMultiple: false,
    );
  } on PlatformException {
    rethrow;
  }
  if (result == null || result.files.isEmpty) return null;

  final file = result.files.first;
  var bytes = file.bytes;
  if ((bytes == null || bytes.isEmpty) && file.path != null) {
    try {
      bytes = await File(file.path!).readAsBytes();
    } catch (_) {
      bytes = null;
    }
  }
  if (bytes == null || bytes.isEmpty) {
    throw const PlanFilePickReadException();
  }
  return PickedPlanFile(
    name: file.name,
    bytes: bytes,
    size: file.size > 0 ? file.size : bytes.length,
    mimeType: file.extension,
  );
}
