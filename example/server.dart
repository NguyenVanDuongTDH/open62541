import 'dart:async';
import 'dart:typed_data';

import 'package:open62541/open62541.dart';

void main() {
  UAServer server = UAServer();

  server.addVariableNodeId(
      uaVariant: "hello world!".uaString(),
      nodeid: UANodeId(1, 123),
      qualifiedName: UAQualifiedName(1, "Availible"));

  server.addMethod(
    browseName: UAQualifiedName(1, 'MethodId'),
    nodeId: UANodeId.parse("ns=1;i=1997"),
    input: UAArgument(name: "Input", uaType: UATypes.STRING),
    output: UAArgument(name: "Output", uaType: UATypes.STRING),
    callBack: (uaNodeId, value) async {
      return "$uaNodeId $value".uaString();
    },
  );
  server.start();
}
