

%
%  children - 1,list of nodes 2, empty list (final state) 3, non_expanded
%       action model_reasoning_node(goal / wgi , plan number, pus) or model_act_node(intention, action, decision)  - intention is neccessary for exclusive actions
%       tree_node(id node, action, children, visited, points)
%


/** 
	<module> fRAgAgent

	This module contains code for threads of individual agents
	2022 - 2023
	@author Frantisek Zboril
	@license GPL

*/


%  :-module(fRAgMCTSModel,
%    [
%	mcts_model_init /0,         
%	mcts_expand_node /2,
% 	mcts_increment_path /2,             
%  	mcts_get_best_ucb_path /2,     
%       mcts_divide_path /3,
%	mcts_print_model /1,		
%  	mcts_print_path /2                
%    ]
%  ).


:-thread_local fresh_node_index/1.                  
:-thread_local tree_node/5.  
:-thread_local root_node/1.                


fresh_node_index(1).



set_root_node(ROOT):-
    retractall(root_node(_)),
    assert(root_node(ROOT)).



model_print_node_children(not_expanded, _, _).

model_print_node_children([], _, _).

model_print_node_children([NodeChild|T], SfxStr, DEBUG):-
    model_print_node(NodeChild,SfxStr, DEBUG),
    model_print_node_children(T,SfxStr, DEBUG).


model_print_node(NODEINDEX, SfxStr, DEBUG):-                      
    tree_node(NODEINDEX, NodeContent, NodeChildren, NodeVisits, NodeScore),
    print_debug(SfxStr, DEBUG),
    println_debug(tree_node(NODEINDEX, NodeContent, NodeChildren, NodeVisits, NodeScore), DEBUG),
    format(atom(SfxStr2),"~w - ",[SfxStr]),
    model_print_node_children(NodeChildren,SfxStr2, DEBUG).


mcts_print_model(DEBUG):-
%   bagof(tree_node(A,B,C,D,E),tree_node(A,B,C,D,E),L),
    root_node(Root),
    model_print_node(Root,' - ', DEBUG).

mcts_print_model.    



get_fresh_node_id(Index):-
    fresh_node_index(Index),
    retract(fresh_node_index(_)),
    Index2 is Index+1,
    assert(fresh_node_index(Index2)).





%!  generate_children(+Index_starts: integer, +Index_ends: integer, -Children: mcts_nodes) is det
%   vytvori seznam indexu od Index_starts do Index_ends,
%   * Index_starts: integer


generate_children(Index, Index, []).

generate_children(INDEXSTART, INDEXEND, [INDEXSTART| TINDEXES]):-
    INDEXSTART2 is INDEXSTART +1,
    generate_children(INDEXSTART2, INDEXEND, TINDEXES).

%!  set_children(+Node_index: ke kteremu uzlu se pripojuji decka, +Index_starts: integer, Index_Ends: integer) is det
%   TODO
%   * Index_starts: integer


set_children(NODEINDEX, INDEXSTART, INDEXEND):-
    print_debug('generate children ', mctsdbg),
    print_debug(INDEXSTART, mctsdbg),
    print_debug(',', mctsdbg),println_debug(INDEXEND, mctsdbg),
    generate_children(INDEXSTART, INDEXEND, Ch),
    retract(tree_node(NODEINDEX, E, _, V, S)),
    assert(tree_node(NODEINDEX, E, Ch, V, S)).

expand_node2([]).

expand_node2([ELEMENT| TELEMENTS]):-
    get_fresh_node_id(INDEX),
    assert(tree_node(INDEX, ELEMENT, not_expanded, 0, 0)),
    expand_node2(TELEMENTS).

%!  expand_node(+Node_index: integer, Elements: list of nodes) is det
%   creates nodes for elements and assign them to a parent node
%   * Node_index
%       index of parent node
%   * Elements
%	elements to be assigned to the parent node

mcts_expand_node(NODE, ELEMENTS):-
    fresh_node_index(INDEXSTART),
    expand_node2(ELEMENTS),
    fresh_node_index(INDEXEND),
    set_children(NODE, INDEXSTART, INDEXEND).


% true, pokud je  not_expanded

expand_candidate(ParentID, ParentID):-
    tree_node(ParentID, _, not_expanded, _, _).





ucb(ParentID, ChildID, UCB):-
% for list of children (4th term in tree_node) finds out their ucb's -> binded
% to UctList
% wi/ni + sqrt(2)*sqrt((ln Ni) / ni)
% wi - wins of the node, ni - runs over the node, Ni runs over parent's node 
% (after ith step)
    tree_node(ParentID,_,_,VP,_),
    tree_node(ChildID,_,_,VCH,SCH),
    UCB is (SCH/VCH)+sqrt(2*(log(VP)/VCH)).


%
% Increment visited / result on path
%
% TODO asi by stacil na vstupu jen INDEX, zbytek se vytahne v retractu


increment_node(tree_node(Index, Action, Children, Visited, Score), Reward):-
    retract(tree_node(Index, Action, Children, Visited, Score)),
    Visited2 is Visited + 1,
    Score2 is Score + Reward,
    assert(tree_node(Index, Action, Children, Visited2, Score2)).



  mcts_increment_path([leaf_node(ID),_], Reward):-
  	tree_node(ID, Action, Children, Visited, Score),
  	increment_node(tree_node(ID, Action, Children, Visited,  Score), Reward).

  mcts_increment_path([node(ID),_], Reward):-      % Success????, dostane se to sem vubec?
        tree_node(ID, Action, Children, Visited, Score),
  	increment_node(tree_node(ID, Action, Children, Visited, Score), Reward).
  
  mcts_increment_path([node(ID),_|T], Reward):-
  	tree_node(ID, Action, Children, Visited, Score),
  	increment_node(tree_node(ID, Action, Children, Visited, Score), Reward),
  	mcts_increment_path(T, Reward).



  mcts_print_path([], _).
  
  mcts_print_path([NODEINDEX, NODE| TPATH], DEBUG):-		
    	print_debug(' - ', mctsdbg_path),
    	print_debug(NODEINDEX, DEBUG),
    	print_debug(':', mctsdbg_path),
    	println_debug(NODE, DEBUG),
    	mcts_print_path(TPATH, DEBUG).



 
  select_best_child3(VAL1,Child1,VAL2,_,Child1):-
    	VAL1>VAL2.

  select_best_child3(_ ,_ ,_ ,Child2,Child2).


%  select_best_child2(Parent, Child1, Child2, Child, false) ?? TODO

  select_best_child2(_ , _, CHILD, CHILD, _):-
    	tree_node(CHILD, _, not_expanded, _, _).

  select_best_child2( _, CHILD1, CHILD2, CHILD, false):-
   	tree_node(CHILD1, _, _, VISITED1, SCORE1),
    	tree_node(CHILD2, _, _, VISITED2, SCORE2),
    	SUCCESS1 is SCORE1 / VISITED1,
    	SUCCESS2 is SCORE2 / VISITED2,
   	select_best_child3(SUCCESS1, CHILD1, SUCCESS2, CHILD2, CHILD).
    
  select_best_child2(PARENT, CHILD1, CHILD2, CHILD, true):-
    	ucb(PARENT, CHILD1, UCB1),
    	ucb(PARENT, CHILD2, UCB2),!,
    	select_best_child3(UCB1, CHILD1, UCB2, CHILD2, CHILD).


  % select_best_child(Parent, List of children, Child, UCB)

  select_best_child(_, [CHILD], CHILD, _).

  select_best_child( _, [CHILD| _], CHILD, _):-
    	tree_node(CHILD, _, not_expanded, _, _).


% best child of the node
%     UCB = true  ... depends on UCB   (for making MCTS model)
%     UCB = false ... depends on score (for extraction of the best path of the model)

  select_best_child(Parent, [CHILD|CHILDREN] , BestChild, UCB):-
    	select_best_child(Parent, CHILDREN, BestChild2, UCB),
    	select_best_child2(Parent, CHILD, BestChild2, BestChild, UCB).



%
% model_get_best_ucb_path(Path, UCB) ... UCB true -> ucb, false -> best score
%

  mcts_get_best_ucb_path(PATH, UCB):-    % only one term -> implicit rood node
   	root_node(ROOT),    
    	mcts_get_best_ucb_path(ROOT, PATH, UCB).

  mcts_get_best_ucb_path(ID, [leaf_node(ID), ACTION], _):-
    	tree_node(ID, ACTION, [], _, _).

  mcts_get_best_ucb_path(ID, [leaf_node(ID), ACTION], _):-
    	tree_node(ID, ACTION, not_expanded, _, _).

  mcts_get_best_ucb_path(ID, [node(ID), ACTION| PATH], UCB):-
    	tree_node(ID, ACTION, CHILDREN, _, _),
    	select_best_child(ID, CHILDREN, BESTCHILD, UCB),
    	mcts_get_best_ucb_path(BESTCHILD, PATH, UCB). 


%
%  MCTS supporting clauses
%

%!  divide_path(+PATH: list of nodes, -REASONING_PREFIX: list of nodes, -FIRST_ACT: node) is det
%   rozdeli path na prefix obsahujici reasoning nodes na zacatku az po prvni akt, a dale onen akt
%   * PATH
%       List of nodes, path in the model
%   * REASONING_PREFIX
%       List of reasoning nodes before the first act node
%   * -FIRST_ACT
%       The first act node in the path 



  divide_path2([_,model_reasoning_node(GOAL,PLAN,CTX)|PATH],[model_reasoning_node(GOAL,PLAN,CTX)|RT],ACT):-
   	divide_path2(PATH,RT,ACT).

  divide_path2([ _, model_act_node(INTENTION, ACTION, CTX)| _], [], [model_act_node(INTENTION, ACTION, CTX)]).

  divide_path2(_,[],[]).


  mcts_divide_path([_,_|PATH], REASONING, ACT):-
  	% PATH - optimal path by MCTS
  	% REASONING - path prefix (without the Root node) of reasoning nodes before the first act
  	% ACT - list with the first act in PATH
  	divide_path2(PATH, REASONING, ACT).


% model_init:-
%   fresh_node_index(_),
%   tree_node(root, _, _, _, _).



  mcts_model_init:-  
    	retractall(fresh_node_index(_)),
    	retractall(tree_node(_,_,_,_,_)),
    	assert(root_node(root)),
    	assert(fresh_node_index(1)),
    	assert(tree_node(root, model_act_node(no_intention, no_action, [[]]), not_expanded, 0, 0)).


