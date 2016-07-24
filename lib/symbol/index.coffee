deepAssign = require './deepAssign'

symbolLibrary = (parts...) ->
  deepAssign.ifUndefined symbolLibrary,
    parts..., sym = Symbol parts.join "::"

  return sym

module.exports = SymbolicMethods =
  symGen: symbolLibrary
  transform: (definer, prefix, namespace, nameGen = symbolLibrary) ->

    for startName, descriptor of Object.getOwnPropertyDescriptors definer
      if startName.startsWith prefix
        className = definer[classNameSym]
        endName   = startName.substr prefix.length
        realName  = nameGen className, endName

        namespace[realName] = definer[startName]
