gcc -std=c99 open62541.c -o main.exe -lws2_32 -lIphlpapi


gcc -std=c99 -shared open62541.c -o open62541.dll  -lws2_32 -lIphlpapi


gcc -std=c99 -shared open62541.c -o open62541.so -fPIC

test
