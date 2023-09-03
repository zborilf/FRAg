%               
%	Reasoning methods - taking biggest joint action
%	Frantisek Zboril jr. 2022 - 2023
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


  :-thread_local model_action /1. 		
  :-thread_local model_intention /1. 		

  reasoning_method(biggest_joint_reasoning).


% First active


  most_f_action(A, [], _ , [ac(1,A)]).
		
  most_f_action(A, [A], N, [ac(N2,A)]):-
	N2 is N+1.
 
  most_f_action(A, [AN], N, [ac(N,A),ac(1,AN)]).


  most_f_action(A, [A|AT], N, AOUT):-
	N2 is N+1,
	most_f_action(A, AT, N2, AOUT).

  most_f_action(A, [AN|AT], N, [ac(N,A)|AOUT]):-
				most_f_action(AN, AT, 1, AOUT).


  get_actions([],[]).

  get_actions([intention(_ ,[plan(_ ,_ ,_ ,_ ,CTXP,[act(A)|_])|_ ],active)|IT], ACTSOUT):-
	functor(A,PREDICATE, Arity),
	is_joint_action(PREDICATE, Arity),
	instance_set(A, CTXP, ACTS),
	get_actions(IT, AST),
	append(ACTS, AST, ACTSOUT).

  get_actions([intention(_ ,[plan(_ ,_ ,_ ,_ ,_ ,[_ |_ ])|_ ],active)|IT],AST):-
	get_actions(IT,AST).

  
  get_actions([intention(_ , INTENTION, AST)]):-
	get_actions(INTENTION, AST).
				

  get_action([],ac(0,null)).
						

  get_action(ACTIONS, ACTION):-
	msort(ACTIONS,[AH|AT]),
	most_f_action(AH,AT,1, A),
	sort(A,AS),
	reverse(AS,[ACTION|_]),
	format(atom(STRING), "[JOINT] ACTIONS GATHERED: ~w~n", [ACTIONS]),
	print_debug(STRING, jointdbg),                               
	format(atom(STRING2), "[JOINT] ACTION CHOSEN: ~w~n", [ACTION]),
	print_debug(STRING2, jointdbg).                               


  get_intention2(null,INTENTIONS,INTENTION):-
	get_intention(simple_reasoning,INTENTIONS,INTENTION).

  get_intention2(ACTION,_,intention(INT,[plan(IDX,GT,G,PC,CTXP,[act(ACTION)|AT])|PT],active)):-
	get_intention(simple_reasoning,_ ,_ ),
     	intention(INT,[plan(IDX,GT,G,PC,CTXP,[act(ACTION)|AT])|PT],active).
			


  get_not_joint_action([intention(_ ,[plan(_ ,_ ,_ ,_ ,_ ,[act(Action)|_ ])|_ ],active)| Intentions], Intention):-
	functor(Action, PREDICATE, Arity),
	is_joint_action(PREDICATE, Arity),
	!,
	get_not_joint_action(Intentions, Intention).

  get_not_joint_action([INTENTION|_ ], INTENTION).


  get_model_intention(biggest_joint_reasoning, INTENTIONS, INTENTION):-
	format(atom(STRING), "[JOINT] INTENTIONS: ~w~n", [INTENTIONS]),
	print_debug(STRING, jointdbg),                               	
	get_actions(INTENTIONS,ACTIONS),
	get_action(ACTIONS, ac(_, ACT)),
	format(atom(STRING2), "[JOINT] ACTIONS2: ~w~n", [ACT]),
	print_debug(STRING2, jointdbg),                               
	get_intention2(ACT, INTENTIONS, INTENTION),
	format(atom(STRING3), "[JOINT] INTENTION: ~w~n", [INTENTION]),
	print_debug(STRING3, jointdbg).                                                            



  update_model(biggest_joint_reasoning):-
	retractall(model_intention( _ )),
	retractall(model_action( _ )),

	format(atom(STRING), "[JOINT] UPDATING JOINT MODEL~n", []),
	bagof(intention(IDENTIFIER,CONTEXT,STATUS),intention(IDENTIFIER,CONTEXT,STATUS),INTENTIONS),
	!,	
	format(atom(STRING2), "[JOINT] UPDATING JOINT MODEL, INTENTIONS: ~w ~n", [INTENTIONS]),
	get_model_intention(biggest_joint_reasoning, INTENTIONS, INTENTION), 
	format(atom(STRING3), "[JOINT] UPDATING JOINT MODEL, INTENTION: ~w ~n", [INTENTION]),
	print_debug(STRING, jointdbg),
	print_debug(STRING2, jointdbg),
	print_debug(STRING3, jointdbg),


	INTENTION = intention( _,  [ plan(_, _, _, _, _, [ACT | _])|  _ ], _),

	assert(model_intention(INTENTION)),
	assert(model_action(ACT)),

	format(atom(STRING4), "[JOINT] UPDATING JOINT MODEL, ACT: ~w ~n", [ACT]),
	print_debug(STRING, jointdbg),
	print_debug(STRING2, jointdbg),
	print_debug(STRING3, jointdbg),
	print_debug(STRING4, jointdbg).

	
  update_model(biggest_joint_reasoning).



  get_intention(biggest_joint_reasoning, INTENTIONS, INTENTION):-
	get_not_joint_action(INTENTIONS, INTENTION).

  get_intention(biggest_joint_reasoning, _, INTENTION):-
	model_intention(INTENTION).






%% K cemu jsou ty dole?

%  get_intention(simple_reasoning,[intention(IDX,CONTENT,active)|_],intention(IDX,CONTENT,active)).
% 
%  get_intention(simple_reasoning,[_|T],INTENTION):-
%	get_intention(simple_reasoning,T,INTENTION).
%
%

%
%	redirecting the other two to simple_reasoning
%

  get_plan(biggest_joint_reasoning, EVENT, MEANS, INTENDEDMEANS):-
        get_plan(simple_reasoning, EVENT, MEANS, INTENDEDMEANS).

  get_substitution(biggest_joint_reasoning, ACTION, _, _, SUBSTITUTION):-
	model_action(ACTION2),
	format(atom(STRING), "[JOINT] ACTION ~w MODEL ACTION: ~w ~n", [ACTION, ACTION2]),
	print_debug(STRING, jointdbg),
	unifiable(act(ACTION), ACTION2, SUBSTITUTION),
	format(atom(STRING2), "[JOINT] SUBSTITUTION: ~w ~n", [SUBSTITUTION]),
	print_debug(STRING2, jointdbg).

  get_substitution(biggest_joint_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION):-
	get_substitution(simple_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION).


  init_reasoning(biggest_joint_reasoning).

