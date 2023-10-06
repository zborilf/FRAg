                                

:-module(card_shop,
    [
        card_shop / 2,
	card_shop / 3,			% agentname, addlist, deletelist
	card_shop / 4			% agentname, act
    ]              
).

:- discontiguous card_shop/2.
:- discontiguous card_shop/3.


time_adjust_multiply(30).

:- dynamic episode /1.
:- dynamic buyers /1.
:- dynamic sellers /1.
:- dynamic previous_time /1.

episode(1).



:-use_module('../FRAgPLEnvironmentUtils').   % interface to environments
:-use_module('stat_utils').



price(cd1, 100).
price(cd2, 80).
price(cd3, 68).
price(cd4, 110).
price(cd5, 50).
price(cd6, 90).
price(cd7, 110).
price(cd8, 55).
price(cd9, 150).



% environment(card_shop).

average_buyers(0.2).
average_sellers(0.2).
mean_discount_buyer(0.6).
dispersion_discount_buyer(0.2).
mean_discount_seller(0.4).
dispersion_discount_seller(0.2).
buyers_stay(100).
sellers_stay(100).
closing_time(750).
buyers(0).
sellers(0).
episode_length(0.0005). % in secs

previous_time(-1).       

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
    init_beliefs([Agent]),
    delete_facts_beliefs_all(card_shop, Agent, [stats_([sold(Sold_By), buyers(B), 
                                               sellers(S)])]),

    append(Sold_By, [sold(Agent, 0)], Sold_By2),
    add_facts_beliefs_all(card_shop, Agent, [stats_([sold(Sold_By2), buyers(B), 
                                               sellers(S)])]).
  

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
    check_episode(Agent),
    retreive_add_delete(Agent, Add_List, Delete_List),
    query_environment(card_shop, Agent, stats_([sold(Sold_By), 
                                                  buyers( _ ), sellers( _ )])),
    delete_facts_beliefs_all(card_shop, Agent, 
                             [stats_([sold(Sold_By), buyers( _ ), sellers( _ )])]),
    sellers(S),
    buyers(B),                                                      
    add_facts_beliefs_all(card_shop, Agent, [stats_([sold(Sold_By), 
                                               buyers(B), sellers(S)])]).



check_episode( _ ):-
    previous_time(-1),
    get_time(Time),
    retract(previous_time( _ )),
    assert(previous_time(Time)).


check_episode(Agent):-
    new_episode_time(Agent, N),
%    writeln(new_episode_time(N)),
    delete_facts_beliefs_all(card_shop, Agent, 
                             [episode( Episode )]),
    add_facts_beliefs_all(card_shop, Agent, [episode(Episode2)]),

    update_environment(Agent, N).
    
check_episode( _ ).


new_episode_time( _ , N):-
    previous_time(Previous_Time),
    get_time(Time),
    episode_length(Episode_Length),

    !,
    Delta is (Time - Previous_Time),
    Episode_Length < Delta,
    N is truncate(Delta / Episode_Length),
    retract(previous_time( _ )),
    assert(previous_time(Time)).



update_environment(Agent, 0).

update_environment(Agent, N):-
    /*
    previous_time(Time),
    get_time(Time2),
    time_adjust_multiply(Multiplier),
    Time3 is (Time2 - Time) * Multiplier,
    retract(previous_time(Time)),
    assert(previous_time(Time2)),
    */
    episode(Episode), 
    retractall(episode(Episode)),
    Episode2 is Episode + 1,
    assert(episode(Episode2)),
%    format("Updating envir ~w~n",[N]),
    patience_out(Agent, Episode2),
    if_open_add_customers(Episode2, Time3, Agent),
    N2 is N-1,
    update_environment(Agent, N2).





   
if_open_add_customers(Episode, Time_Difference, Agent):-
    closing_time(Closing_Time),
    Episode < Closing_Time,
    add_sellers(Agent, Time_Difference),
    add_buyers(Agent, Time_Difference).


if_open_add_customers(Episode, _, Agent):-
    closing_time(Episode),
    get_time(Time2),
    retract(previous_time(Time)),
    assert(previous_time(Time2)),

    closing_time(Episode),
    add_facts_beliefs_all(card_shop, Agent, [closed]).



if_open_add_customers( _, _, _).


patience_out(Agent, Episode):-
    findall_environment(card_shop, Agent, deadline(Person, Name, Episode), 
                        Unpatients),
    unpatients_left(Agent, Unpatients).

unpatients_left(Agent, []).
                                          
unpatients_left(Agent, [Unpatient | Unpatients]):-
    remove_unpatient(Agent, Unpatient),
    unpatients_left(Agent, Unpatients).



remove_unpatient(Agent, deadline(seller, Seller, _)):-
   delete_facts_beliefs_all(card_shop, Agent, 
                              [seller(Seller, _, _)]).
%   add_facts_beliefs_all(card_shop, Agent, 
%                             [left(Seller)]).

    

remove_unpatient(Agent, deadline(buyer, Buyer, _)):-
   delete_facts_beliefs_all(card_shop, Agent, 
                             [buyer(Buyer, _, _)]).
%   add_facts_beliefs_all(card_shop, Agent, 
%                             [left(Buyer)]).




add_sellers(Agent, Time_Difference):-
    average_sellers(Lambda),
    mean_discount_seller(Mean_Seller),
    dispersion_discount_seller(Dispersion_Seller),
    sellers(Seller_Index),
    new_events_number(Lambda, Time_Difference, New_Sellers),
    sellers_stay(Stay_Length),
    add_persons(Agent, Lambda, seller, Seller_Index, New_Sellers, Mean_Seller, 
                Dispersion_Seller, Stay_Length).

add_buyers(Agent, Time_Difference):-
    average_buyers(Lambda),
    mean_discount_buyer(Mean_Buyer),
    dispersion_discount_buyer(Dispersion_Buyer),
    buyers(Buyer_Index),
    new_events_number(Lambda, Time_Difference, New_Buyers),
    sellers_stay(Stay_Length),
    add_persons(Agent, Lambda, buyer, Buyer_Index, New_Buyers, Mean_Buyer, 
                Dispersion_Buyer, Stay_Length).



add_persons(_, _, _, _, 0, _, _, _).

add_persons(Agent, Lambda, Predicate, Index, N, Mean, Dispersion, Stay_Length):-    
    generate_cd_price(CD, Price, Mean, Dispersion),
    Index2 is Index+1,
    N2 is N-1,
    format(atom(Person), "~w~w", [Predicate, Index2]),
    increase_persons(Predicate),
    Fact =..[Predicate, Person, CD, Price],
    add_facts_beliefs_all(card_shop, Agent, [Fact]),
% set deadline ... as a fact only
    episode(E),
    E2 is E + Stay_Length,
    add_facts_agent(card_shop, Agent, [deadline(Predicate, Person, E2)]),
    add_persons(Agent, Lambda, Predicate, Index2, N2, Mean, Dispersion, 
                Stay_Length).



          
increase_persons(buyer):-
    retract(buyers(B)),
    B2 is B+1,
    assert(buyers(B2)).

increase_persons(seller):-
    retract(sellers(S)),
    S2 is S+1,
    assert(sellers(S2)).

generate_cd_price(CD, Price_Out, Mean, Dispersion):-
    findall(cd(CD, Price), price(CD, Price), CDs),
    random_member(cd(CD, Price),CDs),
    get_discount(Mean, Dispersion, Discount),
    Price_Out is truncate(Price * (1 - Discount)).
 
  
                 

%    Agent acts   




card_shop(act, Brooker, sell(Seller, Buyer, What), true):-
    episode(E), 
    query_environment(card_shop, Brooker, seller(Seller, What, Price)),
    query_environment(card_shop, Brooker, buyer(Buyer, What, Price2)),
    add_facts_beliefs_all(card_shop, Brooker, [has(Buyer, What),
                                               sold(Seller, What)]),
    query_environment(card_shop, Brooker, stats_([sold(Sold_By), buyers(B), 
                                                 sellers(S)])),
    delete_facts_beliefs_all(card_shop, Brooker, 
                             [stats_([sold(Sold_By), buyers( _ ), sellers( _ )])]),
    delete_facts_beliefs_all(card_shop, Brooker, 
                             [buyer(Buyer, What, _)]),
    delete_facts_beliefs_all(card_shop, Brooker, 
                             [seller(Seller, What, _)]),

    delete_facts_agent(card_shop, Brooker, [deadline(seller, Seller, _), 
                                            deadline(buyer, Buyer, _)]),

    add_trade(Sold_By, Brooker, Sold_By2),
    add_facts_beliefs_all(card_shop, Brooker, [stats_([sold(Sold_By2), buyers(B), 
                                               sellers(S)])]).



card_shop(act, _, sell( _, _), false).



card_shop(act, _, sell( Seller, Buyer, What), false):-
   format("Prodej ~w komu ~w co ~w pres ~w selhal~n",[Seller, Buyer, What, 
                                                       Brooker]).

add_trade(Sold_By, Seller, Sold_By3):-
    member(sold(Seller, N), Sold_By),
    delete(Sold_By, sold(Seller, N), Sold_By2),
    N2 is N+1,
    append(Sold_By2, [sold(Seller, N2)], Sold_By3).

add_trade(Sold_By, Seller, Sold_By2):-
    append(Sold_By, [sold(Seller, 1)], Sold_By2).



%	Agent AGENTNAME acts silently

  % for mcts

card_shop(act, Seller, silently_(sell(Seller, What)), Result):-
    card_shop(act, Seller, sell(Seller, What), Result).

card_shop(act, Brooker, silently_(sell(Seller, Buyer, What)), Result):- 
    card_shop(act, Brooker, sell(Seller, Buyer, What), Result).

card_shop(act, _, _, fail).

 

                           
:-
    env_utils:register_environment(card_shop),
    findall(price(What, Price), price(What, Price), Facts),
    env_utils:add_facts(card_shop, [stats_([sold([]), buyers(0), sellers(0)])]),
    env_utils:add_facts(card_shop, Facts).



