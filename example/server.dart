import 'package:open62541/open62541.dart';

void main() {
  UAServer server = UAServer();
  server.setAddress(ip: "192.168.31.19", port: 5555);

  server.addMethod(
    browseName: UAQualifiedName(1, "GetDrives.availables"),
    nodeId: UANodeId.parse("ns=1;i=1234"),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) async {
      await Future.delayed(Duration(milliseconds: 100));
      return "$uaNodeId $value".uaString();
    },
  );
  server.addMethod(
    browseName: UAQualifiedName(1, "GetDrives.listFilesAndDirectories"),
    nodeId: UANodeId(1, "1234"),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) {
      return "$uaNodeId $value".uaString();
    },
  );
  server.start();
}
