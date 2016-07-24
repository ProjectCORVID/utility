assert = require 'assert'

module.exports = (namespace) ->
  {create, read, update, del, set} = namespace

  baz = Symbol 'baz'
  ns = create {}, 'foo bar'.split ' ', baz
  assert foo.bar is baz

  try
    e = undefined
    update ns, 'blarg', 'should throw'
  catch e

  assert e

  bumble = Symbol 'bumble'
  update ns, 'foo', 'bar', bumble
  assert foo.bar is bumble

  try
    e = undefined
    create ns, 'foo', 'bar', 'should throw'
  catch e

  assert e

