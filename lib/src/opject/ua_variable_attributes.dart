import 'dart:ffi';

import 'package:open62541/src/opject/c.dart';

import '../open62541_gen.dart';
import 'opc_variant.dart';

class UAVariableAttributes {
  late final Pointer<UA_VariableAttributes> attr;
  UAVariableAttributes() {
    attr = cOPC.UA_VariableAttributes_new2();
  }

  void setVariant(UAVariant variant) {
    attr.ref.value = variant.variant.ref;
    attr.ref.dataType =
        cOPC.UA_GET_TYPES_ID(cOPC.UA_GET_TYPES(variant.variant.ref.type));
  }

  static int get READ => UA_ACCESSLEVELMASK_READ;
  static int get WRITE => UA_ACCESSLEVELMASK_WRITE;

  void setAsset(int access) {
    attr.ref.userAccessLevel |= access;
  }

  static final _en_US = "en-US".toCString();

  void setDescription(String? description) {
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          _en_US.cast(), CString.fromString(description).cast());
    }
  }

  void setDisplayName(String? displayName) {
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          _en_US.cast(), CString.fromString(displayName).cast());
    }
  }
}
