%
%	Reasoning methods - the simple ones
%	Frantisek Zboril jr. 2023
%

%
%	Should define
%                    	get_intention(+Reasoning_type,+Intentions,-Intention).
%                       
%			not defined for:
%				 get_substitution(+Reasoning_type,+ActionTerm,+SubstitutionList, +VariableList,-SubstitutionList).
%                       	 get_plan(+Reasoning_type,+Goal,+RelAppPlans,-IntendedMeans).
%			if required, 'simple_reasoning' will be used.
%

%	This module is loaded / included in the FRAgAgent file

  :-dynamic bindings /3.

  reasoning_method(snakes_reasoning).

			
%
%	redirecting the other two to simple_reasoning
%

%
%	Makes bindings for a list of programs     ( make_bindings(+PROGRAMS). )
%	Asserts bindings(program, program, bindings) for every pair of programs from the input
%

  get_bindings_for_programs(PROGRAM1BODY, PROGRAM2BODY, []).


%*	make_bindings_for_programs(+PROGRAM:program , +PROGRAM:program)

  make_bindings_for_programs(program(PROGRAM1INDEX, PROGRAM1BODY), program(PROGRAM2INDEX, PROGRAM2BODY)):-
	get_bindings_for_programs(PROGRAM1BODY, PROGRAM2BODY, BINDINGS12),
	get_bindings_for_programs(PROGRAM2BODY, PROGRAM1BODY, BINDINGS21),

	assert(bindings(PROGRAM1INDEX, PROGRAM2INDEX, BINDINGS12)),
	assert(bindings(PROGRAM2INDEX, PROGRAM1INDEX, BINDINGS21)).

%*	make_bindings_for_program(+PROGRAM:program , +PROGRAMS:list of programs)

  make_bindigs_for_program(_ , []).
 
  make_bindigs_for_program(PROGRAM1, [PROGRAM2| TPROGRAMS]):-
	make_bindings_for_programs(PROGRAM1, PROGRAM2),
        make_bindigs_for_program(PROGRAM1, TPROGRAMS).


  make_bindings([]).

  make_bindings([PROGRAM| TPROGRAMS]):-
	make_bindigs_for_program(PROGRAM, TPROGRAMS),
	make_bindings(TPROGRAMS).


%   nize smazat, je to ve FragPLFrag

  apply_substitutions([]).                             		% vstupem jsou substituce [[A->a],[B->b] ...] a ty jsou postupne provadeny

  apply_substitutions([BIND|T]):-
	BIND,
	apply_substitutions(T).


  instance_set(_ ,[],[]).

  instance_set(ATOM, [SUBSTITUTION|TSUBSTITUTIONS],IS):-
	copy_term([ATOM|SUBSTITUTION], [NEWATOM|SUBSNEW]),
	apply_substitutions(SUBSNEW),
	instance_set(ATOM, TSUBSTITUTIONS, T2),
	sort([NEWATOM|T2],IS).

%   vyse smazat, je to ve FragPLFrag


  member_variant(E, [H|T]):-
	E =@= H.

  member_variant(E, [ _ |T]):-
       member_variant(E, T).


  % reduces list, removes variants (the same atom except renaming variable)

  remove_variants_from_list([], []).

  remove_variants_from_list([H|T], T2):-
	member_variant(H, T),
	remove_variants_from_list(T, T2).

  remove_variants_from_list([H|T], [H|T2]):-
	remove_variants_from_list(T, T2).


  translate_plan_body_to_program(_, [], []).

  translate_plan_body_to_program(CONTEXT, [ACT| TPLANBODY], [ACTINSTANCESET2| TPROGRAM]):-
	instance_set(ACT, CONTEXT, ACTINSTANCESET),
	remove_variants_from_list(ACTINSTANCESET, ACTINSTANCESET2),
	translate_plan_body_to_program(CONTEXT, TPLANBODY, TPROGRAM).	


  make_program([], []).

  make_program([plan(_, _, _, _, CONTEXT, PLANBODY)| TPLANS], PROGRAM):-
	translate_plan_body_to_program(CONTEXT, PLANBODY, PROGRAM1),
	make_program(TPLANS, PROGRAM2),
	append(PROGRAM1, PROGRAM2, PROGRAM).
	         


  make_programs([], []).

  make_programs([intention(INTENTIONINDEX, PLANS, _)| TINTENTIONS], [program(INTENTIONINDEX,PROGRAM)| TPROGRAMS]):-
	make_program(PLANS, PROGRAM),
	make_programs(TINTENTIONS, TPROGRAMS).	



  get_intention(snakes_reasoning, INTENTIONS, INTENTION):-
	make_programs(INTENTIONS, PROGRAMS),
	make_bindings(PROGRAMS),
	writeln(PROGRAMS).



%
%	TODO
%

/*
intentions([
intention(1,[plan(1,ach,a,[],[[]],[act(do(c)),act(do(e)),act(do(d)),act(do(c))]),
	     plan(5,ach,e,[],[[]],[act(do(b)),act(do(e))]),
	     plan(6,ach,f,[],[[]],[act(do(b)),act(do(e)),act(do(c)),act(do(d)),act(do(e))])],
		active) ,

intention(3,[plan(3,ach,c,[],[[]],[act(do(a)),act(do(d)),act(do(b)),act(do(a)),act(do(e)),act(do(a)),act(do(d)),act(do(b)),act(do(a)),act(do(d)),act(do(e)),act(do(b)),act(do(e)),act(do(c)),act(do(e)),act(do(a)),act(do(b)),act(do(e))])],active) ,
intention(5,[plan(5,ach,e,[],[[]],[act(do(b)),act(do(e))])],active) ,
intention(6,[plan(6,ach,f,[],[[]],[act(do(b)),act(do(e)),act(do(c)),act(do(d)),act(do(e))])],active) ,
intention(7,[plan(7,ach,g,[],[[]],[act(do(a)),act(do(c)),act(do(e)),act(do(b)),act(do(a))])],active) ,
intention(2,[plan(2,ach,b,[],[[]],[act(do(e)),act(do(b)),act(do(a)),act(do(c)),act(do(d)),act(do(c)),act(do(e)),act(do(c)),act(do(d)),act(do(b)),act(do(d))])],active) ,
intention(4,[plan(4,ach,d,[],[[]],[act(do(a)),act(do(d)),act(do(c)),act(do(a)),act(do(c)),act(do(e)),act(do(b)),act(do(d)),act(do(e)),act(do(a)),act(do(d)),act(do(a)),act(do(b)),act(do(d)),act(do(b)),act(do(a)),act(do(d)),act(do(e)),act(do(a))])],active)
]).
*/

intentions([
intention(1,[plan(1,ach,g1,[],[[_27932=a],[_27932=b],[_27932=c]],[test(b(_27984)),test(c(_27998)),test(d(_28012)),act(printfg(a(_27932))),act(printfg(b(_27984))),act(printfg(c(_27998))),act(printfg(d(_28012))),act(printfg(a(_27932)))])],active) ,
intention(2,[plan(4,ach,g2,[],[[]],[act(printfg("h")),act(printfg("o")),act(printfg("j")),act(printfg("t")),act(printfg("e"))])],active) ,
intention(3,[plan(7,ach,g3,[],[[]],[act(printfg("o")),act(printfg("r")),act(printfg("c")),act(printfg("i"))])],active) ,
intention(4,[plan(4,ach,g2,[],[[]],[act(printfg("h")),act(printfg("o")),act(printfg("j")),act(printfg("t")),act(printfg("e"))])],active) ,
intention(5,[plan(1,ach,g1,[],[[_27312=a],[_27312=b],[_27312=c]],[test(b(_27364)),test(c(_27378)),test(d(_27392)),act(printfg(a(_27312))),act(printfg(b(_27364))),act(printfg(c(_27378))),act(printfg(d(_27392))),act(printfg(a(_27312)))])],active)
]).


%
%	redirecting the other two to simple_reasoning
%

  
  get_substitution(snakes_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION):-
	get_substitution(simple_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION).

  get_plan(snakes_reasoningPLANS, INTENDED_MEANS):-
        get_plan(simple_reasoning, PLANS, INTENDED_MEANS).

	
  init_reasoning(snakes_reasoning).





  go:-
	intentions(INTENTIONS),
	get_intention(snakes_reasoning, INTENTIONS, INTENTION),
	writeln(INTENTION).



