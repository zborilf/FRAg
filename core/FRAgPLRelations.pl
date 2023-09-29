
%
%	FragPL, raltion acts processing (+ assignment)
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
%	fRAgTerm(+TermIn, +List, -TermOut)
%       TermIn is either number, expression reducable to number, or
%       variable bounded to a term in List
%

is_relational_operator(Atom):-
    relational_operator(Atom).


get_term(Atom, _, Atom):-
    number(Atom).

get_term(Atom, [], Number):-
    Number is eval(Atom), number(Number).

get_term(_, [], _):-
    !, fail.

get_term(Var1, [Var2 = Term| _], Term):-
    Var1 == Var2.

get_term(Var, [_ | Bindings], Term):-
    get_term(Var, Bindings, Term).


%!  aloprel(+Operator, +Term1, +Term2, +ContextIn, -ContextOut)
% RELATIONS (as a part of arithmetical / relational operations)
% Performs the operation for all term instances by Context, the output
% context corresponds to the operation performed For example, for a
% relation > , the output context will contain only those substitutions
% that match it, e.g. A>B, [ [[A=3],[B=5]], [[A=5],[B=3]] ,
% [[A=2],[B=0]] ] -> [ [[A=5],[B=3]] , [[A=2],[B=0]] ]
%

non_empty_context([], false).

non_empty_context(_, true).


alopreltry(Operator, Operand1, Operand2, Context, Contexts,
           [Context |Contexts]):-
    apply(Operator, [Operand1, Operand2]).

alopreltry(_ ,_ ,_ ,_ , Contexts, Contexts).


aloprel(_,_,_,[],[]).

aloprel(Operator, Operand1, Operand2, [Context| Contexts], Contexts_Out):-
    get_term(Operand1, Context, Term1),
    get_term(Operand2, Context, Term2),
    aloprel(Operator, Operand1, Operand2, Contexts, Contexts2),
    alopreltry(Operator, Term1, Term2, Context, Contexts2, Contexts_Out).

aloprel(Operator, Operand1, Operand2, [ _| Contexts], Contexts2):-
    aloprel(Operator, Operand1, Operand2, Contexts, Contexts2).


%
%
%

membervo(A, [B=_|_]):-
    A==B.

membervo(_,_).


evolve_context(A, _, Context, Context):-
% after applying the substitution, the left side became a number, so in the
% context, if there was a variable on the left, there is an assignment, or
% there was a number
    number(A).

% ... anyway, we do not add anything to the context
% left side variable that did not have a pair in the context, expand the
% context according to the result of the operation

evolve_context(_, B=C, Context, [B=C| Context]).

alop3(E, A, C, D, Context1, Context2):-
    C is D,			% suceeded
    evolve_context(E, A=C, Context1, Context2).

alop3(_,_,_,_,_,[]).


alop2(A is B, Context1, Context3):-
    !,
    copy_term([A, B, Context1], [C, D, Context2]),
% we have to remember the renaming, we rely on term_variables to always return
%  the variables in the same order
    apply_substitutions(Context2), % X should be instantiated,
% to test later whether the left side was already numbered after the
% substitution
    copy_term(C, E),
    alop3(E, A, C, D, Context1, Context3).

alop2(_ is _, _, []).


alop(_ is _,[],[], true).

alop(A is B, [Context1| Contexts1], [Context2| Contexts2], true):-
    alop2(A is B, Context1, Context2),
    length(Context2, L),
    L>0,
    alop(A is B,Contexts1, Contexts2, _).

alop(A is B,[_| T], T2, true):-
    alop(A is B, T, T2, _).



alop(A ,Context1 ,Context2 , Result):-
    A=..[Operator, Operand1, Operand2],
    relational_operator(Operator),
    aloprel(Operator, Operand1, Operand2, Context1, Context2),
    non_empty_context(Context2, Result).
