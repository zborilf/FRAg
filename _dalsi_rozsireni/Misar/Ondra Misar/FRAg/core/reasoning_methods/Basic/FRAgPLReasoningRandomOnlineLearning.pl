
/**

This file is part of the FRAg program. It is included into agent's file
FRAgAgent.pl. It contains clauses that are applied to strategies for selecting
intentions, plans and substitutions. Learning random reasoning uses the
epsilon greedy strategy to select from a set of provided options.

@author Ondrej Misar
@license GPL

*/

:-dynamic state_action/3.
:-dynamic insert_state_action/2.

%!  reasoning_method(random_reasoning_learning) is det
%  announces that the 'random_reasoning_learning' decision strategy is available

reasoning_method(random_reasoning_learning).



%!  get_intention(random_reasoning_learning, +Intentions, - Intention) is det
%  @arg Inention: list of elements from which to select one
%  @arg Intention: selected Intention

get_intention(random_reasoning_learning, Intentions, intention(Intention_ID, Content, active)):-
    take_snapshot_beliefs(Facts),
    term_to_atom(Facts, Facts_Atom),
    term_hash(Facts_Atom, Facts_Hash),
    random(RandomNumber),
    ( RandomNumber < 0.1 ->
         random_member(intention(Intention_ID, Content, active), Intentions)
    ;
        find_sorted_actions(Facts_Hash, Intentions, Actions_Sorted),
        ( Actions_Sorted == [] ->
                 random_member(intention(Intention_ID, Content, active), Intentions)
            ;
                 first_element(Actions_Sorted, intention(Intention_ID, Content, active))
            )
    ),
    !,
    assertz(insert_state_action(Facts_Hash, intention(Intention_ID, Content, active))).

get_intention(random_reasoning_learning, Intentions, _):-
    get_intention(random_reasoning_learning, Intentions).



%!  get_substitution(random_reasoning_learning, _, Context, Vars, Context_Out) is det
%   This clause is to select one of the set of substitutions and reduces it to
%   just the variables from Vars
%  @arg Context_In: actual context of the agent
%  @arg Vars: the variables for which a decision is to be made
%  @arg Context_Out: output context for the Action

get_substitution(random_reasoning_learning, _, Context_In, Vars, Context_Out):-
    random_member(Substitution, Context_In),
    shorting(Substitution, Vars, Context_Out).	% from file FRAgPLFRAg


find_sorted_actions(FactValue, ActionList, SortedActions) :-
    findall(Value-Action,
            (state_action(FactValue, Action, Value),
             member(Action, ActionList)),
            Pairs),
    keysort(Pairs, SortedPairsAscending),
    reverse(SortedPairsAscending, SortedPairsDescending),
    pairs_values(SortedPairsDescending, SortedActions).

first_element([First|_], First).


%!  get_plan(random_reasoning_learning, +Event, +Means, -Intended_Means) is det
%   From the listed means for the Event selects one
%  @arg Event:
%  @arg Means:
%  @arg Intended_Means:

get_plan(random_reasoning_learning, _ , Means, Intended_Means):-
    take_snapshot_beliefs(Facts),
    term_to_atom(Facts, Facts_Atom),
    term_hash(Facts_Atom, Facts_Hash),
    random(RandomNumber),
    ( RandomNumber < 0.1 ->
         random_member(Intended_Means, Means)
    ;
        find_sorted_actions(Facts_Hash, Means, Actions_Sorted),
        ( Actions_Sorted == [] ->
                 random_member(Intended_Means, Means)
            ;
                 first_element(Actions_Sorted, Intended_Means)
            )
    ),
    !,
    assertz(insert_state_action(Facts_Hash, Intended_Means)).



%!  update_model(random_reasoning_learning) is det
%   No update is needed. This clause is valid by default

update_model(random_reasoning_learning).


%!  init_reasoning(random_reasoning_learning) is det
%   No initialization is needed. This clause is valid by default

init_reasoning(random_reasoning_learning).


