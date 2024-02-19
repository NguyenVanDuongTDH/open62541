import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

class UAQualifiedName {
  int nsIndex;
  String name;

  UA_QualifiedName get ua_qualifiedName_new =>
      cOPC.UA_QUALIFIEDNAME(1, name.toCString().cast());

  UAQualifiedName(this.nsIndex, this.name);
}
