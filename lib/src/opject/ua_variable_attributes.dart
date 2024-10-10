import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:open62541/open62541.dart';
import 'package:open62541/src/open62541_gen.dart';
import 'package:open62541/src/opject/c.dart';

class UAVariableAttributes {
  late final Pointer<UA_VariableAttributes> attr;
  UAVariableAttributes() {
    attr = cOPC.UA_VariableAttributes_new();
    cOPC.UA_VariableAttributes_init(attr);
    final res = cOPC.UA_VariableAttributes_default;
    attr.ref = res;
    attr.ref.accessLevel = 255;
  }
  void delete() {
    // cOPC.UA_VariableAttributes_deleteMembers(attr);
    cOPC.UA_VariableAttributes_delete(attr);
  }

  void setVariant(UAVariant variant) {
    attr.ref.value = variant.variant.cast<UA_Variant>().ref;
    attr.ref.dataType = cOPC.UA_GET_TYPES_TYPEID(
        cOPC.UA_GET_TYPES_INTDEX(variant.variant.cast<UA_Variant>().ref.type));
    // attr.ref.dataType = cOPC.UA_GET_TYPES_TYPEID( UATypes.INT64);
    // print(" ${UATypes.INT64} == ${cOPC.UA_GET_TYPES_INTDEX(variant.variant.cast<UA_Variant>().ref.type)} ");
  }

  static int get READ => UA_ACCESSLEVELMASK_READ;
  static int get WRITE => UA_ACCESSLEVELMASK_WRITE;

  void setAsset(int access) {
    // attr.ref.userAccessLevel = access;
  }

  static final en_US = "en-US".toNativeUtf8();

  void setDescription(String? description) {
    if (description != null) {
      attr.ref.description = cOPC.UA_LOCALIZEDTEXT(
          en_US.cast(), description.toNativeUtf8().cast());
    }
  }

  void setDisplayName(String? displayName) {
    if (displayName != null) {
      attr.ref.displayName = cOPC.UA_LOCALIZEDTEXT(
          en_US.cast(), displayName.toNativeUtf8().cast());
    }
  }
}
