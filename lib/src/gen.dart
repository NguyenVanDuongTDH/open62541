// ignore_for_file: dead_code

import 'dart:ffi';
import 'dart:io';
import 'package:open62541/src/open62541_gen.dart';

NativeLibrary get cOPC => NativeLibrary(DynamicLibrary.open(_getPathLib()));

String _getPathLib() {
  if (Platform.isLinux) {
    return "/home/duong/Desktop/open62541/cpp/open62541.so";
    return "${Platform.script.toFilePath().replaceAll('/server', "")}/cpp/open62541.so";
  } else if (Platform.isWindows) {
    return "cpp/open62541.dll";
  } else if (Platform.isAndroid) {
    return "libopen62541.so";
  }
  return "OPEN62541 NOT PATH";
}
