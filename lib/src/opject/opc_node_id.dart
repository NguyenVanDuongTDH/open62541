// ignore_for_file: unnecessary_string_interpolations

import 'package:open62541/src/opject/c.dart';

import '../open62541_gen.dart';

class UANodeID {
  UANodeID(this.ns, dynamic S_OR_I) {
    if (S_OR_I is String) {
      s = S_OR_I;
      isString = true;
    } else if (S_OR_I is int) {
      i = S_OR_I;
      isString = false;
    } else {
      throw "";
    }
  }
  UA_NodeId get nodeId =>
      isString ? _nodeString() : cOPC.UA_NODEID_NUMERIC(ns, i);

  UA_NodeId _nodeString() {
    final Chars = s.toCString();
    final res = cOPC.UA_NODEID_STRING(ns, Chars.cast());
    return res;
  }

  late int ns;
  String s = "";
  int i = 0;
  bool isString = false;
  @override
  String toString() {
    return {"ns": "$ns", isString ? "s" : "i": isString ? "$s" : "$i"}
        .toString();
  }
}
