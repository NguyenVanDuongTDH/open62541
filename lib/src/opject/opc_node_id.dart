// ignore_for_file: unnecessary_string_interpolations, prefer_interpolation_to_compose_strings

import 'dart:ffi';
import 'package:open62541/src/opject/c.dart';

import '../gen.dart';
import '../open62541_gen.dart';

class UANodeId {
  UANodeId(this._ns, dynamic S_OR_I) {
    if (S_OR_I is String) {
      _s = S_OR_I;
      isString = true;
    } else if (S_OR_I is int) {
      _i = S_OR_I;
      isString = false;
    } else {
      throw "";
    }
  }
  UA_NodeId get nodeId =>
      isString ? _nodeString(free: true) : cOPC.UA_NODEID_NUMERIC(_ns, _i);
  UA_NodeId get nodeIdNew =>
      isString ? _nodeString(free: false) : cOPC.UA_NODEID_NUMERIC(_ns, _i);

  UA_NodeId _nodeString({bool free = true}) {
    final Chars = _s.toCString();
    final res = cOPC.UA_NODEID_STRING(_ns, Chars.cast());
    if (free) {
      Chars.free();
    }
    return res;
  }

  late final int _ns;
  late final String _s;
  late final int _i;
  bool isString = false;

  static String pointer2String(Pointer<UA_NodeId> nodeid) {
    Pointer<UA_String> uaStr = cOPC.UA_String_new();
    cOPC.UA_String_init(uaStr);
    cOPC.UA_NodeId_print(nodeid, uaStr);
    String res =
        String.fromCharCodes(uaStr.ref.data.asTypedList(uaStr.ref.length))
            .toString();
    cOPC.UA_String_delete(uaStr);
    return res;
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
    String res;
    if(isString){
      res = "ns=$_ns;s=$_s";
    }
    else{
      res = "ns=$_ns;i=$_i";
    }
    return res;
  }
}
