import 'package:open62541/open62541.dart';

Future<void> main() async {
  UAClient client = UAClient();
  final rev = client.connect("opc.tcp://DESKTOP-MG0D01H:4840/");
  print("connect: $rev");

  for (var i = 0; i < 1; i++) {
    await Future.delayed(const Duration(milliseconds: 1));
    // await client.writeNodeIdAsync(UANodeId(1, "Availible"), "123".uaString());
    print("read: ${await client.readNodeIdAsync(UANodeId(1, "Availible"))}");
  }
  // client.disconnect();
}
