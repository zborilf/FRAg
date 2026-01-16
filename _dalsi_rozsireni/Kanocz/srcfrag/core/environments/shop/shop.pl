:-module(card_shop,
    [
        card_shop / 2,
        card_shop / 4
    ]
).

:- use_module(library(janus)).
:- use_module('../py2pl').

card_shop(set_attributes, _).

card_shop(add_agent, AgentName):-
    py_call(shop:get_environment_by_name("shop"), Env),
    py_call(shop:situate_agent_env(AgentName, Env)).


card_shop(perceive, AgentName , Add_List, Delete_List):-
    py_call(shop:get_environment_by_name("shop"), Env),

    % each agents perceive drives time
    % IF it would be more desirable to drive time forward only once each perception cycle;
    % only agent authorised to drive episode forward would be the last agent in
    % environment's self.agents: list[Agent]
    % This call **also creates new customers internally** in python env
    py_call(Env:drive_time()),

    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:percept(false), [RawAdd, RawDel]),
    py2pl:normalize_pairs(RawAdd, Add_List),
    py2pl:normalize_pairs(RawDel, Delete_List).


card_shop(act, Broker, sell(Seller, Buyer, What), true):-
    py_call(shop:get_environment_by_name("shop"), Env),
    py_call(Env:attempt_transaction(Broker, Seller, Buyer, What), Res),
    py_call(shop:print_msg(">> attempt_transaction returned:")),
    py_call(shop:print_msg(Res)),
    Res = 1,
    py_call(shop:print_msg("USPEL")),
    format("Prodej ~w komu ~w co ~w uspel~n",[Seller, Buyer, What]).



card_shop(act, _, sell( _, _), false).


card_shop(act, _, sell(Seller, Buyer, What), false):-
   format("Prodej ~w komu ~w co ~w selhal~n",[Seller, Buyer, What]).


% Initialization
:-  prolog_load_context(directory, Dir), % absolute path
    py_add_lib_dir(Dir),
    py_import(shop, []),
    py_call(shop:initialize_environment()).
