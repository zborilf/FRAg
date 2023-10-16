
%
%
%		#################    ###############           #######
%		#################    #################       ###########
%		###                  ###           ###     ###         ###
%		###                  ###           ###    ###           ###
%		###                  ###           ###    ###           ###
%		############         ################     #################       #############
%		############         #############        #################      #################
%		###                  ###       ###        ###           ###     ###             ###
%		###                  ###        ###       ###           ###     ###             ###
%		###                  ###         ###      ###           ###     ###             ###
%		###                  ###          ###     ###           ###      #################
%		###                  ###           ###    ###           ###       ################
%                                                                                               ###
%                                                                                ###           ###
%                                                                            .     ###############
%						                                    ############
%
%


%
%	* * * FRAg * * *
%	-- MAIN MODULE --
%	AgentSpeak(L) dialect interpreter in Prolog with late bindings
%	Frantisek Zboril jr. 2021 - 2023
%



:-module(fRAg,
    [
        set_bindings /1,
	set_default_reasoning /2,
	get_frag_attributes /2,
	frag /0,
	frag /1
    ]
).

/** <module>  FRAg: The Flexible Reasoning Agent

This is the main module of the FRAg system.
{pldoc link stranta.txt} dalsi stranka

@author Frantisek Zboril
@license GPL
*/



:- use_module('FRAgBlackboard').
:- use_module('FRAgAgent').

:- discontiguous frag_choice/1.
:- discontiguous frag_choice/2.

version("0.99").



frag_choice(48).

frag_choice(49):-
    writeln("program name:"),
    read(File),
    frag(File).

frag_choice(50,49):-
    set_default_reasoning(all, mcts_reasoning),
    frag.

frag_choice(50,50):-
    set_default_reasoning(all, simple_reasoning),
    frag.

frag_choice(50,51):-
    set_default_reasoning(all, random_reasoning),
    frag.


frag_choice(50,52):-
    set_default_reasoning(intention_selection, biggest_joint_reasoning),
    frag.

frag_choice(50,53):-
    set_default_reasoning(plan_selection, can_reasoning),
    frag.


frag_choice(50):-
    get_default_reasoning(Intention_Reasoning, Plan_Reasoning,
                          Substitution_Reasoning),
    writeln([Intention_Reasoning, Plan_Reasoning, Substitution_Reasoning]),
    writeln("1, mcts reasoning"),
    writeln("2, simple reasoning"),
    writeln("3, random reasoning"),
    writeln("4, biggest joint (for intention selection only)"),
    writeln("5, can reasoning (for plan selection only)"),
    get_single_char(Choince),
    frag_choice(50, Choince).

frag_choice(51,49):-
    set_bindings(late),
    frag.

frag_choice(51,50):-
    set_bindings(early),
    frag.

frag_choice(51):-
    writeln("1, late bindings"),
    writeln("2, early bindings"),
    get_single_char(Choice),
    frag_choice(51, Choice).

frag_choice(52):-
    writeln("todo"),
    frag.

frag_choice(53):-
    gspy(loop),
    frag.

frag_choice(54):-
    get_frag_attributes(default_bindings, Bindings),
    get_frag_attributes(reasonings, [Intention_Selection, Plan_Selection,
                                     Substitution_Selection]),
    get_frag_attributes(debugs, Debugs),
    nl,
    writeln("Settings"),
    writeln("--------"),
    writeln("Default bindings:"),
    write(".. "),write(Bindings),nl,
    writeln("Reasonings:"),
    write("-> Intention selection: "),write(Intention_Selection),nl,
    write("-> Plan selection: "),write(Plan_Selection),nl,
    write("-> Substitution selection: "),write(Substitution_Selection),nl,
    write("-> Debugs:"), write(Debugs), nl,
    nl,
    frag.


frag_choice( _ ):-
    frag('worker').


%!  set_bindings(+BINDINGS_METHOD: atom) is det
%   Nastavi metodu navazovani promennych
%   * BINDINGS_METHOD: late, early


set_bindings(late):-
    set_late_bindings.

set_bindings(early):-
    set_early_bindings.


get_frag_attributes(default_bindings, late):-
    is_default_late_bindings.

get_frag_attributes(default_bindings, early).


get_frag_attributes(bindings, late):-
    is_late_bindings.

get_frag_attributes(bindings, early).

get_frag_attributes(reasonings, [Intention_Selection, Plan_Selection,
                                 Substitution_Selection]):-
    get_default_reasoning(Intention_Selection, Plan_Selection,
                          Substitution_Selection).


get_frag_attributes(debugs, Debugs):-
    bagof(Debug, frag_debug(Debug), Debugs).

get_frag_attributes(debugs, []).


get_frag_attributes(environments, Environments):-
    get_default_environments(Environments).


%!  set_default_reasoning(+reasoning, +reasoning_method) is det
%   Nastavi zpusob vyberu zameru, planu, substituci
%* Reasoning: intention_selection, plan_selection, substitution_selection, all
%* Reasoning_method: simple_reasoning, random_reasoning,
% biggest_joint_reasoning, snakes_reasoning, mcts_reasoning
%       jeden z nich, pokud neni all, pak seznam tri


set_default_reasoning(intention_selection, Intention_Selection):-
    set_default_intention_selection(Intention_Selection).

set_default_reasoning(plan_selection, Plan_Selection):-
    set_default_plan_selection(Plan_Selection).

set_default_reasoning(substitution_selection, Substitution_Selection):-
    set_default_substitution_selection(Substitution_Selection).

set_default_reasoning(all, Reasoning):-
    set_default_reasoning(Reasoning).


%
%	Load agents + attributes
%




fa_init_set_attrs(debug, DBG):-
    assert(agent_debug(DBG)).	 % jak je to na urovni agenta a vlaken agenta?





load_agent(Agent, Program, Attributes, Thread):-
    term_string(Agent_Term, Agent),
    thread_create(fa_init_agent(Program, Attributes), Thread,
                  [alias(Agent_Term)]),
    assert(agent(Agent_Term)).



load_same_agents(_, _, 0, _, []).

load_same_agents(Agent, Program, Number, Attributes, [THREAD| THT]):-
    concat(Agent, Number, AGENTNAME),
    load_agent(AGENTNAME, Program, Attributes, THREAD),
    Number2 is Number - 1,
    load_same_agents(Agent, Program, Number2, Attributes, THT).



load_agents([],[]).

load_agents([load(Agent, Program, 1, Attributes)| Agents],
            [Agent_Thread| Agent_Threads]):-
    load_agent(Agent, Program, Attributes, Agent_Thread),
    load_agents(Agents, Agent_Threads).

load_agents([load(Agent, Program, Number, Attributes)| Agents],
            Agent_Threads):-
    % posledni term je seznam vytvorenych vlaken
    load_same_agents(Agent, Program, Number, Attributes, Agent_Threads1),
    load_agents(Agents, Agent_Threads2),
    append(Agent_Threads1, Agent_Threads2, Agent_Threads).




%  frag2(Stream,LoadClausesList)
%  reads clauses 'load(Filename, Name, Count, Attrs)'
%  from Stream (a *.mas2fp file) to LoadClausesList
%  Attrs: (bindings, [early|late])
%




frag_process_clause(_ , end_of_file, []):-
    !.

%  sets default attributes

frag_process_clause(Stream, set_environment(Environment, Attributes), Clauses):-
    fRAgAgent:set_environment_attributes(Environment, Attributes),
    !,
    load_multiagent(Stream, Clauses).


frag_process_clause(Stream, set_default(Attributes), Clauses):-
    frag_process_attributes(Attributes),
    !,
    load_multiagent(Stream, Clauses).

frag_process_clause(Stream, include_reasoning(Filename), Clauses):-
    fRAgAgent:include_reasoning_method(Filename),
    !,
    load_multiagent(Stream, Clauses).

frag_process_clause(Stream, include_environment(Filename), Clauses):-
    fRAgAgent:load_environment(Filename),
    !,
    load_multiagent(Stream, Clauses).


% loads a new agent in some number and attributes

frag_process_clause(Stream, load(Filename, Agent, Number, Attributes),
		    [load(Filename, Agent, Number, Attributes)| Clauses])
    :-
    !,
    load_multiagent(Stream, Clauses).

frag_process_clause(Stream, load(Filename), Clauses):-
    consult(Filename),
    !,
    load_multiagent(Stream, Clauses).

frag_process_clause(Stream, Clause, Clauses):-
    format("[MAS2FP] Error processing clause ~w~n", [Clause]),
    !,
    load_multiagent(Stream, Clauses).




%! . frag_process_attributes(+List_Of_Attributes)
% Process default attributes of the system
%* List_Of_Attributes

frag_process_attributes([]).

frag_process_attributes([(Key, Value)| Attributes]):-
    set_default_attribute(Key, Value),
    frag_process_attributes(Attributes).


%!  set_default_attribute(+Key, +Value) is det
%*Key:
%*Value:

set_default_attribute(control, Control):-
    set_control(Control).

set_default_attribute(reasoning, Reasoning):-
    set_default_reasoning(Reasoning).

set_default_attribute(bindings ,late):-
    set_default_late_bindings(true).

set_default_attribute(bindings ,early):-
    set_default_late_bindings(false).

set_default_attribute(reasoning_params , Parameters):-
    fRAgAgent:set_reasoning_params(Parameters).

set_default_attribute(environment, Environment):-
    fRAgAgent:set_default_environment(Environment).









load_multiagent(Stream, Clauses):-
    read_clause(Stream, Clause, []),
    !,
    frag_process_clause(Stream, Clause, Clauses).

load_multiagent(_, []).


%
%  __frag_master code
%

wait_agents([]).		% no agents loaded

wait_agents(Threads):-
    bagof(Agent, ready(Agent), Agents_Ready),
    length(Agents_Ready, Agents_Ready_Length),
    length(Threads, Agents_Ready_Length),
    retractall(ready( _ )).

wait_agents(Threads):-
    wait_agents(Threads).


%
%	MAIN
%

frag(Filename):-
    format(atom(Mas2FP),"~w.mas2fp",[Filename]),
    current_module(fRAg, FRAg_Path),
    absolute_file_name(Mas2FP, Absolute_Mas2FP, [relative_to(FRAg_Path)]),
    access_file(Absolute_Mas2FP, read),
    !,
    open(Absolute_Mas2FP, read, Stream, [close_on_abort(true)]),
    thread_setconcurrency(_ , 1000),
    load_multiagent(Stream, Agents),
    !,
    close(Stream),
    load_agents(Agents, Threads),
    !,
    wait_agents(Threads),
    % run (unblock) agents
    assert(go(1)),
    wait_agents(Threads),
    writeln(Threads),
    join_threads(Threads).



join_threads([]).

join_threads([Thread| Threads]):-
    thread_join(Thread, _),    % Prolog native
    join_threads(Threads).


frag(Filename):-
    format("[MAS2FP] Metafile ~w.mas2fp does not exists.~n", [Filename]).




frag:-
    writeln("Select your choice"),
    writeln("1, run program"),
    writeln("2, set reasoning"),
    writeln("3, set bindings"),
    writeln("4, set debugs"),
    writeln("5, set gspy loop"),
    writeln("6, print settings"),
    writeln("0, exit"),
    get_single_char(Choice),
    writeln(Choice),
    frag_choice(Choice),
    writeln(bye).


mainfp:-
    nl,
    version(Version),
    format(
"FRAg version ~w, 2021 - 2023, by Frantisek Zboril & Frantisek Vidensky,
Brno University of Technology~n~n",
	   [Version]),
    frag('fraginit'),
    !,
    get_frag_attributes(default_bindings, Bindings),
    get_frag_attributes(reasonings, [Intention_Selection, Plan_Selection,
	                Substitution_selection]),
    get_default_environments(Environments),
    format("-> Bindings: ~w~n-> Intention selection: ~w ~n-> Plan selection: ~w
-> Substitution selection: ~w ~n-> Environments: ~w ~n~n",
	   [Bindings, Intention_Selection, Plan_Selection,
            Substitution_selection, Environments]).


:-initialization(mainfp, after_load).



md:-
    use_module(library(pldoc/doc_library)),
 %   doc_load_library,
    doc_save('FragPL.pl',[format(html), recursive(true), doc_root(doc)]).



rep(_, 0).

rep(P, N):-
    P,
    N2 is N-1,
    rep(P, N2).
