import 'dart:ffi';
import 'dart:io';
import 'open62541_gen.dart';

NativeLibrary get cOPC => NativeLibrary(DynamicLibrary.open(_getPathLib()));

String _getPathLib() {
  if (Platform.isLinux) {
    return "/media/duong/New Volume/open62541-main/open62541/open62541.so";
  }
  else if(Platform.isWindows){
    return "open62541.dll";
  }
  return "OPEN62541 NOT PATH";
}
