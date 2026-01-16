                                                             

/**

This file is part of the FRAg program. It is insluded into agent's file
FRAgAgent.pl. It contains clauses that are applied to strategies for selecting
intentions, plans and substitutions. MCTS reasoning in Python performs selection of
actions, plans and substitutions based on Monte Carlo Tree Search simulations.

@author Ondrej Misar
@license GPL

*/


% This module is loaded / included in the FRAgAgent file


reasoning_method(mcts_reasoning_integrated_python).


%    Simulations - rollouts for Integrated architecture
%==============================================================================
mcts_rollouts_integrated_python(Steps, FinalResult):-
    retractall(loop_number( _ )),
    assert(loop_number(1)),
    !,
    loop(Steps, Steps_Left),
    rewards_achieved(Rewards),
    !,
    clear_agent,
    delete_clauses,
    garbage_all,
    retractall(intention_fresh( _ )),
    retractall(event_fresh( _ )),
    FinalResult = runResult(Rewards).


%    Clauses exported for agent control loop (reasoning method interface)
%    Agent loop predicates are based on the FRAgPLReasoningMCTS.pl, only modification is for update_model
%===============================================================================

%!  update_model(mcts_reasoning_integrated_python) is nondet
%   updates the model for additional clauses. In this version, it creates a new
%   goal plan tree and assigns MCTS-based ratings to each node. It then extracts
%   the best path from this tree

update_model(mcts_reasoning_integrated_python):-
    writeln("Update model python starts"),
    late_bindings(Bindings),             
    retractall(simulate_late_bindings( _ )),
    assert(simulate_late_bindings(Bindings)),         
% here allways late bindings (for mcts simulation)
% set_late_bindings(true),
% in Program is now a snapshot of actual agent state
    take_snapshot(Program),                              
% ProgramS is silent - does not act toward environments (neither 'prints')
    silence_program(Program, Silent_Program),                      
% Expansions <- number of expansions per (the next) simulation
    mcts_expansions(Expansions),                        
% Number of simulations per expansion
    mcts_number_of_simulations(Simulations),      

% SIMULATIONS (MCTS ALGORITHM)STARTS HERE
    % Get information about environment
    get_default_environments([Environment|_]),
    current_module(Environment, Absolute_Module_Name),

    % Get all the environment facts
    env_utils:all_facts_struct(Environment, Agent, Facts),
    term_string(Facts, Facts_String),

    mcts_simulation_steps(Simulation_Steps),

    term_string(Silent_Program, Silent_Program_String),
 
    % OM %
    writeln("Before python program"),
    writeln(Silent_Program),
    %call python implementation
    py_func('../python_utils/misar/mcts_integrated', 
              get_result(Silent_Program_String, Facts_String, Expansions, 
                         Simulations, Simulation_Steps, Environment, 
                         Absolute_Module_Name), 
              Ret),
    writeln("After python program"),

    term_string([Reasoning, Act], Ret),
    writeln(Reasoning),
    writeln(Act),


    print_mcts_model(mctsdbg_path),

    format(atom(ReportS),"Reasoning prefix:~w
[MCTS] First action:~w",[Reasoning, Act]),
    println_debug(ReportS, mctsdbg),
    retractall(recomended_path( _, _)),
    assert(recomended_path(Reasoning, Act)).



%!  get_intention(mcts_reasoning_integrated_python, +Intentions, -Intention) is det
%
%  @arg Intentions: list of actual agent's Intentions, all active and blocked
%  @arg Intention: selected one of the actione intentions from Intentions
%    intention(Intention_ID, Content, active)

get_intention(mcts_reasoning_integrated_python, Intentions,
              intention(Intention_ID, Content, active)):-
    recomended_path(_ ,[model_act_node(Intention_ID,_,_)]),
    format(atom(IntentionS), '[GET INTENTION] ~w', 
           [model_act_node(Intention_ID, _, _)]),
    println_debug(IntentionS, interdbg),
    member(intention(Intention_ID, Content, active),Intentions).

%!  get_substitution(random_reasoning, +Action,
%                    +Context, +Vars, -Context_Out) is det
%   CAN decisioning in early bindings mode selects substitution randomly.
%   This clause is to select one of the set of substitutions and reduces it to
%   just the variables from Vars.
%  @arv Action: action the agent is about to execute
%  @arg Context_In: actual context of the agent
%  @arg Vars: the variables for which a decision is to be made
%  @arg Context_Out: output context for the Action


get_substitution(mcts_reasoning_integrated_python, Action, Contexts, Vars, Context_Out):-
% findings_deliberation_made( First level of model ... list of [deliberation(goal,plan)]

    println_debug('[GET SUBSTITUTION]', interdbg),
    format(atom(ActionS), "GS1 Action: ~w", [Action]),
    println_debug(ActionS, interdbg),

    format(atom(ContextsS), "GS2 Context: ~w", [Contexts]),
    println_debug(ContextsS, interdbg),   % nepotrebujeme kontext, mame ho v modelu
    format(atom(VarsS), "GS3 Variables: ~w", [Vars]),
    println_debug(VarsS, interdbg),

    get_model_act(Model_Act, Model_Substitution),

% recomended_path(REASONING,[model_act_node(_,_,[MODELSUBSTITUTION])]),

    format(atom(Model_ActS), "GS4 Model Act: ~w", [Model_Act]),
    println_debug(Model_ActS, interdbg),
    format(atom(Model_SubstitutionS), "GS5 Model Context: ~w", 
                [Model_Substitution]),
    println_debug(Model_SubstitutionS, interdbg),
    apply_substitutions(Model_Substitution),
    format(atom(Model_SubsS), "GS6 Model Act Subs: ~w", [Model_Act]),
    println_debug(Model_SubsS, interdbg),
    %	rename_substitution_vars(MODELCTX,VARS,NCTX),
    unifiable_s(Action, Model_Act, Context_Out),
    format(atom(Context_OutS), 'GS7 Context Out: ~w', [Context_Out]),
    println_debug(Context_OutS, interdbg).


%!  get_plan(mcts_reasoning_integrated_python, +Event, +Means, -Intended_Means) is det
%   Depending on how the model (tree) created in the simulations looks like, it
%   selects the means for the event from the listed means according to
%   the best evaluation.
%  @arg Event:
%  @arg Means:
%  @arg Intended_Means:


get_plan(mcts_reasoning_integrated_python, Event, Means, [IM_Plan, IM_Context]):-
    format(atom(PlanS),"[GET PLAN]: Event: ~w~nPossible Means: ~w",
		        [Event, Means]),
    println_debug(PlanS, interdbg),
    !,
    recomended_path([model_reasoning_node(Event, IM_Plan, IM_Context)| _], _),
    format(atom(NodesS), 'Recomended Plan ~w/~w:', [IM_Plan, IM_Context]),
    println_debug(NodesS, interdbg).

get_plan(mcts_reasoning_integrated_python, _, _, []).





%!  init_reasoning(mcts_reasoning_integrated_python) is det
%   initializes reasoning according to parameters, sets whether the agent works
%   in late or early bindings, the number of expansions and simulations

init_reasoning(mcts_reasoning_integrated_python):-
    % tohle lze vytahnout z agentniho lb pred spustenim mcts vlakna
    late_bindings(Bindings),
    % dtto
    assert(simulate_late_bindings(Bindings)),
    mcts_default_expansions(Expansions),
    mcts_default_number_of_simulations(Simulations),
    retractall(mcts_expansions( _ )),
    retractall(mcts_number_of_simulations( _ )),
    assert(mcts_expansions(Expansions)),
    assert(mcts_number_of_simulations(Simulations)),
    mcts_model_init.




