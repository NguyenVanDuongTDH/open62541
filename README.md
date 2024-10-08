gcc build window
```bash
gcc -std=c99 -shared open62541.c -o open62541.dll -lws2_32 -lIphlpapi -lpthread
```
gcc build linux
```bash
gcc -std=c99 -shared open62541.c -o open62541.so -fPIC
```
git clone
```yaml
git clone https://github.com/NguyenVanDuongTDH/open62541.git
```
