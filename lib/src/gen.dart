import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:open62541/src/open62541_gen.dart';

NativeLibrary get cOPC => NativeLibrary(DynamicLibrary.open(_getPathLib()));

String _getPathLib() {
  if (Platform.isLinux) {
    return "/home/duong/Documents/git/open62541/open62541_1_4/open62541.so";
  } else if (Platform.isWindows) {
    return "open62541_1_4/open62541.dll";
  } else if (Platform.isAndroid) {
    return "libopen62541.so";
  }
  return "OPEN62541 NOT PATH";
}

extension GENFFI on NativeLibrary {
  void print(String v1, [String? v2, String? v3, String? v4, String? v5]) {
    String data = v1;
    if (v2 != null) {
      data += " $v2";
    }
    if (v3 != null) {
      data += " $v3";
    }
    if (v4 != null) {
      data += " $v4";
    }
    if (v5 != null) {
      data += " $v5";
    }
    final _ptr = data.toNativeUtf8();

    // cOPC.UA_LOG_INFO(cOPC.UA_Log_Stdout, 0, _ptr.cast());
    calloc.free(_ptr);
  }
}
