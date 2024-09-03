import 'dart:ffi';

import 'package:open62541/open62541.dart';

void main() {
  UAServer server = UAServer();
  server.setAddress(ip: "192.168.31.19",port: 4840);
  server.addMethod(
    name: UAQualifiedName(1, "Method"),
    nodeId: UANodeId(1, 10),
    input: UAArgument(name: "Input", uaType: UATypes.INT64),
    output: UAArgument(name: "Output", uaType: UATypes.INT64),
    callBack: (uaNodeId, value) {
      int res = value * 2;
      print("\n $value \n");
      return res.uaInt64();
    },
  );
  server.start();
}
