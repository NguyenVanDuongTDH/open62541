// ignore_for_file: unused_field, use_function_type_syntax_for_parameters

import 'dart:async';
import 'dart:ffi';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/opc_client.dart';
import 'package:open62541/src/opject/c.dart';
import 'package:open62541/src/opject/opc_c_data.dart';
import 'package:open62541/src/opject/opc_qualifiedname.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/ua_argrument.dart';

import 'opject/ua_variable_attributes.dart';

class UAServer {
  late Pointer<UA_Server> server;
  static final Map<Pointer<UA_Server>, Function(dynamic value)>
      _callBackDataChangeServer = {};
  final Map<String, Function(UANodeID nodeId, dynamic value)>
      _callBackDataChangeNodeID = {};
  Timer? _timer;
  UAServer() {
    server = cOPC.UA_Server_new();
    cOPC.UA_ServerConfig_setDefault(cOPC.UA_Server_getConfig(server));
    _callBackDataChangeServer[server] = (value) {
      _callBackDataChangeNodeID[value[0]]!(
          UANodeID.parse(value[0].toString().split("::::")[1]), value[1]);
    };
  }
  void _listenChangeValue(
      UANodeID nodeID, Function(UANodeID nodeId, dynamic value) callBack) {
    _callBackDataChangeNodeID["$server::::$nodeID"] = callBack;
    UA_MonitoredItemCreateRequest monRequest =
        cOPC.UA_MonitoredItemCreateRequest_default(nodeID.nodeIdNew);
    monRequest.requestedParameters.samplingInterval = 100.0;
    cOPC.UA_Server_createDataChangeMonitoredItem(
        server,
        UA_TimestampsToReturn.UA_TIMESTAMPSTORETURN_SOURCE,
        monRequest,
        Pointer.fromAddress(0),
        _dataChangeCallBack);
  }

  Future<bool> start() async {
    int retval = cOPC.UA_Server_run_startup(server);
    if (retval == 0) {
      _timer = Timer.periodic(const Duration(milliseconds: 2), (timer) {
        cOPC.UA_Server_run_iterate(server, true);
      });
    }
    return retval == 0;
  }

  void setAddress(String ip, int port) {
    final cc = cOPC.UA_Server_getConfig(server);
    final pIP = ip.toCString();
    final uaIP = cOPC.UA_String_fromChars(pIP.cast());
    cc.ref.customHostname = uaIP;
    pIP.free();
    cOPC.UA_ServerConfig_setMinimal(cc, port, Pointer.fromAddress(0));
  }

  bool addObjectTypeNode(
      {required UANodeID nodeID,
      required UAQualifiedName qualifiedName,
      UANodeID? parentNodeId,
      String? description,
      String? displayName}) {
    UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE);
    Pointer<UA_ObjectTypeAttributes> attr = cOPC.UA_ObjectTypeAttributes_new();
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(description).cast());
    }
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(displayName).cast());
    }
    int ret = cOPC.UA_Server_addObjectTypeNode(
        server,
        nodeID.nodeIdNew,
        parentNodeId == null ? parent : parentNodeId.nodeIdNew,
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
        cOPC.UA_QUALIFIEDNAME(
            qualifiedName.nsIndex, qualifiedName.name.toCString().cast()),
        attr.ref,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    // cOPC.UA_ObjectTypeAttributes_delete(attr);
    return ret == 0;
  }

  bool addObjectNode(
      {required UANodeID nodeID,
      required UANodeID nodeIdTypeNodeid,
      required UAQualifiedName qualifiedName,
      UANodeID? parentNodeId,
      String? description,
      String? displayName}) {
    UA_NodeId parent;
    parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
    Pointer<UA_ObjectAttributes> attr = cOPC.UA_ObjectAttributes_new();
    cOPC.UA_ObjectAttributes_init(attr);
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(description).cast());
    }
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(displayName).cast());
    }

    int ret = cOPC.UA_Server_addObjectNode(
        server,
        nodeID.nodeIdNew,
        parentNodeId == null ? parent : parentNodeId.nodeIdNew,
        cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
        cOPC.UA_QUALIFIEDNAME(
            qualifiedName.nsIndex, qualifiedName.name.toCString().cast()),
        nodeIdTypeNodeid.nodeId,
        attr.ref,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    // cOPC.UA_ObjectAttributes_delete(attr);
    return ret == 0;
  }

  bool addVariableNode({
    required UACOpject uaCOpject,
    required UANodeID nodeid,
    required UAQualifiedName qualifiedName,
    String? description,
    String? displayName,
    UANodeID? parentNodeId,
    Function(UANodeID nodeId, dynamic value)? dataChangeCallBack,
  }) {
    UA_NodeId parent = cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
    //var
    UAVariant variant = UAVariant();
    variant.setScalar(uaCOpject);
    UAVariableAttributes attr = UAVariableAttributes();
    attr.setVariant(variant);
    attr.setDescription(description);
    attr.setDisplayName(displayName);
    attr.setAsset(UAVariableAttributes.READ | UAVariableAttributes.WRITE);

    int retval = cOPC.UA_Server_addVariableNode(
      server,
      nodeid.nodeIdNew,
      parentNodeId == null ? parent : parentNodeId.nodeIdNew,
      // parent,
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
      cOPC.UA_QUALIFIEDNAME(
          qualifiedName.nsIndex, CString.fromString(qualifiedName.name).cast()),
      cOPC.UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
      attr.attr.ref,
      Pointer.fromAddress(0),
      Pointer.fromAddress(0),
    );
    cOPC.UA_Server_addReference(
        server,
        nodeid.nodeIdNew,
        UANodeID(0, UA_NS0ID_HASMODELLINGRULE).nodeId,
        cOPC.UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY),
        true);
    finit(nodeid);
    if (dataChangeCallBack != null) {
      _listenChangeValue(nodeid, dataChangeCallBack);
    }
    return retval == 0;
  }

  void finit(UANodeID nodeid) {
    cOPC.UA_Server_addNode_finish(server, nodeid.nodeIdNew);
  }

  void addMethod({
    required UAQualifiedName name,
    required UANodeID nodeId,
    required UAArgument input,
    required UAArgument output,
    required dynamic Function(UANodeID nodeID, dynamic input) callBack,
    UANodeID? perentNodeId,
  }) {
    _callBackDataChangeNodeID["$server::::$nodeId"] = callBack;
    Pointer<UA_MethodAttributes> helloAttr = cOPC.UA_MethodAttributes_new();
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
        _methodCallBackPtr,
        1,
        input.attr,
        1,
        output.attr,
        Pointer.fromAddress(0),
        Pointer.fromAddress(0));
    // /* Get the method node */
    // UA_NodeId id = cOPC.UA_NODEID_NUMERIC(1, 62541);
    // cOPC.UA_Server_setMethodNodeAsync(server, id, UA_TRUE);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    cOPC.UA_Server_delete(server);
  }
}

int _MethodCallBack(
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
  dynamic res = UAVariant.variant2Dart(input.ref);
  dynamic result = UAServer._callBackDataChangeServer[server]!(
    ["$server::::${UANodeID.pointer2String(methodId)}", res],
  );
  if(result != null){
    print("chưa làm chức năng return: $result");
  }

  return 0;
}

final _methodCallBackPtr = Pointer.fromFunction<
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
        Pointer<UA_Variant>)>(_MethodCallBack, 54345);

void _DataChange(
    Pointer<UA_Server> server,
    int monitoredItemId,
    Pointer<Void> monitoredItemContext,
    Pointer<UA_NodeId> nodeid,
    Pointer<Void> nodeContext,
    int attributeId,
    Pointer<UA_DataValue> value) {
  dynamic res = UAVariant.variant2Dart(value.cast<UA_VALUE>().ref.value);
  UAServer._callBackDataChangeServer[server]!(
      ["$server::::${UANodeID.pointer2String(nodeid)}", res]);
}

final _dataChangeCallBack = Pointer.fromFunction<
    Void Function(Pointer<UA_Server>, Uint32, Pointer<Void>, Pointer<UA_NodeId>,
        Pointer<Void>, Uint32, Pointer<UA_DataValue>)>(_DataChange);
