import 'package:open62541/open62541.dart';

Future<void> main() async {
  UAClient client = UAClient();
  final rev = client.connect("opc.tcp://127.0.0.1:4840/");
  print("connect: $rev");

  for (var i = 0; i < 2; i++) {
    await Future.delayed(const Duration(milliseconds: 1));
    print(await client.writeNodeIdAsync(UANodeId(1, "VAR"), "$i".uaString()));
    print("read: ${await client.readNodeIdAsync(UANodeId(1, "VAR"))}");
    print("method: ${await client.methodCallAsync(UANodeId(1, "METHOD"),'dart'.uaString())}");

  }
}
