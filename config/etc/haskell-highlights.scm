; Haskell highlights, forked from nvim-treesitter's queries/haskell/highlights.scm.
; Changes from upstream:
; - every top-level definition (and anything with a signature) is a function,
;   only local bindings without a signature are variables
; - no guessing from names: no hard-coded functions highlighted as
;   keywords/booleans (throwIO, trace, otherwise, ...) and no hard-coded
;   operators ($, ., >>>, ...) making their operands functions.
;   Only definitions and the head of an application (`f x`) are functions.
; - dropped rules that were dead or only undid other rules

; ----------------------------------------------------------------------------
; Parameters and variables
; NOTE: These are at the top, so that they have low priority,
; and don't override destructured parameters
(variable) @variable

(decl/function
  patterns: (patterns
    (_) @variable.parameter))

(expression/lambda
  patterns: (patterns
    (_) @variable.parameter)
  "->")

(decl/function
  (infix
    (pattern) @variable.parameter))

; ----------------------------------------------------------------------------
; Literals and comments
(integer) @number

(negation) @number

(expression/literal
  (float)) @number.float

(char) @character

(string) @string

(comment) @comment

(haddock) @comment.documentation

; ----------------------------------------------------------------------------
; Punctuation
[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
] @punctuation.delimiter

; ----------------------------------------------------------------------------
; Keywords, operators, includes
[
  "forall"
  "∀" ; utf-8 is not cross-platform safe
] @keyword.repeat

(pragma) @keyword.directive

[
  "if"
  "then"
  "else"
  "case"
  "of"
] @keyword.conditional

[
  "import"
  "qualified"
  "module"
] @keyword.import

[
  (operator)
  (constructor_operator)
  (all_names)
  "."
  ".."
  "="
  "|"
  "::"
  "=>"
  "->"
  "<-"
  "\\"
  "`"
  "@"
] @operator

(wildcard) @character.special

(module
  (module_id) @module)

[
  "where"
  "let"
  "in"
  "class"
  "instance"
  "pattern"
  "data"
  "newtype"
  "family"
  "type"
  "as"
  "hiding"
  "deriving"
  "via"
  "stock"
  "anyclass"
  "do"
  "mdo"
  "rec"
  "infix"
  "infixl"
  "infixr"
] @keyword

; ----------------------------------------------------------------------------
; Functions and variables
(decl/signature
  [
    name: (variable) @function
    names: (binding_list
      (variable) @function)
  ])

(decl/function
  [
    name: (variable) @function
    names: (binding_list
      (variable) @function)
  ])

(decl/bind
  [
    name: (variable) @function
    names: (binding_list
      (variable) @function)
  ])

; Only consider local bindings without a signature as variables,
; top-level definitions are always functions
(local_binds
  (decl/bind
    name: (variable) @variable))

(decl/bind
  name: (variable) @function
  (match
    expression: (expression/lambda)))

; view patterns
(view_pattern
  [
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
  ])

; consider infix functions as operators
(infix_id
  [
    (variable) @operator
    (qualified
      (variable) @operator)
  ])

(apply
  function: [
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
  ])

; scoped function types (func :: a -> b)
(signature
  pattern: (pattern/variable) @function
  type: (function))

; local bindings that have a signature
((decl/signature
  name: (variable) @_name)
  .
  (decl/bind
    name: (variable) @function)
  (#eq? @function @_name))

; ----------------------------------------------------------------------------
; Types
(name) @type

(type/unit) @type

(type/unit
  [
    "("
    ")"
  ] @type)

(type/list
  [
    "["
    "]"
  ] @type)

(type/star) @type

(constructor) @constructor

; True or False
((constructor) @boolean
  (#any-of? @boolean "True" "False"))

; ----------------------------------------------------------------------------
; Quasi-quotes
(quoter) @function.call

(quasiquote
  quoter: [
    (quoter) @_name
    (quoter
      (qualified
        id: (variable) @_name))
  ]
  (#eq? @_name "qq")
  body: (quasiquote_body) @string)

; namespaced quasi-quoter
(quoter
  [
    (variable) @function.call
    (_
      (module) @module
      .
      (variable) @function.call)
  ])

; Highlighting of quasiquote_body for other languages is handled by injections.scm
; ----------------------------------------------------------------------------
; Fields
(field_name
  (variable) @variable.member)

(import_name
  (name)
  .
  (children
    (variable) @variable.member))

; ----------------------------------------------------------------------------
; Spell checking
(comment) @spell
