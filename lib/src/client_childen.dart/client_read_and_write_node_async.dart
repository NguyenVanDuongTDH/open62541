// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/ua_data_value.dart';

import '../gen.dart';
import '../open62541_gen.dart';
import '../opject/opc_c_data.dart';

Map<String, Completer> _future = {};

Future<bool> UAClientWriteNodeIdAsync(Pointer<UA_Client> client,
    UANodeId nodeId, int uaType, dynamic value) async {
  UAVariant variant = UAVariant();
  UACOpject cObject = UACOpject(value, uaType);
  variant.setScalar(cObject);
  Pointer<Uint32> reqId = calloc.allocate(0);
  reqId.value = -1;
  int res = cOPC.UA_Client_writeValueAttribute_async(client, nodeId.nodeId,
      variant.variant, _ClientWriteCallbackPtr, Pointer.fromAddress(0), reqId);
  if (res == 0) {
    if (reqId.value >= 0) {
      final compile = Completer<bool>();
      _future["$client::::${reqId.value}"] = compile;

      return compile.future;
    }
  }
  calloc.free(reqId);
  variant.delete();
  cObject.delete();
  return false;
}

Future<dynamic> UAClientReadNodeIdAsync(
    Pointer<UA_Client> client, UANodeId nodeId) async {
  Pointer<Int32> requestId = calloc.allocate(1);
  requestId.value = -1;
  int retval = cOPC.UA_Client_readValueAttribute_async(client, nodeId.nodeId,
      _ClientReadNodeAsyncPtr, Pointer.fromAddress(0), requestId.cast());
  if (retval == 0 && requestId.value >= 0) {
    final compile = Completer();
    _future["$client::::${requestId.value}"] = compile;
    calloc.free(requestId);
    return compile.future;
  } else {
    return null;
  }
}

void _ClientReadNodeAsync(Pointer<UA_Client> client, Pointer<Void> a,
    int requestId, int c, Pointer<UA_DataValue> data) {
  dynamic res = UADataValue.toDart(data);
  if (_future["$client::::$requestId"] != null) {
    _future["$client::::$requestId"]!.complete(res);
    _future.remove("$client::::$requestId");
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
  _future["$client::::$requestId"]?.complete(retval == 0);
  _future.remove("$client::::$requestId");
}

final _ClientWriteCallbackPtr = Pointer.fromFunction<
    Void Function(
        Pointer<UA_Client>, Pointer<Void>, Uint32, Pointer<UA_WriteResponse>)>(
  _ClientWriteAsyncCallback,
);
