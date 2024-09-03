import 'package:open62541/open62541.dart';
import 'dart:io';

Future<void> main() async {
  print(Platform.isLinux);
  UAClient client = UAClient();
  print("Connect : ${client.connect("opc.tcp://duong-Surface-Pro:4840/")}");
  UAVariant i = 1997.uaInt32();
  print(client.methodCall(UANodeId(1, 10), i));
}
