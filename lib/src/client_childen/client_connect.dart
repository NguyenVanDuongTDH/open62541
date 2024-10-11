import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Pointer<Void> UAClientCreate() {
  final client = cOPC.UA_Client_new();
  cOPC.UA_ClientConfig_setDefault(cOPC.UA_Client_getConfig(client));
  return client.cast();
}

bool UAClientConnect(Pointer<UA_Client> client, String endpointUrl) {
  final EndpointUrl = endpointUrl.toNativeUtf8();
  int retval = cOPC.UA_Client_connect(client, EndpointUrl.cast());
  return retval == 0;
}

bool UAClientDisConnect(Pointer<UA_Client> client) {
  return cOPC.UA_Client_disconnect(client) == 0;
}

void UAClientDispose(Pointer<UA_Client> client) {
  return cOPC.UA_Client_delete(client);
}

bool UAClientRunIterate(Pointer<UA_Client> client, int timeOut) {
  if (Platform.isAndroid) {
    cOPC.UA_Client_run_iterate_void(client, timeOut);
    return client.ref.connectStatus == 0;
  }
  return cOPC.UA_Client_run_iterate(client, timeOut) == 0;
}

bool UAClientConnected(Pointer<UA_Client> client) {
  Pointer<Uint32> connectStatus = calloc.allocate(1);
  cOPC.UA_Client_getState(
      client, Pointer.fromAddress(0), Pointer.fromAddress(0), connectStatus);
  int retval = connectStatus.value;
  calloc.free(connectStatus);
  return retval == 0;
}
