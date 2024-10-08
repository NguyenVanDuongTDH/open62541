import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';
import 'package:open62541/src/server_chidren/server_add_listen.dart';

bool UAServerAddVariableNodeId(
  Pointer<UA_Server> server, {
  required UAVariant variant,
  required UANodeId nodeid,
  required UAQualifiedName qualifiedName,
  String? description,
  String? displayName,
  UANodeId? parentNodeId,
  Function(UANodeId nodeId, dynamic value)? dataChangeCallBack,
}) {
  UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
  //var

  UAVariableAttributes attr = UAVariableAttributes();
  attr.setVariant(variant);
  attr.setDescription(description);
  attr.setDisplayName(displayName);
  attr.setAsset(UAVariableAttributes.READ | UAVariableAttributes.WRITE);

  int retval = cOPC.UA_Server_addVariableNode(
    server,
    nodeid.nodeIdNew,
    parentNodeId == null ? parent : parentNodeId.nodeIdNew,
    // parent,
    cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
    cOPC.UA_QUALIFIEDNAME(
        qualifiedName.nsIndex, CString.fromString(qualifiedName.name).cast()),
    cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    attr.attr.ref,
    Pointer.fromAddress(0),
    Pointer.fromAddress(0),
  );
  // cOPC.UA_Server_addReference(
  //     server,
  //     nodeid.nodeIdNew,
  //     UANodeId(0, UA_NS0ID_HASMODELLINGRULE).nodeId,
  //     cOPC.UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
  //     true);
  if (dataChangeCallBack != null) {
    UAServerValueChangeListen(server, nodeid, dataChangeCallBack);
  }
  // attr.delete();
  return retval == 0;
}
