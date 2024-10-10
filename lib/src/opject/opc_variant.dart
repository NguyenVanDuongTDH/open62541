// ignore_for_file: unused_field, camel_case_extensions

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/ua_convert.dart';

class UAVariant {
  UAVariant([Pointer<UA_Variant>? ptr]) {
    if (ptr == null) {
      _variant = cOPC.UA_Variant_new();
      cOPC.UA_Variant_init(_variant!);
    } else {
      _variant = ptr;
    }
  }

  Pointer<UA_Variant>? _variant;
  Pointer<UA_Variant> get variant => _variant!;
  int get arrayLength => variant.ref.arrayLength;
  int get arrayDimensionsSize => variant.ref.arrayDimensionsSize;
  int get type => cOPC.UA_GET_TYPES_INTDEX(variant.ref.type);
  dynamic get data => UaConvert.variant2Dart(this);

  bool isEmpty() {
    return cOPC.UA_Variant_isEmpty(variant);
  }

  void delete() {
    cOPC.UA_Variant_delete(variant);
  }

  void deleteMembers() {
    // cOPC.UA_Variant_deleteMembers(variant);
  }

  void clear() {
    cOPC.UA_Variant_clear(variant);
  }

  int coppyTo(UAVariant dst) {
    return cOPC.UA_Variant_copy(variant, dst.variant);
  }

  void copyFrom(UAVariant src) {
    cOPC.UA_Variant_copy(src.variant, variant);
  }

  void setScalar(dynamic value, int uaType) {
    Pointer ptr = UaConvert.dart2Pointer(value, uaType);
    if (value is List) {
      cOPC.UA_Variant_setArray(variant, ptr.cast(), value.length,
          cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
    } else {
      cOPC.UA_Variant_setScalar(
          variant, ptr.cast(), cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
    }
  }

  // static variant2Dart(UA_Variant variant) {
  //   final type = cOPC.UA_GET_TYPES_INTDEX(variant.type);
  //   final len = variant.arrayLength;
  //   if (len > 0) {
  //     return UACOpject.pointer2DartList(variant.data, len, type);
  //   } else {
  //     return UACOpject.pointer2Dart(variant.data, type);
  //   }
  // }

  @override
  String toString() {
    return data.toString();
  }
}

extension LIST2BOOL on List<bool> {
  UAVariant uaBoolArray() {
    return UAVariant()..setScalar(this, UATypes.BOOLEAN);
  }
}

extension bool2BOOL on bool {
  UAVariant uaBoool() {
    return UAVariant()..setScalar(this, UATypes.BOOLEAN);
  }
}

extension LIST2DF on List<double> {
  UAVariant uaFloatArray() {
    return UAVariant()..setScalar(this, UATypes.FLOAT);
  }

  UAVariant uaDoubleArray() {
    return UAVariant()..setScalar(this, UATypes.DOUBLE);
  }
}

extension LIST2INT on List<int> {
  UAVariant uaBytes() {
    return UAVariant()..setScalar(this, UATypes.BYTE);
  }

  UAVariant uaUint16Array() {
    return UAVariant()..setScalar(this, UATypes.UINT16);
  }

  UAVariant uaInt16Array() {
    return UAVariant()..setScalar(this, UATypes.INT16);
  }

  UAVariant uaUint32Array() {
    return UAVariant()..setScalar(this, UATypes.UINT32);
  }

  UAVariant uaInt32Array() {
    return UAVariant()..setScalar(this, UATypes.INT32);
  }

  UAVariant uaUint63Array() {
    return UAVariant()..setScalar(this, UATypes.UINT64);
  }

  UAVariant uaInt64Array() {
    return UAVariant()..setScalar(this, UATypes.INT64);
  }
}

// ////////////////
// ///////////////
// ///
// ///
// ///////////////
// ///////////////

extension String2STRING on String {
  UAVariant uaString() {
    return UAVariant()..setScalar(this, UATypes.STRING);
  }
}

extension LIST2String on List<String> {
  UAVariant uaStringArray() {
    return UAVariant()..setScalar(this, UATypes.STRING);
  }
}

extension Double2DF on double {
  UAVariant uaFloat() {
    return UAVariant()..setScalar(this, UATypes.FLOAT);
  }

  UAVariant uaDouble() {
    return UAVariant()..setScalar(this, UATypes.DOUBLE);
  }
}

extension int2INT on int {
  UAVariant uaByte() {
    return UAVariant()..setScalar(this, UATypes.BYTE);
  }

  UAVariant uaUint16() {
    return UAVariant()..setScalar(this, UATypes.UINT16);
  }

  UAVariant uaInt16() {
    return UAVariant()..setScalar(this, UATypes.INT16);
  }

  UAVariant uaUint32() {
    return UAVariant()..setScalar(this, UATypes.UINT32);
  }

  UAVariant uaInt32() {
    return UAVariant()..setScalar(this, UATypes.INT32);
  }

  UAVariant uaUint64() {
    return UAVariant()..setScalar(this, UATypes.UINT64);
  }

  UAVariant uaInt64() {
    return UAVariant()..setScalar(this, UATypes.INT64);
  }
}

extension UA_DYNAMIC on dynamic {
  UAVariant uaDynamic() {
    return UAVariant()..setScalar(this, UATypes.VARIANT);
  }
}
