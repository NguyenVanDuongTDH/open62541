import 'dart:ffi';

import '../gen.dart';
import '../open62541_gen.dart';
import 'c.dart';
import 'ua_variable_attributes.dart';

class UAArgument {
  late final Pointer<UA_Argument> attr;
  UAArgument({
    required String name,
    required int uaType,
    int uaValueRank = UA_VALUERANK_SCALAR,
    String? description,
  }) {
    attr = cOPC.UA_Argument_new();
    cOPC.UA_Argument_init(attr);
    setName(name);
    setDataType(uaType);
    setDescription(description);
    setValueRank(uaValueRank);
  }

  void setDescription(String? description) {
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          UAVariableAttributes.en_US.cast(),
          CString.fromString(description).cast());
    }
  }

  void setName(String? name) {
    if (name != null) {
      attr.ref.name = cOPC.UA_String_fromChars(name.toCString().cast());
    }
  }
  int get uaType => _uaType!;
  int? _uaType;

  void setDataType(int uaType) {
    _uaType = uaType;
    attr.ref.dataType = cOPC.UA_GET_TYPES_TYPEID(uaType);
  }

  void setValueRank(int uaValueRank) {
    attr.ref.valueRank = uaValueRank;
  }
}
