
    SymbolicMethods = require './symbol'

# WithRoles

WithRoles is the base class for classes which are extended with Roles.

_(Get it? 'class Foo extends WithRoles'! LOL)_

Calls to WithRoles instances look like

  instance[context].methodName args...


    class WithRoles extends SymbolicMethods
      constructor: ->
        super "WithRoles"

      _addRole: (role) ->
        this[ctx] = role[Role.overriding] this[ctx]

      _removeRole: (ctx, roleToRemove) ->
        this[ctx] = this[ctx]?[Role.removeRole] roleToRemove

    SymbolicMethods.transform WithRoles, '_'

# Context

For now contexts will just be strings. Later they might be symbols or
something fancier.

# Role

The Role class adds or amends the behavior of a WithRoles. A role has a
Context it operates within. When a WithRoles has two roles in the same Context
with the same method name, the most recently added Role receives that method
call first and then may pass the message on to less recently added roles by
calling @nextRole[methodName].

    class Role extends SymbolicMethods
      constructor: (@context, @name) ->
        super "Role"

    SymbolicMethods.transform Role, '', Role,
      createInstance: (these, nextRole) ->
        instance = Object.create @prototype,
          props readonly: {these, constuctor: this}

        return instance._initInstance() ? instance

      initInstance: ->

      overriding: (@nextRole) ->

      removeRole: (roleToRemove) ->
        if @name in [roleToRemove, roleToRemove?.name]
          try
            this[Role.leavingInstance] ()

          return @nextRole
 
        if @nextRole
          @nextRole = @nextRole[Role.removeRole] roleToRemove

        return this

      leavingInstance: ->

# Prop maker

This is ugly and needs to be somewhere else

    props = (props) ->
      descriptor = {}

      for flag, namesAndValues of props
        for name, value of namesAndValues
          descriptor[name] = this[flag] value

      descriptor

    props.readonly = (value) ->
      value: value
      configurable: false
      writeable: false
      enumerable: false


