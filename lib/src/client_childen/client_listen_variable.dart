// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

final Map<Pointer<UA_Client>,
        Map<Pointer<UA_NodeId>, Function(UANodeId nodeId, dynamic value)>>
    _callBack = {};

void UAClientAddClientCallBack(Pointer<UA_Client> client) {
  _callBack[client] = {};
}

void UAClientRemoveClientCallBack(Pointer<UA_Client> client) {
  _callBack.remove(client);
}

void UAClientListenNodeId(Pointer<UA_Client> client, UANodeId nodeId,
    Function(UANodeId nodeID, dynamic value) callBack) {
  _callBack[client]![nodeId.pNodeId] = callBack;

  UA_CreateSubscriptionRequest request =
      cOPC.UA_CreateSubscriptionRequest_default();
  Pointer<UA_CreateSubscriptionResponse> res =
      cOPC.UA_Client_Subscriptions_create_(
              client,
              request,
              Pointer.fromAddress(0),
              Pointer.fromAddress(0),
              Pointer.fromAddress(0))
          .cast();

  int response = cOPC.UA_Client_SubSubscriptions_Check(res.cast());
  UA_NodeId target = nodeId.pNodeId.ref;
  final context = nodeId.pNodeId;
  UA_MonitoredItemCreateRequest monRequest =
      cOPC.UA_MonitoredItemCreateRequest_default(target);
  monRequest.requestedParameters.samplingInterval = 100.0;
  cOPC.UA_Client_MonitoredItems_createDataChange(
      client,
      response,
      UA_TimestampsToReturn.UA_TIMESTAMPSTORETURN_BOTH,
      monRequest,
      context.cast(),
      _UAClientDataChangeCallbackPtr,
      Pointer.fromAddress(0));
}

void _UAClientDataChangeCallBack(
    Pointer<UA_Client> client,
    int subId,
    Pointer<Void> subContext,
    int monId,
    Pointer<Void> monContext,
    Pointer<UA_DataValue> value) {
  dynamic res = UADataValue.toDart(value);
  Pointer<UA_NodeId> context = monContext.cast();
  _callBack[client]![context]!(UANodeId.fromPoint(context), res);
}

final _UAClientDataChangeCallbackPtr = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Uint32, Pointer<Void>, Uint32,
        Pointer<Void>, Pointer<UA_DataValue>)>(_UAClientDataChangeCallBack);
