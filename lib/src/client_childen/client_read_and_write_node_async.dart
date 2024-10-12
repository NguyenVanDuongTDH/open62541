// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Client>, Map<int, Completer>> _future = {};

Future<bool> UAClientWriteNodeIdAsync(
    Pointer<UA_Client> client, UANodeId nodeId, UAVariant variant) async {
  Pointer<UA_UInt32> reqId = cOPC.UA_UInt32_new();
  cOPC.UA_UInt32_init(reqId);
  reqId.value = -1;
  int res = cOPC.UA_Client_writeValueAttribute_async(client, nodeId.nodeId,
      variant.variant, _ClientWriteCallbackPtr, Pointer.fromAddress(0), reqId);
  if (res == 0) {
    final compile = Completer<bool>();
    final req = reqId.value;

    _future[client] ??= {};
    _future[client]![req] = compile;
    compile.future.then((value) {
      _future[client]?.remove(req);
    },);
    compile.future.timeout(const Duration(milliseconds: 3000), onTimeout: () {
      compile.completeError(Exception("Timeout Error"));
      _future[client]?.remove(req);
      return false;
    },);
    return compile.future;

  }
  cOPC.UA_UInt32_delete(reqId);
  nodeId.delete();
  variant.delete();
  return false;
}

Future<dynamic> UAClientReadNodeIdAsync(
    Pointer<UA_Client> client, UANodeId nodeId) async {
  Pointer<UA_UInt32> requestId = cOPC.UA_UInt32_new();
  requestId.value = -1;
  int retval = cOPC.UA_Client_readValueAttribute_async(client, nodeId.nodeId,
      _ClientReadNodeAsyncPtr, Pointer.fromAddress(0), requestId.cast());
  if (retval == 0) {
    int req = requestId.value;
    final compile = Completer();
    _future[client] ??= {};
    _future[client]![req] = compile;
    compile.future.then((value) {
      _future[client]?.remove(req);
    },);
    compile.future.timeout(const Duration(milliseconds: 3000), onTimeout: () {
      compile.completeError(Exception("Timeout Error"));
      _future[client]?.remove(req);
      return false;
    },);
    return compile.future;
  }
  nodeId.delete();
  cOPC.UA_UInt32_delete(requestId);
}

void _ClientReadNodeAsync(Pointer<UA_Client> client, Pointer<Void> a,
    int requestId, int c, Pointer<UA_DataValue> data) {
  if (_future[client] != null) {
    if (_future[client]![requestId] != null) {
      _future[client]![requestId]!.complete(UAVariant(data.cast()).data);
      _future[client]!.remove(requestId);
    } else {
      print("ERROR: _future[client]![requestId]");
    }
  } else {
    print("ERROR: _future[client]");
  }
}

final _ClientReadNodeAsyncPtr = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Pointer<Void>, Uint32, Uint32,
        Pointer<UA_DataValue>)>(
  _ClientReadNodeAsync,
);

void _ClientWriteAsyncCallback(Pointer<UA_Client> client, Pointer<Void> v,
    int requestId, Pointer<UA_WriteResponse> response) {
  int retval = cOPC.UA_CLIENT_WriteResponse_STATUS(response);
  _future[client]![requestId]!.complete(retval == 0);
  _future[client]!.remove(requestId);
}

final _ClientWriteCallbackPtr = Pointer.fromFunction<
    Void Function(
        Pointer<UA_Client>, Pointer<Void>, Uint32, Pointer<UA_WriteResponse>)>(
  _ClientWriteAsyncCallback,
);
