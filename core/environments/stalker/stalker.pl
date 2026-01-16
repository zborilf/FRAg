:- module(stalker,[
	  stalker/2,
	  stalker/4
    ]).

% :- use_module(library(janus)).
:- use_module('../py2pl').

/** <module> stalker Environment bridge for FRAg

This module

@author David Kanocz
@license GPL
*/

/*
    Exported clauses
*/


stalker(set_attributes, _).


stalker(add_agent, AgentName):-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(stalker:situate_agent_modenv_g(AgentName, Env)).


stalker(perceive, AgentName, Add, Del) :-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:percept(true), [RawAdd, RawDel]),
    py2pl:normalize_pairs(RawAdd, Add),
    py2pl:normalize_pairs(RawDel, Del).


stalker(act, AgentName, go(Direction), Reward):-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:move_to_cell(Direction), Reward).


stalker(act, AgentName, pick(Item), Reward):-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:pick_item(Item), Reward).


stalker(act, AgentName, drop(Item), Reward):-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:drop_item(Item), Reward).


stalker(act, AgentName, examine(Item), Reward):-
    py_call(stalker:get_environment_by_name("stalker"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:get_item_description(Item)),
    Reward = 5.


% Initialization
    :-
    prolog_load_context(directory, Dir),
    py_add_lib_dir(Dir),
    py_import(stalker, []),
    py_call(stalker:initialize_environment()).



