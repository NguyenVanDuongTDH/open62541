import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

Map<Pointer<UA_Client>, Map<int, Completer>> _callBack = {};

Future<dynamic> Client_Method_call_async(
  Pointer<UA_Client> client,
  UANodeId methodId,
  UAVariant input,
) async {
  Pointer<Uint32> reqId = calloc.allocate(1);
  try {
    int rev = cOPC.UA_FFI_Client_call_async(
        client.cast(),
        UANodeId(0, UA_NS0ID_OBJECTSFOLDER).nodeId,
        methodId.nodeId,
        1,
        input.variant,
        _UAClientMethodCallbackPtr,
        Pointer.fromAddress(0),
        reqId);

    if (rev == 0) {
      final compile = Completer();
      _callBack[client] ??= {};
      _callBack[client]![reqId.value] = compile;
      compile.future.timeout(const Duration(milliseconds: 3000), onTimeout: () {
        compile.completeError(Exception("TimeOut ReadNodeId Async"));
        _callBack[client]!.remove(reqId.value);
      });
      return _callBack[client]![reqId.value]!.future;
    } else {
      return null;
    }
  } finally {
    calloc.free(reqId);
    methodId.delete();
  }
}

void _UAClientMethodCallBack(Pointer<UA_Client> client, Pointer<Void> userData,
    int requestID, Pointer<UA_Variant> response) {
  _callBack[client]![requestID]!.complete(UAVariant(response).data);
  _callBack[client]!.remove(requestID);
}

final _UAClientMethodCallbackPtr = Pointer.fromFunction<
    Void Function(Pointer<UA_Client>, Pointer<Void>, Uint32,
        Pointer<UA_Variant>)>(_UAClientMethodCallBack);
