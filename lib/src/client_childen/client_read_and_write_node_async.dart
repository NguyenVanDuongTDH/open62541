// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Client>, Map<int, Completer>> _future = {};

Future<bool> UAClientWriteNodeIdAsync(
    Pointer<UA_Client> client, UANodeId nodeId, UAVariant variant) async {
  Pointer<UA_UInt32> reqId = cOPC.UA_UInt32_new()..value = -1;
  final compile = Completer<bool>();

  try {
    int res = cOPC.UA_Client_writeValueAttribute_async(client, nodeId.nodeId,
        variant.variant, _clientWriteAsync, Pointer.fromAddress(0), reqId);
    if (res == 0 && reqId.value >= 0) {
      _future[client] ??= {};
      _future[client]![reqId.value] = compile;

      compile.future.timeout(const Duration(milliseconds: 3000), onTimeout: () {
        compile.completeError(Exception("TimeOut ReadNodeId Async"));
        _future[client]!.remove(reqId.value);
        return false;
      });
      return await compile.future;
    }
    return false;
  } finally {
    cOPC.UA_UInt32_delete(reqId);
    variant.delete();
    nodeId.delete();
  }
}

Future<dynamic> UAClientReadNodeIdAsync(
    Pointer<UA_Client> client, UANodeId nodeId) async {
  Pointer<UA_UInt32> requestId = cOPC.UA_UInt32_new();
  requestId.value = -1;

  try {
    int retval = cOPC.UA_Client_readValueAttribute_async(client, nodeId.nodeId,
        _clientReadAsync, Pointer.fromAddress(0), requestId.cast());
    if (retval == 0 && requestId.value >= 0) {
      final compile = Completer();
      _future[client] ??= {};
      _future[client]![requestId.value] = compile;
      compile.future.timeout(const Duration(milliseconds: 3000), onTimeout: () {
        compile.completeError(Exception("TimeOut ReadNodeId Async"));
        _future[client]!.remove(requestId.value);
      });
      return await compile.future;
    } else {
      return null;
    }
  } finally {
    cOPC.UA_UInt32_delete(requestId);
    nodeId.delete();
  }
}

void _ClientReadNodeAsync(Pointer<UA_Client> client, Pointer<Void> a,
    int requestId, int c, Pointer<UA_DataValue> data) {
  dynamic res = UADataValue.toDart(data);
  if (_future[client]![requestId] != null) {
    _future[client]![requestId]!.complete(res);
    _future[client]!.remove(requestId);
  }
}

final _clientReadAsync = Pointer.fromFunction<
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

final _clientWriteAsync = Pointer.fromFunction<
    Void Function(
        Pointer<UA_Client>, Pointer<Void>, Uint32, Pointer<UA_WriteResponse>)>(
  _ClientWriteAsyncCallback,
);
