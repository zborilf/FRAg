

:-module(card_shop,
    [
        card_shop / 2,
	card_shop / 3,			% agentname, addlist, deletelist
	card_shop / 4			% agentname, act
    ]
).

:- discontiguous card_shop/2.
:- discontiguous card_shop/3.

:- dynamic episode /1.

episode(1).


:-use_module('../FRAgPLEnvironmentUtils').   % interface to environments
:-use_module('stat_utils').


% has -> sells
has(adam, cd1).
has(adam, cd3).
has(adam, cd4).
has(adam, cd6).
has(adam, cd7).
has(adam, cd8).
has(adam, cd9).


price(cd1, 100).
price(cd2, 80).
price(cd3, 68).
price(cd4, 110).
price(cd5, 50).
price(cd6, 90).
price(cd7, 110).
price(cd8, 55).
price(cd9, 150).

sells(adam, cd1, 100).
sells(adam, cd3, 68).
sells(adam, cd4, 110).
sells(adam, cd6, 90).
sells(adam, cd7, 110).
sells(adam, cd8, 55).
sells(adam, cd9, 150).



% environment(card_shop).

average_sellers(0.03).
average_buyers(0.06).

%	Init the environment for agent AGENTNAME

% Fill add list of Agents with actual environment state

                   
init_beliefs(Agents):-
    % inserts all the
    %         has(Who, What)
    %         price(What, Price)
    %     from environment to Agent's add_list
    
    findall_environment(card_shop, Agent, has( _, _), Beliefs1),
    findall_environment(card_shop, Agent, price( _, _), Beliefs2),
    findall_environment(card_shop, Agent, sells( _, _, _), Beliefs3),

    add_beliefs_agents(Agents, Beliefs1),
    add_beliefs_agents(Agents, Beliefs2),
    add_beliefs_agents(Agents, Beliefs3).



%    Situate agent in environment or its clone


card_shop(add_agent, Agent):-
    situate_agent_environment(Agent, card_shop),
    init_beliefs([Agent]).

card_shop(add_agent, Agent, Clone):-
    situate_agents_clone([Agent], card_shop, Clone),
    init_beliefs([Agent]).



card_shop(clone, Clone):-
    clone_environment(card_shop, Clone).
    

card_shop(reset_clone, Clone):-
    reset_environment_clone(card_shop, Clone),
    get_all_situated(card_shop, Clone, Agents),   
    init_beliefs(Agents).


card_shop(remove_clone, Clone):-
    remove_environment_clone(card_shop, Clone).



card_shop(save_state, Instance, State):-
    save_environment_instance_state(card_shop, Instance, State).


card_shop(load_state, Instance, State):-
    load_environment_instance_state(card_shop, Instance, State).


card_shop(remove_state, Instance, State):-
    remove_environment_instance_state(card_shop, Instance, State).



%    Agent percieves

%!  add_tick(+Agent)
% prida jeden token do prostredi 

    
card_shop(perceive, Agent , Add_List, Delete_List):-
    retreive_add_delete(Agent, Add_List, Delete_List),
    episode(E), 
    retractall(episode(E)),
    E2 is E + 1,
    assert(episode(E2)),
    average_sellers(Lambda1),
    add_tick(Lambda1, seller, Agent),
    average_buyers(Lambda2),
    add_tick(Lambda2, buyer, Agent).



add_tick(Lambda, Predicate, Agent):-
    new_events_number(Lambda, New_Customers),
    add_tick2(Lambda, Predicate, New_Customers).



add_tick2(_, _, 0).

add_tick2(Lambda, Predicate, N):-
    generate_cd_price(CD, Price),
    episode(E),
    N2 is N-1,
    format(atom(Person), "~w~w_~w", [Predicate, E, N]),
    Fact =..[Predicate, Person, CD, Price],
    add_facts_beliefs_all(card_shop, Agent, [Fact]),
    add_tick2(Lambda, Predicate, N2).

          

generate_cd_price(CD, Price_Out):-
    findall(cd(CD, Price), price(CD, Price), CDs),
    random_member(cd(CD, Price),CDs),
    get_discount(Discount),
    Price_Out is truncate(Price * (1 - Discount)).
 
  
%    Agent acts


card_shop(act, Seller, sell(Buyer, What), true):- 
    query_environment(card_shop, Seller, sells(Seller, What, Price)),
    delete_facts_beliefs_all(card_shop, Seller, [seller(Seller, What, Price)]),
    delete_facts_beliefs_all(card_shop, Seller, [buyer(Buyer, What, Price)]),
% assert(has(Buyer, What)),
    add_facts_beliefs_all(card_shop, Seller, [has(Buyer, What)]),
    format("Prodej ~w komu ~w co ~w~n",[Seller, Buyer, What]).

    card_shop(act, Seller, sell(Buyer , What), false):-
    format("Prodej ~w komu ~w co ~w selhal~n",[Seller, Buyer, What]).


card_shop(act, Brooker, sell(Seller, Buyer, What), true):- 
    query_environment(card_shop, Brooker, sells(Seller, What, Price)),
    delete_facts_beliefs_all(card_shop, Brooker, [sells(Seller, What, Price)]),
    % assert(has(Buyer, What)),
    add_facts_beliefs_all(card_shop, Brooker, [has(Buyer, What)]).
%    format("Prodej ~w komu ~w co ~w pres ~w~n",[Seller, Buyer, What, Brooker]).

card_shop(act, _, sell( _, _), false).

%    format("Prodej ~w komu ~w co ~w selhal~n",[Seller, Buyer, What]).

card_shop(act, _, sell( _, _, _), false).

%    format("Prodej ~w komu ~w co ~w pres ~w selhal~n",[Seller, Buyer, What, 
%                                                       Brooker]).


%	Agent AGENTNAME acts silently

  % for mcts

card_shop(act, Seller, silently_(sell(Seller, What)), Result):-
    card_shop(act, Seller, sell(Seller, What), Result).

card_shop(act, Brooker, silently_(sell(Seller, Buyer, What)), Result):- 
    card_shop(act, Brooker, sell(Seller, Buyer, What), Result).

card_shop(act, _, _, fail).


 

                           
:-
    env_utils:register_environment(card_shop),
    findall(has(Who, What), has(Who, What), Facts1),
    findall(price(What, Price), price(What, Price), Facts2),
    findall(sells(Who, What, Price), sells(Who, What, Price), Facts3),
    env_utils:add_facts(card_shop, Facts1),
    env_utils:add_facts(card_shop, Facts2),
    env_utils:add_facts(card_shop, Facts3).

    
