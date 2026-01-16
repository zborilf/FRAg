:- module(miconic,[
     miconic/2,
     miconic/4
   ]).

:- use_module('../py2pl').
:- use_module(library(janus)).


/** <module> miconic environment bridge for FRAg

This module

@author David Kanocz
@license GPL
*/

/*
    Exported clauses
*/

miconic(set_attributes, _).

miconic(add_agent, AgentName) :-
    py_call(miconic:get_environment_by_name("miconic"), Env),
    py_call(miconic:situate_agent_modenv_g(AgentName, Env)).


miconic(perceive, AgentName, Add, Del) :-
    py_call(miconic:get_environment_by_name("miconic"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:percept(true), [RawAdd, RawDel]),
    py2pl:normalize_pairs(RawAdd, Add),
    py2pl:normalize_pairs(RawDel, Del).


miconic(act, AgentName, move(Floor), Reward) :-
    py_call(miconic:get_environment_by_name("miconic"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:travel(Floor), Reward).


miconic(act, AgentName, stop, Reward) :-
    py_call(miconic:get_environment_by_name("miconic"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:leave_lift(), Reward),
    py_call(Agent:onboard()).


% Initialization
:-
    prolog_load_context(directory, Dir), % absolute path
    py_add_lib_dir(Dir),
    py_import(miconic, []),
    py_call(miconic:initialize_environment()).
