

path(construction, hall).
path(hall, construction).
path(hall, warehouse).
path(warehouse, workshop).
path(workshop, hall). 

machine(machine1, 6).
machine(machine2, true).
machine(machine3, 4).
machine(machine4, true).

resource(warehouse, plastic, 0).
resource(warehouse, stone, 0).
resource(warehouse, wood, 0).
resource(warehouse, metal, 0).
resource(warehouse, glass, 0).

task(glass, machine1).

% limit for issuing material
to_issue(80).

init_location(construction).


:- dynamic resource /3.
:- dynamic to_issue /1.
:- dynamic generate_resources_list /1.
:- dynamic task/2.
:- dynamic tasks_ratio /1.
:- dynamic to_issue /1.

generate_resources_list([]).
tasks_rate(5).

% !update_workshop_model is det
%  Updates models ... add resources and tasks, updates machines

update_workshop_model(Agent):-
    generate_resources_list(Resources),
    generate_resources(Resources, Agent),
    generate_tasks(Agent),
    repair_machines(Agent).
%    print_workshop_state.


repair_machines(Agent):-
    env_utils:findall_environment(workshop, Agent, machine( _, _), Machines),
    repair_machines(Agent, Machines).


repair_machines( _, []).

% the 'head' machine is ok
repair_machines(Agent, [machine( _, true)| Machines]):-
    repair_machines(Agent, Machines).

% the 'head' machines is about to be ok
repair_machines(Agent, [machine(Machine, 1)| Machines]):-
    env_utils:delete_facts_beliefs(workshop, Agent, [machine(Machine, 1)]),
    env_utils:add_facts_agent(workshop, Agent, [machine(Machine, true)]),
    repair_machines(Agent, Machines).

% the 'head' machines is under repair
repair_machines(Agent, [machine(Machine, Number)| Machines]):-
    Number1 is Number - 1,
    env_utils:delete_facts_beliefs(workshop, Agent, [machine(Machine, Number)]),
    env_utils:add_facts_agent(workshop, Agent, [machine(Machine, Number1)]),
    repair_machines(Agent, Machines).



print_workshop_state:-
    env_utils:findall_environment(workshop, resource(_, _, _), Resources),
    writeln('resources...'),
    writeln(Resources),
    env_utils:findall_environment(workshop, task(_, _), Tasks),
    writeln('tasks...'),
    writeln(Tasks).
    

generate_tasks(Agent):-
    tasks_rate(Tasks_Ratio),
    frag_stats:poisson_dist_sample(Tasks_Ratio, Number),
    generate_tasks(Number, Agent).


generate_tasks(0, Agent).

generate_tasks(N, Agent):-
    findall(m(Machine), env_utils:fact(workshop, workshop, machine(Machine, _)), 
                                       Machines),
    findall(r(Resource), env_utils:fact(workshop, workshop, 
            resource(_, Resource, _)), Resources),
    random_member(m(Machine2), Machines),
    random_member(r(Resource2), Resources),  
    env_utils:add_facts_agent(workshop, Agent, [task(Machine2, Resource2)]),
    N2 is N-1,
    generate_tasks(N2, Agent).

generate_tasks(N):- writeln(chyba).



% for Agent
generate_resources([], _).

generate_resources([Resource| Resources], Agent):-
    generate_resource(Resource, Agent),
    generate_resources(Resources, Agent).

generate_resource(resource(Material, Lambda), Agent):-
    frag_stats:poisson_dist_sample(Lambda, Number),
    writeln(poisson_dist_sample(Lambda, Number)),
    env_utils:query_environment(workshop, Agemt, to_issue(Number_Max)),
    Number2 is min(Number, Number_Max),
    Number3 is Number_Max - Number2,
    env_utils:query_environment(workshop, Agent, resource(warehouse, Material, Number4)),
    env_utils:delete_facts_agent(workshop, Agent, 
				   [to_issue(Number_Max),
			   	    resource(warehouse, Material, Number4)]),
    Number5 is Number4 + Number2,
    env_utils:add_facts_agent(workshop, Agent, 
			       [to_issue(Number3),
 				resource(warehouse, Material, Number5)]).

   
/*
 
% for original environment
generate_resources([]).

generate_resources([Resource| Resources]):-
    generate_resource(Resource),
    generate_resources(Resources).


% generates resource of material in number given by ~Pois(Lambra)
generate_resource(resource(Material, Lambda)):-
    frag_stats:poisson_dist_sample(Lambda, Number),
    increase_material_number(Material, Number, Number2),
    env_utils:add_facts(workshop, [resource(Location, Material, Number2)]).


% if there is some Material, then increase its number up to max_material

increase_material_number(Material, Number, Number_Out):-
   env_utils:query_environment(workshop, resource(Location, Material, 
                               Number2)),
   Number3 is Number+Number2,
   max_material(Number_Max),
   Number_Out is min(Number3, Number_Max).

increase_material_number(Material, Number, Number_Out):-
   to_issue(Number_Max),
   Number_Out is min(Number, Number_Max),
   To_Issue is Number_Max - Number,
   retractall(to_issue),
   assert(to_issue(To_Issue)).
*/ 





%	PLACE PERCEPTS - ADD/DELETE WHEN ROBOT CHANIGES PLACE

update_location_percepts(Agent):-
    env_utils:query_environment(workshop, Agent, location(Agent, Location)),
    delete_location_percepts(Location, Agent),
    add_location_percepts(Location, Agent).


add_location_percepts(Location, Agent):-
    get_location_percepts(Location, Agent, Percepts),
    env_utils:add_beliefs(Agent, Percepts).



%  delete all the percepts about machines, tasks, resources and products

delete_location_percepts(Location, Agent):-
     env_utils:delete_beliefs(Agent, [task( _, _), machine( _, _), 
			 	      resource( _, _, _), product( _, _, _)]).



% new tasks observed at 
get_location_percepts(construction, Agent, Percepts):-
    env_utils:findall_environment(workshop, Agent, task( _, _), 
				  Percepts).


% machines and their states
get_location_percepts(workshop, Agent, Percepts):-
    env_utils:findall_environment(workshop, Agent, machine( _, _), 
				  Machines),
    extract_machines(Machines, Percepts).


% resources
get_location_percepts(warehouse, Agent, Percepts):-
    env_utils:findall_environment(workshop, Agent, resource( _, _, _), 
				  Resources),
    extract_resources(Resources, Percepts).


get_location_percepts(_, _, []).




extract_machines([], []).

extract_machines([machine(Machine, State) | Machines], 
		 [machine(Machine, State) | Percepts]):-
    extract_machines(Machines, Percepts).

extract_machines([ _ | Machines], 
		 Percepts):-
    extract_machines(Machines, Percepts).

     

extract_resources([], []).

extract_resources([resource(_, _, 0) | Resources], 
		 Percepts):-
    extract_resources(Resources, Percepts).

extract_resources([resource(Location, Material, Number) | Resources], 
		 [resource(Location, Material, Number) | Percepts]):-
    extract_resources(Resources, Percepts).




get_place_percepts(warehouse, _, []).


