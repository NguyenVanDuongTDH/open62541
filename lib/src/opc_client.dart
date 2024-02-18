// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:async';
import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:open62541/src/opject/c.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_variant.dart';

import 'open62541_gen.dart';
import 'opject/opc_node_id.dart';

class UAClient {
  static Map<int, Completer> future = {};
  late Pointer<UA_Client> client;
  Timer? _timer;
  UAClient() {
    client = cOPC.UA_Client_new();
    cOPC.UA_ClientConfig_setDefault(cOPC.UA_Client_getConfig(client));
  }

  bool get connected => _connected();
  static final Pointer _NULL = Pointer.fromAddress(0);
  bool _connected() {
    Pointer<Uint32> connectStatus = calloc.allocate(1);
    cOPC.UA_Client_getState(client, _NULL.cast(), _NULL.cast(), connectStatus);
    int retval = connectStatus.value;
    calloc.free(connectStatus);
    return retval == 0;
  }

  bool runIterate() {
    if (connected) {
      return cOPC.UA_Client_run_iterate(client, 0) == 0;
    } else {
      return false;
    }
  }

  bool connect(String endpointUrl) {
    final EndpointUrl = endpointUrl.toCString();
    int retval = cOPC.UA_Client_connect(client, EndpointUrl.cast());
    EndpointUrl.free();
    if (retval == 0) {
      _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
        runIterate();
      });
    }
    return retval == 0;
  }

  void connectAsync(String endpointUrl) {
    final EndpointUrl = endpointUrl.toCString();
    Pointer<UA_ClientConfig> cc = cOPC.UA_Client_getConfig(client);
    cc.ref.stateCallback;
    cOPC.UA_Client_connectAsync(client, EndpointUrl.cast());
  }

  bool disconnect() {
    _timer?.cancel();
    _timer = null;
    return cOPC.UA_Client_disconnect(client) == 0;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    return cOPC.UA_Client_delete(client);
  }

  dynamic readNode(UANodeID nodeId) {
    // read data server
    dynamic result;
    UAVariant variant = UAVariant();
    int res = cOPC.UA_Client_readValueAttribute(
        client, nodeId.nodeId, variant.variant);
    if (res == 0) {
      result = variant.toDart();
    } else {
      result = null;
    }
    return result;
  }

  Future<dynamic>? readNodeAsync(UANodeID nodeId) {
    Pointer<Int32> requestId = calloc.allocate(1);
    requestId.value = -1;
    int retval = cOPC.UA_Client_readValueAttribute_async(client, nodeId.nodeId,
        _readCallback, Pointer.fromAddress(0), requestId.cast());
    if (retval == 0 && requestId.value >= 0) {
      final compile = Completer();
      future[requestId.value] = compile;
      calloc.free(requestId);
      return compile.future;
    } else {
      return null;
    }
  }

  bool writeNodeId(UANodeID nodeId, int opcType, dynamic value) {
    UAVariant variant = UAVariant();
    UACOpject cObject = UACOpject(value, opcType);
    variant.setScalar(cObject);
    int res = cOPC.UA_Client_writeValueAttribute(
        client, nodeId.nodeId, variant.variant);
    variant.delete();
    cObject.delete();
    return res == 0;
  }

  Future<bool> writeNodeIdAsync(
      UANodeID nodeId, int opcType, dynamic value) async {
    UAVariant variant = UAVariant();
    UACOpject cObject = UACOpject(value, opcType);
    variant.setScalar(cObject);
    Pointer<Uint32> reqId = calloc.allocate(0);
    reqId.value = -1;
    int res = cOPC.UA_Client_writeValueAttribute_async(client, nodeId.nodeId,
        variant.variant, _writeCallback, _NULL.cast(), reqId);
    if (res == 0) {
      if (reqId.value >= 0) {
        final compile = Completer<bool>();
        future[reqId.value] = compile;

        return compile.future;
      }
    }
    calloc.free(reqId);
    variant.delete();
    cObject.delete();
    return false;
  }
}

final class UA_VALUE extends ffi.Struct {
  external UA_Variant value;
}

void _Client_Read_Async_Callback(Pointer<UA_Client> client, Pointer<Void> a,
    int requestId, int c, Pointer<UA_DataValue> data) {
  dynamic res = UAVariant.variant2Dart(data.cast<UA_VALUE>().ref.value);
  if (UAClient.future[requestId] != null) {
    UAClient.future[requestId]?.complete(res);
    UAClient.future.remove(requestId);
  }
}

final _readCallback = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Pointer<Void>, Uint32, Uint32,
        Pointer<UA_DataValue>)>(
  _Client_Read_Async_Callback,
);
void _Client_Write_Async_Callback(Pointer<UA_Client> client, Pointer<Void> v,
    int requestId, Pointer<UA_WriteResponse> response) {
  int retval = cOPC.UA_CLIENT_STATUS_RES(response);
  UAClient.future[requestId]?.complete(retval == 0);
  UAClient.future.remove(requestId);
}

final _writeCallback = Pointer.fromFunction<
    Void Function(
        Pointer<UA_Client>, Pointer<Void>, Uint32, Pointer<UA_WriteResponse>)>(
  _Client_Write_Async_Callback,
);
