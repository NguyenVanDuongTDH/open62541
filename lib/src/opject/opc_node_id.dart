// ignore_for_file: unnecessary_string_interpolations, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/ua_convert.dart';
import 'package:ffi/ffi.dart';

class UANodeId {
  UA_NodeId get nodeId => _getNodeId().ref;
  Pointer<UA_NodeId> get pNodeId => _getNodeId();
  Pointer<UA_NodeId>? _pNodeId;
  int namespaceIndex = 0;
  dynamic identifier;

  UANodeId(int nsIndex, this.identifier) {
    namespaceIndex = nsIndex;
  }
  UANodeId clone() {
    return UANodeId(namespaceIndex, identifier);
  }

  Pointer<UA_NodeId> _getNodeId() {
    if (_pNodeId == null) {
      if (identifier is int) {
        _pNodeId = cOPC.UA_NodeId_new();
        _pNodeId!.ref = cOPC.UA_NODEID_NUMERIC(namespaceIndex, identifier);
      } else if (identifier is String) {
        _pNodeId = cOPC.UA_NodeId_new();
        _pNodeId!.ref = cOPC.UA_NODEID_STRING(namespaceIndex, identifier.toString().toNativeUtf8().cast());
      } else if (identifier is Uint8List) {
        _pNodeId = cOPC.UA_NodeId_new();
        final bytes = calloc.allocate<Uint8>(identifier.length);
        bytes.asTypedList(identifier.length).setAll(0, identifier);
        _pNodeId!.ref = cOPC.UA_NODEID_BYTESTRING(
            namespaceIndex, bytes.cast());
      } else {
        throw "UANodeId NOT TYPE $identifier ${identifier.runtimeType}";
      }
    }
    return _pNodeId!;
  }

  static UANodeId fromPoint(Pointer<UA_NodeId> ptr) {
    return UANodeId.fromNode(ptr.ref);
  }

  static UANodeId fromNode(UA_NodeId id) {
    switch (id.identifierType) {
      case UA_NodeIdType.UA_NODEIDTYPE_NUMERIC:
        return UANodeId(id.namespaceIndex, id.identifier.numeric);
      case UA_NodeIdType.UA_NODEIDTYPE_STRING:
        return UANodeId(
            id.namespaceIndex,
            utf8.decode(id.identifier.string.data
                .asTypedList(id.identifier.string.length)).toString());
      case UA_NodeIdType.UA_NODEIDTYPE_BYTESTRING:
        return UANodeId(
            id.namespaceIndex,
            Uint8List.fromList(id.identifier.string.data
                .asTypedList(id.identifier.string.length)));
      default:
        throw "UANodeId.fromNode() NOT TYPE ";
    }
  }

  factory UANodeId.parse(String nodeIdStr) {
    final pId = cOPC.UA_NodeId_new();
    final uaStr = nodeIdStr.uaString();
    cOPC.UA_NodeId_parse(pId, uaStr.variant.ref.data.cast<UA_String>().ref);
   
    try {
      return UANodeId.fromNode(pId.ref);
    } finally {
      cOPC.UA_NodeId_delete(pId);
       uaStr.delete();
    }
  }

  static String ptr2String(Pointer<UA_NodeId> id) {
    Pointer<UA_String> uaStr = cOPC.UA_String_new();
    cOPC.UA_String_init(uaStr);
    cOPC.UA_NodeId_print(id, uaStr);
    String res =
        String.fromCharCodes(uaStr.ref.data.asTypedList(uaStr.ref.length))
            .toString();
    cOPC.UA_String_delete(uaStr);
    return res;
  }

  @override
  String toString() {
    final res = ptr2String(pNodeId);
    return res;
  }

  @override
  bool operator ==(Object other) {
    if (other is UANodeId) {
      return other.toString() == toString();
    }
    return false;
  }

  @override
  int get hashCode => toString().hashCode;

  void delete() {
    if (_pNodeId != null) {
      cOPC.UA_NodeId_delete(_pNodeId!);
    }
  }
}