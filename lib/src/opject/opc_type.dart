// ignore_for_file: constant_identifier_names

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

class _TYPES_ {
  dynamic _value;
  _TYPES_(this._value);
  //
  Pointer<UA_DataType> get type => _type();
  Pointer<UA_DataType> _type() {
    if (_value is int) {
      return cOPC.UA_FFI_TYPE_FROM_INDEX(_value);
    } else {
      return _value;
    }
  }
  //
  int get index => _index();
  int _index() {
    if (_value is int) {
      return _value;
    }
    return cOPC.UA_FFI_INDEX_FROM_TYPE(_value);
  }

  UA_NodeId get typeId => _typeId();
  UA_NodeId _typeId() {
    if (_value is int) {
      return cOPC.UA_FFI_TYPEID_FROM_INDEX(_value);
    }
    return cOPC.UA_FFI_TYPEID_FROM_TYPE(_value);
  }
}

class UATypes {
  static _TYPES_ from(dynamic index) {
    return _TYPES_(index);
  }

  static const  COUNT = 191;
  static const BOOLEAN = 0;
  static const SBYTE = 1;
  static const BYTE = 2;
  static const INT16 = 3;
  static const UINT16 = 4;
  static const INT32 = 5;
  static const UINT32 = 6;
  static const INT64 = 7;
  static const UINT64 = 8;
  static const FLOAT = 9;
  static const DOUBLE = 10;
  static const STRING = 11;
  static const DATETIME = 12;
  static const GUID = 13;
  static const BYTESTRING = 14;
  static const XMLELEMENT = 15;
  static const NODEID = 16;
  static const EXPANDEDNODEID = 17;
  static const STATUSCODE = 18;
  static const QUALIFIEDNAME = 19;
  static const LOCALIZEDTEXT = 20;
  static const EXTENSIONOBJECT = 21;
  static const DATAVALUE = 22;
  static const VARIANT = 23;
  static const DIAGNOSTICINFO = 24;
  static const KEYVALUEPAIR = 25;
  static const NODECLASS = 26;
  static const DURATION = 33;
  static const UTCTIME = 34;
  static const LOCALEID = 35;
}