{create, read} = require '../namespace'

symbolLibrary = (parts...) ->
  try
    read symbolLibrary, parts...
  catch e
    create symbolLibrary, parts..., sym = Symbol parts.join "::"

module.exports = SymbolicMethods =
  symGen: symbolLibrary

  transform: (definer, prefix, namespace, nameGen = symbolLibrary) ->
    if namespace is undefined
      namespace = definer
      deleteOriginal = true

    for startName, descriptor of Object.getOwnPropertyDescriptors definer
      if startName.startsWith prefix
        className = definer[classNameSym]
        endName   = startName.substr prefix.length
        realName  = nameGen className, endName

        namespace[realName] = definer[startName]

        delete definer[startName] if deleteOriginal
