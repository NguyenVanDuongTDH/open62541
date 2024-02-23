// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/gen.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

Map<Pointer<UA_Server>,
        Map<String, dynamic Function(UANodeId nodeID, dynamic input)>>
    _callBack = {};

void UAServerCreateMethodCallBack(Pointer<UA_Server> server) {
  _callBack[server] = {};
}

void UAServerRemoveMethodCallBack(Pointer<UA_Server> server) {
  _callBack.remove(server);
}

void UAServerAddMethod(
  Pointer<UA_Server> server, {
  required UAQualifiedName name,
  required UANodeId nodeId,
  required UAArgument input,
  required UAArgument output,
  required dynamic Function(UANodeId nodeID, dynamic input) callBack,
  UANodeId? perentNodeId,
}) {
  _callBack[server]![nodeId.toString()] = callBack;

  Pointer<UA_MethodAttributes> helloAttr = cOPC.UA_MethodAttributes_new();
  Pointer<Int32> context = calloc.allocate(1);
  context.value = output.uaType;
  helloAttr.ref.description = cOPC.UA_LOCALIZEDTEXT(
      UAVariableAttributes.en_US.cast(),
      "Say `Hello World` async".toCString().cast());
  helloAttr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
      UAVariableAttributes.en_US.cast(),
      "Hello World async".toCString().cast());
  helloAttr.ref.executable = true;
  helloAttr.ref.userExecutable = true;
  cOPC.UA_Server_addMethodNode(
      server,
      nodeId.nodeIdNew,
      perentNodeId == null
          ? cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
          : perentNodeId.nodeIdNew,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
      name.ua_qualifiedName_new,
      helloAttr.ref,
      _UAServerMethodCallbackPtr,
      1,
      input.attr,
      1,
      output.attr,
      context.cast(),
      Pointer.fromAddress(0));
  // /* Get the method node */
  // UA_NodeId id = cOPC.UA_NODEID_NUMERIC(1, 62541);
  // cOPC.UA_Server_setMethodNodeAsync(server, id, UA_TRUE);
}

int _UAServerMethodCallback(
    Pointer<UA_Server> server,
    Pointer<UA_NodeId> sessionId,
    Pointer<Void> sessionHandle,
    Pointer<UA_NodeId> methodId,
    Pointer<Void> methodContext,
    Pointer<UA_NodeId> objectId,
    Pointer<Void> objectContext,
    int inputSize,
    Pointer<UA_Variant> input,
    int outputSize,
    Pointer<UA_Variant> output) {
  dynamic inputData;
  if (inputSize <= 1) {
    inputData = UAVariant.variant2Dart(input.ref);
  } else {
    List list = [];
    for (var i = 0; i < inputSize; i++) {
      list.add(inputData = UAVariant.variant2Dart(input.elementAt(i).ref));
    }
  }

  try {
    dynamic result = _callBack[server]![UANodeId.pointer2String(methodId)]!(
        UANodeId.parse(UANodeId.pointer2String(methodId)), inputData);
    if (result != null) {
      if (result is UAVariant) {
        result.coppyTo(output);
        result.delete();
      } else if (result is List<UAVariant>) {
        for (var i = 0; i < result.length; i++) {
          result[i].coppyTo(output.elementAt(i));
          result[i].delete();
        }
      } else if (result is UACOpject) {
        UAVariant variant = UAVariant();
        variant.setScalar(result);
        variant.coppyTo(output);
        variant.delete();
      } else if (result is List<UACOpject>) {
        for (var i = 0; i < result.length; i++) {
          UAVariant variant = UAVariant();
          variant.setScalar(result[i]);
          variant.coppyTo(output.elementAt(i));
          variant.delete();
        }
      } else {
        UAVariant variant = UAVariant();
        final cValue = UACOpject(result, methodContext.cast<Int32>().value);
        variant.setScalar(cValue);
        variant.coppyTo(output);
        variant.delete();
      }
    }

    return 0;
  } catch (e) {
    return 9997;
  }
}

final _UAServerMethodCallbackPtr = Pointer.fromFunction<
    Uint32 Function(
        Pointer<UA_Server>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Pointer<UA_NodeId>,
        Pointer<Void>,
        Size,
        Pointer<UA_Variant>,
        Size,
        Pointer<UA_Variant>)>(_UAServerMethodCallback, 9998);
