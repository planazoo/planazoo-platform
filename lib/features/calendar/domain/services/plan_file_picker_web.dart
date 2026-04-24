// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:unp_calendario/features/calendar/domain/services/plan_file_picker_common.dart';

Future<PickedPlanFile?> pickPlanAttachment(List<String> allowedExtensions) async {
  final completer = Completer<PickedPlanFile?>();
  final input = html.FileUploadInputElement()..accept = allowedExtensions.map((e) => '.$e').join(',');
  input.click();

  input.onChange.listen((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final bytes = _bytesFromDataUrl(result.toString());
      if (!completer.isCompleted) {
        completer.complete(
          PickedPlanFile(
            name: file.name,
            bytes: bytes,
            size: file.size,
            mimeType: file.type,
          ),
        );
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
  });

  return completer.future;
}

Uint8List _bytesFromDataUrl(String dataUrl) {
  final commaIdx = dataUrl.indexOf(',');
  if (commaIdx < 0 || commaIdx >= dataUrl.length - 1) return Uint8List(0);
  final base64Part = dataUrl.substring(commaIdx + 1);
  try {
    return base64Decode(base64Part);
  } catch (_) {
    return Uint8List(0);
  }
}
