import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:open62541/src/open62541_gen.dart';

NativeLibrary get cOPC => NativeLibrary(DynamicLibrary.open(_getPathLib()));

String _getPathLib() {
  if (Platform.isLinux) {
    return "/home/duong/Desktop/open62541/open62541_1_3/open62541.so";
  } else if (Platform.isWindows) {
    return "open62541_1_3/open62541.dll";
  } else if (Platform.isAndroid) {
    return "libopen62541.so";
  }
  return "OPEN62541 NOT PATH";
}
