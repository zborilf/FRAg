:- module(garden, [
    garden/2,
    garden/3,
    garden/4
]).

:- use_module('../FRAgPLEnvironmentUtils').   % interface for environments

:- dynamic zone_moisture/2.
:- dynamic zone/2.
:- dynamic available_water/1.
:- dynamic critical_zone/1.

coords(a, [1,1]).
coords(b, [2,1]).
coords(c, [3,1]).
coords(d, [1,2]).
coords(e, [2,2]).
coords(f, [3,2]).
coords(g, [1,3]).
coords(h, [2,3]).
coords(i, [3,3]).

critical_zone(a).
critical_zone(i).

zone_moisture(a, 50).
zone_moisture(b, 80).
zone_moisture(c, 75).
zone_moisture(d, 100).
zone_moisture(e, 98).
zone_moisture(f, 55).
zone_moisture(g, 93).
zone_moisture(h, 85).
zone_moisture(i, 45).



zone(a, [1,1]).
zone(b, [2,1]).
zone(c, [3,1]).
zone(d, [1,2]).
zone(e, [2,2]).
zone(f, [3,2]).
zone(g, [1,3]).
zone(h, [2,3]).
zone(i, [3,3]).



available_water(10).

size_x(3).
size_y(3).

path_direction([X,Y], left, [X2, Y]):-
    size_x(X_Max),
    X>0,
    X2 is X-1.

path_direction([X,Y], right, [X2, Y]):-
    size_x(X_Max),
    X<X_Max,
    X2 is X+1.

path_direction([X,Y], up, [X, Y2]):-
    size_y(Y_Max),
    Y>0,
    Y2 is Y-1.

path_direction([X,Y], down, [X, Y2]):-
    size_y(Y_Max),
    Y<Y_Max,
    Y2 is Y+1.

assert_directions([]).

assert_directions([direction(C1, D, C2)| Directions]):-
    assertz(dirs(C1, D, C2)),
    assert_directions(Directions).  % should be added as environment's facts

init_directions:-
    findall(direction(Coords1,Coords2,D),(coords(_, Coords1), coords(_, Coords2),
	    path_direction(Coords1, D, Coords2)), Directions),
    env_utils:add_facts(garden, Directions),
    assert_directions(Directions).


init_zones:-
   findall(zone_moisture(Zone, Level), zone_moisture(Zone, Level), Zones_Moisture),
   retractall(zone_moisture(_, _)),
   env_utils:add_facts(garden, Zones_Moisture),

   findall(zone(Zone, Position), zone(Zone, Position), Zones),
   retractall(zone(_, _)),
   env_utils:add_facts(garden, Zones).


init_critical_zones:-
   findall(critical_zone(Zone), critical_zone(Zone), Zones),
   retractall(critical_zone(_)),
   env_utils:add_facts(garden, Zones).


init_available_water:-
   findall(available_water(Water), available_water(Water), Available_Water),
   env_utils:add_facts(garden, Available_Water).


init_beliefs([]).

init_beliefs([Agent | Agents]):-
    init_beliefs_agent(Agent),
    init_beliefs(Agents).


init_beliefs_agent(Agent):-
    writeln("Init belief garden env"),
    env_utils:query_environment(garden, Agent, position(Position)),
    env_utils:findall_environment(garden, Agent, critical_zone(_), Zones),
    env_utils:query_environment(garden, Agent, available_water(Water)),
    get_percepts_position(Position, Agent, Percepts),
    add_beliefs_agents([Agent], Zones),
    add_beliefs_agents([Agent], [available_water(Water)]),
    add_beliefs_agents([Agent], Percepts).




%!  get_percepts_position(+Position, -Percepts) is det
%@arg Position: Actual agent's position (room)
%@arg Percepts: List of percepts in that position (room)

get_percepts_position(Position, Agent, [zone(Zone, Position) |
					Percepts]):-
    env_utils:findall_environment(garden, Agent, (direction(Position, Position2, Direction)), Directions),
    assign_items_positions(Agent, Directions, Doors),
    env_utils:query_environment(garden, Agent, zone(Zone, Position)),
    append(Items, Doors, Percepts).


assign_items_positions(_, [],[]).

assign_items_positions(Agent, [direction(_, Position2, Direction)| Directions],
		       [door(Direction, Zone)| Doors]):-
    env_utils:query_environment(garden, Agent, zone(Zone, Position2)),
    assign_items_positions(Agent, Directions, Doors).








garden(add_agent, Agent):-
    situate_agent_environment(Agent, garden),
    env_utils:add_facts(garden, [position([1,1])]),
    env_utils:add_beliefs_agents([Agent], [my_position(a)]),
    init_beliefs_agent(Agent).

garden(add_agent, Agent, Clone):-
    situate_agents_clone([Agent], garden, Clone),
    init_beliefs([Agent]).

garden(add_agent, _, _).









%    Agent percieves

garden(perceive, Agent , Add_List, Delete_List):-
   retreive_add_delete(Agent, Add_List, Delete_List).








garden(act, Agent, go(Direction), true):-
    writeln("Going direction"),
    query_environment(garden, Agent, position(Position)),!,
    path_direction(Position, Direction, New_Position),
    coords(Room, Position),
    coords(New_Room, New_Position),
    delete_facts_agent(garden, Agent, [position(Position)]),
    add_facts_agent(garden, Agent, [position(New_Position)]),
    delete_beliefs(Agent, [my_position(Room)]),
    add_beliefs(Agent, [my_position(New_Room)]),
    change_room_percepts(Agent, Position, New_Position),
    !,
    degrade_all_zones(Agent).

garden(act, Agent, go(Direction), false).


garden(act, Agent, water, Result) :-
    writeln("Watering"),
    env_utils:query_environment(garden, Agent, available_water(Water)),!,
    Water > 0,
    env_utils:query_environment(garden, Agent, position(Position)),!,
    writeln(Position),
    env_utils:query_environment(garden, Agent, zone(Zone, Position)),!,
    env_utils:query_environment(garden, Agent, zone_moisture(Zone, OldM)),!,
    writeln(OldM),
    NewM is min(100, OldM + 30),
    writeln(NewM),
    env_utils:delete_facts_agent(garden, Agent, [zone_moisture(Zone, OldM)]),
    env_utils:add_facts_agent(garden, Agent, [zone_moisture(Zone, NewM)]),
    NewWater is Water - 1,
    env_utils:delete_facts_agent(garden, Agent, [available_water(Water)]),
    env_utils:add_facts_agent(garden, Agent, [available_water(NewWater)]),

     ( NewM =< 80 -> RewardVal = 2
     ; RewardVal = 1
     ),
     ( RewardVal > 0 -> Result = reward(RewardVal) ; Result = true ),


    env_utils:delete_beliefs(Agent, [available_water(Water)]),
    env_utils:add_beliefs(Agent, [available_water(NewWater)]),

    degrade_all_zones(Agent),
    update_critical_zones(Agent).

garden(act, Agent, water, false).


degrade_all_zones(Agent) :-
    env_utils:findall_environment(garden, Agent, zone_moisture(_, _), Zones),
    env_utils:delete_facts_agent(garden, Agent, Zones),
    forall(
        member(zone_moisture(Zone, OldM), Zones),
        degrade_zone_without_dead(Agent, Zone, OldM)
     ).


degrade_zone_without_dead(Agent, Zone, OldM) :-
    random_between(5,10,Decay),
    NewM is max(0, OldM - 4),
    env_utils:add_facts_agent(garden, Agent, [ zone_moisture(Zone, NewM) ]).

update_critical_zones(Agent) :-
    env_utils:findall_environment(garden, Agent, zone_moisture(Zone, Moisture), ZMs),
    sort(2, @=<, ZMs, SortedZMs),
    extract_two_zones(SortedZMs, WorstZones),
    env_utils:findall_environment(garden, Agent, critical_zone(Old), OldCrs),
    ( OldCrs \= [] ->
            env_utils:delete_facts_agent(garden, Agent, OldCrs),
            env_utils:delete_beliefs(Agent, OldCrs)
    ; true ),
    forall(
        member(Zone, WorstZones),
        ( env_utils:add_facts_agent(garden, Agent, [critical_zone(Zone)]),
          env_utils:add_beliefs(Agent, [critical_zone(Zone)]) )
    ).

extract_two_zones([], []).
extract_two_zones([zone_moisture(Z1,_)], [Z1]).
extract_two_zones([zone_moisture(Z1,_) , zone_moisture(Z2,_) | _], [Z1, Z2]).



change_room_percepts(Agent, Position1, Position2):-
    get_percepts_position(Position1, Agent, Percepts1),
    get_percepts_position(Position2, Agent, Percepts2),
    delete_beliefs(Agent, Percepts1),
    add_beliefs(Agent, Percepts2).



garden(act, Agent, silently_(go(Direction)), Result):-
    garden(act, Agent, go(Direction), Result).

garden(act, Agent, silently_(water), Result):-
    garden(act, Agent, water, Result).

garden(act, _, _, false).





garden(clone, Clone):-
    clone_environment(garden, Clone).


garden(remove_clone, Clone):-
    remove_environment_clone(garden, Clone).



garden(reset_clone, Clone):-
    reset_environment_clone(garden, Clone),
    get_all_situated(garden, Clone, Agents),
    init_beliefs(Agents).


garden(save_state, Instance, State):-
    save_environment_instance_state(garden, Instance, State).


garden(load_state, Instance, State):-
    load_environment_instance_state(garden, Instance, State).

garden(remove_state, Instance, State):-
    remove_environment_instance_state(garden, Instance, State).


:-
    env_utils:register_environment(garden),
    init_available_water,
    init_directions,
    init_zones,
    init_critical_zones.
