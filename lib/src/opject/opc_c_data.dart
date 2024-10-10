import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

class UACOpject {
  late final Pointer _pointer;
  Pointer<Void> get pointer => _pointer.cast();
  late final int _uaType;
  int get length => _length;
  int _length = 0;
  int get uaType => _uaType;
  UACOpject(dynamic value, int uaType) {
    if (value is List) {
      _length = value.length;
      _pointer = dartList2Pointer(value, uaType);
    } else {
      _length = 0;
      _pointer = dart2Pointer(value, uaType);
    }
    _uaType = uaType;
  }

  void delete() {
    deleteC(_pointer, _uaType);
  }

  dynamic toDart() {
    if (length > 0) {
      return pointer2DartList(pointer, length, uaType);
    } else {
      return pointer2Dart(pointer, uaType);
    }
  }

  static void deleteC(Pointer pValue, int uaType) {
    switch (uaType) {
      case UATypes.BOOLEAN:
        calloc.free(pValue.cast<Bool>());
        break;
      case UATypes.BYTE:
        calloc.free(pValue.cast<Uint8>());
        break;
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        cOPC.UA_String_delete(pValue.cast());
        break;
      case UATypes.INT16:
        calloc.free(pValue.cast<Int16>());
        break;
      case UATypes.UINT16:
        calloc.free(pValue.cast<Uint16>());
        break;
      case UATypes.INT32:
        calloc.free(pValue.cast<Int32>());
        break;
      case UATypes.UINT32:
        calloc.free(pValue.cast<Uint32>());
        break;
      case UATypes.INT64:
        calloc.free(pValue.cast<Int64>());
        break;
      case UATypes.UINT64:
        calloc.free(pValue.cast<Uint64>());
        break;
      case UATypes.FLOAT:
        calloc.free(pValue.cast<Float>());
        break;
      case UATypes.DOUBLE:
        calloc.free(pValue.cast<Double>());
        break;
    }
  }

  static pointer2DartList(Pointer pValue, int len, int uaType) {
    switch (uaType) {
      case UATypes.BOOLEAN:
        return pValue
            .cast<Uint8>()
            .asTypedList(len)
            .map((e) => e == 1)
            .toList();
      case UATypes.BYTE:
        return Uint8List.fromList(
            pValue.cast<Uint8>().asTypedList(len).toList());
      //
      case UATypes.INT16:
        return Int16List.fromList(
            pValue.cast<Int16>().asTypedList(len).toList());
      case UATypes.UINT16:
        return Uint16List.fromList(
            pValue.cast<Uint16>().asTypedList(len).toList());
      //
      case UATypes.INT32:
        return Int32List.fromList(
            pValue.cast<Int32>().asTypedList(len).toList());
      case UATypes.UINT32:
        return Uint32List.fromList(
            pValue.cast<Uint32>().asTypedList(len).toList());
      //
      case UATypes.INT64:
        return Int64List.fromList(
            pValue.cast<Int64>().asTypedList(len).toList());
      case UATypes.UINT64:
        return Uint64List.fromList(
            pValue.cast<Uint64>().asTypedList(len).toList());
      case UATypes.DOUBLE:
        return Float64List.fromList(pValue.cast<Double>().asTypedList(len));
      case UATypes.FLOAT:
        return Float32List.fromList(
            pValue.cast<Float>().asTypedList(len).toList());
      case UATypes.STRING:
        List<String> list = [];
        for (int i = 0; i < len; i++) {
          final uaStr = pValue.cast<UA_String>().elementAt(i);
          list.add(uaStr.ref.data.cast<Utf8>().toDartString().toString());
        }
        return list;
    }
  }

  static pointer2DartArray(Pointer<UA_Variant> ptr, int len, int uaType) {
    final pValue = ptr.ref.data;
    switch (uaType) {
      case UATypes.BOOLEAN:
        return pValue
            .cast<Uint8>()
            .asTypedList(len)
            .map((e) => e == 1)
            .toList();
      case UATypes.BYTE:
        return Uint8List.fromList(
            pValue.cast<Uint8>().asTypedList(len).toList());
      //
      case UATypes.INT16:
        return Int16List.fromList(
            pValue.cast<Int16>().asTypedList(len).toList());
      case UATypes.UINT16:
        return Uint16List.fromList(
            pValue.cast<Uint16>().asTypedList(len).toList());
      //
      case UATypes.INT32:
        return Int32List.fromList(
            pValue.cast<Int32>().asTypedList(len).toList());
      case UATypes.UINT32:
        return Uint32List.fromList(
            pValue.cast<Uint32>().asTypedList(len).toList());
      //
      case UATypes.INT64:
        return Int64List.fromList(
            pValue.cast<Int64>().asTypedList(len).toList());
      case UATypes.UINT64:
        return Uint64List.fromList(
            pValue.cast<Uint64>().asTypedList(len).toList());
      case UATypes.DOUBLE:
        return Float64List.fromList(pValue.cast<Double>().asTypedList(len));
      case UATypes.FLOAT:
        return Float32List.fromList(
            pValue.cast<Float>().asTypedList(len).toList());
      case UATypes.STRING:
        List<String> list = [];
        for (int i = 0; i < len; i++) {
          final uaStr = pValue.cast<UA_String>().elementAt(i);
          list.add(uaStr.ref.data.cast<Utf8>().toDartString().toString());
        }
        return list;
    }
  }

  static dynamic pointer2Dart(Pointer pValue, int uaType) {
    switch (uaType) {
      case UATypes.BOOLEAN:
        return pValue.cast<Bool>().value;
      case UATypes.BYTE:
        return pValue.cast<Uint8>().value;
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        final uaStr = pValue.cast<UA_String>();
        return uaStr.ref.data.cast<Utf8>().toDartString().toString();
      case UATypes.INT16:
        return pValue.cast<Int16>().value;
      case UATypes.UINT16:
        return pValue.cast<Uint16>().value;
      case UATypes.INT32:
        return pValue.cast<Int32>().value;
      case UATypes.UINT32:
        return pValue.cast<Uint32>().value;
      case UATypes.INT64:
        return pValue.cast<Int64>().value;
      case UATypes.UINT64:
        return pValue.cast<Uint64>().value;
      case UATypes.FLOAT:
        return pValue.cast<Float>().value;
      case UATypes.DOUBLE:
        return pValue.cast<Double>().value;
    }
  }

  static dartList2Pointer(List<dynamic> value, int uaType) {
    Pointer? pValue;
    switch (uaType) {
      case UATypes.BOOLEAN:
      case UATypes.BYTE:
        List<int> nList = value.map((e) => e ? 1 : 0).toList();
        pValue = cOPC.UA_Array_new(
            value.length, cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
        pValue
            .cast<Uint8>()
            .asTypedList(value.length)
            .setAll(0, Uint8List.fromList(nList.cast()));
        break;

      case UATypes.BYTESTRING:
      case UATypes.STRING:
        final Pointer<UA_String> arrayStrings = cOPC.UA_Array_new(
                value.length, cOPC.UA_GET_TYPES_FROM_INDEX(uaType))
            .cast();
        for (int i = 0; i < value.length; i++) {
          arrayStrings.elementAt(i).ref.data = utf8Convert(value[i]);
          arrayStrings.elementAt(i).ref.length = (value[i] as String).length;
        }
        pValue = arrayStrings.cast();

        break;
      case UATypes.INT16:
        final Pointer<Int16> cBytes = calloc.allocate<Int16>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Int16List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.UINT16:
        final Pointer<Uint16> cBytes = calloc.allocate<Uint16>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Uint16List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.INT32:
        final Pointer<Int32> cBytes = calloc.allocate<Int32>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Int32List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.UINT32:
        final Pointer<Uint32> cBytes = calloc.allocate<Uint32>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Uint32List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.INT64:
        final Pointer<Int64> cBytes = calloc.allocate<Int64>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Int64List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.UINT64:
        final Pointer<Uint64> cBytes = calloc.allocate<Uint64>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Uint64List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.FLOAT:
        final Pointer<Float> cBytes = calloc.allocate<Float>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Float32List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
      case UATypes.DOUBLE:
        final Pointer<Double> cBytes = calloc.allocate<Double>(value.length);
        cBytes
            .asTypedList(value.length)
            .setAll(0, Float64List.fromList(value.cast()));
        pValue = cBytes.cast();
        break;
    }
    return pValue!;
  }

  static Pointer dart2Pointer(dynamic value, int uaType) {
    Pointer? pValue;
    switch (uaType) {
      case UATypes.BOOLEAN:
        pValue = cOPC.UA_Boolean_new()..value = value;
        break;
      case UATypes.BYTE:
        pValue = cOPC.UA_Byte_new()..value = value;
        break;
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        Pointer<Uint8> result = utf8Convert(value);

        final pUaStr = cOPC.UA_String_new();
        pUaStr.ref.data = result.cast();
        pUaStr.ref.length = (value as String).length;
        pValue = pUaStr;
        break;
      case UATypes.INT16:
        pValue = cOPC.UA_Int16_new()..value = value;
        break;
      case UATypes.UINT16:
        pValue = cOPC.UA_UInt16_new()..value = value;
        break;
      case UATypes.INT32:
        pValue = cOPC.UA_Int32_new()..value = value;
        break;
      case UATypes.UINT32:
        pValue = cOPC.UA_UInt32_new()..value = value;
        break;
      case UATypes.INT64:
        pValue = cOPC.UA_Int64_new()..value = value;
        break;
      case UATypes.UINT64:
        pValue = cOPC.UA_UInt64_new()..value = value;
        break;
      case UATypes.FLOAT:
        pValue = cOPC.UA_Float_new()..value = value;
        break;
      case UATypes.DOUBLE:
        pValue = cOPC.UA_Double_new()..value = value;
        break;
    }
    return pValue!;
  }

  static Pointer<Uint8> utf8Convert(value) {
    final units = utf8.encode(value);
    final result = cOPC.UA_Array_new(
            value.length + 1, cOPC.UA_GET_TYPES_FROM_INDEX(UATypes.BYTE))
        .cast<Uint8>();
    final nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result;
  }
}

Pointer<Uint8> toNativeUtf8(String str) {
  final units = utf8.encode(str);
  final result = cOPC.UA_Array_new(
          str.length + 1, cOPC.UA_GET_TYPES_FROM_INDEX(UATypes.BYTE))
      .cast<Uint8>();
  final nativeString = result.asTypedList(units.length + 1);
  nativeString.setAll(0, units);
  nativeString[units.length] = 0;
  return result.cast();
}
