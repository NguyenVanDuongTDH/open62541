import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import '../open62541_gen.dart';

class UAVariant {
  late Pointer<UA_Variant> variant;
  int? _opcType;
  UAVariant([Pointer<UA_Variant>? _variant]) {
    if (_variant != null) {
      variant = _variant;
    } else {
      variant = cOPC.UA_Variant_new();
      cOPC.UA_Variant_init(variant);
    }
  }

  void delete() {
    cOPC.UA_Variant_deleteMembers(variant);
    cOPC.UA_Variant_delete(variant);
  }

  void clear() {
    cOPC.UA_Variant_clear(variant);
  }

  void setScalarCopy(UACOpject cValue) {
    cOPC.UA_Variant_setScalarCopy(
        variant, cValue.pointer, cOPC.UA_GET_TYPES_(cValue.uaType));
  }

  void setScalar(UACOpject cValue) {
    cOPC.UA_Variant_setScalar(
        variant, cValue.pointer, cOPC.UA_GET_TYPES_(cValue.uaType));
  }

  dynamic toDart() {
    return variant2Dart(variant.ref);
  }

  static variant2Dart(UA_Variant variant) {
    final type = cOPC.UA_GET_TYPES(variant.type);
    final len = variant.arrayLength;
    if (len > 0) {
      return UACOpject.pointer2DartList(variant.data, len, type);
    } else {
      return UACOpject.pointer2Dart(variant.data, type);
    }
  }
}

extension IntToPyDouble on UA_Variant {
  Pointer<U> cast<U extends NativeType>() {
    return data.cast<U>();
  }
}
