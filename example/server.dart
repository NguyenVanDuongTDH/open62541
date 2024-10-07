import 'dart:async';

import 'package:open62541/open62541.dart';

void main() {
  UAServer server = UAServer();

  server.addVariableNodeId(
      uaVariant: "hello world!".uaString(),
      nodeid: UANodeId(1, "Availible"),
      qualifiedName: UAQualifiedName(1, "Availible"));

  server.addMethod(
    browseName: UAQualifiedName(1, 'MethodId'),
    nodeId: UANodeId(1, 'MethodId'),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) async {
      return "$uaNodeId $value".uaString();
    },
  );
  server.start();
}
