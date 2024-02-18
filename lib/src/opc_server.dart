import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/c.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_qualifiedname.dart';
import 'package:open62541/src/open62541_gen.dart';

class UAServer {
  late Pointer<UA_Server> server;
  Timer? _timer;
  UAServer() {
    server = cOPC.UA_Server_new();
    cOPC.UA_ServerConfig_setDefault(cOPC.UA_Server_getConfig(server));
  }
  static final en_US = "en-US".toCString();
  int addVariableNode(
      UANodeID nodeid, UACOpject cValue, UAQualifiedName qualifiedName,
      {String? description, String? displayName}) {
    //var
    UAVariant variant = UAVariant();
    variant.setScalar(cValue);
    Pointer<UA_VariableAttributes> attr = cOPC.UA_VariableAttributes_new2();
    attr.ref.value = variant.variant.ref;
    //
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          en_US.cast(), CString.fromString(description).cast());
    }
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          en_US.cast(), CString.fromString(displayName).cast());
    }

    UA_NodeId _nodeID;
    _nodeID = nodeid.isString == true
        ? cOPC.UA_NODEID_STRING(nodeid.ns, CString.fromString(nodeid.s).cast())
        : cOPC.UA_NODEID_NUMERIC(nodeid.ns, nodeid.i);

    int retval = cOPC.UA_Server_addVariableNode(
        server,
        _nodeID,
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
        cOPC.UA_QUALIFIEDNAME(qualifiedName.nsIndex,
            CString.fromString(qualifiedName.name).cast()),
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
        attr.ref,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    return retval;
  }

  void dispose() {
    cOPC.UA_Server_delete(server);
  }

  Future<bool> start() async {
    int retval = cOPC.UA_Server_run_startup(server);

    if (retval == 0) {
      _timer = Timer.periodic(const Duration(milliseconds: 2), (timer) {
        cOPC.UA_Server_run_iterate(server, true);
      });
    }
    return retval == 0;
  }
}
