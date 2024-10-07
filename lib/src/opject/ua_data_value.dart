// ignore_for_file: camel_case_types, unused_element

import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

final class _UA_DataValue extends ffi.Struct {
  external UA_Variant value;
}

// class UADataValue {
//   static dynamic toDart(ffi.Pointer<UA_DataValue> ptr) {
//     return UAVariant.variant2Dart(ptr.cast<_UA_DataValue>().ref.value);
//   }
// }

class UADataValue {
  static dynamic toDart(ffi.Pointer<UA_DataValue> ptr) {
    Pointer<UA_Variant> p = cOPC.UA_Variant_new();
    p.ref = ptr.cast<_UA_DataValue>().ref.value;
    UAVariant variant = UAVariant(p);
    final res = variant.data;
    p.ref.data = ffi.Pointer.fromAddress(0);
    variant.delete();
    return res;
  }
}
