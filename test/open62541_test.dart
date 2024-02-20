// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_field

import 'dart:async';
import 'package:open62541/open62541.dart';

class UADBVariable<T> {
  int? _uaType;
  int get uaType => _uaType!;
  T? _data;
  final UANodeId nodeID;
  final UAClient client;
  UADBVariable(
      {required this.client, required int uaType, required this.nodeID}) {
    _uaType = uaType;
  }
  T get data => _getData();
  T _getData() {
    return _data!;
  }

  set data(T value) => _setData(value);
  void _setData(T value) {
    if (value != _data) {
      _data = value;
      client.writeNodeIdAsync(nodeID, uaType, value);
    }
  }

  void listen() {
    client.listenNodeId(nodeID, (nodeID, value) {
      _data = value;
    });
  }
}

class UADB {
  static late UAClient __client__;
  static void uaListen() {
    __value__.listen();
  }

  static void uaSetClient(UAClient client) {
    __client__ = client;
  }

  static final UADBVariable<int> __value__ = UADBVariable<int>(
    client: __client__,
    uaType: UATypes.INT64,
    nodeID: UANodeId(1, "value"),
  );

  static int get value => __value__.data;

  static set value(int __input__value__) => __value__.data = __input__value__;
}

Future<void> main() async {
  UAServer server = UAServer();
  server.addTypeNodeId(
      nodeID: UANodeId(1, 3000), qualifiedName: UAQualifiedName(1, "TYPEDATA"));
  server.addObjectNodeId(
      nodeID: UANodeId(1, 3100),
      nodeIdTypeNodeid: UANodeId(1, 3000),
      qualifiedName: UAQualifiedName(1, "NODEDATA"));
  server.addVariableNodeId(
    uaCOpject: UACOpject(1997, UATypes.INT64),
    nodeid: UANodeId(1, 3200),
    qualifiedName: UAQualifiedName(1, "VARDATA"),
    parentNodeId: UANodeId(1, 3100),
    dataChangeCallBack: (nodeId, value) {
      print(nodeId);
      print(value);
    },
  );
  server.addVariableNodeId(
    uaCOpject: UACOpject(1997, UATypes.INT64),
    nodeid: UANodeId(1, 3201),
    qualifiedName: UAQualifiedName(1, "VARDATA2"),
    parentNodeId: UANodeId(1, 3100),
    dataChangeCallBack: (nodeId, value) {
      print(nodeId);
      print(value);
    },
  );

  server.addMethod(
    name: UAQualifiedName(1, "NewMethod"),
    nodeId: UANodeId(1, 3300),
    input: UAArgument(name: "INPUT", uaType: UATypes.INT32),
    output: UAArgument(name: "OUTPUT", uaType: UATypes.INT32),
    callBack: (uaNodeId, value) {
      print(value);
      return 1997;
    },
  );
  // server.setAddress();
  server.start();
  await Future.delayed(const Duration(days: 1));
}
