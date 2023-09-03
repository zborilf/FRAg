                                                                                                       
%                             
%   	FRAg Agent 
%   	Frantisek Zboril jr. 2021 - 2023 
%    


/** 
<module> fRAgAgent

This module contains code for threads of individual agents

@author Frantisek Zboril
@license GPL
*/


%   -- agent thread --
%

:-module(fRAgAgent,
    [
	fa_init_agent / 2,
	go_sync / 2,
	include_reasoning_method /1,
	load_environment /1,
	set_default_reasoning /1,
	get_default_reasoning /3,
	set_plan_selection /1,
	set_default_plan_selection /1,
	set_intention_selection /1,			% je toto opravdu nutne z venku?
	set_default_intention_selection /1,
	set_substitution_selection /1,
	set_default_substitution_selection /1,
	set_default_environment /1,
	get_default_environments /1,
	set_reasoning_params /1,
	set_late_bindings /1,
	set_late_bindings /0,
	set_default_late_bindings /1,
	set_early_bindings /0,
	is_late_bindings /0,
	is_default_late_bindings /0,
	force_reasoning /1,
	force_execution /1,
	take_snapshot /1
    ]
  ).


:- discontiguous get_substitution/5.
:- discontiguous reasoning_method/1.
:- discontiguous get_plan/4.
:- discontiguous get_intention/3.
:- discontiguous init_reasoning/1.
:- discontiguous execute/4.
:- discontiguous apply_substitutions/1.
:- discontiguous extend_intention/3.


:- multifile reasoning_method /1.
:- multifile get_intention /3.
:- multifile get_substitution /5.
:- multifile get_plan /4.
:- multifile init_reasoning /1.
:- multifile update_model /1.


% FRAg specific ops / late bindings etc.
:-include('FRAgPLFRAg.pl').     	
% FRAg operations for relations and assignments
:-include('FRAgPLRelations.pl').     	

% shared data among threads (agents etc.)
:-use_module('FRAgBlackboard').       
% interface to environments
:-use_module('FRAgAgentInterface').   


% :-include('environments/FRAgPLEnvironmentBasic.pl').  	% internal actions library


max_agent_iterations(200).

%
%  	dynamic atoms
%
:-dynamic default_late_bindings / 1.
:-dynamic default_environment /1.

%
%  thread_local predicates ... plans, facts (beliefs), intentions, events (desires, goal), fresh intention index, simulation loop number
%

:-thread_local plan/5.                    			% type, triggering event, guards (context conditions), context, body 
:-thread_local fact/1.                          		% belief is fact, inside fact(.) predicate
:-thread_local intention /3.      				% intention(intention_index, content - plan_stack, active?) 
:-thread_local goal /3.                         		% goal(type - ach/add, pridicate, parent intention , context, state - active / intention number, historie pouzitych planu)
:-thread_local event /7.                                      % event(index, type - ach/add, pridicate, parent intention , context, state - active / intention number, historie pouzitych planu)
:-thread_local intention_fresh / 1.
:-thread_local event_fresh / 1.
:-thread_local loop_number /1.
:-thread_local agent_debug /1. 				% todo takze centralne z nastenky, nebo lokalne?              
:-thread_local late_bindings /1.              





include_reasoning_method(Filename):-
    load_files([Filename], [silent(true)]).

set_reasoning_params(Parameters):-
    set_reasoning_method_params(Parameters).

  % just load it
load_environment(Filename):-
    add_environment_library(Filename).


%%%%%%%%%%%%%%
%
%       DEBUG supporting clauses
%


is_debug(Debug, true):-
    agent_debug(Debug).

is_debug(_, false).
	

print_debug(Content, Debug):-
    agent_debug(Debug),
    write(Content).

print_debug(_, _).


print_debug(String, Data, Debug):-      % 'format' print / no sense fot new line version
    agent_debug(Debug),
    format(String, Data).

print_debug(_, _, _).


println_debug(Content, Debug):-
    agent_debug(Debug),
    !,
    write(Content),
    nl.

println_debug(_, _).            



print_list_state([],S,S).

print_list_state([H|T], S, String_Out):-
    term_string(H, HS),
    concat(S, HS, S2),
    concat(S2, ";\n", S3),
    print_list_state(T, S3, String_Out).  


print_plans([], String, String).

print_plans([plan(PLANINDEX, EVENTTYPE, EVENTATOM, PLANGUARDS, PLANCONTEXT, PLANBODY)| TPLANS], STRINGIN, STRINGOUT):-
    format(atom(PLANSTRING), "   plan(~w, ~w, ~w, ~w ~w ~n       ~w)~n ", [PLANINDEX, EVENTTYPE, EVENTATOM, PLANGUARDS, PLANCONTEXT, PLANBODY]),
    concat(STRINGIN, PLANSTRING, STRINGMID),
    print_plans(TPLANS, STRINGMID, STRINGOUT). 


  print_intention([], STRING, STRING).  

print_intention([intention(INTENTIONINDEX, PLANSTACK, STATE)| TINTENTIONS], STRINGIN, STRINGOUT):-
    concat(STRINGIN, "intention:", STRING2),
    concat(STRING2, INTENTIONINDEX, STRING3),
    concat(STRING3, "\n", STRING4),
    print_plans(PLANSTACK, STRING4, STRING5),
    term_string(STATE, STATESTRING),
    concat(STRING5, STATESTRING , STRING6),
    concat(STRING6, "\n", STRINGMID),
    print_intention(TINTENTIONS, STRINGMID, STRINGOUT).		



print_intentions(STRING, STRINGINTENTIONSOUT):-
    bagof(intention(INTENTIONINDEX, C, STATUS),intention(INTENTIONINDEX, C, STATUS), INTENTIONS),
    concat(STRING, ":: INTENTIONS {\n", STRING2),
    % print_list_state(INTENTIONS, STRING2, STRINGINTENTIONS),
    print_intention(INTENTIONS, STRING2, STRINGINTENTIONS), 
    concat(STRINGINTENTIONS, "}\n", STRINGINTENTIONSOUT).

print_intentions(S, SI):-
    concat(S,":: INTENTIONS: No intentions\n",SI).


print_goals(STRING, SG):-
    bagof(event(EVENTINDEX, T, A, B, C, D, E), event(EVENTINDEX, T, A, B, C, D, E), EVENTS),
    concat(STRING,":: EVENTS {\n", STRING2),
    print_list_state(EVENTS, STRING2, SEVENTS),
    concat(SEVENTS, "}\n", SG).
    
print_goals(S, SG):-
    concat(S, ":: EVENTS: No events\n", SG).


print_beliefs(S,SB):- 
    bagof(fact(Fact), fact(Fact), Facts),
    concat(S,":: BELIEFS {\n",S2),
    print_list_state(Facts, S2, String_Facts),
    concat(String_Facts, "}\n", SB).

print_beliefs(Label, Belief):-
    concat(Label, ":: BELIEFS: No beliefs\n", Belief).
    

print_agent_state(DEBUG):-
    loop_number(LOOP),
    thread_self(NAME),  
    format(atom(S1),":: vvvvvvvvvvvvvvvvvvvvvvvvvv~n",[]),
    format(atom(S2),":: Name:~w~n", [NAME]),
    format(atom(S3),":: LOOP ~w~n", [LOOP]),
    concat(S1,S2,S4),
    concat(S4,S3,S5),
    print_intentions(S5, SI),
    print_goals(SI, SG),
    print_beliefs(SG,SB),
    format(atom(SE),":: ^^^^^^^^^^^^^^^^^^^^^^^^^^~n",[]),
    concat(SB,SE,SD),
    print_debug(SD, DEBUG).


print_state( _ ):- 					% print system state ???
    agent_debug(no_debug).

print_state(Message):-
    println_debug('', reasoningdbg),
    println_debug(Message, reasoningdbg),
    print_agent_state(reasoningdbg),
    !.
                 
print_state(_).    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   	Beliefs processing
%       

process_add_list([]).

process_add_list([BELIEF |TBELIEFS]):-
    fact(BELIEF),					% is already in BB
    process_add_list(TBELIEFS).

process_add_list([BELIEF |TBELIEFS]):-
    assert(fact(BELIEF)),
    create_event(add, BELIEF),
    process_add_list(TBELIEFS).

process_delete_list([]).	

process_delete_list([BELIEF |TBELIEFS]):-
    fact(BELIEF),					% is in BB, should be deletd
    retract(fact(BELIEF)),
    create_event(del, BELIEF),
    process_delete_list(TBELIEFS).

process_delete_list([_ |TBELIEFS]):-			% not present in BB, need not to be deleted
    process_delete_list(TBELIEFS).




%
%	AGENT INTERPRETATION
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   	ONE ACT EXECUTION, 5th interpretation level / execution
%       

create_event(Event_Type, Belief):-
    get_fresh_event_number(Event_Index),
    % generates 'add' event
    assert(event(Event_Index, Event_Type, Belief, null, [[]], active, [])).  



% execute(+Intention, +PlanBefore, - PlanAfter)
% execute(zamer, plan(trigevent, context condition, plan context, plan body), 
%                plan(trigevent, context condition, new plan context, new plan body)).
%




% add belief execution add(pred(t1,t2...))

execute(_ , plan(Event_Type, Event_Atom, Conditions, Context,
                 [add(Belief)| Acts]), 
 		 plan(Event_Type, Event_Atom, Conditions, Context2, Acts), 
        true):-
    % term_variables(Belief, BELIEFVARIABLES),
    decisioning(Belief, Context, Context2),
    assert(fact(Belief)),
    create_event(add, Belief).
    

% delete belief execution del(pred(t1,t2...))

% delete action succeeds even when there is nothing to delete 

nonempty([], false).

nonempty( _, true).


try_retract(F):-
    retract(F),
    get_fresh_event_number(INDEX),
    assert(event(INDEX, del, fact(F), null, [[]], active, [])). % generates 'del' event

try_retract(_).


execute(_ ,
        plan(Goal_Type, Goal_Term, Conditions, Context, [del(Belief)| Acts]),
	plan(Goal_Type, Goal_Term, Conditions, New_Context, Acts),
        true):-
    % term_variables(Belief, Action_Vars),
    decisioning(Belief, Context, New_Context),
    try_retract(fact(Belief)),
    create_event(del, Belief).


% instance set, makes instance set of PRED using CTX, only in FRAg

execute(_ ,plan(Goal_Type, Goal_Term, Conditions, Context,
                [iset(Predicate, Instance_Set)| Acts]),
	   plan(Goal_Type, Goal_Term, Conditions, Context, Acts), true):-
    instance_set(Predicate, Context, Instance_Set).


% performas -- test goal --
% test(+TestGoalPredicate)  
% f.e. test(mean(task,Mean)) - unifies with possible fact(mean(task,hammer))
% bags up all the facts matchig the +TestGoalPredicate and then makes broad unification and restricts with the original plan context

execute( _, plan(GOALTYPE, GOALTERM, CONTEXCONDITIONS, PLANCONTEXT, [test(GOAL)| PACTS]), 
	    plan(GOALTYPE, GOALTERM, CONTEXCONDITIONS, PLANCONTEXTNEW, PACTS),
            RESULT):-
	query(GOAL, PLANCONTEXT, CONTEXT2),
	simulate_early_bindings(GOAL, CONTEXT2, PLANCONTEXTNEW),
	nonempty(PLANCONTEXTNEW, RESULT).             % true / fail as the act result


% vykona cil dosazeni, asi nejnarocnejsi

execute(INTENTIONINDEX, plan(EVENTTYPE, EVENTATOM, PC, PLANCONTEXT, [ach(GOAL) |TPLANS]),
			plan(EVENTTYPE,EVENTATOM, PC, PLANCONTEXT, [ach(GOAL)|TPLANS]),
                        true):-
    retract(intention(INTENTIONINDEX, PLANSTACK, active)),
% this intention is blocked now
    assertz(intention(INTENTIONINDEX, PLANSTACK, blocked)), 	       	
% variables of the goal declared
    term_variables(GOAL, GOALVARIABLES),              		  	
% nashortujeme kontext puvodni urovne podle promennych v dekl. cili
    shorting(GOAL, G3, PLANCONTEXT, GOALVARIABLES,NEWCONTEXT,_),   
    get_fresh_event_number(EVENTINDEX),
% zadame pod-cil i s odkazem na tuto intensnu INT, nashortovanym kontextem CTXSH, cil je ted aktivni
    assert(event(EVENTINDEX, ach, G3, INTENTIONINDEX, NEWCONTEXT, active, [])).      	

% v planu nic neni, nedelame nic a ani jej nemenime, on bude odstranen z intensny na vyssi urovni
  
execute(_ ,plan(EventType,G,PC,CTX,[]),plan(EventType,G,PC,CTX,[]),true).


% vykona aritmeticko-logickou operaci alop(operace)
% napriklad alop(X<3) alop (X is Y+1)
% vykona toto pro veskery kontext (nedela decision narozdil od act, ale provede pro vsechny a redukuje kontext)

execute(_ ,plan(EVENTTYPE, EVENTTERM, CONDITIONS, Context, [rel(A is B)| TBODY]), 
			plan(EVENTTYPE, EVENTTERM, CONDITIONS, ContextOut, TBODY), Result):-
    	alop(A is B, Context, ContextOut, Result).

execute(_ ,plan(Event_Type, Event_Term, Conditions, Context, 
                [rel(Relation)| TBODY]), 
	plan(Event_Type, Event_Term, Conditions, Context_Out, TBODY), Result):-
    functor(Relation, Operator, _),
    is_relational_operator(Operator),
    alop(Relation, Context, Context_Out, Result).
    % agent_acts
    	


execute_environment(Environment, Action, Result):-
    thread_self(Agent_Name),
    agent_acts(Agent_Name, Environment, Action, Result).

execute_environment( _, _, false).


% agent acts in specified environment
execute(_ ,plan(Event_Type, Event_Term, Conditions, Context, 
                [act(Environment, Action)| Acts]), 
	plan(Event_Type, Event_Term, Conditions, Context_Out, Acts), Restult):-
    decisioning(Action, Context, Context_Out), 
    !,
    execute_environment(Environment, Action, Restult).

execute(_ , plan(EventType, EventTerm, Conditions, Context, [act(Action)| Plans]),
		 plan(EventType, EventTerm, Conditions, ContextOut, Plans), Result):-
    % rozhodnem o vybrane akci, zmeni to kontext (udelame rozhodnuti na CTX pro promenne v ACTION)
    decisioning(Action, Context, ContextOut), 
    !,
    % execute action in 'basic' FRAg environment    
    execute_environment(basic, Action, Result).


%  vykonani interni akce, act(action(t1,t2,...))., udela nejakej decisioning kontextu pro t1,t2... a vykona ji (udela to opravdu ty substituce, jak vlastne?? decisioning?? MAGIC!!)
%  obsolete, uz v execute_action
%  execute(_ ,plan(GT,G,PC,CTX,[act(Action)|AT]),plan(GT,G,PC,CTX2,AT), true):-
%   write('eplan4 '),write(Action),nl,
%   Action=..ACTIONTERMS,                           % TODO nepekne, term_variables
%   decisioning(ACTIONTERMS,CTX,CTX2),      % rozhodnem o vybrane akci, zmeni to kontext (udelame rozhodnuti na CTX pro promenne v ACTION)
%   Acti-on.

% TODO false nezmeni kontext, hlavne by mel vratit event zpatky, pokud failne TLP, tak zrusit zamer a vratit goal
  execute(_ ,plan(GT,G,PC,CTX,[AH|AT]),plan(GT,G,PC,CTX,[AH|AT]), false).


% Plan is linear and only one act is executed per cycle

execute_plan(Intention_Index, 
             [plan(Plan_Index, Event_Type, Event_Term, Conditions, Context, Body)| 
                 Plans],
	     [plan(Plan_Index, Event_Type, Event_Term, Conditions, Context2, Body2)| 
                 Plans],             
             Result) 
    :-
    execute(Intention_Index, 
            plan(Event_Type, Event_Term, Conditions, Context, Body),
	    plan(Event_Type, Event_Term, Conditions, Context2, Body2),             
            Result),
    !.
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   INTENTION PROCESSING, 4th interpretation level / reasoning and execution
%


put_back_plan(IDX, false):-                % vybrany plan spadnul, dame jej na konec programu, aby se pripadne priste vybral jiny pro PGT/PG
    %   printfg("Giving the plan to the end of PB",[IDX]),
    retract(plan(IDX,PGT,PG,PGU,PB)),
    assertz(plan(IDX,PGT,PG,PGU,PB)).                      
  
put_back_plan(_,_).     % akce planu byla OK, nedavame nakonec


%
%   MAKE/EXTEND INTENTION with a mean for the goal G with a context CTX
%



% for the next definition, fresh intention ID

get_fresh_intention_number(Intention_Index):-
    intention_fresh(Intention_Index),
    retract(intention_fresh(Intention_Index)),
    Intention_Index2 is Intention_Index+1,
    assertz(intention_fresh(Intention_Index2)).
    extend_intention(_ , [], -1).  % ???


get_fresh_event_number(Event_Index):-
    event_fresh(Event_Index),
    retract(event_fresh(Event_Index)),
    Event_Index2 is Event_Index+1,
    assertz(event_fresh(Event_Index2)).
	

% means found for top level goal

extend_intention(null, [plan(PLANINDEX, EVENTTYPE, EVENTTERM, CONDITIONS, BODY), INTENTIONCONTEXT], INTENTIONINDEX)
    :-
	%   put_back_plan(IDX),
    	get_fresh_intention_number(INTENTIONINDEX),
    	assertz(
	   intention(INTENTIONINDEX, [plan(PLANINDEX, EVENTTYPE, EVENTTERM, CONDITIONS, INTENTIONCONTEXT, BODY)], active)
	   ).

% means found for a subgoal

extend_intention(INTENTIONINDEX, [plan(PLANINDEX, EVENTTYPE, EVENTTERM, CONDITIONS, BODY), INTENTIONCONTEXT], INTENTIONINDEX)
    :-
	%   put_back_plan(PGT,PG),
    	retract(intention(INTENTIONINDEX, PLANSTACK, blocked)),
    	assertz(
	   intention(INTENTIONINDEX,
		[plan(PLANINDEX, EVENTTYPE, EVENTTERM, CONDITIONS, INTENTIONCONTEXT, BODY)| PLANSTACK],active
	            )
	 	).

extend_intention(INTENTIONINDEX, PLANSTACK, Status):-
    format(atom(STRING),"[ERROR] Lost intention ~w",[intention(INTENTIONINDEX, n, PLANSTACK, Status)]),
    println_debug(STRING, error).


%
%  INTENTION SELECTION, 'returns' one active intention due to active reasoning method (see FRAgPLFRAg.pl and FRAg*Reasoning.pl files)
%


select_intention(intention(IDXO,CNTO,ACTO)):-
    bagof(intention(IDX,CNT,STS),intention(IDX,CNT,STS),INTENTIONS),
    get_intention(INTENTIONS,intention(IDXO,CNTO,ACTO)).
  

%
%  UPDATE EVENT 
%      


update_event(-1, event(EVENTINDEX, ach, EVENTATOM, PARENTINTENTIONINDEX, CONTEXT, active, HISTORY), _, _):-
    assert(event(EVENTINDEX, ach, EVENTATOM, PARENTINTENTIONINDEX, CONTEXT, active, HISTORY)).   % No applicable means for any achieve goal, put the goal back
    
update_event(NEWINTENTIONINDEX, event(EVENTINDEX, ach, EVENTATOM, INTENTIONINDEX, CONTEXT, active, HISTORY), true, 
    [plan(PLANINDEX, _, TRIGGERATOM, CONTEXTCONDITIONS, _), PLANCONTEXT]):-
    % Means for the top level ach goal found, active -> intention number (it means blocked)
    assert(event(EVENTINDEX, ach, EVENTATOM, INTENTIONINDEX, CONTEXT, NEWINTENTIONINDEX, 
		 [used_plan(PLANINDEX, TRIGGERATOM, CONTEXTCONDITIONS, PLANCONTEXT)| HISTORY])).   
  % No means for any achieve goal, put the goal back
update_event( _, event(EVENTINDEX, ach, EVENTATOM, PARENTINTENTIONINDEX, CONTEXT, active, HISTORY), false, _):-
    assert(event(EVENTINDEX, ach, EVENTATOM, PARENTINTENTIONINDEX, CONTEXT, active, HISTORY)).   

 % Other types of events (add/del) are kept deleted in both cases (means found / not found)
update_event( _, event( _, _, _, _, _, active, _), _, _).     



%
%  UPDATE INTENTION (cisteni zameru po vykonani akctu, pokud v intention 0, je blokovana, neresime; 1, skoncil toplevel plan, 2; podplan 3; nic z toho, ale akt byl vykonan a zasobnik zmenen
%       TODO ... ktera pravidla z clanku k submitnuti toto vlastne realizuje???
%

  % smaze event zpracovavany INTENTIONINDEX s nejvetsim vlastnim indexem (aktualni pro tento zamer)

try_retract_event(INTENTIONINDEX):-           
    findall(EVENTINDEX, event(EVENTINDEX, _, _, _, _, INTENTIONINDEX, _), 
            EVENTINDEXES),
    max_list(EVENTINDEXES, ACTUALEVENTINDEX),     
    retract(event(ACTUALEVENTINDEX, _, _, _, _, _, _)).

try_retract_event( _).


  % BLOKOVANA
  % pokud je intensna zablokovana, znamena to, ze jako posledni v ni byl provedeno vyvolani podcile. Nemeni se, dokud se podcil nepovede
  
update_intention(intention(INTENTIONINDEX, _, _), true):-  
    intention(INTENTIONINDEX, _, blocked),
    println_debug("[RSNDBG] Update intention: INTENTION BLOCKED", reasoningdbg).  % no update for blocked intention / waiting for subgoal

  % USPEL TOPLEVEL	
  % prazdny toplevel plan, resp. telo tohoto planu znamena, ze je hotovo, tedy smazeme intensnu a cil, ktery ji byl dosazen
  
update_intention(intention(INTENTIONINDEX, [plan(_,_,_,_,_,[])], _), _):-
    println_debug("[RSNDBG] Update intention: TOP LEVEL PLAN SUCCEEDED", reasoningdbg),
    retract(intention(INTENTIONINDEX, _, _)),
    %  try_retract_event(EVENTATOM, ORIGIN, EVENCONTEXT, INTENTIONINDEX)
    %  pro external event je jasne, o ktery event se jedna jen podle INTENTIONINDEX
    try_retract_event(INTENTIONINDEX).

% USPEL PODPLAN	
% skoncil podplan, musime udelat prenos kontextu na vyssi uroven!!! Dale vyhodi akci vyvolani podcile
% znovu zavolame update intention, muze dojit k tomu, ze splnenim podcile byl splnen i nadplan (6.2.2023) 
  
update_intention(intention(INTENTIONINDEX, 
		 [plan( _, _, EVENTATOM2, _, CONTEXT2, []), 
		       plan(PLANINDEX, EVENTTYPE, EVENTATOM, COND, CONTEXT, [ach( GOAL )| TACTS])| 
		  TPLANS], 
					STATUS), _ ):-
    println_debug("[RSNDBG] Update intention: SUBPLAN SUCCEEDED", reasoningdbg),
    intersectionF(EVENTATOM2, CONTEXT2, GOAL, CONTEXT, NEWCONTEXT),
    retract(intention(INTENTIONINDEX, [ _, _| TPLANS], STATUS)),
    assertz(intention(INTENTIONINDEX, [plan(PLANINDEX, EVENTTYPE, EVENTATOM, COND, NEWCONTEXT, TACTS)| TPLANS], STATUS)),
    % writeln(intention(INTENTIONINDEX, [plan(PLANINDEX, EVENTTYPE, EVENTATOM, COND, NEWCONTEXT, TACTS)| TPLANS], STATUS)),
    try_retract_event(INTENTIONINDEX),
    update_intention(intention(INTENTIONINDEX, 
                               [plan(PLANINDEX, EVENTTYPE, EVENTATOM, 
                                     COND, NEWCONTEXT, TACTS)| TPLANS], 
                                STATUS), 
                      true).       

% NEUSPEL TOPLEVEL	
% neuspela akce v toplevel planu zameru, zrusi zamer a obnovi cil 

update_intention(intention(INTENTION, [ _ ], Status), false):-
    println_debug("[RSNDBG] Update intention: TOP LEVEL PLAN FAILED", reasoningdbg),
    retract(intention(INTENTION, _, Status)),   
    % event(EVENTINDEX, EVENTYPE, EVENTTERM, null, CONTEXT, INTENTION2, HISTORY),
    % zapoznamkoval jsem, zdalo se mi to zbytecne
    % bagof(event(A,B,C,D,E,F,G), event(A,B,C,D,E,F,G), ES),		
    % cil, pro ktery byl zamer udelan, ma predposledni term INTENTION
    retract(event(EVENTINDEX, EVENTYPE, EVENTTERM, null, CONTEXT, INTENTION, HISTORY)),  
    assertz(event(EVENTINDEX, EVENTYPE, EVENTTERM, null, CONTEXT, active, HISTORY)).


% neuspela akce v podplanu, plan vyhodime z intensny a plan vyssi urovne bude aktivni, znovu vytvori event pro cil dosazeni atd...
% TODO, jako v predchozim, cil by mel byt zadan a nastaven na aktivni

update_intention(intention(INTENTION, [Plan| Plans], Status), false):-
    println_debug("[RSNDBG] Update intention: SUBPLAN FAILED", reasoningdbg),
    retract(intention(INTENTION, [Plan| Plans], Status)),   
    assertz(intention(INTENTION, Plans, active)). 
	                                                                                                                                  	

  % zmenil se plan / zasobnik vykonanim predchozi akce, ale neni na jeho vrcholu prazdny plan, tedy ...
  % na zaklade identifikatoru INT si vytahneme starou tuto intensnu, resp. ji vymazeme a vlozime znovu s novym zasobnikem PLANSTACK (proc je v hlavicce cil jako _ nevim, to by snad mohlo byt primo G??)

update_intention(intention(INTENTION, PLANSTACK, STATUS), _):-
    println_debug("[RSNDBG] Update intention: ACTION SUCCEEDED", reasoningdbg),
    retract(intention(INTENTION, _, STATUS)),   % stary zasobnik nevim, je to jedno, stejne ho chceme prepsat, udelame anonymni _
    assertz(intention(INTENTION, PLANSTACK, STATUS)).



  % if late_bindings(false) -> cut contexes of top level (it should be enough) plans of each intention to size max 1

expand_plans([plan( _, _, _, _, _), []]  , []).   % no mode substitutions in context

expand_plans([plan(INDEX, TRIGGERTYPE, TRIGGERATOM, CONTEXTCONDITIONS, BODY), [SUBSTITUTION| TCONTEXT]],
 		   [[plan(INDEX, TRIGGERTYPE, TRIGGERATOM, CONTEXTCONDITIONS, BODY), [SUBSTITUTION]] | TPLANS]):-
    expand_plans([plan(INDEX, TRIGGERTYPE, TRIGGERATOM, CONTEXTCONDITIONS, BODY), TCONTEXT], TPLANS).


simulate_early_reasoning([], []).

simulate_early_reasoning([[plan(INDEX, TRIGGERTYPE, TRIGGERATOM, 
                                CONTEXTCONDITIONS, BODY), CONTEXT]| Plans], 
                           Means):-
    expand_plans([plan(INDEX, TRIGGERTYPE, TRIGGERATOM, CONTEXTCONDITIONS, BODY), CONTEXT], Means1), 
    simulate_early_reasoning(Plans, Means2), 
    append(Means1, Means2, Means).	


check_early_reasoning([], []).

check_early_reasoning(MEANS, MEANS):-
    late_bindings(true).	

check_early_reasoning(PLANS, MEANS):-
    simulate_early_reasoning(PLANS, MEANS).



%%%%%% Update Intentions - remove joint_action from the top of any intention
                                  
update_intentions(Result):-
    % res is ground action, for this ...
    % following query bounds the free variable in plan's act(Result) and later 
    % it leads to reduction of the plan context
    % takes 'another' intention with act(Result) on its top
    intention(INT, [plan(IDX,GT,G,PC,CTXP,[act(Result)| TACTS])| TPLANS], active),       
    shortNoVars(CTXP, NCTXP),
    update_intention(intention(INT,[plan(IDX,GT,G,PC,NCTXP, TACTS)| TPLANS], 
                               active), 
                     true),
    update_intentions(Result).    

update_intentions( _):-
    println_debug("[RSNDBG] Update intention: OTHER", reasoningdbg).

            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   REASONING, 3rd interpretation level (event selection, relevant and applicable plan / intended mean selection)
%



% for context [] Means is not taken 

is_means([],_,[]).
  
is_means(_, Means, Means).


check_applicable(CONTEXT, [], CONTEXT).      

% 'true' allways succeeds
check_applicable(CONTEXT, [true| T], NEWCONTEXT):-
    check_applicable(CONTEXT, T , NEWCONTEXT).
             
% condition is a relation <  >  =  ==

check_applicable(Context, [Relation| T], Context_Out):-
    Relation=..[Operator, _, _], 
    is_relational_operator(Operator),
    alop(Relation, Context, NEWPUS, true),
    check_applicable(NEWPUS, T, Context_Out).
    
% condition is a query

% CONTEXTOUT = [] -> not applicable, else applicable
check_applicable(Context, [Context_Condition| Context_Conditions], 
                 Context_Out):-
    query(Context_Condition, Context, Context2),!, 
    check_applicable(Context2, Context_Conditions, Context_Out).


check_relevant_applicable_plan(EVENTATOM, Context, 
				plan(Plan_Index, Event_Type, TRIGGERATOM, 
				     Context_Conditions, PLANBODY), 
				Means):-
    intersectionF(EVENTATOM, Context, TRIGGERATOM, CONTEXT2),
%	simulate_early_bindings(TRIGGERATOM, CONTEXT2, CONTEXT3), 
%	!,
    check_applicable(CONTEXT2, Context_Conditions, Context4),
% Means is either the second term, if Context is not [], or [] if it is
    is_means(Context4, [[plan(Plan_Index, Event_Type, TRIGGERATOM, 
			 Context_Conditions, PLANBODY), Context4]], 
	     Means).


%  check_relevant_applicable_plan(_, _, _, []).		% is not applicable



check_relevant_applicable_plans(_,_,[],[]).  % no more adepts

check_relevant_applicable_plans(G,CTX,[H| TPLANS],T3):-
    % H pokud projde, bude v H2 jako [[H,Kontext]], jinak []
    check_relevant_applicable_plan(G,CTX,H,H2),     	
    check_relevant_applicable_plans(G, CTX, TPLANS, T2),
    append(H2,T2,T3).

check_relevant_applicable_plans(G, Context_Conditions, [_ | Plans], T2):-
    check_relevant_applicable_plans(G, Context_Conditions, Plans, T2).
    
% RELEVANT PLAN for GOAL in CTX, -> REL

get_relevant_applicable_plans(Event_Type, Event_Atom, Context, MEANSBINDINGS):-
    bagof(plan(Plan_ID, Event_Type, Event_Atom, Context_Conditions, Body), 
	  plan(Plan_ID, Event_Type, Event_Atom, Context_Conditions, Body), 
          PREREL),
    check_relevant_applicable_plans(Event_Atom, Context, PREREL, MEANS),
    check_early_reasoning(MEANS, MEANSBINDINGS).
                    


get_relevant_applicable_plans(_,_,[],[]).
  
                             
  % CHECK GUARDS (in the input list)    

%
%  valid([]).                              
%
%  valid([CONTEXTCONDITION|TCONTEXTCONDITIONS]):-
%	fact(CONTEXTCONDITION),
%	valid(TCONTEXTCONDITIONS).
% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	FORCE REASONING / EXECUTION ( DUE TO THE MCTS MODEL )
%

%
%  Force reasoing like force execution, to concrete action
%  used by MCTS model module
%



force_reasoning(model_reasoning_node(
                    event(Event_Index, Event_Type, EVENTATOM, INTENTIONINDEX, 
                          EVENTCONTEXT, active, HISTORY), 
                    Plan, 
                    PLANCONTEXT)
               ) 
:- 
    retract(event(Event_Index, Event_Type, EVENTATOM, INTENTIONINDEX, 
                  EVENTCONTEXT, active, HISTORY)), 
    extend_intention(INTENTIONINDEX, [Plan, PLANCONTEXT], NEWINTENTIONINDEX),
    update_event(NEWINTENTIONINDEX, 
                 event(Event_Index, Event_Type, EVENTATOM, INTENTIONINDEX, 
                       CONTEXT, active, HISTORY), 
                 true, 
                 [Plan, CONTEXT]).
	
  % printInentions("",SI),
  % write(SI),nl.


printints:-
    findall(intention(Intention_IS ,Plan_Stack ,State), 
            intention(Intention_IS ,Plan_Stack ,State), Intentions),
    writeln('Intentions:'),
    writeln(Intentions). 

printints.


% sub-plan finished
force_execution(model_act_node(Intention_Index, true, _)):-
    intention(Intention_Index, Plan_Stack, Status),
    update_intention(intention(Intention_Index, Plan_Stack, Status), _).

force_execution(model_act_node(Intention_Index, Act, Decision)):- 
    retract(intention(Intention_Index, [plan(IDX, GT, G, PC, CTX, [PLANACT| TACTS])| T], 
                      Status)),       
    % action in node and in the plan could have renamed vars, unify them
    unifiable(PLANACT, Act, ACTUNIFIER),
    apply_substitutions(ACTUNIFIER),
    restrict(CTX, Decision, CTXNew),
    % update intention ... plan has now a new context restricted by decision
    assert(intention(Intention_Index, [plan(IDX, GT, G, PC, CTXNew, [PLANACT| TACTS])| T],
                     Status)),          % update intention ... plan has now a new context restricted by decision
    execute_plan(Intention_Index, [plan(IDX, GT, G, PC, CTXNew, [PLANACT| TACTS])| T], P2, 
                 Result),
    update_intention(intention(Intention_Index, P2, Status), Result),
    update_intentions(Result).


%   write('acting finished'),nl.                % if RES is a joint_action, it should be removed from the top of any intention

                
  force_execution(model_act_node( _, _, _)).

%   write('Execution failed '), write(model_act_node(Intention, no_action, Decision)),nl,!.     % Execution failed 
                                                                                                      




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   REASONING and act EXECUTION, 2nd interpretation level
%


%
% Execution
%

execution:-
    select_intention(intention(INT,[plan(IDX,GT,G,PC,CTXP,P)| TPLANS],STATUS)),
    !,
    execute_plan(INT,[plan(IDX,GT,G,PC,CTXP,P)| TPLANS], P2, Result),
    % if RES is false, the plan failed, it is good to put it to the end of PB 
    % (cyclic RR approach as default for failing plans)
    put_back_plan(IDX, Result),           		  
    update_intention(intention(INT,P2,STATUS), Result),
    % if RES is a joint_action, it should be removed from the top of intention
    update_intentions(Result).

execution.  % nothing left to do


%
%   Reasoning 
%



  % reasoning3(goal, result, assigned intention)

reasoning3(event(EVENTINDEX, EVENTTTYPE, EVENTATOM, Parent_Intention_ID, 
                 CONTEXT, active, HISTORY)):-
    get_relevant_applicable_plans(EVENTTTYPE, EVENTATOM, CONTEXT, MEANS),      
    get_intended_means(MEANS, event(EVENTINDEX, EVENTTTYPE, EVENTATOM, 
                                    Parent_Intention_ID, CONTEXT, active, 
                                    HISTORY), INTENDEDMEANS),
    extend_intention(Parent_Intention_ID, INTENDEDMEANS, INTENTIONINDEX),
    update_event(INTENTIONINDEX, 
	         event(EVENTINDEX, EVENTTTYPE, EVENTATOM, Parent_Intention_ID,
                       CONTEXT, active, HISTORY), true, INTENDEDMEANS).

  % reasoning -> no means

reasoning3(event(Event_ID, Event_Type, Event_Atom, Intention_ID, Context,
                 active, History)):-
    update_event(-1, event(Event_ID, Event_Type, Event_Atom, Intention_ID, 
                           Context, active, History), false, _).




reasoning2([]).

reasoning2([EVENT | TEVENTS]):-
    retract(EVENT),
    reasoning3(EVENT),
 %  reasoning_finisher(INTN, EVENT, SUCC),
    reasoning2(TEVENTS).


reasoning:-
    bagof(event(EVENTINDEX, EVENTTYPE, EVENTATOM, INTENTION, CONTEXT, active, HISTORY), 
		event(EVENTINDEX, EVENTTYPE, EVENTATOM, INTENTION, CONTEXT, active, HISTORY), 
		      EVENTS),
   reasoning2(EVENTS).

reasoning.  % no events




%
%  Communication handler
%

process_messages:-
    % expected form message(sender,perfomatie,pld(payload))
    thread_peek_message(Message),                
    thread_get_message(Message),
    % thread_self(ME),
    % format("Received message for  ~w with content ~w~n",[ME,MSSG]),
    get_fresh_event_number(Event_Index),
    assert(event(Event_Index, add, Message, null, [[]], active, [])).
    
process_messages.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   AGENT CONTROL LOOP, top interpretation level
%


% pokracujeme ve vykonavani smycky?
% ne, pokud 1, pocitadlo je na nule, nebo pokud neni zadna aktivni intensna a 
% zaroven neni zadny deklarovany cil, pak dame jeste 'finished', kde se 
% vyblbnem a reknem nashledanou


finished:-
    thread_self(NAME),
    loop_number(STEPS),
    format(atom(STRINGS), "~n[SYSDBG] Agent ~w finished in ~w steps. ~n",[NAME, STEPS]),
    println_debug(STRINGS, systemdbg).

write_stats([Steps_Left]):-
    open('stats2', append, Stats_File),
    thread_self(Agent),
    max_agent_iterations(Max_Iterations),
    Steps_Total is Max_Iterations - Steps_Left,
    write(Stats_File, Agent), write(Stats_File,','),
    writeln(Stats_File, Steps_Total),
    close(Stats_File).



next_loop(-1):-
    loop(-1).

next_loop(0,0):- 
    print_state('Finished'),
    finished.

next_loop(Steps, Steps_Left):- 
    intention(_, _, active),
    loop(Steps, Steps_Left).		% should be gosync

next_loop(Steps, Steps_Left):- 
    event( _, _, _, _, _, active, _),
    loop(Steps, Steps_Left).         % should be gosync

next_loop(Steps, Steps):- 
    print_state('Finished'),
    finished.


% main aget control loop

incrementLoop:-
    retract(loop_number(Loop)),
    New_Loop is Loop + 1,
    assert(loop_number(New_Loop)).

sensing:-
    thread_self(Agent),
    agent_perceives(Agent, Add_List, Delete_List),	
    % conflict should be resolved in 'agent_perceived'
    process_add_list(Add_List),
    process_delete_list(Delete_List),		
    process_messages.


loop(-1, -1).			% born dead


loop(Steps, Steps_Left):-
    loop_number(Loop_Number),
    format(atom(STRINGS), "~n~n[RSNDBG] =========================================================================================
[RSNDBG] ==================================== Loop ~w started =====================================
[RSNDBG] =========================================================================================~n~n",
          [Loop_Number]),
    println_debug(STRINGS, reasoningdbg),
    format(atom(STRINGL), "[RSNDBG] STATE IN LOOP ~w~n", [Loop_Number]),
    print_state(STRINGL),

    late_bindings(Bindings),    % ???
    format(atom(STRINGB), "[INTER] Bindings ~w~n", [Bindings]),                
    println_debug(STRINGB, interdbg),

    sensing,

    update_models,

    !,

    format(atom(STRINGPM), "+|+ RE ~w", [Loop_Number]),
    println_debug(STRINGPM, interdbg), 	
    reasoning,              					
    !,

    format(atom(STRINGRE), "+|+ EX ~w", [Loop_Number]),
    println_debug(STRINGRE, interdbg), 
    execution,
    !,                                 
                   
    format(atom(STRINGEX), "+|+ FIN ~w", [Loop_Number]),
    println_debug(STRINGEX, interdbg), 
    println_debug("loop_finished", interdbg), 
    % increases loop number / loop_number(number).
    incrementLoop,          
    % countdown					
    Steps2 is Steps-1,				      					
    
    % next loop?
    next_loop(Steps2, Steps_Left).   					



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
%  	AGENT INITIALISATION, SETTTINGS and LAUNCHING
%


set_clauses([],_).
  
set_clauses([plan(GT,G,GDS,BODY)|Clauses],IDX):-
    assert(plan(IDX,GT,G,GDS,BODY)),
    IDX2 is IDX+1,
    set_clauses(Clauses,IDX2),
    !.

% process declared top-level goal -> creates events for them
set_clauses([goal(Goal_Type, Goal_Atom, Context)| Clauses],IDX):-
    get_fresh_event_number(Event_Index),
    assert(event(Event_Index, Goal_Type, Goal_Atom, null, Context, active, 
                 [])),
    set_clauses(Clauses, IDX),
    !.

set_clauses([Clause|Clauses],IDX):-
    assert(Clause),
    set_clauses(Clauses,IDX).

clear_agent:-
    retractall(fact(_)),
    retractall(event( _, _, _, _, _, _, _)),
    retractall(plan( _, _, _, _)),
    retractall(plan( _, _, _, _, _)),
    retractall(intention( _, _, _)).


read_clauses(end_of_file, [], _):- !.

read_clauses(Clause, [Clause|Clauses], String):-
    read_clause(String, Clause2, []),
    read_clauses(Clause2, Clauses, String).

load_program(AGENTFILE, CLAUSES):-
    access_file(AGENTFILE, read),! ,
    open(AGENTFILE, read, STRING, [close_on_abort(true)]),
    read_clause(STRING, CLAUSE, []),
    !,
    read_clauses(CLAUSE, CLAUSES, STRING),
    close(STRING, [force(true)]).

load_program(Agent_File, []):-
    format("[FRAG] Agent file ~w does not exists.~n", [Agent_File]),
    !,
    fail.


  
%
%  Taking agent state snapshot
%

take_snapshot_beliefs(SnapshotB):-
    bagof(fact(X),fact(X),SnapshotB).

take_snapshot_beliefs([]).


take_snapshot_goals(Event_Snapshot):-
    bagof(event(Event_Index, Type, Predicate, Intention, Context, Status,
                History),
     	  event(Event_Index, Type, Predicate, Intention, Context, Status, 
                History), 
	  Event_Snapshot).
    
take_snapshot_goals([]).


take_snapshot_plans(PLANSSNAPSHOT):-
    bagof(plan(Number, Type, Predicate, Context, Body), plan(Number, Type, Predicate, Context, Body), PLANSSNAPSHOT).
    
take_snapshot_plans([]).


take_snapshot_intentions(INTENTIONSSNAPSHOT):-
    bagof(intention(Number, PlanStack, Status), intention(Number, PlanStack, Status), INTENTIONSSNAPSHOT). 

take_snapshot_intentions([]).
                  

take_snapshot(SNAPSHOT):-
    take_snapshot_beliefs(BELIEFSNAPSHOT),
    take_snapshot_goals(EVENTSSNAPSHOT),
    take_snapshot_plans(PLANSSNAPSHOT),
    take_snapshot_intentions(INTENTIONSSNAPSHOT),    
    append([BELIEFSNAPSHOT, EVENTSSNAPSHOT, PLANSSNAPSHOT, INTENTIONSSNAPSHOT], SNAPSHOT).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Initiation and settings
%


  % 'wait_go' waits for 'go' atom on the blackboard
  % go(0) ... cancel execution, go(1) ... go on agent execution

wait_go( _ ):-
    go(0),								 
    thread_exit(1).

wait_go(I):-
    go(I),
    !.

wait_go(I):-
    wait_go(I).



go_sync(Steps, I):-
    thread_self(Agent),
    assert(ready(Agent)),
    wait_go(I),
    loop(Steps, Steps_Left),
    write_stats([Steps_Left]),
    assert(ready(Agent)).


fa_init_com(Filename):-
    thread_self(Agent),
    format(atom(Filename2), "~w_~w.out", [Filename, Agent]),  
    tell(Filename2),
    assert(agent_debug(1)),
    !.

  fa_finalize_com:-
	told.


get_default_environments(Environments):-
    bagof(Environment, default_environment(Environment), Environments).

get_default_environments([]).


set_default_environment(Environment):-
    % such environment is loaded
    environment_loaded(Environment),			
    assert(default_environment(Environment)).	


set_default_environment(Environment):-
    format(atom(String),"[ERROR] Environment '~w' does not exists~n",
           [Environment]),
    println_debug(String, error).

    
set_late_bindings:-
    retractall(late_bindings( _ )),
    assert(late_bindings(true)).


set_early_bindings:-
    retractall(late_bindings( _ )),
    assert(late_bindings(false)).



set_late_bindings(BINDINGS):-
    retractall(late_bindings( _ )),
    assert(late_bindings(BINDINGS)).



set_default_late_bindings(Bindings):-
    retractall(default_late_bindings( _ )),
    assert(default_late_bindings(Bindings)).


set_environment(Environment):-
    thread_self(Agent),
    situate_agent(Agent, Environment),
    format(atom(String), "[SYSDBG] Agent ~w is situated to environment ~w ~n",
           [Agent, Environment]),
    println_debug(String, systemdbg).
  


is_late_bindings:-
    late_bindings(true).

is_default_late_bindings:-
    default_late_bindings(true).


init_intention_selection( _ ):-
    active_intention_selection( _ ).

init_intention_selection(Default_Intention_Selection):-
    set_intention_selection(Default_Intention_Selection).


init_plan_selection( _ ):-
    active_plan_selection( _ ).

init_plan_selection(Default_Plan_Selection):-
    set_plan_selection(Default_Plan_Selection).


init_substitution_selection( _ ):-
    active_substitution_selection( _ ).

init_substitution_selection(Default_Substitution_Selection):-
    set_substitution_selection(Default_Substitution_Selection).
                


fa_set_reasoning:- 
    default_intention_selection(Intention_Selection),
    default_plan_selection(Plan_Selection),
    default_substitution_selection(Substitution_Selection),
    init_intention_selection(Intention_Selection),
    init_plan_selection(Plan_Selection),
    init_substitution_selection(Substitution_Selection),
    !.

fa_set_reasoning:-
    format(atom(STRING),"[ERROR] Default reasoning mehods not specified~n", []),
    println_debug(STRING, error),
    !,
    fail.


fa_init_reasoning:- 
    active_intention_selection(Intention_Selection),!,
    active_plan_selection(Plan_Selection),!,
    active_substitution_selection(Substitution_Selection),
    init_reasoning(Intention_Selection),
    init_reasoning(Plan_Selection),
    init_reasoning(Substitution_Selection),
!.
    

fa_init_reasoning:- 
    format(atom(STRING),"[ERROR] Reasoning methods initialization failed~n", []),
    println_debug(STRING, error),
    !,
    fail.



fa_init_environments2([]).

fa_init_environments2([Environment| Environments]):-
    set_environment(Environment),
    !,
    fa_init_environments2(Environments).

fa_init_environments2([Environment| Environments]):-
    format(atom(STRING),"[ERROR] Environment '~w' initialization failed~n", [Environment]),
    println_debug(STRING, error),
    fa_init_environments2(Environments).


fa_init_environments:-
    bagof(Environment, default_environment(Environment), Environments),
    !,
    fa_init_environments2(Environments).

fa_init_environments:-
    thread_self(AGENTNAME),
    format(atom(STRINGS), "[SYSDBG] No environment for agent ~w~n", [AGENTNAME]),
    println_debug(STRINGS, systemdbg).
 

    
fa_init_run:-
    retractall(late_bindings( _ )),
    default_late_bindings(BINDINGS),
    assert(late_bindings(BINDINGS)),
    retractall(loop_number( _ )),
    retractall(intention_fresh( _ )),
    retractall(event_fresh( _ )),
    assert(loop_number(1)),
    assert(intention_fresh(1)),
    assert(event_fresh(1)),
    !.

fa_init_run:-
    format(atom(STRING),"[ERROR] Bindings method missing~n", []),
    println_debug(STRING, error),
    !,
    fail.


fa_init_set_attrs(environment, Environment):-
    thread_self(Agent),
    situate_agent(Agent, Environment). 

fa_init_set_attrs(environment, ENVIRONMENT):-
    thread_self(AGENTNAME),
    format(atom(STRING),"[ERROR] Failed assignment of envrironment ~w to agent ~w", [ENVIRONMENT, AGENTNAME]),
    println_debug(STRING, error).


fa_init_set_attrs(reasoning, Reasoning):-
    set_reasoning(Reasoning).


fa_init_set_attrs(debug, DBG):-
  	assert(agent_debug(DBG)).


fa_init_set_attrs(bindings, late):-
    set_late_bindings(true).
	
fa_init_set_attrs(bindings, early):-
    set_late_bindings(false).
	                         
fa_init_set_attrs(Key, Value):-
    format(atom(String), "[ERROR] wrong attributes (~w:~w)~n", [Key, Value]),
    println_debug(String, error).



fa_init_process_attrs([]).

fa_init_process_attrs([(Key, Value)| Attributes]):-
    fa_init_set_attrs(Key, Value),
    !,
    fa_init_process_attrs(Attributes).

  

fa_init_agent(Filename, Attributes):-
    max_agent_iterations(Iterations),
    string(Filename),
    format(atom(Filename2), "~w.fap", [Filename]),
    load_program(Filename2, Clauses),
    assert(agent_debug(error)),
    fa_init_com(Filename), 
    fa_init_run, 
    fa_set_reasoning, 
    fa_init_process_attrs(Attributes), 
    fa_init_environments,
    fa_init_reasoning, 
    set_clauses(Clauses, 1),    	
    go_sync(Iterations, 1),
    fa_finalize_com,
    thread_exit(1).


fa_init_agent( _, _):-
    go_sync(-1, _),				% born dead  (0 interations to do)
    thread_self(Agent),
    format(atom(String), "[FATAL ERROR] Agent ~w initialization failed~n",[Agent]),
    println_debug(String, error),
    fa_finalize_com,
    thread_exit(1).

