import 'dart:ffi';

import '../../open62541.dart';
import '../gen.dart';
import '../open62541_gen.dart';
import '../opject/opc_c_data.dart';

dynamic UAClientReadNodeId(Pointer<UA_Client> client, UANodeId nodeId) {
  // read data server
  dynamic result;
  UAVariant variant = UAVariant();
  int res =
      cOPC.UA_Client_readValueAttribute(client, nodeId.nodeId, variant.variant);
  if (res == 0) {
    result = variant.toDart();
  } else {
    result = null;
  }
  return result;
}

bool UAClientWriteNodeId(
    Pointer<UA_Client> client, UANodeId nodeId, int opcType, dynamic value) {
  UAVariant variant = UAVariant();
  UACOpject cObject = UACOpject(value, opcType);
  variant.setScalar(cObject);
  int res = cOPC.UA_Client_writeValueAttribute(
      client, nodeId.nodeId, variant.variant);
  variant.delete();
  cObject.delete();
  return res == 0;
}
