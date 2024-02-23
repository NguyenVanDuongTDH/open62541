// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_field

import 'dart:async';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/opc_variant.dart';

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
    _data ??= client.readNodeId(nodeID);
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

  static final UADBVariable<bool> __value__ = UADBVariable<bool>(
    client: __client__,
    uaType: UATypes.BOOLEAN,
    nodeID: UANodeId.parse('ns=3;s="Data_block_2"."OK OK"'),
  );

  static bool get value => __value__.data;

  static set value(bool __input__value__) => __value__.data = __input__value__;
}


Future<void> main() async { 
  String data = "data";
  while (data.length < 10240) {
    data = data + data;
  }
  int x = 0;

  UAClient client = UAClient();
  client.connect("opc.tcp://Admin-PC:4840/");
  client.listenNodeId(UANodeId(1, "NODE FORDER"), (p0, p1) {
    print("listen: $p0 => ${p1.length}");
  });
  while (true) {
    await Future.delayed(Duration(milliseconds: 50));
    try {
      String res = client.readNodeId(UANodeId(1, "NODE FORDER"));
      x = x + 1;
      client.writeNodeId(UANodeId(1, "NODE FORDER"), (data + "$x").uaString());
    } catch (e) {
      print(e);
    }
  }

  await Future.delayed(Duration(days: 1));
}
