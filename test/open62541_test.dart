import 'dart:async';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_qualifiedname.dart';
import 'package:open62541/src/opc_server.dart';

Future<void> main() async {
  UAServer server = UAServer();
  server.addObjectTypeNode(
    nodeID: UANodeID(1, "dataType"),
    qualifiedName: UAQualifiedName(0, "NAME TYPE"),
    description: "variable state motor",
    displayName: "Y1",
  );
  server.addObjectNode(
    nodeID: UANodeID(1, "ONE"),
    nodeIdTypeNodeid: UANodeID(1, "dataType"),
    qualifiedName: UAQualifiedName(1, "ONE FORDER"),
    description: "variable state motor",
    displayName: "Y1",
  );
  server.addVariableNode(
    uaCOpject: UACOpject(1997, UATypes.INT64),
    nodeid: UANodeID(1, "KEY"),
    qualifiedName: UAQualifiedName(1, "DATA"),
    parentNodeId: UANodeID(1, "ONE"),
    description: "variable state motor",
    displayName: "Y1",
  );
  
  server.setAddress("192.168.1.29", 4840);

  server.start();
  
  await Future.delayed(Duration(days: 1));
}
