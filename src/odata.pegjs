/*
 * Inspired by http://docs.oasis-open.org/odata/odata/v4.01/cs01/abnf/odata-abnf-construction-rules.txt
 */

expression
  = orExpr

// GROUPING
groupingExpr
  = parenExpr

parenExpr
  = "(" value:expression ")" {
      return value;
    }

// PRIMARY

primaryExpr
  = leftExpr
  / rightExpr

leftExpr
  = memberExpr

rightExpr
  = primitive

memberExpr
  = value:odataIdentifier {
      return {
        type: 'memberExpr',
        value,
      };
    }

functionExpr
  = name:odataIdentifier "(" head:primaryExpr tail:("," arg:primaryExpr { return arg; })* ")" {
      return {
        type: 'functionExpr',
        name,
        arguments: [head, ...tail],
      }
    }

// RELATIONAL

relationalExpr
  = functionExpr
  / groupingExpr
  / inExpr
  / eqExpr
  / neExpr
  / gtExpr
  / geExpr
  / ltExpr
  / leExpr

inExpr
  = left:leftExpr SP "in" SP right:arrayExpr {
      return {
        type: 'inExpr',
        left,
        right
      }
    }

eqExpr
  = left:leftExpr SP "eq" SP right:rightExpr {
      return {
        type: 'eqExpr',
        left,
        right,
      };
    }

neExpr
  = left:leftExpr SP "ne" SP right:rightExpr {
      return {
        type: 'neExpr',
        left,
        right,
      };
    }

gtExpr
  = left:leftExpr SP "gt" SP right:rightExpr {
      return {
        type: 'gtExpr',
        left,
        right,
      };
    }

geExpr
  = left:leftExpr SP "ge" SP right:rightExpr {
      return {
        type: 'geExpr',
        left,
        right,
      };
    }

ltExpr
  = left:leftExpr SP "lt" SP right:rightExpr {
      return {
        type: 'ltExpr',
        left,
        right,
      };
    }

leExpr
  = left:leftExpr SP "le" SP right:rightExpr {
      return {
        type: 'leExpr',
        left,
        right,
      };
    }

// CONDITIONAL AND

andExpr
  = left:relationalExpr SP "and" SP right:andExpr {
      return {
        type: 'andExpr',
        left,
        right,
      };
    }
  / relationalExpr

orExpr
  = left:andExpr SP "or" SP right:orExpr {
      return {
        type: 'orExpr',
        left,
        right,
      };
    }
  / andExpr

// TOKENS

arrayExpr
  = "[" head:primitive tail:("," elem:primitive { return elem; })* "]" {
      return {
        type: 'arrayExpr',
        value: [head, ...tail],
      };
    }

primitive
  = string
  / number
  / boolean
  / null

string
  = DQUOTE value:[^"]+ DQUOTE {
      return {
        type: 'primitive',
        value: value.join(''),
      }
    };

number
  = SIGN? DIGIT+ ( "." DIGIT+ )? ( "e"i SIGN? DIGIT+ )? {
      return {
        type: 'primitive',
        value: Number.parseFloat(text()),
      };
    }

boolean
  = value:("true"i / "false"i) {
      return {
        type: 'primitive',
        value: Boolean(value),
      };
    }

null
  = "null" {
      return {
        type: 'primitive',
        value: null,
      };
    }

odataIdentifier
  = $ ( identifierLeadingCharacter identifierCharacter* )

identifierLeadingCharacter
  = ALPHA
  / "_"         // plus Unicode characters from the categories L or Nl

identifierCharacter
  = ALPHA
  / "_"
  / DIGIT // plus Unicode characters from the categories L, Nl, Nd, Mn, Mc, Pc, or Cf

SIGN
  = "+"
  / "-"

ALPHA
  = [\x41-\x5A]
  / [\x61-\x7A]

DIGIT
  = [\x30-\x39]

DQUOTE
  = "\x22"

SP
  = "\x20"
