grammar MAS2Java;

// --- rules  ---------------------------------------------------------------------------

mas:
    'MAS' ID '{'
    ( infrastructure )?
    ( environment )?
    (exec_control)?
    agents
    '}'
;

infrastructure:
    'infrastructure' ':' ID
    ;

environment:
    'environment' ':' ID STRING parameters
    ;

parameters:
    '[' parameter_list ']'
    | '[' ']'
    |
    ;

 parameter_list:
    parameter (',' parameter)*
    ;

parameter:
    ID
    | NUMBER
    | '(' parameter_list ')'
    | '[' parameter_list ']'
    ;

exec_control:
    'executionControl' ':' ID
    ('at' ID)?
    ;

agents:
    'agents' ':' (agent)+
    ;

agent:
    ID
    ( FILENAME )?
    ( agt_options )?
    ( agt_arch_class )?
    ( agt_belief_base_class )?
    ( agt_class )?
    ('#' NUMBER)?
    (agt_at)?
    ';'
    ;

agt_options:
    '[' .*? ']'
    ;

agt_arch_class:
    'agentArchClass' ID
    ;

agt_belief_base_class:
    'beliefBaseClass' ID
    ;

agt_class:
    'agentClass' ID
    ;

agt_at:
    'at' ID
    ;

// --- terminal symbols -----------------------------------------------------------------
NUMBER:
    INT_PART DOT DEC_PART
    | INT_PART
    ;

 FILENAME:
    [a-zA-Z0-9_/]+'.'[A-Za-z0-9]+
    ;

 STRING:
    '"' ~('"')* '"'
    | '\'' ~('\'')* '\''
    ;

ID: (LC_LETTER | UP_LETTER)+( LC_LETTER | UP_LETTER | DIGIT | '_' )*;

fragment INT_PART: DIGIT+;
fragment DEC_PART: DIGIT+;
fragment DOT: '.';

fragment LC_LETTER :
    [a-z]
    ;

fragment UP_LETTER :
    [A-Z]
    ;

fragment DIGIT:
    [0-9]
    ;

// --- skip items -----------------------------------------------------------------------

WS: // while space
   (' ' | '\t' | '\n' | '\r')+ -> skip
   ;
