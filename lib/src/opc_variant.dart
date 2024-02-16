import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'open62541_gen.dart';

class OPCVariant {
  late Pointer<UA_Variant> variant;
  OPCVariant() {
    variant = cOPC.UA_Variant_new();
    cOPC.UA_Variant_init(variant);
  }

  void delete() {
    cOPC.UA_Variant_delete(variant);
  }

  void clear() {
    cOPC.UA_Variant_clear(variant);
  }

  void setScalar(double value) {
    Pointer<Double> pValue = calloc.allocate(1);
    pValue.value = value;
   return cOPC.UA_Variant_setScalar(
        variant, pValue.cast(), cOPC.UA_GET_TYPES_(UA_TYPES_DOUBLE));
  }

  dynamic toDart() {
    Pointer<UA_Variant> value = variant;
    final type = cOPC.UA_GET_TYPES(value.ref.type);
    final len = value.ref.arrayLength;
    if (value.ref.arrayLength > 0) {
      switch (type) {
        case UA_TYPES_BOOLEAN:
          return value
              .castData<Uint8>()
              .asTypedList(len)
              .map((e) => e == 1)
              .toList();
        case UA_TYPES_SBYTE:
          return Int8List.fromList(
              value.castData<Int8>().asTypedList(len).toList());
        case UA_TYPES_BYTE:
          return Uint8List.fromList(
              value.castData<Uint8>().asTypedList(len).toList());
        //
        case UA_TYPES_INT16:
          return Int16List.fromList(
              value.castData<Int16>().asTypedList(len).toList());
        case UA_TYPES_UINT16:
          return Uint16List.fromList(
              value.castData<Uint16>().asTypedList(len).toList());
        //
        case UA_TYPES_INT32:
          return Int32List.fromList(
              value.castData<Int32>().asTypedList(len).toList());
        case UA_TYPES_UINT32:
          return Uint32List.fromList(
              value.castData<Uint32>().asTypedList(len).toList());
        //
        case UA_TYPES_INT64:
          return Int64List.fromList(
              value.castData<Int64>().asTypedList(len).toList());
        case UA_TYPES_UINT64:
          return Uint64List.fromList(
              value.castData<Uint64>().asTypedList(len).toList());
        case UA_TYPES_DOUBLE:
          return Float64List.fromList(
              value.castData<Double>().asTypedList(len));
        case UA_TYPES_FLOAT:
          return Float32List.fromList(
              value.castData<Float>().asTypedList(len).toList());
        case UA_TYPES_STRING:
          List<String> _list = [];
          for (int i = 0; i < len; i++) {
            final _ua_str = value.castData<UA_String>().elementAt(i);
            _list.add(_ua_str.ref.data.cast<Utf8>().toDartString().toString());
          }
          return _list;
      }
    } else {
      return _toDart(value);
    }
  }

  static dynamic _toDart(Pointer<UA_Variant> value) {
    final type = cOPC.UA_GET_TYPES(value.ref.type);
    switch (type) {
      case UA_TYPES_BOOLEAN:
        return value.castData<Bool>().value;
      case UA_TYPES_SBYTE:
        return value.castData<Int8>().value;
      case UA_TYPES_BYTE:
        return value.castData<Uint8>().value;
      //
      case UA_TYPES_INT16:
        return value.castData<Int16>().value;
      case UA_TYPES_UINT16:
        return value.castData<Uint16>().value;
      //
      case UA_TYPES_INT32:
        return value.castData<Int32>().value;
      case UA_TYPES_UINT32:
        return value.castData<Uint32>().value;
      //
      case UA_TYPES_INT64:
        return value.castData<Int64>().value;
      case UA_TYPES_UINT64:
        return value.castData<Uint64>().value;
      case UA_TYPES_DOUBLE:
        return value.castData<Double>().value;
      case UA_TYPES_FLOAT:
        return value.castData<Float>().value;
      case UA_TYPES_STRING:
        final _ua_str = value.castData<UA_String>();
        return _ua_str.ref.data.cast<Utf8>().toDartString().toString();
    }
  }
}

extension IntToPyDouble on Pointer<UA_Variant> {
  Pointer<U> castData<U extends NativeType>() {
    return ref.data.cast<U>();
  }
}
