%               
% Reasoning methods - the simple ones
% Frantisek Zboril jr. 2025
%

%
% Should define
%    get_intention(+Reasoning_type,+Intentions,-Intention).
%                       
% not defined for:
%    get_substitution(+Reasoning_type, +ActionTerm, +Substitution_List, 
%                     +Variable_List,-Substitution_List).
%    get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%		
% if required, 'simple_reasoning' will be used.
%

%	This module is loaded / included in the FRAgAgent file


:-dynamic initialized /0.
:-dynamic joint_bindings /2.
:-thread_local joint_actions /2.

reasoning_method(snakes_reasoning).


%
%	Snaked
%


%!  serialize_plans(+Plans, -Serilaized_Plans) is det
%   It combines the bodies of plans into a single list, each act is marked with
%   the number of the plan in which it is located and its position in it.
%  @arg
%  @arg

serialize_plans([], []).

serialize_plans([plan(ID, Body) | Plans], Serialized_Plans_Out):-
    serialize_plan(ID, Body, 1, Serialized_Plan),
    serialize_plans(Plans, Serialized_Plans),
    append(Serialized_Plan, Serialized_Plans, Serialized_Plans_Out).



serialize_plan(_, [], _, []).

serialize_plan(ID, [Act | Acts], Position, [act_indexed(Act, ID, Position) | 
			                    Acts_Indexed]):-
   Position2 is Position+1,
   serialize_plan(ID, Acts, Position2, Acts_Indexed).


%!  find_joint_acts(+Serializad_Plans_Sorted, -Joint_Acts) is det
%  @
%  @

find_joint_acts([], []).

find_joint_acts([Act_Indexed | Acts_Indexed], 
                [joint(Act_Indexed, Act_Indexed) | Joint_Acts_Out]):-
   assert(joint_actions(Act_Indexed, Act_Indexed)),

   find_joint_acts_for_act(Act_Indexed, Acts_Indexed, Joint_Acts),
   find_joint_acts(Acts_Indexed, Joint_Acts2),
   append(Joint_Acts, Joint_Acts2, Joint_Acts_Out).

			

find_joint_acts_for_act( _, [], []).

find_joint_acts_for_act(act_indexed(Act, ID, Position), 
			[act_indexed(Act2, ID2, Position2) | Acts_Indexed],
			  [joint(act_indexed(Act, ID, Position), 
			         act_indexed(Act2, ID2, Position2)) |
   			   Joint_Acts]):-
    unifiable(Act, Act2, _),
    assert(joint_actions(act_indexed(Act, ID, Position), 
			         act_indexed(Act2, ID2, Position2))),
    find_joint_acts_for_act(act_indexed(Act, ID, Position), Acts_Indexed, 
			    Joint_Acts).

find_joint_acts_for_act(act_indexed(Act, ID, Position),  [ _ | Acts_Indexed],
			Joint_Acts):-
    find_joint_acts_for_act(act_indexed(Act, ID, Position), Acts_Indexed, 
			    Joint_Acts).



%
%	redirecting the other two to random_reasoning
%

get_intention(snakes_reasoning, Intentions, Intention):-
    print_list(Intentions),
    get_intention(random_reasoning, Intentions, Intention).


%
%	redirecting the other two to simple_reasoning
%


get_substitution(snakes_reasoning, Action, Context, Variables, Substitution):-
    get_substitution(random_reasoning, Action, Context, Variables, 
                     Substitution).

get_plan(snakes_reasoning, Event, Plans, Intended_Means):-
    get_plan(random_reasoning, Event, Plans, Intended_Means).

	
update_model(snakes_reasoning):-
    initialized.

update_model(snakes_reasoning):-
    findall(plan(ID, Body), plan(ID, _, _, _, Body), Plans),
    serialize_plans(Plans, Serialized_Plans),
%   msort(Serialized_Plans, Serialized_Plans_Sorted),
    find_joint_acts(Serialized_Plans, Joint_Acts),
%    readln( _ ),
    assert(initialized).


print_list([]).

print_list([H|T]):-
    writeln(H),
    print_list(T).

init_reasoning(snakes_reasoning):-
    retractall(initialized).



