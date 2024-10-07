// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

dynamic UAClientReadNodeId(Pointer<UA_Client> client, UANodeId nodeId) {
  // read data server
  dynamic result;
  UAVariant variant = UAVariant();
  int res = cOPC.UA_Client_readValueAttribute(
      client, nodeId.nodeId, variant.variant.cast());
  if (res == 0) {
    result = variant.data();
  } else {
    result = null;
  }
  variant.delete();
  nodeId.delete();
  return result;
}

bool UAClientWriteNodeId(
    Pointer<UA_Client> client, UANodeId nodeId, UAVariant variant) {
  int res = cOPC.UA_Client_writeValueAttribute(
      client, nodeId.nodeId, variant.variant);
  nodeId.delete();
  variant.delete();
  return res == 0;
}
