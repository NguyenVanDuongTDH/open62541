// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/server_chidren/server_add_method.dart';

Pointer<Void> UAServerCreate() {
  final server = cOPC.UA_Server_new();
  cOPC.UA_ServerConfig_setDefault(cOPC.UA_Server_getConfig(server));
  return server.cast();
}

void UAServerSetAddress(Pointer<UA_Server> server,
    {String ip = "127.0.0.1", int port = 4840}) {
  final cc = cOPC.UA_Server_getConfig(server);
  cc.ref.customHostname.length = 0;
  if(cc.ref.customHostname.data.address != 0){
    calloc.free(cc.ref.customHostname.data);
  }  
  cc.ref.customHostname = cOPC.UA_String_fromChars(ip.toNativeUtf8().cast());
  cOPC.UA_ServerConfig_setMinimal(cc, port, Pointer.fromAddress(0));
}

bool UAServerRunIterate(Pointer<UA_Server> server, bool waitInternal) {
  return cOPC.UA_Server_run_iterate(server, waitInternal) == 0;
}

bool UAServerRunStartup(Pointer<UA_Server> server) {
  return cOPC.UA_Server_run_startup(server) == 0;
}

void UAServerDelete(Pointer<UA_Server> server) {
  cOPC.UA_Server_delete(server);
}
