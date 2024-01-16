


:-module(miconic10,
    [                
% two or three arity clauses of the module name
% see documentation for FRAg environment realizations
	miconic10 / 2,
	miconic10 / 3,
	miconic10 / 4
    ]
).	

/** <module>  Miconic10 Environment for FRAg 

This module 

@author Frantisek Zboril
@license GPL
*/


:- dynamic situated_agents /1.  % Agents in this environment or clone
:- dynamic clone_situated /2.	% Clone, Agent
:- dynamic clone /2.		% Clone, Belief


:- dynamic number_of_floors /1.
:- dynamic no_access /2.
:- dynamic travelled_distance /1.



:-use_module('../FRAgPLEnvironmentUtils').   % interface to environments


/*
  Example model
*/

lift_at(f0).
origin(p1,f2).
origin(p2,f2).
origin(p3,f1).
origin(p4,f7).
origin(p5,f7).
origin(p6,f6).
origin(p7,f7).
destin(p1,f4).
destin(p2,f6).
destin(p3,f4).
destin(p4,f2).
destin(p5,f3).
destin(p6,f7).
destin(p7,f1).
position(f0,0).
position(f1,1).
position(f2,2).
position(f3,3).
position(f4,4).
position(f5,5).
position(f6,6).
position(f7,7).



floors_distance(Floor1,  Floor2, Distance):-
    position(Floor1, Position1),
    position(Floor2, Position2),
    Distance is abs(Position2 - Position1).




init_beliefs(Agents):-
    query_environment(miconic10, Agent, lift_at(Lift_Floor)),
    add_beliefs_agents(Agents, [lift_at(Lift_Floor)]),
    query_environment(miconic10, Agent, 
                      travelled_distance(Travelled_Distance)),
    findall_environment(miconic10, Agent, origin(Passenger, Floor), Beliefs1),
    findall_environment(miconic10, Agent, destin(Passenger, Floor), Beliefs2),
    findall_environment(miconic10, Agent, boarded(Passenger, Floor), Beliefs3),
    findall_environment(miconic10, Agent, served(Passenger, Floor), Beliefs4),
    add_beliefs_agents(Agents, [travelled_distance(Travelled_Distance)]),
    add_beliefs_agents(Agents, Beliefs1),
    add_beliefs_agents(Agents, Beliefs2),
    add_beliefs_agents(Agents, Beliefs3),
    add_beliefs_agents(Agents, Beliefs4).

/*
Exported clauses
*/


miconic10(add_agent, Agent):-
    situate_agent_environment(Agent, miconic10),
    init_beliefs([Agent]).

miconic10(add_agent, Agent, Clone):-
    situate_agents_clone([Agent], miconic10, Clone),
    init_beliefs([Agent]).



miconic10(perceive, Agent , Add_List, Delete_List):-
     retreive_add_delete(Agent, Add_List, Delete_List).
          
   
miconic10(set_property, Property_List).


	              
/*
	Acting
*/

	
    
exit_lift( _, []).

exit_lift(Agent, [boarded(Person, Floor)| Persons]):-
    delete_facts_beliefs(miconic10, Agent, [boarded(Person, Floor)]),
    add_facts_beliefs(miconic10, Agent, [served(Person)]),
%    format("Vystupuje mi pasazer ~w~n", [Person]),
    exit_lift(Agent, Persons).


process_transported(Agent, Floor):-
    findall_environment(miconic10, Agent, boarded(_ , Floor), To_Exit),
    exit_lift(Agent, To_Exit).


    
enter_lift( _, []).


enter_lift(Agent, [origin(Person, Floor) | Persons]):-
    delete_facts_beliefs(miconic10, Agent, [origin(Person, Floor), 
			   destin(Person, Floor_Destination)]),
%    format("Nastupuje mi pasazer ~w~n",[Person]),
    add_facts_beliefs(miconic10, Agent, [boarded(Person, Floor_Destination)]),
    enter_lift(Agent, Persons).                                  


process_waiting(Agent, Floor):-
    findall_environment(miconic10, Agent, origin(_, Floor), On_Board),
    enter_lift(Agent, On_Board).

 


%!  miconic10(act, +Agent, +Action, -Result) is det
%Situates agent to an environment. Agent will percieve the environment and
%may act in it
%  @arg Agent: agent name / identifier
%  @arg  Action: 
%	      go(+Floor_Destination)
%  @arg Result: action result (see results ling)




miconic10(act, Agent, go(Destination), true):-
    query_environment(miconic10, Agent, lift_at(Destination)),
    query_environment(miconic10, Agent, travelled_distance(Distance)).
%    format("~w: Nemusim nikad jezdit, uz jsem na poschod¡ ~w, 
%            celkem najeto ~w~n", [Agent, Destination, Distance]).

miconic10(act, Agent, go(Destination), true):-
    position(Destination, _),
    !,    
    query_environment(miconic10, Agent, lift_at(Floor_Actual)),
    process_waiting(Agent, Floor_Actual),
    floors_distance(Floor_Actual, Destination, Distance), % static beliefs
    delete_facts_beliefs_all(miconic10, Agent, 
                             [travelled_distance(Travelled_Distance)]),
    Travelled_Distance2 is Travelled_Distance + Distance,
    add_facts_beliefs_all(miconic10, Agent, 
                          [travelled_distance(Travelled_Distance2)]),	                   
%    format("~w: Pojedu z poschodi ~w do poschodi ~w, coz je ~w poschodi,
%    	    celkem najeto ~w ~n",
%	       [Agent, Floor_Actual, Destination, Distance, 
%               Travelled_Distance2]),
    process_waiting(Agent, Destination),
    delete_facts_beliefs_all(miconic10, Agent, [lift_at(Floor_Actual)]),
    add_facts_beliefs_all(miconic10, Agent, [lift_at(Destination)]),
    process_transported(Agent, Destination).


miconic10(act, Agent, silently_(go(Destination)), Result):-
    miconic10(act, Agent, go(Destination), Result).

miconic10(act, _, _, fail).

/*
	Kopie prostredi pro specifikovane agenty
	Udela kopii modelu a s tou pracuje, pokud act nebo percieve vola
 	uvedeny agent.
	Zruseni kopie -> smazani vsech klauzuli kopie (+ garbage collector?)
*/


miconic10(clone, Clone):-
    clone_environment(miconic10, Clone).
    

miconic10(remove_clone, Clone):-
    remove_environment_clone(miconic10, Clone).
 

miconic10(reset_clone, Clone):-
    reset_environment_clone(miconic10, Clone),
    get_all_situated(miconic10, Clone, Agents),   
    init_beliefs(Agents).  


miconic10(miconic10, Instance, State):-
    save_environment_instance_state(simple_counter, Instance, State).


miconic10(miconic10, Instance, State):-
    load_environment_instance_state(simple_counter, Instance, State).


miconic10(miconic10, Instance, State):-
    remove_environment_instance_state(simple_counter, Instance, State).




% Initialization
% miconic10(init, Agent_Name):-

:-
    env_utils:register_environment(miconic10),
    add_facts(miconic10, [travelled_distance(0)]),
    findall(lift_at(Floor), lift_at(Floor), Facts1),
    findall(position(Floor, Position), position(Floor, Position), Facts2),
    findall(origin(Passenger, Floor), origin(Passenger, Floor), Facts3),
    findall(destin(Passenger, Floor), destin(Passenger, Floor), Facts4),
    add_facts(miconic10, Facts1),
    add_facts(miconic10, Facts2),
    add_facts(miconic10, Facts3),
    add_facts(miconic10, Facts4).
    


                  