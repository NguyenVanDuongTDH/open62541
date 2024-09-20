import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

class CObject {
  Pointer reference;
  CObject(this.reference);
  void free() {
    calloc.free(reference);
  }

  Pointer<U> cast<U extends NativeType>() {
    return reference.cast();
  }
}

class CBytes extends CObject {
  CBytes._(super.reference);
  factory CBytes.fromUint8List(Uint8List uList) {
    Pointer<Uint8> cBytes = calloc.allocate<Uint8>(uList.length);
    cBytes.asTypedList(uList.length).setAll(0, uList);
    return CBytes._(cBytes);
  }
  Uint8List toUint8List(int length) {
    return Uint8List.fromList(reference.cast<Uint8>().asTypedList(length));
  }
}

class CString extends CObject {
  CString._(Pointer reference) : super(reference);
  factory CString.fromString(String str, {String mode = "utf-8"}) {
    if (mode == "utf-8") {
      return CString._(str.toNativeUtf8());
    } else if (mode == "utf-16") {
      return CString._(str.toNativeUtf16());
    } else {
      throw ("invalid mode");
    }
  }

  String toDartString({String mode = "utf-8"}) {
    if (mode == "utf-8") {
      return reference.cast<Utf8>().toDartString();
    } else if (mode == "utf-16") {
      return reference.cast<Utf16>().toDartString();
    }
    return throw ("Invalid mode");
  }
}

extension DARTSTRINGTOC on String {
  CString toCString() {
    return CString.fromString(this);
  }
}

extension DARTSTRINGTOC_CBytes on Uint8List {
  CBytes toCBytes() {
    return CBytes.fromUint8List(this);
  }
}
