/// `toJSON!T` converts a instance of `T` to a `JSONValue`
module internal.tojson;

import std.json;
import std.conv;
import std.range;
import std.traits;
import std.string;
import std.algorithm;
import std.exception;
import std.typetuple;
import std.typecons : staticIota;
import internal.attribute;

// Primitive Type Conversions -----------------------------------------------------------
/// convert a bool to a JSONValue
JSONValue toJSON(T : bool)(T val) {
  return JSONValue(val);
}

/// convert a string to a JSONValue
JSONValue toJSON(T : string)(T val) {
  return JSONValue(val);
}

/// convert a floating point value to a JSONValue
JSONValue toJSON(T : real)(T val) if (!is(T == enum)) {
  return JSONValue(val);
}

/// convert a signed integer to a JSONValue
JSONValue toJSON(T : long)(T val) if (isSigned!T && !is(T == enum)) {
  return JSONValue(val);
}

/// convert an unsigned integer to a JSONValue
JSONValue toJSON(T : ulong)(T val) if (isUnsigned!T && !is(T == enum)) {
  return JSONValue(val);
}

/// convert an enum name to a JSONValue
JSONValue toJSON(T)(T val) if (is(T == enum)) {
  JSONValue json;
  json.str = to!string(val);
  return json;
}

/// convert a homogenous array into a JSONValue array
JSONValue toJSON(T)(T args) if (isArray!T && !isSomeString!T) {
  static if (isDynamicArray!T) {
    if (args is null) { return JSONValue(null); }
  }
  JSONValue[] jsonVals;
  foreach(arg ; args) {
    jsonVals ~= toJSON(arg);
  }
  JSONValue json;
  json.array = jsonVals;
  return json;
}

/// convert a set of heterogenous values into a JSONValue array
JSONValue toJSON(T...)(T args) {
  JSONValue[] jsonVals;
  foreach(arg ; args) {
    jsonVals ~= toJSON(arg);
  }
  JSONValue json;
  json.array = jsonVals;
  return json;
}

/// convert a associative array into a JSONValue object
JSONValue toJSON(T)(T map) if (isAssociativeArray!T) {
  assert(is(KeyType!T : string), "toJSON requires string keys for associative array");
  if (map is null) { return JSONValue(null); }
  JSONValue[string] obj;
  foreach(key, val ; map) {
    obj[key] = toJSON(val);
  }
  JSONValue json;
  json.object = obj;
  return json;
}

JSONValue toJSON(T)(T obj) if (!isBuiltinType!T) {
  static if (is (T == class)) {
    if (obj is null) { return JSONValue(null); }
  }
  return obj.convertToJSON();
}
