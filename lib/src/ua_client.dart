import 'dart:async';
import 'dart:ffi';

import 'package:open62541/src/client_childen.dart/client_connect.dart';
import 'package:open62541/src/client_childen.dart/client_listen_variable.dart';
import 'package:open62541/src/client_childen.dart/client_read_and_write_node_async.dart';
import 'package:open62541/src/client_childen.dart/client_read_and_write_nodeid.dart';
import 'package:open62541/src/opject/opc_node_id.dart';

class UAClient {
  late final Pointer<Void> client;
  Timer? _timer;
  UAClient() {
    client = UAClientCreate();
    UAClientAddClientCallBack(client.cast());
  }
  bool connect(String endpointUrl) {
    final retval = UAClientConnect(client.cast(), endpointUrl);
    if (retval) {
      _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
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

  bool writeNodeId(UANodeId nodeId, int opcType, dynamic value) {
    return UAClientWriteNodeId(client.cast(), nodeId, opcType, value);
  }

  Future<dynamic> readNodeIdAsync(UANodeId nodeId) {
    return UAClientReadNodeIdAsync(client.cast(), nodeId);
  }

  Future<bool> writeNodeIdAsync(UANodeId nodeId, int uaType, dynamic value) {
    return UAClientWriteNodeIdAsync(client.cast(), nodeId, uaType, value);
  }

  void listenNodeId(
    UANodeId nodeId,
    void Function(UANodeId, dynamic) callBack,
  ) {
    UAClientListenNodeId(client.cast(), nodeId, callBack);
  }
}