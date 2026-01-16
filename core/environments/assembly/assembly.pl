
:- module(assembly,[
	  assembly/2,
	  assembly/4
    ]).

% spis do inicializace
% :- use_module(library(janus)).
:- use_module('../py2pl').

/** <module> assembly Environment bridge for FRAg

This module

@author David Kanocz
@license GPL
*/

/*
    Exported clauses
*/


assembly(set_attributes, _).


assembly(add_agent, AgentName):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(assembly:situate_agent_modenv_s(AgentName, Env)).


assembly(perceive, AgentName, Add, Del) :-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:percept(true), [RawAdd, RawDel]),
    py2pl:normalize_pairs(RawAdd, Add),
    py2pl:normalize_pairs(RawDel, Del).


assembly(act, AgentName, go(Direction), Reward):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:move_to_cell(Direction), Reward).


assembly(act, AgentName, pick(Item), Reward):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:pick_item(Item), Reward).


assembly(act, AgentName, create, Reward):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:create_product(), Reward).


assembly(act, AgentName, drop(Item), Reward):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:drop_item(Item), Reward).


assembly(act, AgentName, examine(Item), Reward):-
    py_call(assembly:get_environment_by_name("assembly"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:get_item_description(Item), Reward).


% Initialization
:-
  %  use_module(library(janus)),
    prolog_load_context(directory, Dir), % absolute path
    py_add_lib_dir(Dir),
    py_import(assembly, []),
    py_call(assembly:initialize_environment()).

