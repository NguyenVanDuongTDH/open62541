import 'dart:ffi';
import 'package:open62541/src/c.dart';
import 'package:open62541/src/opc_variant.dart';

import 'opc_node_id.dart';
import 'open62541_gen.dart';

class OPCClient {
  late Pointer<UA_Client> client;
  OPCClient() {
    client = cOPC.UA_Client_new();
    cOPC.UA_ClientConfig_setDefault(cOPC.UA_Client_getConfig(client));
  }

  bool connect(String endpointUrl) {
    final EndpointUrl = endpointUrl.toCString();
    int retval = cOPC.UA_Client_connect(client, EndpointUrl.cast());
    EndpointUrl.free();
    return retval == 0;
  }

  bool disconnect() {
    return cOPC.UA_Client_disconnect(client) == 0;
  }

  void dispose() {
    return cOPC.UA_Client_delete(client);
  }

  dynamic readNode(OPCNodeId nodeId) {
    // read data server
    dynamic result;
    OPCVariant variant = OPCVariant();
    int res = cOPC.UA_Client_readValueAttribute(
        client, nodeId.nodeId, variant.variant);
    if (res == 0) {
      result = variant.toDart();
    } else {
      result = null;
    }
    return result;
  }

  bool writeNodeId(OPCNodeId nodeId, double value) {
    OPCVariant variant = OPCVariant();
    variant.setScalar(value);
    int res = cOPC.UA_Client_writeValueAttribute(client, nodeId.nodeId, variant.variant);
    variant.delete();
    return res == 0;
  }
}
