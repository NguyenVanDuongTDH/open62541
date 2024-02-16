import 'package:open62541/open62541.dart';

Future<void> main() async {
  OPCClient client = OPCClient();
  client.connect("opc.tcp://192.168.1.29:4840");
  for (var v = 0; v < 100000; v++) {
    double z = client.readNode(OPCNodeId(2, 2));
    client.writeNodeId(OPCNodeId(2, 2), z + 1);
    print(z);
  }
  client.disconnect();
  client.dispose();
}
