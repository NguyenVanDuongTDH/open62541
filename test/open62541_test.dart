// // ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_field

// import 'dart:async';
// import 'package:open62541/open62541.dart';
// import 'package:open62541/src/opject/opc_variant.dart';

// class UADBVariable<T> {
//   int? _uaType;
//   int get uaType => _uaType!;
//   T? _data;
//   final UANodeId nodeID;
//   final UAClient client;
//   UADBVariable(
//       {required this.client, required int uaType, required this.nodeID}) {
//     _uaType = uaType;
//   }
//   T get data => _getData();
//   T _getData() {
//     _data ??= client.readNodeId(nodeID);
//     return _data!;
//   }

//   set data(T value) => _setData(value);
//   void _setData(T value) {
//     if (value != _data) {
//       _data = value;
//       client.writeNodeIdAsync(nodeID, uaType, value);
//     }
//   }

//   void listen() {
//     client.listenNodeId(nodeID, (nodeID, value) {
//       _data = value;
//     });
//   }
// }

// class UADB {
//   static late UAClient __client__;
//   static void uaListen() {
//     __value__.listen();
//   }

//   static void uaSetClient(UAClient client) {
//     __client__ = client;
//   }

//   static final UADBVariable<bool> __value__ = UADBVariable<bool>(
//     client: __client__,
//     uaType: UATypes.BOOLEAN,
//     nodeID: UANodeId.parse('ns=3;s="Data_block_2"."OK OK"'),
//   );

//   static bool get value => __value__.data;

//   static set value(bool __input__value__) => __value__.data = __input__value__;
// }

// Future<void> main() async {
//   // UAServer server = UAServer();
//   // server.setAddress();

//   // server.addVariableNodeId(
//   //     uaVariant: 123.uaUint64(),
//   //     nodeid: UANodeId(1, "var"),
//   //     qualifiedName: UAQualifiedName(1, "variable"));

//   // server.start();
//   // while (true) {
//   //   server.iterate();
//   // }

//   UAClient client = UAClient();
//   client.connect("opc.tcp://127.0.0.1:4840");
  
//   while (true) {
//     print(await client.readNodeIdAsync(UANodeId(1, "var")));
//     // await Future.delayed(const Duration(milliseconds: 100));
//   }

//   await Future.delayed(Duration(days: 1));
// }
