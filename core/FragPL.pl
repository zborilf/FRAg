
%
%  AgentSpeak(L) interpreter in Prolog with FRAg's late bindings    
%  2021
%  Frantisek Zboril jr.   (& spol.?)
% 

:-include('FragPLDebug.pl').  % toto je o nicem, jenom debug
:-include('FragPLFrag.pl').   % sem jsem ulil svoje metody, 'operace', ktere jsou FRAg specificke

:-dynamic fact / 1.
:-dynamic intentionFresh / 1.
:-dynamic intention / 4.  	% id, goal, plans, status
:-dynamic goal / 4.  		% predicate, intention, context, status
:-dynamic loopNumber / 1.

intentionFresh(1).      % 'cerstve' IDcko pro dalsi novou intensnu
loopNumber(1). 		% iterace interpreteru




%%%%%%%%%%%%%%
%
% 	EXECUTION   / vykonani jednoho aktu z planu
%	execute(zamer, plan(trigevent, strazci, kontext, teloplanu), plan(trigevent, strazci, novykontext, noveteloplanu)).
%


% vykona pridani predstavu add(pred(t1,t2...))
execute(INT,plan(G,PC,CTX,[add(AF)|PT]),plan(G,PC,CTX2,PT)):-
		AF=..ACTIONTERMS,
		decisioning(ACTIONTERMS,CTX,CTX2),
		assert(fact(AF)).


%  pro del(pred(t1,t2...)), zkusi vymazat, pokud neni co, nevadi
tryRetract(F):-retract(F).
tryRetract(_).

% vykona odstraneni predstavu del(pred(t1,t2...))
execute(INT,plan(G,PC,CTX,[del(AF)|PT]),plan(G,PC,CTX2,PT)):-
		AF=..ACTIONTERMS,
		decisioning(ACTIONTERMS,CTX,CTX2),
		tryRetract(fact(AF)).


% vykona cil testovani, test(pred(t1,t2 ...)).
execute(INT,plan(G,PC,CTX,[test(TG)|PT]),plan(G,PC,CTX3,PT)):-
		bagof(fact(TG),fact(TG),TGL),
		broadUnification(fact(TG),TGL,CTX2),
		restrict(CTX,CTX2,CTX3).
	%	fact(TG).

% vykona cil dosazeni, asi nejnarocnejsi
execute(INT,plan(G,PC,CTX,[ach(G2)|PT]),plan(G,PC,CTX,[ach(G2)|PT])):-
		writeln("ACHIEVE"),
		retract(intention(INT,G,P,active)),
		assert(intention(INT,G,P,blocked)),     % zablokovali jsme tuto intensnu
		G2=..G2TERMS,				% ?? TODO upravit, shorting je asi jen pro jedno PU ?? tohle vytahne z pred(t1,t2...) seznam [pred,t1,t2 ...]
		getVars(G2TERMS,G2VARS),                % vytahneme promenne z deklarovaneho achiev. cile
		shorting(CTX,G2VARS,CTXSH),             % nashortujeme kontext puvodni urovne podle promennych v dekl. cili
		assert(goal(G2,INT,CTXSH,active)).      % zadame pod-cil i s odkazem na tuto intensnu INT, nashortovanym kontextem CTXSH, cil je ted aktivni


execute(_,plan(G,PC,CTX,[]),plan(G,PC,CTX,[])).


% vykonani interni akce, act(action(t1,t2,...))., udela nejakej decisioning kontextu pro t1,t2... a vykona ji (udela to opravdu ty substituce, jak vlastne?? decisioning?? MAGIC!!) 
execute(_,plan(G,PC,CTX,[act(ACTION)|AT]),plan(G,PC,CTX2,AT)):-
		ACTION=..ACTIONTERMS,
		decisioning(ACTIONTERMS,CTX,CTX2),  % rozhodnem o vybrane akci, zmeni to kontext (udelame rozhodnuti na CTX pro promenne v ACTION)
		ACTION.
	
% TODO fail nezmeni kontext
execute(_,plan(G,PC,CTX,[AH|AT]),plan(G,PC,CTX,[AH|AT])):-format("Action failed ~w~n",[AH]).

%
%  ONE ACT EXECUTION
%

executePlan(INT,[plan(G,PC,CTXP,P)|T],[plan(G,PC,CTXP2,P2)|T]):-
		execute(INT,plan(G,PC,CTXP,P),plan(G,PC,CTXP2,P2)).


%%%%%%%%%%%%%%%
%
%  	INTENTION LEVEL OPERATIONS
%


%
% 	MAKE/EXTEND INTENTION with a mean for the goal G with a context CTX
%

% no means for this goal, set it as an active goal active again
extendIntention(INT,G,CTX,[]):-
		retract(goal(G,INT,CTX,blocked)),
		assert(goal(G,INT,CTX,active)).

% for the next definition, fresh intention ID
getFreshIntNumber(INT):-
		intentionFresh(INT),
		retract(intentionFresh(INT)),
		INT2 is INT+1,
		assert(intentionFresh(INT2)).


% means found for top level goal
extendIntention(null,G,CTX,plan(G2,COND,BODY)):-
		intersection(G,CTX,G2,CTX2),
		getFreshIntNumber(INT),
		assert(intention(INT,G,[plan(G,COND,CTX2,BODY)],active)).

% means found for a subgoal
extendIntention(INT,G,CTX,plan(G2,COND,BODY)):- % TODO, pro existujici
		intersection(G,CTX,G2,CTX2),
		retract(intention(INT,GI,PS,blocked)),
		writeln(CTX2),
		assert(intention(INT,GI,[plan(G2,COND,CTX2,BODY)|PS],active)).


%
%  INTENTION SELECTION, 'vrati' jeden zamer, ktery je aktivni, primitivna / naivni pristup
%
 
selectIntention(intention(INT,G,PS,active)):-
		intention(INT,G,PS,active).


%
%  UPDATE INTENTION (cisteni zameru po vykonani akctu, pokud v intention 0, je blokovana, neresime; 1, skoncil toplevel plan, 2; podplan 3; nic z toho, ale akt byl vykonan a zasobnik zmenen
% 

% pokud je intensna zablokovana, znamena to, ze jako posledni v ni byl provedeno vyvolani podcile. Nemeni se, dokud se podcil nepovede
updateIntention(intention(INT,_,_,_)):-
		intention(INT,_,_,blocked).  % no update for blocked intention / waiting for subgoal



% prazdny toplevel plan, resp. telo tohoto planu znamena, ze je hotovo, tedy smazeme intensnu a cil, ktery ji byl dosazen
updateIntention(intention(INT,G,[plan(_,_,_,[])],STATUS)):-  
                retract(intention(INT,G,_,_)),
		retract(goal(G,null,_,blocked)).


% skoncil podplan, musime udelat prenoc kontextu na vyssi uroven!!!
updateIntention(intention(INT,_,
			[plan(G2,_,CTX2,[]),plan(G,COND,CTXP,[ach(GA)|PT2])],
						STATUS)):-		
		intersection(G2,CTX2,GA,CTXP,CTXNEW),
		retract(intention(INT,G,[_,_|PT],STATUS)),
		assert(intention(INT,G,[plan(G,COND,CTXNEW,PT2)|PT],STATUS)),
		retract(goal(G2,INT,CTX,blocked)).

% zmenil se plan / zasobnik vykonanim predchozi akce, ale neni na jeho vrcholu prazdny plan, tedy ...
% na zaklade identifikatoru INT si vytahneme starou tuto intensnu, resp. ji vymazeme a vlozime znovu s novym zasobnikem P2 (proc je v hlavicce cil jako _ nevim, to by snad mohlo byt primo G??)
updateIntention(intention(INT,_,P2,STATUS)):-  
		retract(intention(INT,G,_,STATUS)),   % stary zasobnik nevim, je to jedno, stejne ho chceme prepsat, udelame anonymni _
		assert(intention(INT,G,P2,STATUS)).


%%%%%%%%%%%%%%
%
% 	REASONING, 3rd level (vyber udalosti apod.)
%


% RELEVANT PLAN for GOAL, -> REL
getRelevant(GOAL,REL):-
		bagof(plan(GOAL,A,B),plan(GOAL,A,B),REL).
getRelevant(_,[]).

% CHECK GUARDS (in the input list)
valid([]).
valid([H|T]):-fact(H),valid(T).

% APPLICABLE PLANS for an input list of guards, recurcion for the list of guards
getApplicable([],[]).
getApplicable([plan(X,PC,A)|T],[plan(X,PC,A)|AT]):-valid(PC),getApplicable(T,AT).
getApplicable([_|T],AT):-getApplicable(T,AT).

% NAIVE gets the first intended mean form an input list of intended means (plans, which are relevant and applicable)
getIM([],[]).
getIM([H|_],H).


selectEvent(goal(G,INT,CTX,active)):-
		goal(G,INT,CTX,active),
		retract(goal(G,INT,CTX,active)),
		assert(goal(G,INT,CTX,blocked)).



%%%%%%%%%%%%%%%
%
%  	REASONING and act EXECUTION, Second interpretation level 
%


execution:-
		selectIntention(intention(INT,G,PS,STATUS)),
		executePlan(INT,PS,PS2),
		updateIntention(intention(INT,G,PS2,STATUS)).

execution.	% nic k vykonani

reasoning:-
		selectEvent(goal(G,INT,CTX,active)),
		getRelevant(G,REL),
		getApplicable(REL,APP),
		getIM(APP,IM),
		extendIntention(INT,G,CTX,IM).

reasoning. 	% neprosla udalost




%%%%%%%%%%%%%%
%
%  	AGENT CONTROL LOOP, top interpretation level
%



% pokracujeme ve vykonavani smycky?
% ne, pokud 1, pocitadlo je na nule, nebo pokud neni zadna aktivni intensna a zaroven neni zadny deklarovany cil, pak dame jeste 'finished', kde se vyblbnem a reknem nashledanou

finished:-format("FINISHED~n"),printAgentState.

cont(0):-finished.
cont(STEPS):-intention(_,_,_,active),loop(STEPS).
cont(STEPS):-goal(_,_,_,active),loop(STEPS).
cont(STEPS):-finished.

% hlavni kontrolni smycka agenta 

incrementLoop:-
		retract(loopNumber(LOOP)),
		NEWLOOP is LOOP+1,
		assert(loopNumber(NEWLOOP)).


loop(STEPS):-
		printAgentState,	% pro debug
		reasoning,              % simply reasoning           	
		execution,              % simply execution
		incrementLoop,          % zvysime cislo v loopNumber(cislo).
		STEPS2 is STEPS-1,      % countdown
		cont(STEPS2).           % pokracujeme? viz vyse

%%%%%%%%%%%%%%
%
%	AGENT EXECUTION, spousteci smeti
%

% goalPredicate can be either atomic or compound

goalPredicate(X):-atomic(X).
goalPredicate(X):-compound(X).


fap(FILENAME,STEPS):-
		tell('out.fap'),
		string(FILENAME),
		consult(FILENAME),
		loop(STEPS),
		told.
	                            

fap(X):-
		goalPredicate(X),
		assert(goal(X,null,[],active)),
		loop(X).

fap([]):-
		loop(-1).

fap([H|T]):-
		goalPredicate(H),
		assert(goal(H,null,[],active)),
		fap(T).

