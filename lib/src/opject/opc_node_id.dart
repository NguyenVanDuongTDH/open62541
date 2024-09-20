// ignore_for_file: unnecessary_string_interpolations, prefer_interpolation_to_compose_strings

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

class UANodeId {
  late UA_NodeId _nodeId;
  UA_NodeId get nodeId => _nodeId;
  UA_NodeId get nodeIdNew => _nodeId;

  static UANodeId fromPoint(Pointer<UA_NodeId> ptr) {
    Pointer<UA_String> uaStr = cOPC.UA_String_new();
    cOPC.UA_String_init(uaStr);
    cOPC.UA_NodeId_print(ptr, uaStr);
    String res =
        String.fromCharCodes(uaStr.ref.data.asTypedList(uaStr.ref.length))
            .toString();
    cOPC.UA_String_delete(uaStr);
    return UANodeId.parse(res);
  }

  static UANodeId fromNode(UA_NodeId nodeId) {
    UANodeId _nodeId = UANodeId(0, 0);
    _nodeId._nodeId = nodeId;
    return _nodeId;
  }

  UANodeId(int ns, dynamic S_OR_I) {
    if (S_OR_I is String) {
      Pointer<Utf8> ptr = S_OR_I.toNativeUtf8();

      _nodeId = cOPC.UA_NODEID_STRING_ALLOC(ns, ptr.cast());
      //
      calloc.free(ptr);
    } else {
      _nodeId = cOPC.UA_NODEID_NUMERIC(ns, S_OR_I);
    }
  }

  factory UANodeId.parse(String nodeIdStr) {
    String? s;
    int? i;
    int? ns;
    String IS = nodeIdStr.split(";")[1];
    ns = int.parse(nodeIdStr.split(";")[0].substring(3));

    if (IS.startsWith("s=")) {
      s = IS.replaceFirst("s=", '');
    } else {
      i = int.parse(IS.replaceFirst("i=", ''));
    }
    if (s != null) {
      return UANodeId(ns, s);
    } else {
      return UANodeId(ns, i);
    }
  }

  @override
  String toString() {
    Pointer<UA_NodeId> ptrNodeId = cOPC.UA_NodeId_new();
    ptrNodeId.ref = _nodeId;
    Pointer<UA_String> uaStr = cOPC.UA_String_new();
    cOPC.UA_String_init(uaStr);
    cOPC.UA_NodeId_print(ptrNodeId, uaStr);
    String res =
        String.fromCharCodes(uaStr.ref.data.asTypedList(uaStr.ref.length))
            .toString();
    cOPC.UA_String_delete(uaStr);
    cOPC.UA_NodeId_delete(ptrNodeId);
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
}
