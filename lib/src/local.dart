import 'dart:ffi';
import 'dart:io';
// import 'package:ffi/ffi.dart';

typedef GetLogicalDrivesC = Uint32 Function();
typedef GetLogicalDrivesDart = int Function();
// Load the Windows API library
final kernel32 = DynamicLibrary.open('kernel32.dll');
// Get the function from the library
final getLogicalDrives =
    kernel32.lookupFunction<GetLogicalDrivesC, GetLogicalDrivesDart>(
        'GetLogicalDrives');
// Call the function to get the drive mask
final driveMask = getLogicalDrives();

class GetDrives {
  static List<String> availables() {
    final drives = <String>[];
    for (int i = 0; i < 26; i++) {
      final mask = 1 << i;
      if ((driveMask & mask) != 0) {
        final driveLetter = '${String.fromCharCode(65 + i)}:';
        drives.add(driveLetter);
      }
    }

    return drives;
  }

 static Future<Map<String, List<String>>> listFilesAndDirectories(String path) async {
  final directory = Directory(path);
  final Map<String, List<String>> result = {
    'files': [],
    'directories': [],
  };

  try {
    // Lấy danh sách các thư mục và tập tin trong thư mục đã cho
    final entities = directory.listSync(recursive: false); // recursive: false chỉ lấy danh sách trực tiếp

    for (var entity in entities) {
      if (entity is File) {
        result['files']?.add(entity.path);
      } else if (entity is Directory) {
        result['directories']?.add(entity.path);
      }
    }
  } catch (e) {
    print('Error reading directory: $e');
  }

  return result;
}
}
