

/**

This file is part of the FRAg program. It is insluded into agent's file 
FRAgAgent.pl. It contains clauses that are applied to strategies for selecting 
intentions, plans and substitutions. MCTS reasoning performs selection of 
actions, plans and substitutions based on Monte Carlo Tree Search simulations.

@author Frantisek Zboril
@version 2022 - 2024
@license GPL

*/


% This module is loaded / included in the FRAgAgent file

% :-thread_local tree_node/5.				% id node, action, children, visited, points

%  :- use_module('FRAgMCTSModel').


:-dynamic simulate_late_bindings/1.		% should do the tree for early bindings (expand individual reasonings and tests?)
:-dynamic mcts_default_expansions/1.
:-dynamic mcts_default_number_of_simulations/1.
:-dynamic mcts_simulation_steps/1.
% based on model, either greedy, or ucb
:-thread_local recomended_path/2.			
:-thread_local mcts_expansions/1.
:-thread_local mcts_number_of_simulations/1.



:-include('FRAgMCTSModel.pl').  % internal actions library


%
%	Static atoms
%

mcts_default_expansions(10).
mcts_default_number_of_simulations(10).
mcts_simulation_steps(100).

reasoning_method(mcts_reasoning).


% actual path found by last mcts execution, first is reasoning prefix,
% then action?

recomended_path([],[]).

% signalizes that mcts model is needed to mantain during agent's execution
% for this type of reasoning


%!  set_reasoning_method_params(Parameters) is det
%  @arg Parameters: expected mcts_params(+Expansions, +Simulations, +Steps)
%  @Expansions: Number of expansions during model update
%  @Simulations: Number of rollout simulations per expansion
%  @Steps: Maximal number of loops/steps in simulation, when agent does not 
%   finish, then is aborted by force after Steps loops

set_reasoning_method_params(mcts_params(Expansions, Simulations, Steps)):-
    retractall(mcts_default_expansions( _ )),
    retractall(mcts_default_number_of_simulations( _ )),
    retractall(mcts_simulation_steps( _ )),
    assert(mcts_default_expansions(Expansions)),
    assert(mcts_default_number_of_simulations(Simulations)),
    assert(mcts_simulation_steps(Steps)).


%
%  strom -> akce, potomkovske akce
%  akce -> vyber planu pro zamer, nebo akce planu 
%                     (ale bude to mit desne vetveni)
%




%
% Reasoning redefined here ... gets all options for all the goals
%
%

get_decisions(PUS, Variables, Decisions):-
    shorting_pus(PUS, Variables, Decisions).


perform_reasoning( _, _):-
    true.



%
% expand actions -> gets all possible actions + decisions
%


% get_actions ... add, del, act (with decisionings) test, ach (just goals,
% no context selection/decisions)

get_all_action_decisions2(_, _, [], []).

get_all_action_decisions2(Intention_Index, Action, [Decision| Decisions],
                          [model_act_node(Intention_Index, Action, [Decision])|
                              Acts]):-
    get_all_action_decisions2(Intention_Index, Action, Decisions, Acts).


% Action is ground
get_all_action_decisions(Intention_Index, Action, _,
                         [model_act_node(Intention_Index, Action,[[]])])
    :-
    term_variables(Action, []).


get_all_action_decisions(Intention_ID, Action, Context, Actions):-
    term_variables(Action, Variables),
    get_decisions(Context, Variables, Decisions),
%	write("decisions: "), write(get_decisions(CONTEXT, VARS, DECISIONS)),
    get_all_action_decisions2(Intention_ID, Action, Decisions, Actions).


% For late bindings goals actions (test, ach) are abstracted without decisions
% in the case of early bindings, must be also expanded for individual decisions

get_actions(Intention_Index, test(Goal), _,
            [model_act_node(Intention_Index, test(Goal),[[]])])
    :-
    simulate_late_bindings(true).


get_actions(Intention_Index, test(Goal), Context, Actions):-
% test goal is set with its results, should be simulated
    bagof(fact(Goal), fact(Goal), Test_Goals),
    broad_unification(fact(Goal), Test_Goals, Context2),
    restriction(Context, Context2, Context3),
    get_all_action_decisions(Intention_Index, test(Goal), Context3, Actions).


% tato akce ma spadnout, takze nechame test goal jak byl (i kdyby nahodou ve
% skutecnosti prosel)
get_actions(Intention_Index, test(Goal), _,
            [model_act_node(Intention_Index, test(Goal),[[]])]).
% test goal is set with its results, should be simulated


get_actions(Intention_Index, rel(Relation), _,
            [model_act_node(Intention_Index, rel(Relation),[[]])]).
% test goal is set with its results, should be simulated


% case of late bindings
get_actions(Intention_Index, ach(Goal),_ ,
            [model_act_node(Intention_Index, ach(Goal),[[]])]):-
    simulate_late_bindings(true).

get_actions(Intention_ID, ach(Goal), Context, Actions):-
    get_all_action_decisions(Intention_ID, ach(Goal), Context, Actions).

get_actions(Intention_ID, add(Goal), Context, Actions):-
    get_all_action_decisions(Intention_ID, add(Goal), Context, Actions).

get_actions(Intention_ID, del(Goal), Context, Actions):-
    get_all_action_decisions(Intention_ID, del(Goal), Context, Actions).

get_actions(Intention_ID, act(Goal), Context, Actions):-
    get_all_action_decisions(Intention_ID, act(Goal), Context, Actions).

get_actions(Intention_ID, act(Environment, Goal), Context, Actions):-
    get_all_action_decisions(Intention_ID, act(Environment, Goal), Context,
                             Actions).


% expand state -> all possible actions

model_expand_actions2([],[]).   % no intention left, no actions

model_expand_actions2([intention(Intention_ID ,
                                [plan( _, _, _, _, _, [])| _],
                                active) |
                          Intentions],
                      [model_act_node(Intention_ID, true, [])| Acts]
                     ):-
    model_expand_actions2(Intentions, Acts).

model_expand_actions2([intention(Intention_ID ,
                                 [plan( _, _, _, _, Context, [Act | _])| _],
                                       active) | Intentions], Acts3):-
    get_actions(Intention_ID, Act, Context, Acts),
    format(atom(String),"[MCTS] +++ Actions to expand: ~w", [Acts]),
    println_debug(String, mctsdbg),
    sort(Acts, Acts_Sorted),    % remove duplicates
    model_expand_actions2(Intentions, Acts2),
    append(Acts_Sorted, Acts2, Acts3).


model_expand_actions(Actions):-
    bagof(intention(Intention_ID,Plan_Stack, Status),
          intention(Intention_ID, Plan_Stack, Status), Intentions),
    model_expand_actions2(Intentions, Actions),
    format(atom(String),"[MCTS] Expanded actions: ~w",[Actions]),
    println_debug(String, mctsdbg).

model_expand_actions([]).   % in the case there is no intention


%
% expand state -> all possible deliberations
%
%!  model_expand_deliberations(
%TODO


model_expand_deliberations(Deliberations):-
    bagof(event(EVENTINDEX, Type,Predicate,Intention, Context,active, History),
	  event(EVENTINDEX, Type,Predicate,Intention, Context,active, History),
	  Events),
    !,
    model_expand_deliberations2(Events, Deliberations).

model_expand_deliberations([]).   % in the case there is no goal



model_expand_deliberations2([], []).

model_expand_deliberations2([event(EVENTINDEX, Type, Predicate,Intention,Context,State, HISTORY)| TEVENTS], Deliberations):-
    get_relevant_applicable_plans(Type, Predicate, Context, RAPlans),
    println_debug("[MCTS] Expand RA, RAPlans:", mctsdbg),
    println_debug(RAPlans, mctsdbg),
    model_expand_deliberations3(event(EVENTINDEX, Type,Predicate,Intention,Context,State, HISTORY), RAPlans, RAPlans_elements),
    model_expand_deliberations2(TEVENTS, RAT),
    append(RAPlans_elements, RAT, Deliberations).

  % no RE plans
model_expand_deliberations2([event( _, _, _, _, _, _, _)| Events], MEANS):-
        model_expand_deliberations2(Events, MEANS).



model_expand_deliberations3(_,[],[]).

model_expand_deliberations3(Goal,[[plan(Plan_ID, Event_Type, Event_Atom,
                                        Conditions, Body), Context]| Plans],
                            Deliberation_Nodes):-
    model_expand_deliberations4(Goal,[plan(Plan_ID, Event_Type, Event_Atom,
                                           Conditions, Body), Context], MDNT1),
    model_expand_deliberations3(Goal, Plans, MDNT2),
    append(MDNT1,MDNT2,Deliberation_Nodes).



model_expand_deliberations4(Goal,
                           [plan(Plan_ID, Goal_Type, Goal_Atom, Conditions ,
                                 Plan_Body), Context],
                           [model_reasoning_node(Goal,
                                                 plan(Plan_ID,Goal_Type,
                                                      Goal_Atom, Conditions,
                                                      Plan_Body),
                                                 Context)]):-
    simulate_late_bindings(true).

model_expand_deliberations4(_,[_,[]], []).

model_expand_deliberations4(Goal, [plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody),[Unif| T]],
    [model_reasoning_node(Goal, plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody), [Unif])| MDNT]):-
    model_expand_deliberations4(Goal, [plan(PlanNumber,PlanType,PlanGoal,PlanGuards,PlanBody),T], MDNT).



% Silence program / plan ... translates plan such that all act(ACT) in the 
% program plans which are not relations or 'is' are translated to act(__foo(ACT))
% such act is not executed, but the decision on the variables in ACT is kept
%


silence_program([],[]).

silence_program(
    [plan(Plan_ID, Goal_Type, Goal_Atom, Conditions, Context, Acts)| Plans],
    [plan(Plan_ID, Goal_Type, Goal_Atom, Conditions, Context, Acts2)| Plans2]):-
    silence_plan(Acts,Acts2),
    silence_program(Plans,Plans2).

silence_program(
    [plan(Goal_Type, Goal_Atom, Conditions, Context, Acts)| Plans],
    [plan(Goal_Type, Goal_Atom, Conditions, Context, Acts2)| Plans2]):-
    silence_plan(Acts,Acts2),
    silence_program(Plans,Plans2).


silence_program([intention(A,Plans,C)|T], [intention(A,Plans2,C)|T2]):-
    silence_program(Plans,Plans2),
    silence_program(T,T2).

silence_program([H|T], [H|T2]):-
    silence_program(T,T2).



silence_plan([],[]).

silence_plan([act(A is B)| Acts1], [act(A is B)| Acts2]):-
    silence_plan(Acts1, Acts2).

silence_plan([act(Act)| Acts1], [act(Act)| Acts2]):-
    Act=..[Operation, _, _],
    relational_operator(Operation),        % in the FragPLActions.pl file
    silence_plan(Acts1, Acts2).

silence_plan([act(Act)| Acts1], [(act(silently_(Act)))| Acts2]):-
%  the only modification is here (act that is not 'is' or relops)
    silence_plan(Acts1, Acts2).

silence_plan([act(Environment, Act)| Acts1],
             [(act(Environment, silently_(Act)))| Acts2]):-
%  the only modification is here (act that is not 'is' or relops)
    silence_plan(Acts1, Acts2).

silence_plan([H|T],[H|T2]):-
    silence_plan(T,T2).



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
%	Start of engine code
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
    assert(intention_fresh(INTENTIONFRESH)),		% ponecham jako v originalnim vlakne
    assert(event_fresh(EVENTFRESH)),

    println_debug('+++++ PATH +++++', mctsdbg),

    mcts_print_path(Path, mctsdbg),

    print_state('MCTS BEFORE FORCE PATH'),
    force_execute_model_path(Path),			% executes program in Path
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
%	End of engine code
%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


number_of_top_level_events(Number):-
    bagof(top_level_goal(Event_Type, Event_Atom, Context, History),
          event(_ , Event_Type, Event_Atom, null, Context,
                                                   active, History),
          Top_Level_Goals),
    length(Top_Level_Goals, Number).

number_of_top_level_events(0).


number_of_intentions(Number):-
    bagof(IntentionIndex,intention(IntentionIndex,_,_), Intentions),
    length(Intentions, Number).

number_of_intentions(0).

number_of_top_level_goals(Number):-
    % actually, top level events + number of active intentions
    number_of_top_level_events(Number1),
    number_of_intentions(Number2),
    Number is Number1 + Number2.

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         Exported clauses for reasoning
%

% first act is the fourth in the path, the first tuple is root, the third is node id
get_first_act([_, _, ID, Act|_], ID, Act).

get_first_act(_, null, no_action).   % root only, finished


get_plan_for_goal(event(Event_ID, Event_Type, Event_Atom, INTENTION,
                        GOALCTX, STATE, HISTORY),
                  REASONINGNODES, Plan_ID):-

% plan(Plan_ID,PLANTYPE,PLANPREDICATE,CTXCONDITIONS,BODY,PLANCTX)):-

    member(model_reasoning_node(event(Event_ID, Event_Type, Event_Atom, INTENTION, GOALCTX, STATE, HISTORY),
    plan(Plan_ID, PLANTYPE,PLANPREDICATE,CTXCONDITIONS,BODY),PLANCTX),REASONINGNODES),
    delete(REASONINGNODES,
           model_reasoning_node(event(Event_ID, Event_Type, Event_Atom,
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



get_model_act(Model_Act, Substitution):-
%	recomended_path( _, [model_act_node( _, act(ENVIRONMENT, silently_(MODELACT)), [MODELSUBSTITUTION])]).
    recomended_path( _, [model_act_node( _, act(_ , silently_(Model_Act)), [Substitution])]).

get_model_act(Model_Act, Substitution):-
    recomended_path( _, [model_act_node( _, act(silently_(Model_Act)), [Substitution])]).

get_model_act(Model_Act, Substitution):-
    recomended_path( _, [model_act_node( _, test(Model_Act), [Substitution])]).

get_model_act(Model_Act, Substitution):-
    recomended_path( _, [model_act_node( _, add(Model_Act), [Substitution])]).

get_model_act(Model_Act, Substitution):-
    recomended_path( _, [model_act_node( _, del(Model_Act), [Substitution])]).


get_substitution(mcts_reasoning, Action, Contexts, Vars, Context_Out):-
% findings_deliberation_made( First level of model ... list of [deliberation(goal,plan)]

    println_debug('[INTER] ++++  GET ACTION:', interdbg),
    print_debug('[INTER] ACTION:', interdbg),
    println_debug(Action, interdbg),

    print_debug('[INTER] CTXS:', interdbg),
    println_debug(Contexts, interdbg),   % nepotrebujeme kontext, mame ho v modelu
    print_debug('[INTER] VARS:', interdbg),
    println_debug(Vars, interdbg),

    get_model_act(Model_Act, Model_Substitution),

% recomended_path(REASONING,[model_act_node(_,_,[MODELSUBSTITUTION])]),

    print_debug('MODELACT:', interdbg),
    println_debug(Model_Act, interdbg),
    print_debug('MODELCTX:', interdbg),
    println_debug(Model_Substitution, interdbg),
    apply_substitutions(Model_Substitution),
    print_debug('MODELACTSUB:', interdbg),
    println_debug(Model_Act, interdbg),
    %	rename_substitution_vars(MODELCTX,VARS,NCTX),
    unifiable(Action, Model_Act, Context_Out),
    println_debug('DONE', interdbg),
    println_debug(Context_Out, interdbg).




% get_plan(mcts_reasoning,RAPLANS,plan(ID,PTYPE,PTRIGEVENT,PCONDITIONS,PBODY,PCONTEXT)):-

get_plan2(Means, Plan_ID, [plan(Plan_ID, Event_Type, Event_Atom, Conditions, Body), Context]):-
    member([plan(Plan_ID, Event_Type, Event_Atom, Conditions, Body), Context], Means).

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

