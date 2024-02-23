import 'dart:async';
import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/server_chidren.dart/server_add_avarible_node.dart';
import 'package:open62541/src/server_chidren.dart/server_add_listen.dart';
import 'package:open62541/src/server_chidren.dart/server_add_method.dart';
import 'package:open62541/src/server_chidren.dart/server_add_nodeid_object.dart';
import 'package:open62541/src/server_chidren.dart/server_add_type_nodeid.dart';
import 'package:open62541/src/server_chidren.dart/server_bind.dart';

class UAServer {
  late final Pointer server;
  Timer? _timer;
  UAServer() {
    server = UAServerCreate();
    UAServerCreateMethodCallBack(server.cast());
    UAServerCreateListenCallBack(server.cast());
  }

  bool start() {
    bool retval = UAServerRunStartup(server.cast());
    if (retval) {
      _timer = Timer.periodic(const Duration(milliseconds: 2), (timer) {
        UAServerRunIterate(server.cast(), true);
      });
    }
    return retval;
  }

  void dispose() {
    UAServerRemoveMethodCallBack(server.cast());
    UAServerRemoveListenCallBack(server.cast());
    UAServerDelete(server.cast());
  }

  void setAddress({
    String ip = "127.0.0.1",
    int port = 4840,
  }) {
    UAServerSetAddress(server.cast(), ip: ip, port: port);
  }

  bool addTypeNodeId({
    required UANodeId nodeID,
    required UAQualifiedName qualifiedName,
    UANodeId? parentNodeId,
    String? description,
    String? displayName,
  }) {
    return UAServerTypeNodeId(server.cast(),
        nodeID: nodeID,
        qualifiedName: qualifiedName,
        description: description,
        displayName: description,
        parentNodeId: parentNodeId);
  }

  bool addObjectNodeId({
    required UANodeId nodeID,
    required UANodeId nodeIdTypeNodeid,
    required UAQualifiedName qualifiedName,
    UANodeId? parentNodeId,
    String? description,
    String? displayName,
  }) {
    return UAServerAddObjectNodeId(server.cast(),
        nodeID: nodeID,
        nodeIdTypeNodeid: nodeIdTypeNodeid,
        qualifiedName: qualifiedName,
        description: description,
        displayName: displayName,
        parentNodeId: parentNodeId);
  }

  bool addVariableNodeId({
    required UAVariant uaCOpject,
    required UANodeId nodeid,
    required UAQualifiedName qualifiedName,
    String? description,
    String? displayName,
    UANodeId? parentNodeId,
    dynamic Function(UANodeId nodeId, dynamic value)? dataChangeCallBack,
  }) {
    return UAServerAddVariableNodeId(
      server.cast(),
      variant: uaCOpject,
      nodeid: nodeid,
      qualifiedName: qualifiedName,
      dataChangeCallBack: dataChangeCallBack,
      description: description,
      displayName: displayName,
      parentNodeId: parentNodeId,
    );
  }

  void listenNodeId(UANodeId nodeID,
      dynamic Function(UANodeId nodeId, dynamic value) callBack) {
    UAServerValueChangeListen(server.cast(), nodeID, callBack);
  }

  void addMethod({
    required UAQualifiedName name,
    required UANodeId nodeId,
    required UAArgument input,
    required UAArgument output,
    required dynamic Function(UANodeId uaNodeId, dynamic value) callBack,
    UANodeId? perentNodeId,
  }) {
    UAServerAddMethod(server.cast(),
        name: name,
        nodeId: nodeId,
        input: input,
        output: output,
        callBack: callBack,
        perentNodeId: perentNodeId);
  }
}
