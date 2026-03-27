import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart';

Future<PickedPlanFile?> pickPlanAttachment(List<String> allowedExtensions) async {
  final result = await FilePicker.platform.pickFiles(
    // iOS builds with a stale native file_picker implementation can throw
    // MissingPluginException for method "custom". We pick any file here and
    // rely on PlanFileService.validateAttachment for extension filtering.
    type: FileType.any,
    withData: true,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  var bytes = file.bytes;
  if ((bytes == null || bytes.isEmpty) && file.path != null) {
    try {
      bytes = await File(file.path!).readAsBytes();
    } catch (_) {
      // Keep null/empty and let caller validation handle user feedback.
    }
  }
  if (bytes == null || bytes.isEmpty) return null;
  return PickedPlanFile(
    name: file.name,
    bytes: bytes,
    size: file.size,
    mimeType: file.extension,
  );
}
