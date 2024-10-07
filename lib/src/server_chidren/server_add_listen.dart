// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Server>, Map<UANodeId, Function(UANodeId nodeId, dynamic value)>>
    _callBack = {};

void UAServerCreateListenCallBack(Pointer<UA_Server> server) {
  _callBack[server] = {};
}

void UAServerRemoveListenCallBack(Pointer<UA_Server> server) {
  _callBack.remove(server);
}

void UAServerValueChangeListen(Pointer<UA_Server> server, UANodeId nodeID,
    Function(UANodeId nodeId, dynamic value) callBack) {
  _callBack[server]![nodeID] = callBack;
  UA_MonitoredItemCreateRequest monRequest =
      cOPC.UA_MonitoredItemCreateRequest_default(nodeID.nodeId);
  monRequest.requestedParameters.samplingInterval = 100.0;
  cOPC.UA_Server_createDataChangeMonitoredItem(
      server,
      UA_TimestampsToReturn.UA_TIMESTAMPSTORETURN_SOURCE,
      monRequest,
      Pointer.fromAddress(0),
      _UAServerDataChangeCallbackPtr);
}

void _UAServerDataChangeCallback(
    Pointer<UA_Server> server,
    int monitoredItemId,
    Pointer<Void> monitoredItemContext,
    Pointer<UA_NodeId> nodeid,
    Pointer<Void> nodeContext,
    int attributeId,
    Pointer<UA_DataValue> value) {
  dynamic res = UADataValue.toDart(value);
  _callBack[server]![UANodeId.fromPoint(nodeid)]!(
      UANodeId.fromPoint(nodeid), res);
}

final _UAServerDataChangeCallbackPtr = Pointer.fromFunction<
    Void Function(
        Pointer<UA_Server>,
        Uint32,
        Pointer<Void>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Uint32,
        Pointer<UA_DataValue>)>(_UAServerDataChangeCallback);
