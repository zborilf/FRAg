
/**

This file is part of the FRAg program. It is included into agent's file 
FRAgAgent.pl. It contains clauses that are applied to strategies for selecting 
intentions, plans and substitutions. Random reasoning selects the first 
option from of options that have not yet been tried.

@author Frantisek Zboril
@version 2022 - 2024
@license GPL

*/


%
% Should define
%    get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%
% not defined for:
%    get_substitution(+Reasoning_type, +ActionTerm, +SubstitutionList,
%		      +VariableList, -SubstitutionList).
%				 get_intention(+Reasoning_type, +Intentions, -Intention).
%			if required, 'simple_reasoning' will be used.
%



reasoning_method(can_reasoning).



%  Takes the first active intention
%

get_intention(can_reasoning, [intention(Index, CONTENT, active)| _ ],
	      intention(Index, CONTENT, active)).
	                                             
get_intention(can_reasoning, [ _ | Intentions], Intention_Out):-
    get_intention(simple_reasoning, Intentions, Intention_Out).



%!  get_substitution(random_reasoning, _, Context, Vars, Context_Out) is det
%   CAN decisioning in early bindings mode selects substitution randomly.
%   This clause is to select one of the set of substitutions and reduces it to 
%   just the variables from Vars.
%  @arg Context_In: input context
%  @arg Vars: the variables for which a decision is to be made
%  @arg Context_Out: output context

get_substitution(can_reasoning, _, Context_In, Vars, Context_Out):-
    random_member(Substitution, Context_In),
    shorting(Substitution, Vars, Context_Out).	% from file FRAgPLFRAg


% is used when PlanId= UsedPlanID and context / usedcontext?
% pokud se PlanId a UsedPlanID lisi, pak Indended Means neni pokryt/pouzit
% jak ukazat, ze v jednom kontextu je neco, co nepokryl druhy kontext??
% Var kontextu je stejna mnozina v obou pripadech
% Pokud kontext Intended means obsahuje neco, co neni v Used, pak ok




reduce_context([] , [Plan, Context], Context).

% some used to check

reduce_context([used_plan(Plan_ID, Trigger, Conditions, Context)| Used], 
		[plan(Plan_ID, _, Trigger, Conditions, _), Context_In], 
 		Context_Out):-
% Context2 = Context_In - Context, from FRAgPLFRAg file
    substract_subsubstitions(Context_In, Context, Context2),
  writeln(substract_subsubstitions(Context_In, Context, Context2)),
    reduce_context(Used, [Plan, Context2], Context_Out).

reduce_context([ _ | Used] , 
		[Plan, Context_In], Context_Out):-
    reduce_context(Used, [Plan, Context_In], Context_Out).



get_plan(can_reasoning, Event, [[Plan, Context] | Means], 
					[Plan2, Context_Out]):-
    Event = event( _ , _ , _ , _ , _ , _ , Used_Means),
    reduce_context(Used_Means, [Plan, Context], Context2),
    format(atom(String), "~n[CANDBG] Original context was ~w
[......] used were ~w
[......] unused substitutions ~w", 
		[[Plan, Context], Used_Means, Context2]),
    println_debug(String, candbg),
    get_plan2(can_reasoning, Event, [Plan, Context2], 
				Means, [Plan2, Context_Out]),
    !,
% get_plan fails when no fresh means is available (previously unused)
    valid_context(Context_Out). 


valid_context([]):-!, fail.

valid_context(_).





% context after discarding used substitutions is empty -> try another

get_plan2(can_reasoning, Event, [Plan, [] ], Means, Intended_Means):-
    format(atom(String), "~n[CANDBG] Nothing new there ~w
[......] continuing with ~w", 
		[Plan, Means]),
    println_debug(String, candbg),
    get_plan(can_reasoning, Event, Means, Intended_Means).

get_plan2(can_reasoning, Event, Intended_Means, _, Intended_Means):-
    format(atom(String), "~n[CANDBG] Check OK, ~w ", [Intended_Means]),
    println_debug(String, candbg).




%!  update_model(can_reasoning) is det
%   No update is needed. This clause is valid by default  

update_model(can_reasoning).



%!  init_reasoning(can_reasoning) is det
%   No initialization is needed. This clause is valid by default

init_reasoning(can_reasoning).


