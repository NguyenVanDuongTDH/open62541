import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'opc_type.dart';
import '../open62541_gen.dart';

class UACOpject {
  late final Pointer _pointer;
  Pointer<Void> get pointer => _pointer.cast();
  late final int _uaType;
  late final int length = 0;
  int get uaType => _uaType;
  UACOpject(dynamic value, int uaType) {
    _uaType = uaType;
    _pointer = dart2Pointer(value, uaType);
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
        calloc.free(pValue.cast<Utf8>());
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
        List<String> _list = [];
        for (int i = 0; i < len; i++) {
          final _ua_str = pValue.cast<UA_String>().elementAt(i);
          _list.add(_ua_str.ref.data.cast<Utf8>().toDartString().toString());
        }
        return _list;
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
        return pValue.cast<Utf8>().toDartString();
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

  static Pointer dart2Pointer(dynamic value, int uaType) {
    Pointer? pValue;
    switch (uaType) {
      case UATypes.BOOLEAN:
        pValue = calloc<Bool>(1)..value = value;
        break;
      case UATypes.BYTE:
        pValue = calloc<Uint8>(1)..value = value;
        break;
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        pValue = (value as String).toNativeUtf8();
        break;
      case UATypes.INT16:
        pValue = calloc<Int16>(1)..value = value;
        break;
      case UATypes.UINT16:
        pValue = calloc<Uint16>(1)..value = value;
        break;
      case UATypes.INT32:
        pValue = calloc<Int32>(1)..value = value;
        break;
      case UATypes.UINT32:
        pValue = calloc<Uint32>(1)..value = value;
        break;
      case UATypes.INT64:
        pValue = calloc<Int64>(1)..value = value;
        break;
      case UATypes.UINT64:
        pValue = calloc<Uint64>(1)..value = value;
        break;
      case UATypes.FLOAT:
        pValue = calloc<Float>(1)..value = value;
        break;
      case UATypes.DOUBLE:
        pValue = calloc<Double>(1)..value = value;
        break;
    }
    return pValue!;
  }
}
