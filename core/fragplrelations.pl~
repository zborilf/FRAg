
%
% 	FragPL, raltion acts processing (+ assignment)
%       Frantisek Zboril jr. 2021 - 2022
%	
%


%
%	relations, arithmetic (these actions are implicit to the agent)
%	these relations reduce plan context  
%

relational_operator(>=).
relational_operator(=<).
relational_operator(<).
relational_operator(>).
relational_operator(=).
relational_operator(==).

%
% 	fRAgTerm(+TermIn, +List, -TermOut)
% 	TermIn is either number, expression reducable to number, or variable bounded to a term in List
%

is_relational_operator(Atom):-
    relational_operator(Atom).


get_term(Atom, _, Atom):-	
    number(Atom).

get_term(Atom, [], Number):-	
    Number is eval(Atom), number(Number).

get_term(_, [], _):-	
    !, fail.

get_term(V1, [V2 = TM| _], TM):-
    V1 == V2.

get_term(V, [_ | T], TM):-
    get_term(V, T, TM).	


%
%	RELATIONS (as a part of arithmetical / relational operations)
% 	aloprel(+Operator,+Term1,+Term2,+ContextIn,-ContextOut)
%	Performs the operation for all term instances by Context, the output context corresponds to the operation performed 
% 	For example, for a relation > , the output context will contain only those substitutions that match it, 
%	e.g. A>B, [ [[A=3],[B=5]], [[A=5],[B=3]] , [[A=2],[B=0]] ] -> [ [[A=5],[B=3]] , [[A=2],[B=0]] ]
% 
                
non_empty_context([], false).

non_empty_context(_, true).

     
alopreltry(Operator, Operand1, Operand2, Context, Contexts, 
           [Context |Contexts]):-
    apply(Operator, [Operand1, Operand2]).

alopreltry(_ ,_ ,_ ,_ , Contexts, Contexts).


aloprel(_,_,_,[],[]).
                                                                                                                              
aloprel(Operator, Operand1, Operand2, [HCTX|TCTX], LOUT):-
    get_term(Operand1, HCTX, TERM1),
    get_term(Operand2, HCTX, TERM2),
    aloprel(Operator, Operand1, Operand2, TCTX, TCTX2),
    alopreltry(Operator, TERM1, TERM2, HCTX, TCTX2, LOUT).

aloprel(Operator, Operand1, Operand2, [ _| Contexts], Contexts2):-
    aloprel(Operator, Operand1, Operand2, Contexts, Contexts2).


%
%	
%

membervo(A, [B=_|_]):-
    A==B.

membervo(_,_).


evolveContext(A, _, CTX, CTX):-
% after applying the substitution, the left side became a number, so in the 
% context, if there was a variable on the left, there is an assignment, or 
% there was a number
    number(A).   		   		

% ... anyway, we do not add anything to the context
evolveContext(_, B=C, CTX, [B=C|CTX]).     	% left side variable that did not have a pair in the context, expand the context according to the result of the operation



alop3(E,A,C,D,CTX1,CTX2):-
    C is D,			% suceeded
    evolveContext(E, A=C, CTX1,CTX2).

alop3(_,_,_,_,_,[]).


alop2(A is B,CTX1,CTX3):-
    !,
    copy_term([A,B,CTX1],[C,D,CTX2]),
    % we have to remember the renaming, we rely on term_variables to always return the variables in the same order
    apply_substitutions(CTX2), % X should be instantiated,
    copy_term(C,E),   % to test later whether the left side was already numbered after the substitution
    alop3(E,A,C,D,CTX1,CTX3).

alop2(_ is _,_,[]).				


alop(_ is _,[],[], true).

alop(A is B, [H| T],[H2| T2], true):-
    alop2(A is B,H,H2),
    length(H2,L),L>0,
    alop(A is B,T,T2, _).			

alop(A is B,[_|T],T2, true):-
    alop(A is B,T,T2, _).			



alop(A ,Context1 ,Context2 , Result):-	
    A=..[Operator, Operand1, Operand2],	
    relational_operator(Operator),
    aloprel(Operator, Operand1, Operand2, Context1, Context2),
    non_empty_context(Context2, Result).

       