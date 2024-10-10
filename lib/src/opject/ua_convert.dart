// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

class UaConvert {
  static Pointer<Uint8> str2Point(dynamic value) {
    final result = calloc.allocate<Uint8>(value.length);
    result.asTypedList(value.length).setAll(
        0,
        value is String
            ? value.codeUnits
            : value is Uint8List
                ? value
                : throw "STRING OR UINT8LSIT");
    return result;
  }

  static Pointer dart2Pointer(dynamic value, [int? type]) {
    int uaType = type ?? getUaTypes(value);
    Pointer? _ptr;
    if (value is List) {
      _ptr =
          cOPC.UA_Array_new(value.length, cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
    }

    switch (uaType) {
      case UATypes.VARIANT:
        if (_ptr != null && value is List) {
          for (int i = 0; i < value.length; i++) {
            final element = value[i];
            if (element is List) {
              final variant = UAVariant();
              variant.setScalar(element, UATypes.VARIANT);
              cOPC.UA_Variant_setScalar(_ptr.cast<UA_Variant>().elementAt(i),
                  variant.variant.cast(), cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
            } else {
              if (element is UAVariant) {
                cOPC.UA_Variant_setScalar(
                    _ptr.cast<UA_Variant>().elementAt(i),
                    element.variant.cast(),
                    cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
              } else {
                final variant0 = UAVariant();
                variant0.setScalar(element, getUaTypes(element));
                cOPC.UA_Variant_setScalar(
                    _ptr.cast<UA_Variant>().elementAt(i),
                    variant0.variant.cast(),
                    cOPC.UA_GET_TYPES_FROM_INDEX(uaType));
              }
            }
          }
        } else {
          final variant1 = UAVariant();
          variant1.setScalar(value, getUaTypes(value));
          return variant1.variant.cast();
        }

        break;
      case UATypes.BOOLEAN:
        if (value != null) {
          List<int> nList = value.map((e) => e ? 1 : 0).toList();
          _ptr!
              .cast<Uint8>()
              .asTypedList(value.length)
              .setAll(0, Uint8List.fromList(nList.cast()));
          break;
        } else {
          _ptr = cOPC.UA_Boolean_new()..value = value;
        }
        break;

      case UATypes.BYTE:
        if (_ptr != null) {
          _ptr.cast<Uint8>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Byte_new()..value = value;
        }

        break;
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        if (_ptr != null) {
          for (int i = 0; i < value.length; i++) {
            _ptr.cast<UA_String>().elementAt(i).ref.data = str2Point(value[i]);
            _ptr.cast<UA_String>().elementAt(i).ref.length =
                (value[i] as String).length;
          }
        } else {
          _ptr = cOPC.UA_String_new();
          _ptr.cast<UA_String>().ref.data = str2Point(value);
          _ptr.cast<UA_String>().ref.length = (value as String).length;
        }

        break;
      case UATypes.INT16:
        if (_ptr != null) {
          _ptr.cast<Int16>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Int16_new()..value = value;
        }
        break;
      case UATypes.UINT16:
        if (_ptr != null) {
          _ptr.cast<Uint16>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_UInt16_new()..value = value;
        }
        break;
      case UATypes.INT32:
        if (_ptr != null) {
          _ptr.cast<Int32>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Int32_new()..value = value;
        }
        break;
      case UATypes.UINT32:
        if (_ptr != null) {
          _ptr.cast<Uint32>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_UInt32_new()..value = value;
        }
        break;
      case UATypes.INT64:
        if (_ptr != null) {
          _ptr.cast<Int64>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Int64_new()..value = value;
        }
        break;
      case UATypes.UINT64:
        if (_ptr != null) {
          _ptr.cast<Uint64>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_UInt64_new()..value = value;
        }
        break;
      case UATypes.FLOAT:
        if (_ptr != null) {
          _ptr.cast<Float>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Float_new()..value = value;
        }
        break;
      case UATypes.DOUBLE:
        if (_ptr != null) {
          _ptr.cast<Double>().asTypedList(value.length).setAll(0, value);
        } else {
          _ptr = cOPC.UA_Double_new()..value = value;
        }
        break;
    }
    return _ptr!;
  }

  static dynamic variant2Dart(UAVariant v) {
    switch (v.type) {
      case UATypes.VARIANT:
        if (v.arrayLength > 0) {
          List l = [];
          for (int i = 0; i < v.arrayLength; i++) {
            l.add(variant2Dart(
                UAVariant(v.variant.ref.data.cast<UA_Variant>().elementAt(i))));
          }
          return l;
        } else {
          return UAVariant(v.variant.ref.data.cast());
        }
      case UATypes.BOOLEAN:
        if (v.arrayLength > 0) {
          return v.variant.ref.data
              .cast<Uint8>()
              .asTypedList(v.arrayLength)
              .map((e) => e == 1)
              .toList();
        } else {
          return v.variant.ref.data.cast<Bool>().value;
        }

      case UATypes.BYTE:
        if (v.arrayLength > 0) {
          return Uint8List.fromList(
              v.variant.ref.data.cast<Uint8>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Uint8>().value;
        }
      case UATypes.BYTESTRING:
      case UATypes.STRING:
        if (v.arrayLength > 0) {
          List<String> arr = [];
          for (var i = 0; i < v.arrayLength; i++) {
            final ptrArray = v.variant.ref.data.cast<UA_String>() + i;
            arr.add(utf8
                .decode(ptrArray.ref.data.asTypedList(ptrArray.ref.length)));
          }
          return arr;
        } else {
          return utf8.decode(v.variant.ref.data
              .cast<UA_String>()
              .ref
              .data
              .asTypedList(v.variant.ref.data.cast<UA_String>().ref.length));
        }
      case UATypes.INT16:
        if (v.arrayLength > 0) {
          return Int16List.fromList(
              v.variant.ref.data.cast<Int16>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Int16>().value;
        }
      case UATypes.UINT16:
        if (v.arrayLength > 0) {
          return Uint16List.fromList(
              v.variant.ref.data.cast<Uint16>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Uint16>().value;
        }
      case UATypes.INT32:
        if (v.arrayLength > 0) {
          return Int32List.fromList(
              v.variant.ref.data.cast<Int32>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Int32>().value;
        }
      case UATypes.UINT32:
        if (v.arrayLength > 0) {
          return Uint32List.fromList(
              v.variant.ref.data.cast<Uint32>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Uint32>().value;
        }
      case UATypes.INT64:
        if (v.arrayLength > 0) {
          return Int32List.fromList(
              v.variant.ref.data.cast<Int64>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Int64>().value;
        }
      case UATypes.UINT64:
        if (v.arrayLength > 0) {
          return Uint64List.fromList(
              v.variant.ref.data.cast<Uint64>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Uint64>().value;
        }
      case UATypes.FLOAT:
        if (v.arrayLength > 0) {
          return Float32List.fromList(
              v.variant.ref.data.cast<Float>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Float>().value;
        }
      case UATypes.DOUBLE:
        if (v.arrayLength > 0) {
          return Float64List.fromList(
              v.variant.ref.data.cast<Double>().asTypedList(v.arrayLength));
        } else {
          return v.variant.ref.data.cast<Double>().value;
        }
    }
  }

  static int getUaTypes(dynamic value) {
    if (value is int) {
      return UATypes.INT64;
    } else if (value is double) {
      return UATypes.DOUBLE;
    } else if (value is String) {
      return UATypes.STRING;
    } else {
      return -1;
    }
  }
}
