grammar AgentSpeak;

// --- rules  ---------------------------------------------------------------------------

agent:
    init_bels init_goals plans '.'
    ;

init_bels:
    beliefs rules
    ;

beliefs:
    ( literal '.' )*
    ;

rules:
    ( literal ':-' log_expr '.')*
    ;

init_goals:
    ( '!' literal '.' )*
    ;

plans:
    ( plan )*
    ;

plan: 
    ('@' atomic_formula )? triggering_event
    (':' context )?
    ( '<-' body )? '.'
    ;

triggering_event:
    ( '+' | '-' ) ( '!' | '?' )? literal
    ;

literal:
    '~'? atomic_formula
    ;

context:
    log_expr | 'true'
    ;

log_expr:
    simple_log_expr
    | 'not' log_expr
    | log_expr '&' log_expr
    | log_expr '|' log_expr
    | '(' log_expr ')'
    ;

simple_log_expr:
    ( literal | rel_expr | VAR )
    ;

body: 
    body_formula ( ';' body_formula )*
    ;

body_formula:
    ( '!' | '!!' | '?' | '+' | '-' | '-+' ) literal
    | atomic_formula
    | VAR
    | rel_expr
    ;

atomic_formula:
    ( ATOM | VAR )
    ( '(' list_of_terms ')' )?
    ( '[' list_of_terms ']' )?
    ;

list_of_terms:
    term ( ',' term )*
    ;

term:
    literal
    | list_structure
    | arithm_expr
    | VAR
    | STRING
    ;

list_structure:
    '[' ( term ( ',' term )* ( '|' ( list_structure | VAR ) )? )? ']'
    ;

rel_expr:
    rel_term
    ( ('<' | '<=' | '>' | '>=' | '==' | '\\==' | '=' | '=..') rel_term )*
    ;

rel_term: 
    literal | arithm_expr
    ;

arithm_expr:
    arithm_term
    ( ( '+' | '-' | '*' | '**' | '/' | 'div' | 'mod' )
    arithm_term )*
    ;

arithm_term:
    NUMBER
    | VAR
    | '-' arithm_term
    | '(' arithm_expr ')'
    ;

// --- terminal symbols -----------------------------------------------------------------

ATOM: 
    LC_LETTER | '.' CHAR (CHAR | '.' CHAR)*
    | '\'' (~['])* '\''
    ;

VAR: 
    LC_LETTER (CHAR)*
;

CHAR:
    LETTER
    | DIGIT 
    | '_'
;

LETTER:
    LC_LETTER
    | UP_LETTER
    ;

LC_LETTER :
    [a-z]
;

UP_LETTER : 
    [A-Z]
    ;

DIGIT:
    [0-9]
    ;

STRING:
    '"' ~('"')* '"'
    | '\'' ~('\'')* '\''
    ;

NUMBER:
    DIGIT (DIGIT)*
    | (DIGIT)* '.' (DIGIT)+ ([eE] ([+-])? (DIGIT)+)?
    | (DIGIT)+ ([eE] ([+-])? (DIGIT)+)
    ;


// --- skip items -----------------------------------------------------------------------

WS: // while space
   (' ' | '\t' | '\n' | '\r')+ -> skip
   ;

LC:  // line comment
    ('//' | '#') .*? '\r'? '\n' -> skip
    ;

BC: // block comment
    '/*' .*? '*/' -> skip
    ;
