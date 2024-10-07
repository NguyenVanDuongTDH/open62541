import 'package:open62541/open62541.dart';

Future<void> main() async {
  UAClient client = UAClient();
  final rev = client.connect("opc.tcp://duong-Surface-Pro:4840/");
  print("connect: $rev");
  print(
      "read: ${await client.methodCallAsync(UANodeId(1, 'MethodId'), "vcl".uaString())}");

  print(
      "write: ${await client.writeNodeIdAsync(UANodeId(1, "Availible"), "123".uaString())}");
  print("read: ${await client.readNodeIdAsync(UANodeId(1, "Availible"))}");
  client.disconnect();
}
