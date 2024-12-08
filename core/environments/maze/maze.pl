

:-module(simple_maze,
    [
        simple_maze / 2,
	simple_maze / 3,			
	simple_maze / 4			
    ]
).


:-use_module('../FRAgPLEnvironmentUtils').   % interface for environments

:-dynamic dirs /3. % direction from one position to another
:-dynamic item /2. % items in a position

coords(a,[1,1]).
coords(b,[2,1]).
coords(c,[3,1]).
coords(d,[4,1]).
coords(e,[5,1]).
coords(f,[6,1]).
coords(g,[1,2]).
coords(h,[2,2]).
coords(i,[3,2]).
coords(j,[4,2]).
coords(k,[5,2]).
coords(l,[6,2]).
coords(m,[1,3]).
coords(n,[2,3]).
coords(o,[3,3]).
coords(p,[4,3]).
coords(q,[5,3]).
coords(r,[6,3]).
coords(s,[1,4]).
coords(t,[2,4]).
coords(u,[3,4]).
coords(v,[4,4]).
coords(w,[5,4]).
coords(x,[6,4]).
coords(y,[1,5]).
coords(z,[2,5]).
coords(aa,[3,5]).
coords(ab,[4,5]).
coords(ac,[5,5]).
coords(ad,[6,5]).
coords(ae,[1,6]).
coords(af,[2,6]).
coords(ag,[3,6]).
coords(ah,[4,6]).
coords(ai,[5,6]).
coords(aj,[6,6]).


item([2,2], gold).
item([3,3], gold).
item([4,4], gold).                                                   
item([5,5], gold).
item([6,6], gold).

path([A,B],[C,B]):-C is A+1.
path([A,B],[A,C]):-C is B+1.

size_x(6).
size_y(6).


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

assert_directions([direction(C1, C2, D)| Directions]):-
    assertz(dirs(C1, C2, D)),
    assert_directions(Directions).  % should be added as environment's facts

init_directions:-
    findall(direction(Coords1,Coords2,D),(coords(_, Coords1), coords(_, Coords2), 
	    direction(Coords1, Coords2, D)), Directions),
    assert_directions(Directions).


init_items:- 
   findall(item(Position, Item), item(Position, Item), Items),
    add_facts(simple_maze, Items).



direction([A,B],[C,D],down):- D>B, C>=A, !.
direction([A,B],[C,B],right):- C>A.


                 



print_directions:-
   tell('d.pl'),
   findall(direction(Room1, Room2 ,D),(coords(_, Coords1), coords(_, Coords2), 
	   direction(Coords1, Coords2, D), coords(Room1, Coords1),
           coords(Room2, Coords2)), Directions),
   print_directions2(Directions),
   told.


print_directions2([]).
 
print_directions2([H|T]):-
  write(H), writeln('.'),
  print_directions2(T).






directions(Room, Directions):-
    coords(Room, Coords),
    bagof(direction(Coords2, Dir), (coords(Room2, Coords2), 
	  direction(Coords, Coords2, Dir)), 
          Directions). 

%!  get_percepts_position(+Position, -Percepts) is det
%@arg Position: Actual agent's position (room)
%@arg Percepts: List of percepts in that position (room)

get_percepts_position(Position, Agent, Percepts):-
   findall(direction(Room, Direction), 
            (dirs(Position, Coords, Direction), coords(Room, Coords)), 
	    Directions_Percepts),
    findall_environment(simple_maze, Agent, item(Position, Item), 
			Items),
   append(Directions_Percepts, Items_Percepts, Percepts).


init_beliefs([]).

init_beliefs([Agent | Agents]):-                          
    init_beliefs_agent(Agent),
    init_beliefs(Agents).


init_beliefs_agent(Agent):-
    query_environment(simple_maze, Agent, position(Position)),
    get_percepts_position(Position, Agent, Percepts),
    add_beliefs(Agent, Percepts).   


simple_maze(add_agent, Agent):-
    situate_agent_environment(Agent, simple_maze),
    env_utils:add_facts(simple_maze, [position([1,1])]),
    env_utils:add_beliefs(Agent, [my_position(a)]),
    init_beliefs([Agent]).

simple_maze(add_agent, Agent, Clone):-
    situate_agents_clone([Agent], simple_maze, Clone),
    init_beliefs([Agent]).

simple_maze(add_agent, _, _).
 
%    Agent percieves

simple_maze(perceive, Agent , Add_List, Delete_List):-
   retreive_add_delete(Agent, Add_List, Delete_List).    


%    Agent acts
                                
simple_maze(act, Agent, go(Direction), Result):- 
    query_environment(simple_maze, Agent, position(Position)),!,
    path_direction(Position, Direction, New_Position),
    coords(Room, Position),
    coords(New_Room, New_Position),
    delete_facts_agent(simple_maze, Agent, [position(Position)]),
    add_facts_agent(simple_maze, Agent, [position(New_Position)]),
    delete_beliefs(Agent, [my_position(Room)]),
    add_beliefs(Agent, [my_position(New_Room)]),
    change_room_percepts(Agent, Position, New_Position),
    get_result(New_Position, Agent, Result).

simple_maze(act, Agent, go(Direction), false).

 
get_result(Position, Agent, reward(1)):-
    query_environment(simple_maze, Agent, item(Position, gold)),
    delete_facts_beliefs_all(simple_maze, Agent, [item(Position, gold)]),
    coords(Room, Position),
    delete_beliefs_all(Agent, [reward_at(Room)]).

get_result(Position, _, true).


%! change_room_percepts(in Position1, in Position2) is ? 
%   adds from the percept delete list everything it saw in the original room 
%   and adds to the add list what it sees in the new room

change_room_percepts(Agent, Position1, Position2):-
    get_percepts_position(Position1, Agent, Percepts1),
    get_percepts_position(Position2, Agent, Percepts2),
    delete_beliefs(Agent, Percepts1),       
    add_beliefs(Agent, Percepts2).   



% Silent actions, clones

simple_maze(act, Agent, silently_(go(Direction)), Result):-
 writeln(simple_maze(act, Agent, go(Direction), Result)),
    simple_maze(act, Agent, go(Direction), Result).
                                            


simple_maze(act, _, _, false).


simple_maze(clone, Clone):-
    clone_environment(simple_maze, Clone).
    

simple_maze(remove_clone, Clone):-
    remove_environment_clone(simple_maze, Clone).
 


simple_maze(reset_clone, Clone):-
    reset_environment_clone(simple_maze, Clone),
    get_all_situated(simple_maze, Clone, Agents),   
    init_beliefs(Agents).


simple_maze(save_state, Instance, State):-
    save_environment_instance_state(simple_maze, Instance, State).


simple_maze(load_state, Instance, State):-
    load_environment_instance_state(simple_maze, Instance, State).


simple_maze(remove_state, Instance, State):-
    remove_environment_instance_state(simple_maze, Instance, State).




:-
    env_utils:register_environment(simple_maze),
    init_directions,
    init_items.
