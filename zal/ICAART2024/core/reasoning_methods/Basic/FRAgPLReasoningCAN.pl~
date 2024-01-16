%
%	Reasoning methods - the simple ones
%	Frantisek Zboril jr. 2022 - 2023
%

%
%	Should define
%                    	 get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%                       
%			not defined for:
%				 get_substitution(+Reasoning_type, +ActionTerm, +SubstitutionList, +VariableList, -SubstitutionList).
%				 get_intention(+Reasoning_type, +Intentions, -Intention).                      	
%			if required, 'simple_reasoning' will be used.
%



  reasoning_method(can_reasoning).


% First active

  %
  %  Takes the first active intention
  %

  get_intention(can_reasoning, [intention(INDEX, CONTENT, active)| _ ], intention(INDEX, CONTENT, active)).

  get_intention(can_reasoning, [ _ | TINTENTIONS], INTENTION):-
	get_intention(simple_reasoning, TINTENTIONS, INTENTION).


  get_substitution(can_reasoning, _, [CONTEXTH| _ ], VARS, CONTEXT):-
	shorting(CONTEXTH, VARS, CONTEXT).	% from file FRAgPLFRAg

  % prvni plan jeste nebyl pouzit


   check_used( _ , _ ).

%  check_used([ used_plan(PLANINDEX, _ , _ , PLANCONTEXT) | _], ??INTENDEDMEANS):-
		

%  check_used([ _ | TUSEDMEANS], INTENDEDMEANS):-
%	check_used(TUSEDMEANS, INTENDEDMEANS).


  get_plan(can_reasoning, event( _ , _ , _ , _ , _ , _ , USEDMEANS), [ _ | TINTENDEDMEANS], INTENDEDMEANS):-
	format(atom(STRING), "[CANDBG] ~w", [USEDMEANS]),
	println_debug(STRING, candbg),
	check_used(USEDMEANS, INTENDEDMEANS),
	get_plan(can_reasoning, _ , TINTENDEDMEANS, INTENDEDMEANS).

  get_plan(can_reasoning, _, [INTENDEDMEANS| _ ], INTENDEDMEANS).
	 
  update_model(can_reasoning).
				
  init_reasoning(can_reasoning).

