
%
% Procedure Udelej_hada(A=[a1,a2,…an],B=[b1,b2,…bm],stack)
% begin
%	if(A=[]) then
%		Vypis_stack(stack)
%	else
%		originalni := [b1,b2,… bm]
%		aktualni:= aktualni
%		repeat
%			bmatch=bj ; prvni shoda, v aktualni=[bi…bm], i<=j<=m nebo STOP, pokud neni
%			push(stack,[a1,bmatch])
%			if(bmatch==stop)
%				aktualni:=originalni
%			else
%				aktualni:=aktualni – [b1,b2…bj]
%			Udelej_hada([a2,…an],aktualni)
%			pop(stack)
%		until(bmatch==stop)
% end
%
% … Udelej_hada([a1,a2,…an],[b1,b2,…bm],[])
%


:-dynamic bind/3.
:-dynamic best_snake/2.
:-dynamic perm/1.
:-dynamic count/1.
:-dynamic pokus/1.
:-dynamic result/4. % pokus, pocet akci, optimum, snake
:-dynamic maxlength/1.

count(0).
limit(1500000).
maxlength(0).


limitDFS(11).

%
%
%   DFS
%
%       [act(a,1,1),act(b,1,2),act(c,1,3),act(d,1,4),act(a,1,5)],
%	[act(a,2,1),act(a,2,2),act(b,2,3),act(c,2,4),act(a,2,5)],
%	[act(c,3,1),act(b,3,2),act(a,3,3),act(b,3,4),act(a,3,5)],
%	[act(b,4,1),act(a,4,2),act(b,4,3)],
%	[act(b,5,1),act(a,5,2),act(b,5,3),act(d,5,4)],
%	[act(d,5,1),act(a,5,2),act(c,5,3)]
%
%


%
% poskytne vsechny druhy akci z prvnich mist programu
%  getAtions(programy, akce)
%

%
% myslenka - vezmem prvni program a udelame kopii (dame do pytle)
%            pro kazdy dalsi program zkontrolujeme, jestli je v pytli dostatecny pocet odpovidajicich akci
%            pokud v nejakem dalsim programu akce prebyvaji (je zde trikrat akce b, v pytli jen dvakrat,
%            nebo je zde akce, ktera v pytli vubec neni) pridame ji do pytle - je to urcite akce, ktera musi
%	     byt vykonana (zatim) samostatne. Heuristika je tak stale pripustna.
%            pocet akci v pytli je potom heuristika pro tuto sadu programu
% (2025) edit, bag tedy obsahuje nejvetsi pocet vyskytu jednotlivych promennych 
%   v jednom programu napric vsemi programy


%!  expand_bag(+Program, ? ?) is det
%  @Program: input program (intention), list of acts

expand_bag([], _,[]).

expand_bag([act(A,_,_)|T],BAG,T2):-
    member(act(A,B,C), Bag),         % bag ma odpovidajici akci
% pouzili jsme z bagu odpovidajici akci, takze nepridavat
    delete(Bag, act(A,B,C), Bag2),    
    expand_bag(T,Bag2,T2).  % a T2 je vysledek, akce H nerozsiri bag, ma odpovidajici zde

% v Bagu nebyla odpovidajici, takze tato bude expandovat bag a je ve tretim termu
    expand_bag([H|T],Bag, [H|T2]):- 
    expand_bag(T, Bag, T2).

%!  heuristic_do
%  @Programs: List of programs to merge by joint acts


heuristic_do([], Bag, Bag).

heuristic_do([Act| Acts], Bag, Bag_Out):-
    expand_bag(Act, Bag, Bag_Expanded),
    append(Bag, Bag_Expanded, Bag_Out2),
    heuristic_do(Acts, Bag_Out2, Bag_Out).


%  Heuristika je tedy delka seznamu, ktery spocte heuristicDO
% @arg [Program| Programs] asi programy / zamery
% @arg Heuristic ... vypoctena heuristika

heuristic([Program| Programs], Heuristic):-
    heuristic_do(Program, Programs, Bag),
    length(Bag, Heuristic).


% heuristic([],0).
% heuristic([L1|T],N):-
%		length(L1,L1L),
%		heuristic(T,L2L),
%		N is max(L1L,L2L).

 getActions([],[]).
 getActions([[]|T],O2):-
		getActions(T,O2).
 getActions([[act(A,_,_)|_]|T],O4):-
		getActions(T,O2),
		append([A],O2,O3),
		sort(O3,O4).           

%
% executeAction(akce,programy,programyPoVykonaniAkce)
%

executeAction(_,[],[]).
executeAction(A,[[]|TP1],TP2):-
		executeAction(A,TP1,TP2).
executeAction(A,[[act(A,_,_)|TP1]|TP2],[TP1|TP3]):-
		executeAction(A,TP2,TP3).
executeAction(A,[HP1|TP2],[HP1|TP3]):-
		executeAction(A,TP2,TP3).

%
%  vykona sekvenci akci v programech a poskytne pocet zbyvajicich akci v castecne provedenych programech
%


remainingActions([],0).
remainingActions([[]|T],N):-
		remainingActions(T,N).
remainingActions([[H|T1]|T2],N2):-
		remainingActions([T1|T2],N),
		N2 is N+1.

executeActions([],P,P,N):-
		remainingActions(P,N).
executeActions([A|AT],P,P3,N):-
		executeAction(A,P,P2),
		executeActions(AT,P2,P3,N).

%
%	stav je [seznam_akci,cena]
%	na pocatku spocitame cenu, dame do OPEN=[[],cena] a spustime astar
%

getCheaper([A1,V1,IT1],[A2,V2,IT2],[A1,V1,IT1]):-VAL1 is V1+IT1, VAL2 is V2+IT2, VAL1<VAL2.
getCheaper(_,[A2,V2,IT2],[A2,V2,IT2]).

getCheapest([[ACTIONS,V,IT]],[ACTIONS,V,IT]).
getCheapest([[ACTIONS,V,IT]|T],[ACTIONS3,V3,IT3]):-
		getCheapest(T,[ACTIONS2,V2,IT2]),
		getCheaper([ACTIONS,V,IT],[ACTIONS2,V2,IT2],[ACTIONS3,V3,IT3]).

expandDo(_,[],[],_,_).

expandDo(PROGRAMS,[A|AT],[[ACTIONSNEW,V,IT]|O2T],IT,ACTIONS):-
	executeAction(A,PROGRAMS,PROGRAMS2),
	heuristic(PROGRAMS2,V),
	append(ACTIONS,[A],ACTIONSNEW),
	expandDo(PROGRAMS,AT,O2T,IT,ACTIONS).

expand(PROGRAMS,OPEN,[ACTIONS,N,IT],OPEN2):-
	executeActions(ACTIONS,PROGRAMS,PROGRAMS2,_),
	% a ted vsechny, co jdou vykonat a do open s nema
	getActions(PROGRAMS2,O),
	IT2 is IT+1,
	expandDo(PROGRAMS2,O,OPENNEW,IT2,ACTIONS),
	append(OPEN,OPENNEW,OPEN2).


signalize(LIMIT,LO):-
	X is (LIMIT mod 100),
	X = 0,
	format("// ~w [~w] ~n",[LIMIT,LO]),nl.

signalize(_,_).


astarDo(_,_,[],-1,0).

astarDo(PROGRAMS,OPEN,ACTIONS,IT2,_):-
	getCheapest(OPEN,[ACTIONS,0,IT2]).

astarDo(PROGRAMS,OPEN,SOL,N,LIMIT):-
	length(OPEN,LO),
	signalize(LIMIT,LO),
	getCheapest(OPEN,[ACTIONS,N2,IT2]),
	delete(OPEN,[ACTIONS,N2,IT2],OPEN2),
	expand(PROGRAMS,OPEN2,[ACTIONS,N2,IT2],OPEN3),!,
	LIMIT2 is LIMIT-1,!,
	astarDo(PROGRAMS,OPEN3,SOL,N,LIMIT2).

astar(P,SOL,N):-
	heuristic(P,N2),
	OPEN = [[[],N2,0]],
	astarDo(P,OPEN,SOL,N,1500).





execute([],_,0,LIMIT):-print('soution!'),nl,print(LIMIT),nl.
execute(_,_,0,0). %:-print('dosazen limit'),nl.
execute([[]|T],A,N,LIMIT):-
		execute(T,A,N,LIMIT).
execute(PROGRAMS,[],1000,LIMIT).
execute(PROGRAMS,[A|AT],N,LIMIT):-
		LIMIT2 is LIMIT-1,
		executeAction(A,PROGRAMS,PROGRAMS2),
	%	print(A),nl,print(PROGRAMS2),nl,
		dfs(PROGRAMS2,N2,LIMIT2),
		N3 is N2+1,
		execute(PROGRAMS,AT,N4,LIMIT),
		N is min(N3,N4).


dfs(PROGRAMS,RES,LIMIT):-
		    getActions(PROGRAMS,O),
		    execute(PROGRAMS,O,RES,LIMIT).

% god(RES):-dfs([[act(a,1,1),act(b,1,2)],
%		[act(a,2,1),act(b,2,3),act(c,2,4),act(a,2,5)],
%		[act(c,3,1),act(a,3,5)]
%		],
%		RES).


god(RES):-dfs([[act(a,1,1),act(b,1,2),act(c,1,3),act(d,1,4),act(a,1,5)],
		[act(a,2,1),act(a,2,2),act(b,2,3),act(c,2,4),act(a,2,5)],
		[act(c,3,1),act(b,3,2),act(a,3,3),act(b,3,4),act(a,3,5)],
		[act(b,4,1),act(a,4,2),act(b,4,3)],
		[act(b,5,1),act(a,5,2),act(b,5,3),act(d,5,4)],
		[act(d,5,1),act(a,5,2),act(c,5,3)]
		],
		RES).



%
%
%	SNAKE							BINDINGS
%
%
%



timeout:-count(X),limit(Y),X>Y.


otoc([],[]).
otoc([p(A,B)|T],[p(B,A)|T2]):-
		otoc(T,T2).

% binding nahradi, jen pokud list dvojic je delsi nez v dosavadnim ulozenem bindingu pro danou dvojici

assert_longer_bnd(bind(A,B,L)):-
		bind(A,B,L2),
		length(L,LL),
		length(L2,L2L),
		LL=<L2L.

assert_longer_bnd(bind(A,B,L)):-
		length(L,LL),
		retractall(maxlength(_)),
		assert(maxlength(LL)),
		retractall(bind(A,B,_)),
		retractall(bind(B,A,_)),
		assert(bind(A,B,L)),
		otoc(L,L2),
		assert(bind(B,A,L2)).

vypis_stackGo([],[]).
vypis_stackGo([p(A,0)|T],L):-
		vypis_stackGo(T,L).
vypis_stackGo([p(A,B)|T],LOUT):-
		vypis_stackGo(T,L),
		append(L,[p(A,B)],LOUT).


vypis_stack(A,B,L,LOUT):-
		vypis_stackGo(L,LOUT),
		assert_longer_bnd(bind(A,B,LOUT)).


find_binding(act(A,I,N),[],p(N,0),[]).
find_binding(act(A,I,N),[act(A,I2,N2)|T],p(N,N2),T).
find_binding(A,[_|T],B,T2):-find_binding(A,T,B,T2).


obnov_pro_stop(0,L,_,L).
obnov_pro_stop(_,_,L,L).

% ukoncime, pokud nemuzeme udelat  delsiho hada


%udelej_hada(I1,I2,L1,L2,_,Stack):-
%		bind(I1,I2,B),
%		length(L1,LL1),
%		length(L2,LL2),
%		length(Stack,LS),
%		LMIN is min(LL1,LL2),
%		I3 is LMIN+LS,		% maximalni mozny had, dosavadni satck + mensi ze zbyvajicich seznamu
%		length(B,LB),
%		I3<LB.

% nepripojujeme, pokud B je nula
append_stack(_,0,S,S).
append_stack(A,B,S,[p(A,B)|S]).

udelej_hada(I1,I2,[],_,_,Stack):-vypis_stack(I1,I2,Stack,LOUT).

udelej_hada(I1,I2,[A|T1],L2,OrigL2,Stack):-
	find_binding(A,L2,p(A2,B),LRest),
	obnov_pro_stop(B,OrigL2,LRest,LRest2),
	append_stack(A2,B,Stack,StackOut),
	udelej_hada(I1,I2,T1,LRest2,LRest2,StackOut),!,  % jdeme na dalsi uroven, i jeji Orig bude LRest2
	dalsi_rekurze(I1,I2,[A|T1],B,LRest,OrigL2,Stack).

dalsi_rekurze(_,_,_,0,_,_,_). % uz byla stopka

dalsi_rekurze2(A,B,I1,I2,L1,L2,OrigL2,Stack):-
                A>B,
		udelej_hada(I1,I2,L1,L2,OrigL2,Stack).

dalsi_rekurze2(_,_,_,_,_,_,_,_).


dalsi_rekurze(I1,I2,L1,_,L2,OrigL2,Stack):-
		maxlength(ML),
		length(L1,LL1),
		length(OrigL2,LL2),
		length(Stack,LS),
		LMIN is min(LL1,LL2),
		I3 is LMIN+LS,		% maximalni mozny had, dosavadni satck + mensi ze zbyvajicich seznamu
		dalsi_rekurze2(I3,ML,I1,I2,L1,L2,OrigL2,Stack).



udelej_hady2(_,_,_,[]).
udelej_hady2(I1,I2,L1,[L2|T]):-
		udelej_hada(I1,I2,L1,L2,L2,[]),
		I2N is I2+1,
		udelej_hady2(I1,I2N,L1,T).

udelej_hady(_,[]).
udelej_hady(I1,[H|T]):-
		I2 is I1+1,
		udelej_hady2(I1,I2,H,T),
		udelej_hady(I2,T).

%ggg:-udelej_hada(
%	1,2,
%	[act(a,1,1),act(b,1,2),act(b,1,3),act(a,1,4),act(a,1,5),act(b,1,6),act(a,1,7)], %act(b,1,8),act(a,1,9),act(b,1,10),act(a,1,11),act(b,1,12),act(a,1,13)],
%	[act(b,2,1),act(a,2,2),act(a,2,3),act(a,2,4)],
%	[act(b,2,1),act(a,2,2),act(a,2,3),act(a,2,4)],
%	[]).

%
%
%	mame seznam navazani [b1,b2 ... bn], pro Nty prvek z b1 najde dalsi a vymaze jej z b1
%
% had_nty(kolikatyChci,bind(odkud,kam,[p(kolikaty,nakolikateho]),indexDalsiho,vystup)
%

nasledovnik_nty(A,bind(I1,I2,[p(A,B)|T22]),B,bind(I1,I2,T22)).        % souhlasi v bind kolikateho chci, vratim, na kolikateho ukazuje

nasledovnik_nty(_,bind(I1,I2,[]),0,bind(I1,I2,[])).

nasledovnik_nty(A,bind(I1,I2,[BH|BT]),B,bind(I1,I2,[BH|BT2])):-
		nasledovnik_nty(A,bind(I1,I2,BT),B,bind(I1,I2,BT2)).   % zkratim seznam ukazatelu ze zameru I1 do zameru I2

%
% vytvori hada, had2 od zadaneho indexu a zbyvajicih intensen jako vyse, ale vezme prvniho a pokracuje v seznamu navazani, nez bude vysledek nula, nebo seznam navazani prazdny
%
% had_rekurze(kolikaty_v_prvni_intensne,[intensny_navazani],[int_navazani_po_skonceni],seznam_hadu)
%

had_rekurze(0,B,B,[]).	% uz nebude rekurze
had_rekurze(N,[bind(I1,I2,[])],[bind(I1,I2,[])],[sb(I1,N,I2,-1)]).
had_rekurze(N,BT,BOUTT,HADT):-
	had(N,BT,BOUTT,HADT).

%
% had(kolikaty_v_prvni_intensne,[intensny_navazani],[int_navazani_po_skonceni],seznam_hadu)
%

% neni nic v intensnach navazani, tedy neni zadna dalsi intensna

had(N,[],[],[]).

% zde mame jako druhy term jen jednu intensnu, nezanorujeme, vytvorime hada smerem k posledni, neviditelne intensne jako dvojici (N a kam ukazuje N do I2)
% pokud se ukazatel nalezne a ukazje do I2, odstranime z ukazatelu mezi I1 a I2 (udela nasledovnik_nty)

had_ukonceni(_,0,[]).
had_ukonceni(I2,I,[sb(I2,I,x,0)]).

had(N,[bind(I1,I2,P)],[bind(I1,I2,P2)],[sb(I1,N,I2,I)|UKONCENI]):-
        nasledovnik_nty(N,bind(I1,I2,P),I,bind(I1,I2,P2)),
	had_ukonceni(I2,I,UKONCENI).

% je vice intensen s ukazateli, takze bud najdeme dalsi ukazatel, nebo ne (pak je I rovno nule a rekurze uz nepojede)

had(N,[bind(I1,I2,P)|T],[bind(I1,I2,L2)|TP3],[sb(I1,N,I2,I)|HADT]):-
	nasledovnik_nty(N,bind(I1,I2,P),I,bind(I1,I2,L2)),
	% co nove hledame, co zbylo po nasledovnikovi, co zbude, az se dobehne do konce, had
	had_rekurze(I,T,TP3,HADT).        % bude rekurze?


%
% nize vsichni mozni hadi, po jdeme zamerech a v nich po zbyvajicich parech jako zacatcich hada
%

ball_of_snakes(_,_):-timeout.  %nepocitame vetsi

ball_of_snakes([],[]).
ball_of_snakes([bind(_,_,[])],[]).
ball_of_snakes([bind(I1,I2,[p(A,B)])],[[sb(I1,A,I2,B),sb(I2,B,x,0)]]).


% pokracujeme v dalsi intensne, I1 je komplet, prvni dochovany z I2 ukazuje z pozice P1
ball_of_snakes([bind(I1,I2,[])|PT],HADIOUT):-ball_of_snakes(PT,HADIOUT).

% v teto intensne je jeste nejake navazani, vezmem odkud ukazuje prvni a pokracujeme
ball_of_snakes([bind(I1,I2,[p(P1,P2)|T])|T2],[HADOUT|HADIOUT]):-
	had(P1,[bind(I1,I2,[p(P1,P2)|T])|T2],BOUT,HADOUT), ball_of_snakes(BOUT,HADIOUT).

%
%    VYSE DOKAZEME UDELAT VSECHNY HADY PRO ZADANOU POSLOUPNOST NAVAZANI
%    NYNI UDELAME VSECHNA MOZNA ZJISTENA NAVAZANI PRO ZADANOU POSLOUPNOST INTENSEN
%    TODO - zde by pak mohla byt i nejaka heuristika pro odhad nejlepsich navazani

%
%	mame bind(odkud,kam,[seznam_navazani])
%	pro vstup([i1,i2...in] udelat seznam navazani [b1,b2 ...bn] mezi dvema nasledujicimi
%	zatim vezmeme prvni
%

navazani_zamery([],[]).
navazani_zamery([H],[]).

navazani_zamery([I1,I2|T],[bind(I1,I2,BH)|BT]):-
	bind(I1,I2,BH),
	navazani_zamery([I2|T],BT).


%
%  spocteme, jak jsou hadi na tom
%  napr [[sb(1,3,2,1),sb(2,1,3,0)],[sb(1,5,2,2),sb(2,2,3,0)]] jsou dva hadi, kteri usetri dve akce (maji oba delku dva, takze v kazdem jedna akce se zredukuje)
%  analyza - suma delek prvku minus pocet prvku
%  pripadne nahradime nejlepsiho hada, ktery je ulozen v dynamickem predikaty best_snake(had,fitnes hada).


nahrad_hada(F1,F2,_):-F1=<F2.  % novy had neni lepsi
nahrad_hada(FIT,_,HAD):-
		count(X),
		pokus(Y),
		result(Y,N,O,_),
		retract(result(Y,_,_,_)),
		FIT2 is N-FIT,
		assert(result(Y,N,O,FIT2)),
		format("% nejklubko(~w,~w,~w,~w).~n",[Y,X,FIT,HAD]),
		retractall(best_snake(_,_)),
		assert(best_snake(HAD,FIT)).

analyzuj_hady2([],0).
analyzuj_hady2([H|T],N):-
		length(H,N1),
		analyzuj_hady2(T,N2),
		N is N1+N2-1.
analyzuj_hady(L):-
	count(X),
	analyzuj_hady2(L,FIT),
	best_snake(L2,FIT2),
	nahrad_hada(FIT,FIT2,L),
	retractall(count(_)),
	X2 is X+1,
	assert(count(X2)).

%
%	Seznam seznamu, vsechny moznosti bindingu pro kazdy par
%

% je potreba rekurzivne udelat kombinace propojeni mezi intensnami
% rekurze - vezmi prvni, posli dal, vezmi dalsi, dokud neni na dane urovni prazdny


% dosli jsme na konec seznamu, udelejme hada
hadi_propojeni2(L,[]):-
			ball_of_snakes(L,HADI),
			analyzuj_hady(HADI).

% na dane urovni je prazdny, je treba se vratit
hadi_propojeni2(L1,[[]|T]).
% na dane urovni jeste neco je, vezmu to, pripojim k prvnimu seznamu a poslu dal
hadi_propojeni2(L1,[[H|T]|T2]):-
		hadi_propojeni2([H|L1],T2),!,		%  nejprve dalsi uroven propojeni
		hadi_propojeni2(L1,[T|T2]).


%
% hadi_propojeni(N,B), pro N do nuly nabaguje vsechny bindy do B (seznam seznamu bindu pro kazdou intensnu N..1), vyvola hadi_propojeni2
%

had_propojeni_bof(N1,N2,B):-
	bagof(bind(N1,N2,P),bind(N1,N2,P),B).

ojeni_bof(_,_,[]).

hadi_propojeni(_,_):-timeout.

hadi_propojeni([],_).
hadi_propojeni([_],B):-
	hadi_propojeni2([],B).
hadi_propojeni([H1,H2|T],B):-
	had_propojeni_bof(H1,H2,B2),
	hadi_propojeni([H2|T],[B2|B]).


%
%    PERMUTUJEME VSECHNY INTENSNY A PRO KAZDOU PERMUTACI UDELAME VSECNY MOZNE HADI HNIZDA
%    TODO - heuristika pro usporadani zameru
%

h_permutace(L,_):-
	permutation(L,X),
	assert(perm(X)),
	false.

h_permutace(L,OUT):-
	bagof(L2,perm(L2),OUT),
	retractall(perm(_)).

hadi_poradi2([]).
hadi_poradi2([H|T]):-
	hadi_propojeni(H,HADI),
	hadi_poradi2(T).

hadi_poradi(_):-timeout.

hadi_poradi(L):-
	retractall(perm(X)),
	h_permutace(L,PERM),
	retractall(count(_)),
	assert(count(1)),
	hadi_poradi2(PERM).


%
%    Pro experimenty, nahodne vygeneruje hady
%	generuj_hady(pocet_hadu, stred_delky,pocet_akci,seznam hadu).
%
%

random_action2(1,a).
random_action2(2,b).
random_action2(3,c).
random_action2(4,d).
random_action2(5,e).
random_action2(6,f).
random_action2(7,g).
random_action2(8,h).
random_action2(9,i).
random_action2(10,j).
random_action2(11,k).
random_action2(12,l).
random_action2(13,n).
random_action2(14,o).
random_action2(15,p).
random_action2(16,r).
random_action2(17,t).
random_action2(18,u).
random_action2(19,v).
random_action2(20,w).
random_action2(21,x).
random_action2(22,y).


random_action3(Action, X, Action, Action2):-		% new action must not be the same as the previous one (dont repeat the same action in the plan)
		random_action(Action, X, Action2).

random_action3(_, _, Action, Action).

random_action(PREVACTION,X,ACTION2):-
		random(1,X,ACTIONNUMBER),
		random_action2(ACTIONNUMBER,ACTION),
		random_action3(PREVACTION,X, ACTION, ACTION2).

random_intention2(ACTN,ITNN,INTNL,INTNL,_,[]).

random_intention2(ACTN,ITNN,ITNL2,ITNL,PREVACTION,[act(ACTION,ITNN,ITNL2)|T]):-
		random_action(PREVACTION,ACTN,ACTION),
		ITNL3 is ITNL2 + 1,
		random_intention2(ACTN,ITNN,ITNL3,ITNL,ACTION,T).

random_intention(ACTN,X,ITNN,ITNS):-  % X je max delka intesny
                random(1,X,ITNL),
		ITNL2 is ITNL + 1,
		random_intention2(ACTN,ITNN,1,ITNL2,noaction,ITNS).

% random_intentions(prumerna_delka,pocet_intensen,vystup)

random_intentions(_,_,0,[]).
random_intentions(ACTN,AVGLNG,ITNN,[ITN|T]):-
		random_intention(ACTN,AVGLNG,ITNN,ITN),
		ITNN2 is ITNN - 1,
		random_intentions(ACTN,AVGLNG,ITNN2,T).

%%%%%%%%%%%%%%%%%%%%%%%
%         Heuristiky, vyperu nejdelsi z bindings pro kazdou intensnu
%         Udelam vektor podle delky nejdelsich bindings

get_longer_list(I1,I2,L1,L1L,L2,L2L,bind(I1,I2,L1)):-L1L>L2L.
get_longer_list(I1,I2,_,_,L2,L2L,bind(I1,I2,L2)).

get_longest_list([],bind(I1,I2,[])).

get_longest_list([bind(I1,I2,H)|T],LOUT):-
	get_longest_list(T,bind(I1,I2,L2)),
	length(L2,L2L),
	length(H,HL),
	get_longer_list(I1,I2,L2,L2L,H,HL,LOUT).


% prvni dva termy jsou intensny
get_longest_binds_2its(I1,I2,BIND):-
	had_propojeni_bof(I1,I2,B),
	get_longest_list(B,BIND).

% prvni je seznam intensen, kazda s kazdou

get_longest_binds_allist2(_,[],[]).

get_longest_binds_allist2(I1,[I2|T],[BIND|BINDT]):-
	get_longest_binds_2its(I1,I2,BIND),
	get_longest_binds_allist2(I1,T,BINDT).

% nejlepsi bindingsy na vsechny pary z listu, ktery je prvnim argumentem

glba([],_,[]).
glba([H|T],L,BINDS):-
	get_longest_binds_allist2(H,T,BINDSA),
	glba(T,L,BINDSB),
	append(BINDSA,BINDSB,BINDS).


% had_pestof([poradi intensen],HADI pro nejlepsi bindingsy)

had_bestof_najdi(_,_,[],[]).
had_bestof_najdi(I1,I2,[bind(I1,I2,P)|T],bind(I1,I2,P)).
had_bestof_najdi(I1,I2,[_|T],BINDS):-
	had_bestof_najdi(I1,I2,T,BINDS).

had_bestof2([H],BINDINGSY,[]).
had_bestof2([I1,I2|T],BINDINGSY,[BPH|BPT]):-
	had_bestof2([I2|T],BINDINGSY,BPT),
	had_bestof_najdi(I1,I2,BINDINGSY,BPH).

had_bestof(IDXS,BINDINXYIDXS):-
	glba(IDXS,IDXS,BINDINGSY),
	had_bestof2(IDXS,BINDINGSY,BINDINXYIDXS).


%
%	Optimum je permutace s nejvetsim poctem navazani mezi nasledniky, zkusime
%

% vyhodnoti posloupnost intensen, druhy term je seznam nejlepsich bindingsu [bind(1,2,[]),bind(1,3,[]),bind(1,4,[p(2,3),p(3,4),p(4,6)]),bind(2,3,[p(1,1)]),bind(2,4,[]),bind(3,4,[])]

dej_vetsi(A,AV,B,BV,A,AV):-AV>BV.
dej_vetsi(_,_,B,BV,B,BV).

longest_binding(_,_,[],0).
longest_binding(I1,I2,[bind(I1,I2,L)|BDST],N):-
		length(L,NL),
		longest_binding(I1,I2,BDST,N2L),
		N is max(NL,N2L).

longest_binding(I1,I2,[_|BDST],N):-
		longest_binding(I1,I2,BDST,N).

evaluate_permutation([],_,0).
evaluate_permutation([_],_,0).
evaluate_permutation([I1,I2|T],BINDINGSY,V):-
		longest_binding(I1,I2,BINDINGSY,LL),
		evaluate_permutation([I2|T],BINDINGSY,V2),
		V is V2 + LL.

evaluate_permutations([],_,[],0).
evaluate_permutations([H|T],BINDINGSY,BESTP,BESTPV):-
		evaluate_permutation(H,BINDINGSY,V),
		evaluate_permutations(T,BINDINGSY,BESTP2,BESTPV2),
		dej_vetsi(H,V,BESTP2,BESTPV2,BESTP,BESTPV).

best_permutace(IDXS, Best_Binds):-
		bagof(bind(N1,N2,P),bind(N1,N2,P),Bindings),
		h_permutace(IDXS,PERMS),
		evaluate_permutations(PERMS, Bindings, BESTP, BESTPV),
		format("% Snake solution ~w / ~w ~n",[BESTP,BESTPV]),
		hadi_propojeni(BESTP, Best_Binds).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pocet akci, prumdel zameru, pocet zameru, vystup
%
%
seznam_do(N,N,[N]).
seznam_do(N2,N,[N2|T]):-N3 is N2+1, seznam_do(N3,N,T).

print_intention([],0).
print_intention([act(ACTION,_,_)],1):-format("act(do(~w))]).~n",[ACTION]).
print_intention([act(ACTION,_,_)|T],N):-format("act(do(~w)),",[ACTION]),print_intention(T,N2),N is N2+1.

print_intentions(_,N,[]):-format("% size=~w~n",[N]),pokus(P),assert(result(P,N,0,0)).
print_intentions(I,N,[H|T]):-random_action2(I,G),I2 is I+1,
				format("goal(ach,~w,null,[[]],active).~nplan(ach,~w,[], [",[G,G]),
				print_intention(H,N2),nl,N3 is N+N2, print_intentions(I2,N3,T).

go(ACTN,AVGLNG,ITNN):-

	set_prolog_stack(global, limit(8 000 000 000)),
	set_prolog_stack(trail, limit(5 000 000 000)),
	set_prolog_stack(local, limit(5 000 000 000)),
	retractall(best_snake(_,_)),
	assert(best_snake([],0)),
	retractall(perm(_)),
	retractall(bind(_,_,_)),
	retractall(count(_)),
	assert(count(0)),
        get_time(TTT0),
	random_intentions(ACTN,AVGLNG,ITNN,ITNSOUT),

	astar(ITNSOUT,ACTIONS,N),
        get_time(TTT1),

	print(astarKonec),nl,

	pokus(P),

	format(atom(OUTM),"res/snakes~w.mas2fp",[P]),
	tell(OUTM),

	format("load(\"snakes~w\",\"snakes~w.fap\",1).",[P,P]),

	told,

	format(atom(OUT),"res/snakes~w.fap",[P]),
	tell(OUT),


	format("% ~w ~w ~w~n",[ACTN,AVGLNG,ITNN]),

	format("% ~w ~n",[TTT0]),
	format("% ~w ~n",[TTT1]),

	format("~n% ~w / ~w ~n",[ACTIONS,N]),
	format("% ASTAR Optimum ~w~n",[N]),
	print_intentions(1,0,ITNSOUT),

	result(P,A,_,_),
	retract(result(P,A,_,_)),
	assert(result(P,A,N,0)),

	udelej_hady(1,ITNSOUT),


	seznam_do(1,ITNN,IDXLIST),
	best_permutace(IDXLIST,EVPERM),

	analyzuj_hady(HADIBP),
	get_time(TTT),
	format("~n~n% ~w~n",TTT),

	D2 is TTT-TTT1,
	D1 is TTT1-TTT0,
	format("% casy(~w,~w).~n~n",[D1,D2]),

	retractall(best_snake(_,_)),
	assert(best_snake([],0)),
	told.


printResult(P):-
		format(atom(OUT),"res/results",[]),
		append(OUT),
		result(P,A,B,C),
		format("~w.~n",[result(P,A,B,C)]),
		told.



go(POK,0,_,_,_,SOLVE).

go(P,N,A,B,C,SOLVE):-
	retractall(pokus(_)),
	assert(pokus(P)),
	go(A,B,C),
	printResult(P),
	P2 is P+1,
	N2 is N-1,
	told,!,
	go(P2,N2,A,B,C,SOLVE).



go3:-udelej_hady(1,[
	[act(a,1,1),act(b,1,2),act(c,1,3),act(d,1,4),act(a,1,5)],
	[act(a,2,1),act(a,2,2),act(b,2,3),act(c,2,4),act(a,2,5)],
	[act(c,3,1),act(b,3,2),act(a,3,3),act(b,3,4),act(a,3,5)],
	[act(b,4,1),act(a,4,2),act(b,4,3)],
	[act(b,5,1),act(a,5,2),act(b,5,3),act(d,5,4)],
	[act(d,5,1),act(a,5,2),act(c,5,3)]
	]),
	hadi_propojeni([1,2,3,4,5,6],[]).


