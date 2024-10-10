// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

final Map<Pointer<UA_Client>,
    Map<String, Function(UANodeId nodeId, dynamic value)>> _callBack = {};

void UAClientAddClientCallBack(Pointer<UA_Client> client) {
  _callBack[client] = {};
}

void UAClientRemoveClientCallBack(Pointer<UA_Client> client) {
  _callBack.remove(client);
}

void UAClientListenNodeId(Pointer<UA_Client> client, UANodeId nodeId,
    Function(UANodeId nodeID, dynamic value) callBack) {
  _callBack[client]![nodeId.toString()] = callBack;

  UA_CreateSubscriptionRequest request =
      cOPC.UA_CreateSubscriptionRequest_default();
  Pointer<UA_CreateSubscriptionResponse> res =
      cOPC.UA_FFI_Client_Subscriptions_create(
              client,
              request,
              Pointer.fromAddress(0),
              Pointer.fromAddress(0),
              Pointer.fromAddress(0))
          .cast();

  int response = cOPC.UA_FFI_Client_SubSubscriptions_Check(res.cast());
  UA_NodeId target = nodeId.nodeId;
  final cString = nodeId.toString().toNativeUtf8();
  UA_MonitoredItemCreateRequest monRequest =
      cOPC.UA_MonitoredItemCreateRequest_default(target);
  monRequest.requestedParameters.samplingInterval = 100.0;
  cOPC.UA_Client_MonitoredItems_createDataChange(
      client,
      response,
      UA_TimestampsToReturn.UA_TIMESTAMPSTORETURN_BOTH,
      monRequest,
      cString.cast(),
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
  String context = monContext.cast<Utf8>().toDartString().toString();
  _callBack[client]![context]!(UANodeId.parse(context), res);
}

final _UAClientDataChangeCallbackPtr = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Uint32, Pointer<Void>, Uint32,
        Pointer<Void>, Pointer<UA_DataValue>)>(_UAClientDataChangeCallBack);
