// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

bool UAServerTypeNodeId(Pointer<UA_Server> server,
    {required UANodeId nodeID,
    required UAQualifiedName qualifiedName,
    UANodeId? parentNodeId,
    String? description,
    String? displayName}) {
  UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE);
  Pointer<UA_ObjectTypeAttributes> attr = cOPC.UA_ObjectTypeAttributes_new();
  if (description != null) {
    attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
        UAVariableAttributes.en_US.cast(), description.toNativeUtf8().cast());
  }
  if (displayName != null) {
    attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
        UAVariableAttributes.en_US.cast(), displayName.toNativeUtf8().cast());
  }
  int ret = cOPC.UA_Server_addObjectTypeNode(
      server,
      nodeID.nodeId,
      parentNodeId == null ? parent : parentNodeId.nodeId,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
      cOPC.UA_QUALIFIEDNAME(
          qualifiedName.nsIndex, qualifiedName.name.toNativeUtf8().cast()),
      attr.ref,
      Pointer.fromAddress(0),
      Pointer.fromAddress(0));
  // cOPC.UA_ObjectTypeAttributes_delete(attr);
  return ret == 0;
}
