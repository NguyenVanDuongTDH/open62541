import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/gen.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Client>, Map<int, Completer>> _callBack = {};

Future<dynamic> Client_Method_call_async(
  Pointer<UA_Client> client,
  UANodeId methodId,
  int inputSize,
  UAVariant input,
) async {
  Pointer<UA_UInt32> reqId = cOPC.UA_UInt32_new();
  int rev = cOPC.UA_Client_call_async(
      client,
      UANodeId(0, UA_NS0ID_OBJECTSFOLDER).nodeId,
      methodId.nodeId,
      inputSize,
      input.variant,
      _UAClientMethodCallbackPtr,
      Pointer.fromAddress(0),
      reqId);
  if (rev == 0) {
    final compile = Completer();
    _callBack[client] ??= {};
    _callBack[client]![reqId.value] = compile;
    compile.future.timeout(const Duration(milliseconds: 1000), onTimeout: () {
      compile.completeError("TimeOut");
    });
    return compile.future;
  }
}

void _UAClientMethodCallBack(Pointer<UA_Client> client, Pointer<Void> userData,
    int requestID, Pointer<UA_CallResponse> response) {
  print("_UAClientMethodCallBack");
  _callBack[client]![requestID]!.complete("Call Method Succes");
  _callBack[client]!.remove(requestID);
}

final _UAClientMethodCallbackPtr = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Pointer<Void>, Uint32,
        Pointer<UA_CallResponse>)>(_UAClientMethodCallBack);

dynamic Client_Method_call(
  Pointer<UA_Client> client,
  UANodeId methodId,
  UAVariant input,
) {
  Pointer<Size> outputSsize = calloc.allocate(1);
  Pointer<Pointer<UA_Variant>> output = calloc.allocate(1);
  UAVariant variant = UAVariant();
  final p = cOPC.UA_Client_call(
      client.cast(),
      UANodeId(0, UA_NS0ID_OBJECTSFOLDER).nodeId,
      UANodeId(1, 10).nodeId,
      1,
      input.variant,
      outputSsize,
      output);
  // print("outputSsize ${outputSsize.value}");
  if (p == 0) {
    final res = UAVariant(output.value);
    final val = res.data;
    calloc.free(outputSsize);
    res.clear();
    res.delete();
    calloc.free(output);
    return val;
  } else {
    calloc.free(outputSsize);
    calloc.free(output);
    return null;
  }
}
