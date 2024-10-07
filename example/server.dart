import 'dart:async';

import 'package:open62541/open62541.dart';

void main() {
  UAServer server = UAServer();

  server.addMethod(
    browseName: UAQualifiedName(1, "GetDrives.availables"),
    nodeId: UANodeId(1, '"UANodeId.2"'),
    // nodeId: UANodeId(1, 1997),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) async {
      await Future.delayed(Duration(milliseconds: 100));
      return "$uaNodeId $value".uaString();
    },
  );
  var uaNodeId2 = UANodeId(1, '"UANodeId.1"');
  server.addMethod(
    browseName: UAQualifiedName(1, "GetDrives.listFilesAndDirectories"),
    nodeId: uaNodeId2,
    // nodeId: UANodeId(1, 1999),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) {
      return "$uaNodeId $value".uaString();
    },
  );
  server.start();
  Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      print(uaNodeId2);
    },
  );
}
