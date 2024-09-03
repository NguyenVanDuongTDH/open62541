import 'dart:async';
import 'dart:ffi';

import 'package:open62541/src/client_childen.dart/client_connect.dart';
import 'package:open62541/src/client_childen.dart/client_listen_variable.dart';
import 'package:open62541/src/client_childen.dart/client_read_and_write_node_async.dart';
import 'package:open62541/src/client_childen.dart/client_read_and_write_nodeid.dart';

import '../open62541.dart';
import 'client_childen.dart/client_method_call.dart';

class UAClient {
  late final Pointer<Void> client;
  Timer? _timer;
  UAClient() {
    client = UAClientCreate();
    UAClientAddClientCallBack(client.cast());
  }
  bool connect(String endpointUrl) {
    final retval = UAClientConnect(client.cast(), endpointUrl);
    print("connect");
    if (retval && _timer == null) {
      _timer ??= Timer.periodic(const Duration(milliseconds: 1), (timer) {
        runIterate(1);
      });
    }
    return retval;
  }

  bool get connected => UAClientConnected(client.cast());

  bool disconnect() {
    _timer?.cancel();
    _timer = null;
    return UAClientDisConnect(client.cast());
  }

  bool runIterate(int timeOut) {
    return UAClientRunIterate(client.cast(), timeOut);
  }

  void dispose() {
    return UAClientDispose(client.cast());
  }

  dynamic readNodeId(UANodeId nodeId) {
    return UAClientReadNodeId(client.cast(), nodeId);
  }

  bool writeNodeId(UANodeId nodeId, UAVariant variant) {
    return UAClientWriteNodeId(client.cast(), nodeId, variant);
  }

  Future<dynamic> readNodeIdAsync(UANodeId nodeId) {
    return UAClientReadNodeIdAsync(client.cast(), nodeId);
  }

  Future<bool> writeNodeIdAsync(UANodeId nodeId, UAVariant variant) {
    return UAClientWriteNodeIdAsync(client.cast(), nodeId, variant);
  }

  Future<dynamic> methodCallAsync(
      UANodeId methodId, int inputSize, UAVariant input) {
    return Client_Method_call_async(client.cast(), methodId, inputSize, input);
  }

  dynamic methodCall(UANodeId methodId, UAVariant input) {
    return Client_Method_call(client.cast(), methodId, input);
  }

  void listenNodeId(
    UANodeId nodeId,
    void Function(UANodeId, dynamic) callBack,
  ) {
    UAClientListenNodeId(client.cast(), nodeId, callBack);
  }
}
