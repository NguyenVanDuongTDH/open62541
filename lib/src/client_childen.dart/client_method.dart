// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/gen.dart';
import 'package:open62541/src/open62541_gen.dart';

void UAClientCallMethod(
  Pointer<UA_Client> client,
  UANodeId objectId,
  UANodeId methodId,
  int inputSize,
  UAVariant input,
  Pointer<Size> outputSize,
  Pointer<Pointer<UA_Variant>> output,
) {

  // cOPC.UA_Client_call(client, objectId.nodeId, methodId.nodeId, inputSize,
  //     input.variant, outputSize, output);
}
