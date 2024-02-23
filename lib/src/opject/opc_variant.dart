// ignore_for_file: unused_field, camel_case_extensions

import 'dart:ffi';
import 'package:open62541/open62541.dart';
import '../gen.dart';
import '../open62541_gen.dart';

class UAVariant {
  late final Pointer<UA_Variant> variant;
  int? _opcType;
  int? _sizeCalloc;

  UAVariant({Pointer<UA_Variant>? ref, int? sizeCalloc}) {
    if (ref == null) {
      variant = cOPC.UA_Variant_new().cast();
      cOPC.UA_Variant_init(variant.cast());
    } else {
      variant = ref;
      _sizeCalloc = sizeCalloc;
    }
  }
  factory UAVariant.calloc(int length) {
    return UAVariant(
        sizeCalloc: length,
        ref: cOPC.UA_Array_new(
                length, cOPC.UA_GET_TYPES_FROM_INDEX(UATypes.VARIANT))
            .cast());
  }

  UAVariant elementAt(int index) {
    return UAVariant(ref: variant.elementAt(index));
  }

  UAVariant clone() {
    UAVariant dst;
    if (_sizeCalloc != null) {
      dst = UAVariant.calloc(_sizeCalloc!);
      cOPC.UA_Array_copy(variant.cast(), _sizeCalloc!, dst.variant.cast(),
          cOPC.UA_GET_TYPES_FROM_INDEX(UATypes.VARIANT));
    } else {
      dst = UAVariant();
      cOPC.UA_Variant_copy(variant, dst.variant);
    }

    return dst;
  }

  void delete() {
    deleteMembers();
    if (_sizeCalloc != null) {
      cOPC.UA_Array_delete(variant.cast(), _sizeCalloc!,
          cOPC.UA_GET_TYPES_FROM_INDEX(UATypes.VARIANT));
    } else {
      cOPC.UA_Variant_delete(variant);
    }
  }

  void deleteMembers() {
    if (_sizeCalloc != null) {
      for (var i = 0; i < _sizeCalloc!; i++) {
        cOPC.UA_Variant_deleteMembers(variant);
      }
    } else {
      cOPC.UA_Variant_deleteMembers(variant);
    }
  }

  int coppyTo(Pointer<UA_Variant> dst) {
    return cOPC.UA_Variant_copy(variant, dst);
  }

  void setScalarCopy(UACOpject cValue) {
    if (cValue.length > 0) {
      cOPC.UA_Variant_setArrayCopy(variant.cast(), cValue.pointer,
          cValue.length, cOPC.UA_GET_TYPES_FROM_INDEX(cValue.uaType));
    } else {
      cOPC.UA_Variant_setScalarCopy(variant.cast(), cValue.pointer,
          cOPC.UA_GET_TYPES_FROM_INDEX(cValue.uaType));
    }
  }

  void setScalar(UACOpject cValue) {
    if (cValue.length > 0) {
      cOPC.UA_Variant_setArray(variant.cast(), cValue.pointer, cValue.length,
          cOPC.UA_GET_TYPES_FROM_INDEX(cValue.uaType));
    } else {
      cOPC.UA_Variant_setScalar(variant.cast(), cValue.pointer,
          cOPC.UA_GET_TYPES_FROM_INDEX(cValue.uaType));
    }
  }

  dynamic toDart() {
    return variant2Dart(variant.cast<UA_Variant>().ref);
  }

  static variant2Dart(UA_Variant variant) {
    final type = cOPC.UA_GET_TYPES_INTDEX(variant.type);
    final len = variant.arrayLength;
    if (len > 0) {
      return UACOpject.pointer2DartList(variant.data, len, type);
    } else {
      return UACOpject.pointer2Dart(variant.data, type);
    }
  }
}

extension CASTVARIANT on UA_Variant {
  Pointer<U> cast<U extends NativeType>() {
    return data.cast<U>();
  }
}

extension LIST2BOOL on List<bool> {
  UAVariant toVariantBool() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.BOOLEAN));
  }
}

extension bool2BOOL on bool {
  UAVariant toVariantBool() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.BOOLEAN));
  }
}

extension LIST2DF on List<double> {
  UAVariant toVariantFloat() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.FLOAT));
  }

  UAVariant toVariantDouble() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.DOUBLE));
  }
}

extension LIST2INT on List<int> {
  UAVariant uaBytes() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.BYTE));
  }

  UAVariant uaUint16() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT16));
  }

  UAVariant uaInt16() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT16));
  }

  UAVariant uaUint32() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT32));
  }

  UAVariant uaInt32() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT32));
  }

  UAVariant uaUint63() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT64));
  }

  UAVariant uaInt64() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT64));
  }
}

////////////////
///////////////
///
///
///////////////
///////////////

extension String2STRING on String {
  UAVariant uaString() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.STRING));
  }
}

extension LIST2String on List<String> {
  UAVariant uaStrings() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.STRING));
  }
}

extension Double2DF on double {
  UAVariant uaFloat() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.FLOAT));
  }

  UAVariant uaDouble() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.DOUBLE));
  }
}

extension int2INT on int {
  UAVariant uaByte() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.BYTE));
  }

  UAVariant uaUint16() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT16));
  }

  UAVariant uaInt16() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT16));
  }

  UAVariant uaUint32() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT32));
  }

  UAVariant uaInt32() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT32));
  }

  UAVariant uaUint64() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.UINT64));
  }

  UAVariant uaInt64() {
    return UAVariant()..setScalar(UACOpject(this, UATypes.INT64));
  }
}

extension CObject2C on UACOpject {
  UAVariant toVariant() {
    return UAVariant()..setScalar(this);
  }
}

extension LISTCOBJEC2ArrayVariant on List<UACOpject> {
  UAVariant uaArray() {
    UAVariant variant = UAVariant.calloc(length);
    for (var i = 0; i < length; i++) {
      variant.elementAt(i).setScalar(this[i]);
    }
    return variant;
  }
}

extension LISTVARIANTArrayVariant on List<UAVariant> {
  UAVariant uaArray() {
    UAVariant variant = UAVariant.calloc(length);
    for (var i = 0; i < length; i++) {
      this[i].coppyTo(variant.elementAt(i).variant);
      this[i].delete();
    }
    return variant;
  }
}
