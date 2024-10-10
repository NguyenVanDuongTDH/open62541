#include "open62541.h"
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/*                                  UA_TYPES                                     */

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
UA_EXPORT const UA_DataType *
UA_FFI_GET_TYPES_FROM_INDEX(int index) {
    return &UA_TYPES[index];
}

UA_EXPORT UA_NodeId
UA_FFI_GET_TYPEID_FROM_INDEX(int index) {
    return UA_TYPES[index].typeId;
}

UA_EXPORT UA_NodeId
UA_FFI_GET_TYPEID_FROM_TYPES(UA_DataType *type) {
    for(int i = 0; i < UA_TYPES_COUNT; i++) {
        if(&UA_TYPES[i] == type) {
            return UA_TYPES[i].typeId;
        }
    }
}

UA_EXPORT int 
UA_FFI_GET_INTDEX_FROM_TYPES(UA_DataType *type) {
    for(int i = 0; i < UA_TYPES_COUNT; i++) {
        if(&UA_TYPES[i] == type) {
            return i;
        }
    }
    return -1;
}

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/*                                  UA_CLIENT_CALL_METHOD                         */

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

typedef void (*UA_FFI_Callback_method_async)(UA_Client *client, void *userdata,
                                         UA_UInt32 requestId, UA_Variant *response);


UA_FFI_Callback_method_async _callBack;

UA_EXPORT void
UA_FFI_Client_callBack_method(UA_Client *client, void *userdata, UA_UInt32 requestId,
             UA_CallResponse *response) {
    _callBack(client, userdata, requestId, response->results[0].outputArguments);
    UA_CallResponse_clear(response);
}

UA_EXPORT UA_StatusCode
UA_FFI_Client_call_async(UA_Client *client, const UA_NodeId objectId, const UA_NodeId methodId, size_t inputSize, 
const UA_Variant *input, UA_FFI_Callback_method_async callBack, void *userdata, UA_UInt32 *reqId) {
    _callBack = callBack;
  return  UA_Client_call_async(client, objectId,
                         methodId, inputSize, input, UA_FFI_Client_callBack_method, userdata, reqId);
}


//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/*                                  UA_SERVER_METHOD_CALL                         */

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------


UA_EXPORT void
UA_FFI_Server_call_result(UA_Server *server, const UA_AsyncOperationRequest **request, void *context,  UA_Variant *out) {
    UA_CallMethodResult response =
        UA_Server_call(server, &(*request)->callMethodRequest);
    UA_Variant_copy(out, response.outputArguments);
    response.outputArgumentsSize = 1;
    UA_Server_setAsyncOperationResult(
                server, (UA_AsyncOperationResponse *)&response, context);
    UA_CallMethodResult_clear(&response);
    
}

UA_EXPORT UA_CallMethodResult* UA_FFI_Server_call(UA_Server *server,
const UA_AsyncOperationRequest **request)
{
    UA_CallMethodResult response =
        UA_Server_call(server, &(*request)->callMethodRequest);
    UA_CallMethodResult *res = UA_CallMethodResult_new();
    UA_CallMethodResult_copy(&response,res);
    return res;
}

UA_EXPORT void UA_FFI_Server_setAsyncOperationResult(UA_Server *server, UA_CallMethodResult *response, void *context){
    UA_Server_setAsyncOperationResult(
                server, (UA_AsyncOperationResponse *)&response, context);
}






//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/*                                  UA_SERVER_METHOD_CALL                         */

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------


UA_EXPORT int
UA_CLIENT_WriteResponse_STATUS(UA_WriteResponse *res) {
    if(res == NULL) {
        return -1;
    } else {
        if(res->results == NULL) {
            return -1;
        } else {
            return *(int *)res->results;
        }
    }
}


UA_EXPORT void * UA_FFI_Client_Subscriptions_create(UA_Client *client,
                               const UA_CreateSubscriptionRequest request,
                               void *subscriptionContext,
                               UA_Client_StatusChangeNotificationCallback statusChangeCallback,
                               UA_Client_DeleteSubscriptionCallback deleteCallback){

                                UA_CreateSubscriptionResponse * res = UA_CreateSubscriptionResponse_new();
                                *res = UA_Client_Subscriptions_create(
                                    client,
                                request,
                                subscriptionContext,
                                statusChangeCallback,
                                deleteCallback
                                );
                                return res;
                               }

UA_EXPORT int UA_FFI_Client_SubSubscriptions_Check(UA_CreateSubscriptionResponse* response){
    if(response->responseHeader.serviceResult == 0){
        return response->subscriptionId;
    }
    else return -1;
}


 



UA_EXPORT void UA_FFI_Server_run_iterate_void(UA_Server *server, UA_Boolean waitInternal){
    UA_Server_run_iterate(server, waitInternal);
}

UA_EXPORT void UA_FFI_Client_run_iterate_void(UA_Client *client, UA_UInt32 timeout){
    UA_Client_run_iterate(client,timeout);
}


