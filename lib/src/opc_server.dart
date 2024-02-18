// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/c.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_qualifiedname.dart';
import 'package:open62541/src/open62541_gen.dart';

import 'opject/ua_variable_attributes.dart';

class UAServer {
  late Pointer<UA_Server> server;
  Timer? _timer;
  UAServer() {
    server = cOPC.UA_Server_new();
    cOPC.UA_ServerConfig_setDefault(cOPC.UA_Server_getConfig(server));
  }

  void setAddress(String ip, int port) {
    final cc = cOPC.UA_Server_getConfig(server);
    final pIP = ip.toCString();
    final uaIP = cOPC.UA_String_fromChars(pIP.cast());
    cc.ref.customHostname = uaIP;
    pIP.free();
    cOPC.UA_ServerConfig_setMinimal(cc, port, Pointer.fromAddress(0));
  }

  bool addObjectTypeNode(
      {required UANodeID nodeID,
      required UAQualifiedName qualifiedName,
      UANodeID? parentNodeId,
      String? description,
      String? displayName}) {
    UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE);
    Pointer<UA_ObjectTypeAttributes> attr = cOPC.UA_ObjectTypeAttributes_new();
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(description).cast());
    }
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(displayName).cast());
    }
    int ret = cOPC.UA_Server_addObjectTypeNode(
        server,
        nodeID.nodeId,
        parentNodeId == null ? parent : parentNodeId.nodeId,
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
        cOPC.UA_QUALIFIEDNAME(
            qualifiedName.nsIndex, qualifiedName.name.toCString().cast()),
        attr.ref,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    // cOPC.UA_ObjectTypeAttributes_delete(attr);
    return ret == 0;
  }

  bool addObjectNode(
      {required UANodeID nodeID,
      required UANodeID nodeIdTypeNodeid,
      required UAQualifiedName qualifiedName,
      UANodeID? parentNodeId,
      String? description,
      String? displayName}) {
    UA_NodeId parent;
    parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
    Pointer<UA_ObjectAttributes> attr = cOPC.UA_ObjectAttributes_new();
    cOPC.UA_ObjectAttributes_init(attr);
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(description).cast());
    }
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(displayName).cast());
    }

    int ret = cOPC.UA_Server_addObjectNode(
        server,
        nodeID.nodeId,
        parentNodeId == null ? parent : parentNodeId.nodeId,
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
        cOPC.UA_QUALIFIEDNAME(
            qualifiedName.nsIndex, qualifiedName.name.toCString().cast()),
        nodeIdTypeNodeid.nodeId,
        attr.ref,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    // cOPC.UA_ObjectAttributes_delete(attr);
    return ret == 0;
  }

  int addVariableNode(
      {required UACOpject uaCOpject,
      required UANodeID nodeid,
      required UAQualifiedName qualifiedName,
      String? description,
      String? displayName,
      UANodeID? parentNodeId}) {
    UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
    //var
    UAVariant variant = UAVariant();
    variant.setScalar(uaCOpject);
    UAVariableAttributes attr = UAVariableAttributes();
    attr.setVariant(variant);
    attr.setDescription(description);
    attr.setDisplayName(displayName);
    attr.setAsset(UAVariableAttributes.READ | UAVariableAttributes.WRITE);

    UA_NodeId _nodeID;
    _nodeID = nodeid.isString == true
        ? cOPC.UA_NODEID_STRING(nodeid.ns, CString.fromString(nodeid.s).cast())
        : cOPC.UA_NODEID_NUMERIC(nodeid.ns, nodeid.i);

    int retval = cOPC.UA_Server_addVariableNode(
      server,
      _nodeID,
      parentNodeId == null ? parent : parentNodeId.nodeId,
      // parent,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
      cOPC.UA_QUALIFIEDNAME(
          qualifiedName.nsIndex, CString.fromString(qualifiedName.name).cast()),
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
      attr.attr.ref,
      Pointer.fromAddress(0),
      Pointer.fromAddress(0),
    );
    // attr.delete();
    return retval;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
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
