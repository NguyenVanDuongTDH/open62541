// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Server>,
        Map<UANodeId, dynamic Function(UANodeId nodeID, dynamic input)>>
    _callBack = {};

void UAServerCreateMethodCallBack(Pointer<UA_Server> server) {
  _callBack[server] = {};
}

void UAServerRemoveMethodCallBack(Pointer<UA_Server> server) {
  _callBack.remove(server);
}

Future<dynamic> UAServerDartMethodCall(
    Pointer<UA_Server> server, UANodeId noidId, dynamic value) async {
  if (_callBack[server] != null) {
    if (_callBack[server]![noidId] != null) {
      return await _callBack[server]![noidId]!(noidId, value);
    } else {
      throw ("Not find method nodeId: $noidId");
    }
  } else {
    throw ("Not find server callback: $server");
  }
}

void UAServerAddMethod(
  Pointer<UA_Server> server, {
  required UAQualifiedName browseName,
  required UANodeId nodeId,
  required UAArgument input,
  required UAArgument output,
  required dynamic Function(UANodeId nodeID, dynamic input) callBack,
  UANodeId? parentNodeId,
  String? displayName,
  String? description,
}) {
  _callBack[server]![nodeId] = callBack;

  Pointer<UA_MethodAttributes> helloAttr = cOPC.UA_MethodAttributes_new();
  Pointer<Int32> context = calloc.allocate(1);
  context.value = output.uaType;
  if (description != null) {
    helloAttr.ref.description = cOPC.UA_LOCALIZEDTEXT(
        UAVariableAttributes.en_US.cast(), description.toNativeUtf8().cast());
  }
  if (displayName != null) {
    helloAttr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
        UAVariableAttributes.en_US.cast(), displayName.toNativeUtf8().cast());
  }
  helloAttr.ref.executable = true;
  helloAttr.ref.userExecutable = true;
  cOPC.UA_Server_addMethodNode(
      server,
      nodeId.nodeId,
      parentNodeId == null
          ? cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
          : parentNodeId.nodeId,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
      browseName.ua_qualifiedName_new,
      helloAttr.ref,
      _UAServerMethodCallbackPtr,
      1,
      input.attr,
      1,
      output.attr,
      context.cast(),
      Pointer.fromAddress(0));
  cOPC.UA_Server_setMethodNodeAsync(server, nodeId.nodeId, true);
}

int _UAServerMethodCallback(
    Pointer<UA_Server> server,
    Pointer<UA_NodeId> sessionId,
    Pointer<Void> sessionHandle,
    Pointer<UA_NodeId> methodId,
    Pointer<Void> methodContext,
    Pointer<UA_NodeId> objectId,
    Pointer<Void> objectContext,
    int inputSize,
    Pointer<UA_Variant> input,
    int outputSize,
    Pointer<UA_Variant> output) {
  return 0;
}

final _UAServerMethodCallbackPtr = Pointer.fromFunction<
    Uint32 Function(
        Pointer<UA_Server>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Size,
        Pointer<UA_Variant>,
        Size,
        Pointer<UA_Variant>)>(_UAServerMethodCallback, 9998);
