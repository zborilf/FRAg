                                                    
%
%  	Reasoning methods - MCTS supported reasoning
%  	Frantisek Zboril jr. 2022 - 2023
%

%
%  Should define
%                       get_intention(+Reasoning_type, +Intentions, -Intention).
%                       get_substitution(+Reasoning_type, +ActionTerm, +SubstitutionList, +VariableList, -SubstitutionList).
%                       get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%

% This module is loaded / included in the FRAgAgent file

% :-thread_local tree_node/5.                  		% id node, action, children, visited, points

%  :- use_module('FRAgMCTSModel').


:-dynamic simulate_late_bindings/1.    		% should do the tree for early bindings (expand individual reasonings and tests?)
:-dynamic mcts_default_expansions/1.
:-dynamic mcts_default_number_of_simulations/1.
:-dynamic mcts_simulation_steps/1.

:-thread_local recomended_path/2.    			% based on model, either greedy, or ucb
:-thread_local mcts_expansions/1.
:-thread_local mcts_number_of_simulations/1.



:-include('FRAgMCTSModel.pl').  % internal actions library


%
% 	Static atoms
%

  mcts_default_expansions(10).
  mcts_default_number_of_simulations(10).
  mcts_simulation_steps(100).
  
  reasoning_method(mcts_reasoning).
                                   

  recomended_path([],[]).     % actual path found by last mcts execution, first is reasoning prefix, then action?



% signalizes that mcts model is needed to mantain during agent's execution
% for this type of reasoning
 


  

%
%	Zpracovani atributu v metasouboru, specialne pro tento modul
%

set_reasoning_method_params(mcts_params(EXPANSIONS, SIMULATIONS, STEPS)):-
    retractall(mcts_default_expansions( _ )),
    retractall(mcts_default_number_of_simulations( _ )),
    retractall(mcts_simulation_steps( _ )),
    assert(mcts_default_expansions(EXPANSIONS)),
    assert(mcts_default_number_of_simulations(SIMULATIONS)),
    assert(mcts_simulation_steps(STEPS)).	


%
%  strom -> akce, potomkovske akce
%           akce -> vyber planu pro zamer, nebo akce planu (ale bude to mit desne vetveni)
%




%
% Reasoning redefined here ... gets all options for all the goals
%
%



  get_decisions(PUS, VARS, DECISIONS):-
    	shorting_pus(PUS, VARS, DECISIONS).


  perform_reasoning( _, _):-
    	true.



%
% expand actions -> gets all possible actions + decisions
%


% get_actions ... add, del, act (with decisionings) test, ach (just goals, no context selection/decisions)

  get_all_action_decisions2(_, _, [], []).     

  get_all_action_decisions2(INTENTIONINDEX, ACTION, [DECISION| TDECISIONS], 
                            [model_act_node(INTENTIONINDEX, ACTION, [DECISION])| 
                               Acts]):-
  	get_all_action_decisions2(INTENTIONINDEX, ACTION, TDECISIONS, Acts).


  get_all_action_decisions(INTENTIONINDEX, ACTION, _, [model_act_node(INTENTIONINDEX, ACTION,[[]])]):-  % Action is ground
       term_variables(ACTION, []).
    

  get_all_action_decisions(INTN, ACTION, CONTEXT, ACTIONS):-  
    	term_variables(ACTION, VARS),
    	get_decisions(CONTEXT, VARS, DECISIONS),
%	write("decisions: "), write(get_decisions(CONTEXT, VARS, DECISIONS)),
    	get_all_action_decisions2(INTN, ACTION, DECISIONS, ACTIONS).    


% For late bindings goals actions (test, ach) are abstracted without decisions
%  in the case of early bindings, must be also expanded for individual decisions

  get_actions(INTENTIONINDEX, test(GOAL), _,[model_act_node(INTENTIONINDEX, test(GOAL),[[]])]):-
	simulate_late_bindings(true).


  get_actions(INTENTIONINDEX, test(GOAL), CONTEXT, ACTIONS):-
	% test goal is set with its results, should be simulated
    	bagof(fact(GOAL), fact(GOAL), TESTGOALS),
    	broadUnification(fact(GOAL), TESTGOALS, CONTEXT2), 
	restrict(CONTEXT, CONTEXT2, CONTEXT3),
	get_all_action_decisions(INTENTIONINDEX, test(GOAL), CONTEXT3, ACTIONS).
	
  % tato akce ma spadnout, takze nechame test goal jak byl (i kdyby nahodou ve skutecnosti prosel)
  get_actions(Intention_Index, test(Goal), _, 
              [model_act_node(Intention_Index, test(Goal),[[]])]).   
	% test goal is set with its results, should be simulated

get_actions(Intention_Index, rel(Relation), _, 
              [model_act_node(Intention_Index, rel(Relation),[[]])]).   
	% test goal is set with its results, should be simulated

	
get_actions(Intention_Index, ach(Goal),_ ,
              [model_act_node(Intention_Index, ach(Goal),[[]])]):-      % case of late bindings
    simulate_late_bindings(true).        

get_actions(Intention_Index, ach(GOAL), CONTEXT, ACTIONS):-
    get_all_action_decisions(Intention_Index, ach(GOAL), CONTEXT, ACTIONS).


get_actions(Intention_Index, add(GOAL), CONTEXT, ACTIONS):-
    get_all_action_decisions(Intention_Index, add(GOAL), CONTEXT, ACTIONS).

get_actions(Intention_Index, del(GOAL), CONTEXT, ACTIONS):-
    get_all_action_decisions(Intention_Index, del(GOAL), CONTEXT, ACTIONS).

get_actions(Intention_Index, act(GOAL), CONTEXT, ACTIONS):-
    get_all_action_decisions(Intention_Index, act(GOAL), CONTEXT, ACTIONS).

get_actions(INTENTIONINDEX, act(ENVIRONMENT, GOAL), CONTEXT, ACTIONS):-
    get_all_action_decisions(INTENTIONINDEX, act(ENVIRONMENT, GOAL), CONTEXT, ACTIONS).


% expand state -> all possible actions

model_expand_actions2([],[]).   % no intention left, no actions

model_expand_actions2([intention(Intention_Index ,
                                [plan( _, _, _, _, _, [])| _], 
                                active) | 
                          Intentions], 
                      [model_act_node(Intention_Index, true, [])| Acts]
                     ):- 
    model_expand_actions2(Intentions, Acts).                 
       
model_expand_actions2([intention(INTN ,
                                 [plan( _, _, _, _, Context, [Act | _])| _],
                                       active) | IT], ACTIONS2):-          
    get_actions(INTN, Act, Context, Acts),
    format(atom(STRING),"[MCTS] +++ Actions to expand: ~w", [Acts]),
    println_debug(STRING, mctsdbg),
    sort(Acts, ACTIONSS),    % remove duplicates
    model_expand_actions2(IT, AT),                 
    append(ACTIONSS, AT, ACTIONS2).


model_expand_actions(Actions):-
    bagof(intention(N,P,S), intention(N,P,S), INTENTIONS),
    model_expand_actions2(INTENTIONS, Actions),
    format(atom(STRING),"[MCTS] Expanded actions: ~w",[Actions]),
    println_debug(STRING, mctsdbg).         
 
model_expand_actions([]).   % in the case there is no intention


%
% expand state -> all possible deliberations
%



model_expand_deliberations4(Goal, 
                           [plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), CONTEXT],
              [model_reasoning_node(Goal, plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), CONTEXT)]):-
    simulate_late_bindings(true).

  model_expand_deliberations4(_,[_,[]], []).

  model_expand_deliberations4(Goal, [plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody),[Unif| T]],
      	[model_reasoning_node(Goal, plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), [Unif])| MDNT]):-
      	model_expand_deliberations4(Goal, [plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody),T], MDNT).
    

model_expand_deliberations3(_,[],[]).

model_expand_deliberations3(Goal,[[plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), Unifs]|PT], MDNTS):-
    model_expand_deliberations4(Goal,[plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), Unifs], MDNT1), 
    model_expand_deliberations3(Goal, PT, MDNT2),
    append(MDNT1,MDNT2,MDNTS).

model_expand_deliberations2([],[]).

model_expand_deliberations2([event(EVENTINDEX, Type,Predicate,Intention,Context,State, HISTORY)| TEVENTS], Deliberations):-
    get_relevant_applicable_plans(Type, Predicate, Context, RAPlans),
    println_debug("[MCTS] Expand RA, RAPlans:", mctsdbg),
    println_debug(RAPlans, mctsdbg),
    model_expand_deliberations3(event(EVENTINDEX, Type,Predicate,Intention,Context,State, HISTORY), RAPlans, RAPlans_elements),
    model_expand_deliberations2(TEVENTS, RAT),
    append(RAPlans_elements, RAT, Deliberations).

  % no RE plans
model_expand_deliberations2([event( _, _, _, _, _, _, _)| Events], MEANS):-
        model_expand_deliberations2(Events, MEANS).
    	

model_expand_deliberations(Deliberations):-                                             
    findall(event(EVENTINDEX, Type,Predicate,Intention, Context,active, History),
	    event(EVENTINDEX, Type,Predicate,Intention, Context,active, History),
	    Events),
    !,
    model_expand_deliberations2(Events, Deliberations).

  model_expand_deliberations([]).   % in the case there is no goal
    


%
%  Silence program / plan ... translates plan such that all act(ACT) in the program plans which are not relations or 'is' are translated to act(__foo(ACT))
%  such act is not executed, but the decision on the variables in ACT is kept
%

silence_plan([],[]).

silence_plan([act(A is B)| T], [act(A is B)| T2]):-
    silence_plan(T,T2).

silence_plan([act(ACT)| T], [act(ACT)| T2]):-
    ACT=..[OPERATION, _, _], 
    relational_operator(OPERATION),        % in the FragPLActions.pl file
    silence_plan(T,T2).

silence_plan([act(ACT)| T], [(act(silently_(ACT)))| T2]):-
%  the only modification is here (act that is not 'is' or relops)
    silence_plan(T,T2).   

silence_plan([act(ENVIRONMENT, ACT)| T], [(act(ENVIRONMENT, silently_(ACT)))| T2]):-
%  the only modification is here (act that is not 'is' or relops)
    silence_plan(T,T2).   



silence_plan([H|T],[H|T2]):-
    silence_plan(T,T2).

silence_program([],[]).

silence_program([plan(A,B,C,D,E,F)|T], [plan(A,B,C,D,E,F2)|T2]):-
    silence_plan(F,F2),
    silence_program(T,T2).

silence_program([plan(A,B,C,D,E)|T], [plan(A,B,C,D,E2)|T2]):-
    silence_plan(E,E2),
    silence_program(T,T2).


silence_program([intention(A,Plans,C)|T], [intention(A,Plans2,C)|T2]):-
    silence_program(Plans,Plans2),
    silence_program(T,T2).

silence_program([H|T], [H|T2]):- 
    silence_program(T,T2).


%
%  simulation
%

garbage_all:-   
    garbage_collect,
    garbage_collect_atoms,
    garbage_collect_clauses,
    trim_stacks.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%
% 	Start of engine code
%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  

frag_simulate_program2(Program, STEPS, 0, RESULTS, EXPANDED):-
    number_of_top_level_goals(GOALSREMAIN), 
    print_debug(runResult(RESULTS, 0, EXPANDED, GOALSREMAIN),mctsdbg),
    thread_self(Virtual_Agent),
% writeln(remove_clones(Virtual_Agent)),
    remove_clones(Virtual_Agent),
% writeln(bbb),
    close_engine_file,				% close stream 
    engine_yield(runResult(RESULTS,0, EXPANDED, GOALSREMAIN)),
    !,
	
    	% ENGINE RESTARTS HERE!
        
    garbage_collect_atoms,
    mcts_number_of_simulations(Simulations),
    frag_simulate_program2(Program, STEPS, Simulations, [], EXPANDED). 
  


frag_simulate_program2(Program, STEPS, SIMULATIONS, RESULTS, EXPANDED):-
    retractall(loop_number( _ )), % init run
    assert(loop_number(1)),	
    clear_agent,
    !,    
    thread_self(Agent),
    reset_clones(Agent),
    set_clauses(Program, 1),
    thread_self(Virtual_Agent),
    load_all_instances_state(Virtual_Agent, mcts_save),
    print_debug("[MCTS] Program to simulate:", mctsdbg),
    println_debug(Program, mctsdbg),
    loop(STEPS, STEPSLEFT),
    Steps_Done is STEPS - STEPSLEFT,
    !,
    garbage_all,  
    Simulations2 is SIMULATIONS - 1,
    frag_simulate_program2(Program, STEPS, Simulations2, [Steps_Done| RESULTS], 
                           EXPANDED).




frag_simulate_program(Program, Steps, Expanded, Simulations):-
    frag_simulate_program2(Program, Steps, Simulations, [], Expanded). 

%
% Node selection
%

% clauses for simulating acts and reasoning / plan adaption

% model_act_node(intention, action, decision)
% mcts_select_simulate_act(model_act_node(intention, action, decision)):-

    

%
% Executes acts in list of model_reasoning_node(goal / wgi , plan number, pus) or model_act_node(intention, action, decision)
%
                                                   
force_execute_model_path([_, success]).	

force_execute_model_path([]).


force_execute_model_path([_,  model_act_node( _, no_action, _) | Nodes]):-
    force_execute_model_path(Nodes).


force_execute_model_path([_,  model_act_node(INTENTION, ACT, CONTEXT) 
                            | Nodes]):-
    % in FRAgAgent.pl
    force_execution(model_act_node(INTENTION, ACT, CONTEXT)),      
    force_execute_model_path(Nodes).


force_execute_model_path([_,  model_reasoning_node(Goal, Plan_Number, Context) 
                            | Nodes]):-
    force_reasoning(model_reasoning_node(Goal, Plan_Number, Context)),            
    force_execute_model_path(Nodes).
  
    

open_engine_file(Agent, Agent_Loop, Runs):-
    agent_debug(mctsdbg),
    format(atom(Filename),"logs/_~w_mcts_engine_~w_~w.mcts",
                              [Agent, Agent_Loop, Runs]),
    tell(Filename).		% TODO, open?

open_engine_file( _, _, _).



close_engine_file:-
    agent_debug(mctsdbg),
    told.

close_engine_file.



set_debugs(true):-
    assert(agent_debug(mctsdbg)),
    assert(agent_debug(reasoningdbg)).

set_debugs(false).



mcts_frag_engine(Program, INTENTIONFRESH, EVENTFRESH, Path, Expanded, 
	  	 RUNS, STEPS, SIMULATIONS, AGENTLOOP, Agent, BINDINGS, DEBUG):-

    %
    %  simulation engine ...
    %  1, performs program 'Path'
    %  2, makes expansion at this point (for the leaf node of Program)
    %    ?? result of expansions is in Expanded (in which form?)
    %  3, makes simulation of postfix of the program (Program2) 
    %      at this point as an engine - each execution of engine makes number_of_simulations(NOS) simulations
    %

    set_debugs(DEBUG),
    open_engine_file(Agent, AGENTLOOP, RUNS),
    set_late_bindings(BINDINGS),
    set_reasoning(random_reasoning),
    assert(loop_number(-1)),
    set_clauses(Program, 1),
    thread_self(Virtual_Agent),
    virtualize_agent(Agent, Virtual_Agent),
    assert(intention_fresh(INTENTIONFRESH)), 		% ponecham jako v originalnim vlakne	
    assert(event_fresh(EVENTFRESH)),

    println_debug('+++++ PATH +++++', mctsdbg),

    mcts_print_path(Path, mctsdbg),    	

    print_state('MCTS BEFORE FORCE PATH'),
    force_execute_model_path(Path),   			% executes program in Path
    print_state('MCTS AFTER FORCE'),

    model_expand_actions(Expanded_Acts),    
    model_expand_deliberations(Expanded_Plans),
    append(Expanded_Acts, Expanded_Plans, Expanded),
    print_debug('[MCTS] Expanded nodes - ', mctsdbg),
    println_debug(Expanded, mctsdbg),
                
    take_snapshot(Program2),      
    save_all_instances_state(Virtual_Agent, mcts_save),
    frag_simulate_program(Program2, STEPS, Expanded, SIMULATIONS).             



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%
% 	End of engine code
%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   
number_of_top_level_events(NOTLE):-
    bagof(top_level_goal(ET,G,CTX, HISTORY), event(_ , ET, G, null, CTX, 
                                                   active, HISTORY), 
          TOPLEVELEVENTS),
    length(TOPLEVELEVENTS, NOTLE).

number_of_top_level_events(0).


number_of_intentions(NOI):-
    bagof(IntentionIndex,intention(IntentionIndex,_,_), Intentions),
    length(Intentions, NOI).

number_of_intentions(0).  

number_of_top_level_goals(NOTLG):-
    % actually, top level events + number of active intentions
    number_of_top_level_events(NOTLE),
    number_of_intentions(NOI),
    NOTLG is NOTLE + NOI.

number_of_top_level_goals(0). 



mcts_compute_reward(_ , 0, _, 0).

mcts_compute_reward(_ , _, 0, 0).

mcts_compute_reward(0, GoalsTotal, GoalsAchieved, Reward):-
    Reward is (GoalsAchieved/GoalsTotal).

mcts_compute_reward(Awerage, GoalsTotal, GoalsAchieved, Reward):-
    Reward is ((1/(Awerage/3+1))*(GoalsAchieved/GoalsTotal)),
    print_debug('R:',mctsdbg),println_debug(Reward,mctsdbg).

	                  
   

mcts_expansion_loop( _, 0, _, _).  


mcts_expansion_loop(Program, EXPANSIONS, GOALSTOTAL, SIMULATIONS):-
    late_bindings(BINDINGS),
    % in FragMCTSModel.pl, second term is UCB (true) just score (false)
    mcts_get_best_ucb_path(Path, true),            
    print_debug('[MCTS] Path is:', mctsdbg), 
    println_debug(Path, mctsdbg),
    intention_fresh(INTENTIONFRESH),
    event_fresh(EVENTFRESH),
    mcts_simulation_steps(SIMULATIONSTEPS),
    loop_number(AGENTLOOP),
    thread_self(Agent),
	
    is_debug(mctsdbg, DEBUG),

    engine_create(run_result(_ ,_), 
    		  mcts_frag_engine(Program, INTENTIONFRESH, EVENTFRESH, Path, 
                                   EXPANDED, EXPANSIONS, SIMULATIONSTEPS, 
                                   SIMULATIONS, AGENTLOOP, Agent, BINDINGS,
                                   DEBUG), 
                  ENGINE),

    println_debug('[MCTS] Engine next', mctsdbg),
    println_debug(Program, mctsdbg),
    engine_next(ENGINE, runResult(RESULTS, 0, EXPANDED, GOALSREMAIN)),
    println_debug('[MCTS] Engine finished', mctsdbg),
    
    
    engine_destroy(ENGINE),
    member(leaf_node(LEAF), Path),
  
    sumlist(RESULTS, SUMLIST),
    length(RESULTS, LENGTH),
    Average is SUMLIST/LENGTH,
    GOALSACHIEVED is GOALSTOTAL - GOALSREMAIN,
              
    print_debug('[MCTS] +++ Result is: ', mctsdbg), 
    println_debug(RESULTS, mctsdbg),
    print_debug('[MCTS] +++ Expanded ', mctsdbg), 
    println_debug(EXPANDED, mctsdbg),
    print_debug('[MCTS] +++ Average: ', mctsdbg), 
    println_debug(Average, mctsdbg),
    print_debug('[MCTS] +++ Goals total: ', mctsdbg), 
    println_debug(GOALSTOTAL, mctsdbg),
    print_debug('[MCTS] +++ Goals remain: ', mctsdbg), 
    println_debug(GOALSREMAIN, mctsdbg),

    mcts_compute_reward(Average, GOALSTOTAL, GOALSACHIEVED, REWARD), % TODO, toto je provizorni
    println_debug(mcts_compute_reward(Average, GOALSTOTAL, GOALSACHIEVED, REWARD),mctsdbg),
    
    print_debug('[MCTS] Reward: ',mctsdbg), 
    println_debug(REWARD, mctsdbg),

    mcts_print_model(mctsdbg),

    mcts_increment_path(Path, REWARD),
    mcts_expand_node(LEAF, EXPANDED),
    
    Expansions2 is EXPANSIONS - 1,
    print_debug('[MCTS] Expansions ', mctsdbg), 
    println_debug(Expansions2,  mctsdbg),	
    mcts_expansion_loop(Program, Expansions2, GOALSTOTAL, SIMULATIONS).



mcts_simulation(Program, Expansions, Simulations):-
    mcts_model_init,   
    number_of_top_level_goals(Goals_Total),   
    mcts_expansion_loop(Program, Expansions, Goals_Total, Simulations).
                                                 
            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Work with model

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_mcts_model(Debug):-
    println_debug('MODEL', Debug),
    mcts_print_model(Debug),
    println_debug('', Debug),
    println_debug('', Debug),
    println_debug('', Debug),
    % in FragMCTSModel.pl, second term is UCB (true) just score (false)
    mcts_get_best_ucb_path(Path, true),            
    println_debug('Best path is:', Debug),
    mcts_print_path(Path, Debug),
    println_debug('', Debug).




update_model(mcts_reasoning):-
    late_bindings(BINDINGS),
    retractall(simulate_late_bindings( _ )),
    assert(simulate_late_bindings(BINDINGS)),
    println_debug('[MCTS] Updating model',mctsdbg),
    % here allways late bindings (for mcts simulation)
    % set_late_bindings(true),			
    % in Program is now a snapshot of actual agent state
    take_snapshot(Program),                 	
    % ProgramS does not produce outputs now
    silence_program(Program, Silent_Program),      	

    println_debug('',mctsdbg),
    println_debug(Silent_Program, mctsdbg),
    println_debug('simstr',mctsdbg),
    % Expansions <- number of expansions per (the next) simulation
    mcts_expansions(Expansions),          	
    % Number of simulations per expansion	    
    mcts_number_of_simulations(SIMULATIONS),	

    mcts_simulation(Silent_Program, Expansions, SIMULATIONS),
    print_mcts_model(mctsdbg_path),
    mcts_get_best_ucb_path(PATH, false),
    % REASONING: 'reasoning node' prefix of PATH, ACT is the first ACT in PATH
    mcts_divide_path(PATH, REASONING, ACT),         
    print_debug('[MCTS] Path:', mctsdbg),
    println_debug(PATH, mctsdbg),
    print_debug('[MCTS] Reasoning prefix:', mctsdbg),println_debug(REASONING, mctsdbg),
    print_debug('[MCTS] First action:', mctsdbg),println_debug(ACT, mctsdbg),
    retractall(recomended_path( _, _)),
    assert(recomended_path(REASONING, ACT)).
    % simulate_late_bindings(BINDINGS),
    % println_debug(set_late_bindings(BINDINGS), interdbg),
    % restore bindings policy, tohle asi neni nutne, je to lokalni pro vlakna 
    % (v agentnim se nezmeni) // ZASTARELE
    % set_late_bindings(BINDINGS).			    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         Exported clauses for reasoning
%

% first act is the fourth in the path, the first tuple is root, the third is node id                
get_first_act([_, _, ID, Act|_], ID, Act). 

get_first_act(_, null, no_action).   % root only, finished    


get_plan_for_goal(event(EVENTINDEX, GOALTYPE, GOALPREDICATE, INTENTION, 
                        GOALCTX, STATE, HISTORY), 
                  REASONINGNODES, Plan_ID):-
    	
% plan(Plan_ID,PLANTYPE,PLANPREDICATE,CTXCONDITIONS,BODY,PLANCTX)):-
  
    member(model_reasoning_node(event(EVENTINDEX, GOALTYPE, GOALPREDICATE, INTENTION, GOALCTX, STATE, HISTORY),
    plan(Plan_ID, PLANTYPE,PLANPREDICATE,CTXCONDITIONS,BODY),PLANCTX),REASONINGNODES),
    delete(REASONINGNODES,
           model_reasoning_node(event(EVENTINDEX, GOALTYPE, GOALPREDICATE, 
                                      INTENTION, GOALCTX, STATE, HISTORY),
    plan(Plan_ID,PLANTYPE,PLANPREDICATE,CTXCONDITIONS,BODY),PLANCTX), REASONINGNODES2),
    recomended_path( _, ACT),
    retractall(recomended_path(_,ACT)),                             % delete this reasoning node and update
    assert(recomended_path(REASONINGNODES2,ACT)).
    

get_plan_for_goal(_, _, no_plan, _).    


get_intention(mcts_reasoning,Intentions,intention(INTIDX,CONTENT,active)):-
    print_debug('[INTER] ++++++  GET INTENTION:', interdbg),
    recomended_path(_ ,[model_act_node(INTIDX,_,_)]),
    println_debug(model_act_node(INTIDX,_,_), interdbg),
    member(intention(INTIDX,CONTENT,active),Intentions).
                

 

rename_substitution_vars([],[],[]).

rename_substitution_vars([ _=C | T1], [B | T2], [B=C | T3]):-
    rename_substitution_vars(T1,T2,T3).



get_model_act(MODELACT, MODELSUBSTITUTION):-
%	recomended_path( _, [model_act_node( _, act(ENVIRONMENT, silently_(MODELACT)), [MODELSUBSTITUTION])]).	
    recomended_path( _, [model_act_node( _, act(_ , silently_(MODELACT)), [MODELSUBSTITUTION])]).	

get_model_act(MODELACT, MODELSUBSTITUTION):-
    recomended_path( _, [model_act_node( _, act(silently_(MODELACT)), [MODELSUBSTITUTION])]).	

get_model_act(MODELACT, MODELSUBSTITUTION):-
    recomended_path( _, [model_act_node( _, test(MODELACT), [MODELSUBSTITUTION])]).	

get_model_act(MODELACT, MODELSUBSTITUTION):-
    recomended_path( _, [model_act_node( _, add(MODELACT), [MODELSUBSTITUTION])]).	

get_model_act(MODELACT, MODELSUBSTITUTION):-
    recomended_path( _, [model_act_node( _, del(MODELACT), [MODELSUBSTITUTION])]).	


get_substitution(mcts_reasoning, ACTION, CTXS, VARS, NCTX):-
  %       findings_deliberation_made( First level of model ... list of [deliberation(goal,plan)]
  
    println_debug('[INTER] ++++  GET ACTION:', interdbg),
    print_debug('[INTER] ACTION:', interdbg),
    println_debug(ACTION, interdbg),
  	
    print_debug('[INTER] CTXS:', interdbg),
    println_debug(CTXS, interdbg),   % nepotrebujeme kontext, mame ho v modelu
    print_debug('[INTER] VARS:', interdbg),
    println_debug(VARS, interdbg),

    get_model_act(MODELACT, MODELSUBSTITUTION),

%       recomended_path(REASONING,[model_act_node(_,_,[MODELSUBSTITUTION])]),

    print_debug('MODELACT:', interdbg),
    println_debug(MODELACT, interdbg),
    print_debug('MODELCTX:', interdbg),
    println_debug(MODELSUBSTITUTION, interdbg),
    apply_substitutions(MODELSUBSTITUTION),
    print_debug('MODELACTSUB:', interdbg),
    println_debug(MODELACT, interdbg),
    %  	rename_substitution_vars(MODELCTX,VARS,NCTX),
    unifiable(ACTION, MODELACT, NCTX),  
    println_debug('DONE', interdbg),
    println_debug(NCTX, interdbg).
	
    
  % set_root_node(ID),    % set root pointer to this node

  % random_member(CTXH,CTXS),
  % shorting(CTXH,VARS,NCTX), % from file FRAgPLFRAg
  %       print_debug('NCTX:',mctsdbg_path),
  % println_debug(NCTX,mctsdbg_path).

  

% get_plan(mcts_reasoning,RAPLANS,plan(ID,PTYPE,PTRIGEVENT,PCONDITIONS,PBODY,PCONTEXT)):-

get_plan2(RAPLANS,IMEANSIDX, [plan(IMEANSIDX,TYPE,PREDICATE,CTXCONDITIONS,BODY),CTX]):-
    member([plan(IMEANSIDX,TYPE,PREDICATE,CTXCONDITIONS,BODY),CTX],RAPLANS).

get_plan2(_,_,[]).


get_plan(mcts_reasoning, Event, Means, Intended_Means):-
    println_debug('++++  GET PLAN:', interdbg),
    print_debug('EVent:', interdbg),
    println_debug(Event, interdbg),
    print_debug('Possible Means:', interdbg),
    println_debug(Means, interdbg),!,  
    recomended_path(Reasoning_Nodes, _),
    print_debug('Recomended Path (REASONINGNODES):', interdbg),
    println_debug(Reasoning_Nodes, interdbg),!,  
    get_plan_for_goal(Event, Reasoning_Nodes, Means_Index),
    print_debug('IM Index:', interdbg),
    println_debug(Means_Index, interdbg),!,
    get_plan2(Means, Means_Index, Intended_Means),
    print_debug('Chosen plan:', interdbg),
    println_debug(Intended_Means, interdbg).
    
get_plan(mcts_reasoning,_,_,[]).



%
%	INIT
%

set_mcts_parameters(Expansions, Simulations):-
    retractall(mcts_expansions( _ )),	
    retractall(mcts_number_of_simulations( _ )),
    assert(mcts_expansions(Expansions)),
    assert(mcts_number_of_simulations(Simulations)).

     
init_reasoning(mcts_reasoning):-
    % tohle lze vytahnout z agentniho lb pred spustenim mcts vlakna
    late_bindings(Bindings),			
    % dtto
    assert(simulate_late_bindings(Bindings)),       
    mcts_default_expansions(Expansions),
    mcts_default_number_of_simulations(Simulations),
    set_mcts_parameters(Expansions, Simulations),
    mcts_model_init. 

