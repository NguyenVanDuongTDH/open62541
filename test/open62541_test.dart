// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_field

import 'dart:async';

import 'package:open62541/open62541.dart';

class UADBVariable<T> {
  int? _uaType;
  int get uaType => _uaType!;
  T? _data;
  final UANodeID nodeID;
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
    client.listen(nodeID, (nodeID, value) {
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
    nodeID: UANodeID(1, "__value__"),
  );

  static int get value => __value__.data;

  static set value(int __input__value__) => __value__.data = __input__value__;
}

Future<void> main() async {
  UAClient client = UAClient();
  UADB.uaSetClient(client);
  UADB.uaListen();
  UADB.__client__ = client;
  UADB.value = 1;
  UADB.value;
  await Future.delayed(Duration(days: 1));
}
