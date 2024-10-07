import 'package:open62541/open62541.dart';

Future<void> main() async {
  UANodeId id = UANodeId(23, "hello");

  UAClient client = UAClient();
  final rev = client.connect("opc.tcp://duong-Surface-Pro:4840/");
  print("connect: $rev");
  print(
      "read: ${await client.methodCallAsync(UANodeId(1, '"UANodeId.2"'), "vcl".uaString())}");

  print(
      "read: ${await client.methodCallAsync(UANodeId(1, '"UANodeId.2"'), "vcl".uaString())}");
}
