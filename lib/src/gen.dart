import 'dart:ffi';
import 'open62541_gen.dart';
NativeLibrary cOPC = NativeLibrary(DynamicLibrary.open("open62541.dll"));