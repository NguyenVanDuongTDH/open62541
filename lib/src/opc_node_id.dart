import 'package:ffi/ffi.dart';

import 'open62541_gen.dart';

class OPCNodeId {
  late UA_NodeId nodeId;
  OPCNodeId(int ns, dynamic S_OR_I) {
    if (S_OR_I is String) {
      final Chars = S_OR_I.toNativeUtf8();
      nodeId = cOPC.UA_NODEID_STRING(ns, Chars.cast());
      calloc.free(Chars);
    } else if (S_OR_I is int) {
      nodeId = cOPC.UA_NODEID_NUMERIC(ns, S_OR_I);
    } else {
      throw "";
    }
  }
}
