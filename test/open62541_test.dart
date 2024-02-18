import 'dart:async';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_qualifiedname.dart';
import 'package:open62541/src/opc_server.dart';

Future<void> main() async {
  // UAClient client = UAClient();

  // client.connect("opc.tcp://Admin-PC:4840/");
  // for (var i = 0; i < 10; i++) {
  //   dynamic data = (await client.readNodeAsync(UANodeID(1, "the.answer")));
  //   await client.writeNodeIdAsync(UANodeID(1, "the.answer"), UATypes.INT64, data+1);
  //   print(data);
  // }
  // client.disconnect();
  // client.dispose();

  UAServer server = UAServer();
  final i = UACOpject(1199, UATypes.INT64);
  server.addVariableNode(
      UANodeID(1, "the.answer"), i, UAQualifiedName(1, "DATA 2"));
  server.addVariableNode(UANodeID(1, "the.answer2"),
      UACOpject(true, UATypes.BOOLEAN), UAQualifiedName(1, "DATA 1"));

  server.start();
  Timer.periodic(Duration(seconds: 1), (timer) {
    print(i.toDart());
  });
  await Future.delayed(Duration(days: 1));
}
