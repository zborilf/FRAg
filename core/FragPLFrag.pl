

%
%	FRAg clause for late binding
%

% bind(X,a).

%
% query to a list of facts, possible unifiers set as a result
%

broadUnification2(G,[],[]).

broadUnification2(G,[BELIEF|BELIEFS],[SUBSTITUTION|T]):-
		unifiable(G,BELIEF,SUBSTITUTION),
		broadUnification2(G,BELIEFS,T).		

broadUnification2(G,[BELIEF|BELIEFS],T):-
		broadUnification2(G,BELIEFS,T).

broadUnification(G,BB,SUBS2):-
		broadUnification2(G,BB,SUBS),
		sort(SUBS,SUBS2).
                   
%
%     INSTANCE SET, predikat+kontext -> seznam predikatu
%					nesmi se ale zlikvidovat promenne v kontextu
%

applySubstitutions([]).
applySubstitutions([H|T]):-
		H,
		applySubstitutions(T).

instanceSet(G,[],[]).
instanceSet(G,[SUBS|T],[GNEW|T2]):-
		copy_term([G|SUBS],[GNEW|SUBSNEW]),
		applySubstitutions(SUBSNEW),
		instanceSet(G,T,T2).


getVars([],[]).
getVars([H|T],[H|T2]):-
		var(H),
		getVars(T,T2).
getVars([_|T],T2):-
		getVars(T,T2).


memberVar(A=B,[C|T]):-A==C.
memberVar(BIND,[_|T]):-memberVar(BIND,T).

%
%	SHORT  // neodpovida clanku, tady se z PUS jen vytahnou promenne
%


shorting([],_,[]).
shorting([BIND|T],VARS,[BIND|T2]):-
		memberVar(BIND,VARS),
%		BIND,
		shorting(T,VARS,T2).

shorting([_|T],VARS,T2):-
		shorting(T,VARS,T2).

TODO, dodelat shortings

shortings(PUS,G,PUS2):-
	G=..GTERMS,
	getVars(GTERMS,GVARS).



%
%	DECISIONING
%                            

% PUS , pro mnozinu promennych vybere z jednoho prvku PUS prirazeni, restriction na tyto prirazeni a aplikace

applySubstitutions([]).
applySubstitutions([BIND|T]):-
		BIND,
		applySubstitutions(T).



% takes the first PUS from the context / easy decide
decide([CTXH|_],VARS,CTXSHORT):-
		shorting(CTXH,VARS,CTXSHORT),
		format("shorting(~w,~w,~w)~n",[CTXH,VARS,CTXSHORT]).

decisioning(ACTIONTERMS,CONTEXT,CONTEXTNEW):-
		getVars(ACTIONTERMS,ACTIONVARIABLES),
		decide(CONTEXT,ACTIONVARIABLES,PU),
		restrict(CONTEXT,[PU],CONTEXTNEW),
		applySubstitutions(PU).
		

%
%  	MERGING
%	merging(PU1,PU2,PUMerged).
%

appendNE([[]],L,L).
appendNE(L,[[]],L).
appendNE(L1,L2,L3):-append(L1,L2,L3).

merging3([],_).

merging3([A=B|T1],[C=D|T2]):-
		A==C,!,	% the same variable , to ale overit, jestli za behu je promenna porad ta sama i v hierarchii
		B=D,
		merging3(T1,[C=D|T2]).

merging3([A=B|T1],[C=D|T2]):-
		merging3(T1,[C=D|T2]).


merging2(_,[]).

merging2(L,[H|T]):-
		merging3(L,[H|T]),
		merging2(L,T).

	
merging(PU1,PU2,PUOUT):-
		merging2(PU1,PU2),
		append(PU1,PU2,PU3),
		sort(PU3,PUOUT).
merging(_,_,[]).

%
%	RESTRICTION
%       Restrict(PU1, PU2, 'PU1 T PU2').


restrict2(_,[],[[]]).
restrict2(PU1,[PU2|TPUS2],PUS):-
		merging(PU1,PU2,PUS2),
		restrict2(PU1,TPUS2,PUS3),
		appendNE([PUS2],PUS3,PUS).

restrict([],_,[[]]).
restrict([H|T],L,PUS):-
		restrict2(H,L,PUS2),
		restrict(T,L,PUS3),
		appendNE(PUS2,PUS3,PUS).

%
%	INTERSECTION   (1)
%       goal1,context ~ goal2, BU(IS(goal1,context),goal2)
%	intersection(Goal1, Context, Goal2, 'Goal1,Context ~ Goal2') 
%

intersection(G1,CTX,G2,ISEC):-
	instanceSet(G1,CTX,IS),
	broadUnification(G2,IS,ISEC).

%
%	INTERSECTION   (2)
%       goal1,context ~ goal2, PUS // REST(BU(IS(goal1,context),goal2),PUS)
%

intersection(G1,CTX,G2,PUS,ISEC2):-
	intersection(G1,CTX,G2,ISEC),
	restrict(ISEC,PUS,ISEC2).


%
%   DEBUG EXECUTION
%

go(PUS,PUS2,PUS3):-
		broadUnification(a(X,Y),[a(a,b),a(c,d)],PUS),
	 	broadUnification(b(X,Z),[b(x,y),b(c,v),b(c,p)],PUS2),
		restrict(PUS,PUS2,PUS3).


                