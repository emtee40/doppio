
_ = require '../vendor/_.js'
util = require './util'
types = require './types'
{vtrace} = require './logging'
{java_throw} = require './exceptions'

"use strict"

# things assigned to root will be available outside this module
root = exports ? window.java_object ?= {}

class root.JavaArray
  constructor: (@type, rs, obj) ->
    @ref = rs.high_oref++
    @array = obj

  clone: (rs) ->
    # note: we don't clone the type, because they're effectively immutable
    new root.JavaArray @type, rs, _.clone(@array)

  get_field_from_offset: (rs, offset) -> @array[offset.toInt()]
  set_field_from_offset: (rs, offset, value) -> @array[offset.toInt()] = value

  toString: ->
    if @array.length <= 10
      "<#{@type} [#{@array}] (*#{@ref})>"
    else
      "<#{@type} of length #{@array.length} (*#{@ref})>"


class root.JavaObject
  constructor: (@type, rs, obj={}) ->
    @ref = rs.high_oref++
    # Object.create(null) avoids interference with Object.prototype's properties
    @fields = Object.create null
    # init fields from this and inherited ClassFiles
    t = @type
    while t?
      cls = rs.class_lookup t
      for f in cls.fields when not f.access_flags.static
        val = util.initial_value f.raw_descriptor
        slot_val = @fields[f.name]
        if slot_val isnt undefined
          # Field shadowing.
          if slot_val?.$first is undefined
            @fields[f.name] = slot_val = {$first: slot_val}
          slot_val[t.toClassString()] = val
        else
          @fields[f.name] = val
      t = cls.super_class

    # init fields from manually given object
    for k in Object.keys obj
      v = obj[k]
      slot_val = @fields[k]
      if slot_val?.$first isnt undefined
        slot_val.$first = v
      else
        @fields[k] = v

  clone: (rs) ->
    # note: we don't clone the type, because they're effectively immutable
    new root.JavaObject @type, rs, _.clone(@fields)

  set_field: (rs, name, val, for_class) ->
    slot_val = @fields[name]
    if slot_val is undefined
      java_throw rs, 'java/lang/NoSuchFieldError', name
    else if slot_val?.$first is undefined  # not shadowed
      @fields[name] = val
    else if not for_class? or slot_val[for_class] is undefined
      slot_val.$first = val
    else
      slot_val[for_class] = val
    return

  get_field: (rs, name, for_class) ->
    slot_val = @fields[name]
    if slot_val is undefined
      java_throw rs, 'java/lang/NoSuchFieldError', name
    else if slot_val?.$first is undefined
      slot_val
    else if not for_class? or slot_val[for_class] is undefined
      slot_val.$first
    else
      slot_val[for_class]

  get_field_from_offset: (rs, offset) ->
    f = rs.get_field_from_offset rs.class_lookup(@type), offset.toInt()
    if f.access_flags.static
      return rs.static_get({class:@type.toClassString(),name:f.name})
    @get_field rs, f.name

  set_field_from_offset: (rs, offset, value) ->
    f = rs.get_field_from_offset rs.class_lookup(@type), offset.toInt()
    if f.access_flags.static
      rs.push value
      rs.static_put({class:@type.toClassString(),name:f.name})
    else
      @set_field rs, f.name, value

  toString: ->
    if @type.toClassString() is 'java/lang/String'
      "<#{@type} '#{@jvm2js_str()}' (*#{@ref})>"
    else
      "<#{@type} (*#{@ref})>"

  # Convert a Java String object into an equivalent JS one.
  jvm2js_str: ->
    util.chars2js_str(@fields.value, @fields.offset, @fields.count)


class root.JavaClassObject extends root.JavaObject
  constructor: (rs, @$type, @file) ->
    super types.c2t('java/lang/Class'), rs

  toString: -> "<Class #{@$type} (*#{@ref})>"

root.thread_name = (rs, thread) ->
  util.chars2js_str thread.get_field rs, 'name', 'java/lang/Thread'
