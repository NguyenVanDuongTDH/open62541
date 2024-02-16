

#include "open62541.h"


UA_EXPORT int UA_GET_TYPES(UA_DataType *type)
{
    for (int count = 0; count < 235 + 1; count++)
    {
        if (type == &UA_TYPES[count])
        {
            return count;
        }
    }
    return -1;
}
UA_EXPORT UA_DataType* UA_GET_TYPES_PTR(int typeNumber)
{
    
    return &UA_TYPES[typeNumber];
}

UA_EXPORT int UA_FIND_TYPE(UA_Client *client,UA_NodeId nodeId){

    // Lấy thông tin kiểu dữ liệu từ server
    UA_ReadRequest request;
    UA_ReadRequest_init(&request);
    request.nodesToRead = UA_ReadValueId_new();
    request.nodesToReadSize = 1;
    request.nodesToRead[0].nodeId = nodeId;
    request.nodesToRead[0].attributeId = UA_ATTRIBUTEID_VALUE;

    UA_ReadResponse response = UA_Client_Service_read(client, request);
    int res = -1;
    if(response.responseHeader.serviceResult == UA_STATUSCODE_GOOD &&
       response.resultsSize > 0 && response.results[0].hasValue) {
        res = UA_GET_TYPES(response.results[0].value.type);
    } 

    UA_ReadRequest_deleteMembers(&request);
    UA_ReadResponse_deleteMembers(&response);
    return res;
}