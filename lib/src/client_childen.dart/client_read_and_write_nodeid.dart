// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import '../../open62541.dart';
import '../gen.dart';
import '../open62541_gen.dart';

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
  return result;
}

bool UAClientWriteNodeId(
    Pointer<UA_Client> client, UANodeId nodeId, UAVariant variant) {
  int res = cOPC.UA_Client_writeValueAttribute(
      client, nodeId.nodeId, variant.variant);

  variant.delete();
  return res == 0;
}
