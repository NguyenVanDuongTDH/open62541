import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';

class UAQualifiedName {
  int nsIndex;
  String name;

  UA_QualifiedName get ua_qualifiedName_new =>
      cOPC.UA_QUALIFIEDNAME(1, name.toNativeUtf8().cast());

  UAQualifiedName(this.nsIndex, this.name);
}
