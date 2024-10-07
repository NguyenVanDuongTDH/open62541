// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

bool UAServerAddObjectNodeId(Pointer<UA_Server> server,
    {required UANodeId nodeId,
    required UANodeId nodeIdTypeNodeid,
    required UAQualifiedName qualifiedName,
    UANodeId? parentNodeId,
    String? description,
    String? displayName}) {
  //
  UANodeId copyNodeId = nodeId.clone();
  UANodeId? copyParentNodeId = parentNodeId?.clone();
  UANodeId copynodeIdTypeNodeid = nodeIdTypeNodeid.clone();

  UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
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
      copyNodeId.nodeId,
      copyParentNodeId == null ? parent : copyParentNodeId.nodeId,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
      cOPC.UA_QUALIFIEDNAME(
          qualifiedName.nsIndex, qualifiedName.name.toCString().cast()),
      copynodeIdTypeNodeid.nodeId,
      attr.ref,
      Pointer.fromAddress(0),
      Pointer.fromAddress(0));
  // cOPC.UA_ObjectAttributes_delete(attr);
  return ret == 0;
}
