App.RESTAdapter.registerTransform 'array',
  deserialize: (serialized) ->
    if Em.isNone(serialized) then [] else serialized
  serialize: (deserialized) ->
    if Em.isNone(deserialized) then [] else deserialized

App.RESTAdapter.registerTransform 'object',
  deserialize: (serialized) ->
    if Em.isNone(serialized) then {} else serialized
  serialize: (deserialized) ->
    if Em.isNone(deserialized) then {} else deserialized
