            

:-module(workshop,
    [
        workshop / 2,
	workshop / 3,
	workshop / 4
    ]
).


/**
@Author Frantisek Zboril jr.
@version 0.1 (2024) 
*/

:-use_module('../FRAgPLEnvironmentUtils').   % interface for environments
:-use_module('../FRAgPLStatsUtils').
:-use_module('../FRAgPLEpisodeSteps').

%   workshop model, state, clauses for model changes, model interface
:-include('workshop_model.pl').


episode(1).
% machine(+Type, +State).
%   @arg Type: unique machine identifier
%   @arg State: true - working, Number - Number of episodes out of order


                          

%!  workshop(++Functionality, +Parameters) is det 
%  @arg Functionality is one of 
%*      set_parameters 
%*      add_agent
%*      clone
%*      reset_clone
%*      remove_clone
%  @arg Attributes: List of parameters in the form of tuples
%   1. For functionality 'set_parameters' the parameters can be
%*      (resources, [(Material,Number)*])
%*	(failure_rate, [Mean, Dispersion]).
%*      (tasks, [Initial_Number, Lambda_Arrivals]).
%   2. For functionality 'add_agant' the parameter is agent's name


%===============================================================================
%                                                                              |
%    WORKSHOP INITALIZATION, MANAGEMENT, CLONING AND SITING AGENTS             |
%                                                                              |
%===============================================================================

%!  init_beliefs(+Agents)
%   Inserts beliefs has / price / sells to Agents
%  @arg Agents: List of agents for which beliefs should be initialized

init_beliefs(Agents):-
    Agents = [Agent | _],	% suppose all the agents are in the same instance
    init_location(Location),
    add_location_percepts(Location, Agent),
    env_utils:add_facts_agent(workshop, Agent, [location(Agent, Location)]),
    env_utils:add_beliefs(Agent, [location(Location)]),
    env_utils:add_facts_beliefs(workshop, Agent, [episode(1)]),
    env_utils:add_facts_beliefs(workshop, Agent, [reward(Agent, 0)]).



workshop(set_parameters, []).

workshop(set_parameters, [(Key, Value)| Parameters]):-
    set_parameter(Key, Value),
    workshop(set_parameters, Parameters).



set_parameter(resources, Resources):-
    retractall(generate_resources_list(_)),
    assert(generate_resources_list(Resources)).


set_parameter(tasks_rate, Task_Rate):-
   change_params(task_rate(Task_Rate)).    

change_params(Atom):-
   Atom=..[Predicate, _],
   Retract=..[Predicate, _],
   retract(Retract),
   assert(Atom).

change_params(Atom):-
    assert(Atom).



workshop(add_agent, Agent):-
    env_utils:situate_agent_environment(Agent, workshop),
    init_beliefs([Agent]).
    

workshop(add_agent, Agent, Clone):-
    env_utils:situate_agents_clone([Agent], workshop, Clone),
    init_beliefs([Agent]).
    


%!  workshop(add_agent, +Instance +Agent) is det
%   Adds agent Agent to the +Instance of workshop environment
%  @arg Agent: Name of the agent
%  @arg Instance: Insatnce of the workshop environment

workshop(add_agent, Agent, Clone):-
    env_utils:situate_agents_clone([Agent], workshop, Clone),
    init_beliefs([Agent]).


%!  workshop(clone, +Instance) is det
%   Creates a clone 
%  @arg Instance: Insatnce of the workshop environment

workshop(clone, Instance):-
    env_utils:clone_environment(workshop, Instance).


%!  workshop(reset_clone, +Clone) is det
%   Resets clone to its initial state
%  @arg Clone: workshop environment clone

workshop(reset_clone, Clone):-
    env_utils:reset_environment_clone(workshop, Clone),
    env_utils:get_all_situated(workshop, Clone, Agents),
    init_beliefs(Agents).


%!  workshop(remove_clone, +Clone) is det
%   Removes clone instance
%  @arg Clone:

workshop(remove_clone, Clone):-
    env_utils:remove_environment_clone(workshop, Clone).

workshop(save_state, Instance, State):-
    env_utils:save_environment_instance_state(workshop, Instance, State).

workshop(load_state, Instance, State):-
    env_utils:load_environment_instance_state(workshop, Instance, State).

workshop(remove_state, Instance, State):-
    env_utils:remove_environment_instance_state(workshop, Instance, State).




%===============================================================================
%                                                                              |
%    WORKSHOP PERCEIVING                                                       |
%                                                                              |
%===============================================================================

%!  workshop(perceive, +Agent, -Add_List, -Delete_List) is det
%   Provides environment updates to Agent as Add_List and Delete_List
%  @arg Agent: Agent that perceives some instance of workshop environment
%  @arg Add_List: New percept since last perceiving
%  @arg Delete_List: Disapeared peceps since last perceiving

workshop(perceive, Agent , Add_List, Delete_List):-
    check_episode(Agent),
    !,
    update_location_percepts(Agent),
    env_utils:retreive_add_delete(Agent, Add_List, Delete_List).


check_episode(Agent):-
% druhej workshop ma byt instance ws pro Agenta
    episode_steps:add_agent(Agent, workshop, workshop),
    episode_steps:is_new_episode,
    !,
    query_environment(workshop, Agent, episode(Episode)),
    delete_facts_beliefs_all(workshop, Agent,
                             [episode( Episode )]),
    Episode2 is Episode + 1,
    add_facts_beliefs_all(workshop, Agent, [episode(Episode2)]),
    update_workshop_model(Agent).

check_episode( _ ).

%===============================================================================
%                                                                              |
%    WORKSHOP ACTING	                                                       |
%                                                                              |
%===============================================================================


workshop(act, Agent, go(Location), true):-
writeln(herewego),
    env_utils:query_environment(workshop, Agent, location(Agent, Location2)),
    !,
    env_utils:query_environment(workshop, Agent, path(Location2, Location)),
    env_utils:delete_facts_agent(workshop, Agent, [location(Agent, Location2)]),
    env_utils:add_facts_agent(workshop, Agent, [location(Agent, Location)]),
    env_utils:delete_beliefs(Agent, [location(Location2)]),
    env_utils:add_beliefs(Agent, [location(Location)]).


workshop(act, Agent, pick(Material), false):-
    !,
    env_utils:query_environment(workshop, Agent, carry(Agent, _)).
                                                          
    
workshop(act, Agent, pick(Material), true):- 
    env_utils:query_environment(workshop, Agent, location(Agent, Location)),
    !,
    env_utils:query_environment(workshop, Agent, resource(Location, Material,
                                                          Number)),
    !,
    Number > 0,
    Number2 is Number - 1,
    env_utils:delete_facts_agent(workshop, Agent, [resource(Location, Material,
                                                            Number)]),
    env_utils:add_facts_agent(workshop, Agent, [resource(Location, Material,
                                                         Number2)]),
    env_utils:add_facts_beliefs(workshop, Agent, [carry(Agent,
                                                        resource(Material))]).


workshop(act, Agent, do(Machine, Material), true):-
    env_utils:query_environment(workshop, Agent, location(Agent, workshop)),
    !,
    env_utils:query_environment(workshop, Agent, machine(Machine, true)),
    !,
    env_utils:query_environment(workshop, Agent, carry(Agent, 
						       resource(Material))),
    env_utils:delete_facts_beliefs(workshop, Agent, 
                                   [carry(Agent, resource(Material))]),
    env_utils:add_facts_beliefs(workshop, Agent,[carry(Agent, product(Machine, Material))]).



workshop(act, Agent, submit, true):-
    env_utils:query_environment(workshop, Agent, location(Agent, construction)),
    !,
    env_utils:query_environment(workshop, Agent, carry(Agent, product(Machine, Material))),
    !,
    env_utils:query_environment(workshop, Agent, task(Machine, Material)),
    !,
    env_utils:query_environment(workshop, Agent, reward(Agent, Reward)),

    env_utils:delete_facts_beliefs(workshop, Agent, 
                                   [reward(Agent, Reward)]),


workshop(act, Agent, drop, true).




% every other act succeeds
workshop(act, Agent, _, false).





:-
    env_utils:register_environment(workshop),
    findall(resource(Kind, Number), resource(Locaion, Kind, Number), Facts1),
    findall(machine(Type, State), machine(Type, State), Facts2),
    findall(path(Location1, Location2), path(Location1, Location2), Facts3),
    findall(resource(Location, Material, Number), 
	    resource(Location, Material, Number), Facts4),
    to_issue(Material_To_Issue),
    episode(Episode),
    env_utils:add_facts(workshop, Facts1),
    env_utils:add_facts(workshop, Facts2),
    env_utils:add_facts(workshop, Facts3),
    env_utils:add_facts(workshop, Facts4),
    env_utils:add_facts(workshop, [episode(Episode)]),
    env_utils:add_facts(workshop, [to_issue(Material_To_Issue)]).


