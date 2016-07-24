badPathError = (name, moreNames...) ->
  Object.assign new Error,
    brokeAt: badPath = [name, moreNames...]
    validPath: []
    sym: badPathError.sym
    update: ->
      Object.assign badPathError @breakAt
        message:
          [ "Invalid name:",  "  " + JSON.stringify @brokeAt
            "Valid portion:", "  " + JSON.stringify @validPath
          ].join "\n"
        {@brokeAt, @validPath}

badPathError.sym = Symbol()


descend = (nameSpace, name, moreNames..., value, fn) ->
  if moreNames?.length is 0
    (fn.leaf or fn) nameSpace, name, value

  if 'object' isnt typeof value or value is null
    return fn.brokenBranch?(nameSpace, name, moreNames..., value) or
      throw badPathError name, moreNames...

  if not name in Object.getOwnPropertyNames nameSpace
    return fn.missingBranch?(nameSpace, name, moreNames..., value) or
      throw badPathError name, moreNames...

  try
    descend nameSpace[name], moreNames..., value, fn
  catch e
    if e.sym is badPathError.sym
      e = e.update()

    throw e

createAll = (nameSpace, path...) ->
  nameSpace = nameSpace[name] = {} for name in path

create = (nameSpace, path..., value) ->
  descend nameSpace, path..., [value],
    missingBranch:
      (parent, branchName, moreNames..., lastName, value) ->
        (parent[branchName] = createAll {}, moreNames...)[lastName] = value

    leaf: (leaf, [lastName, value]) ->
      if leaf isnt undefined
        throw new Error "key already exists"

      leaf[name] = value

  nameSpace


read = (nameSpace, name, moreNames...) ->
  descend nameSpace, name, moreNames..., [],
    (end, []) -> end


update = (nameSpace, name, moreNames..., lastName, value) ->
  descend nameSpace, name, moreNames..., [lastName, value],
    missingBranch: ->
      throw new Error "key doesn't exist"

    leaf: (leaf, [lastName, value]) ->
      if leaf is undefined
        throw new Error "key doesn't exist"

      [was, leaf[name] = [leaf[name], value]
      return was


del = (nameSpace, name, moreNames..., lastName) ->
  descend nameSpace, name, moreNames..., [lastName]),
    missingBranch: -> false
    leaf: (leaf, [name]) ->
      delete leaf[name]


set = (args...) ->
  [nameSpace] = args

  try
    was = update args...
    return was
  catch e
    if e.message is "key doesn't exist"
      create args...
    else
      throw e

  return undefined

module.exports = {create, read, update, set, del}
