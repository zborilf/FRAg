

%
%	FRAg clauses for late bindings
%	2021 - 2022 
%	Frantisek Zboril
%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Reasoning methods - intention, plan and substitution selections
%



:-thread_local active_intention_selection /1. 		% reasoning - plan selection + substitution selection (decide op.) + intention selection
:-thread_local active_plan_selection /1. 	
:-thread_local active_substitution_selection /1. 		

:-dynamic default_intention_selection /1. 		
:-dynamic default_plan_selection /1. 		
:-dynamic default_substitution_selection /1. 		


set_intention_selection(Intention_Selection):-
    reasoning_method(Intention_Selection),				% checks if such reasoning exists
    retractall(active_intention_selection( _ )),
    assert(active_intention_selection(Intention_Selection)),
    print_debug("[SYSDBG] Setting intention selection method to ", systemdbg),
    println_debug(Intention_Selection, systemdbg).


set_intention_selection(Intention_Selection):-
    format(atom(String), "Intention selection cannot be switched to ~w~n",
	       [Intention_Selection]),
    print_debug(String, error).


set_default_intention_selection(INTENTIONSELECTION):-
    reasoning_method(INTENTIONSELECTION),
    retractall(default_intention_selection( _ )),
    assert(default_intention_selection(INTENTIONSELECTION)),
    print_debug("[SYSDBG] Setting default intention selection method to ", systemdbg),
    println_debug(INTENTIONSELECTION, systemdbg).

set_default_intention_selection(INTENTIONSELECTION):-
    format(atom(STRING), "Default intention selection cannot be switched to ~w~n",[INTENTIONSELECTION]),
    print_debug(STRING, error).


set_plan_selection(Plan_Selection):-
    reasoning_method(Plan_Selection),
    retractall(active_plan_selection( _ )),
    assert(active_plan_selection(Plan_Selection)),
    print_debug("[SYSDBG] Setting plan selection method to ", systemdbg),
    println_debug(Plan_Selection, systemdbg).


set_plan_selection(Plan_Selection):-
    format(atom(String), "[ERROR] Plan selection cannot be switched to ~w~n",
	       [Plan_Selection]),
    print_debug(String, error).


set_default_plan_selection(PLANSELECTION):-
    reasoning_method(PLANSELECTION),
    retractall(default_plan_selection( _ )),
    assert(default_plan_selection(PLANSELECTION)),
    print_debug("[SYSDBG] Setting default plan selection method to ", 
                systemdbg),
    println_debug(PLANSELECTION, systemdbg).

set_default_plan_selection(PLANSELECTION):-
    format(atom(STRING), 
           "[ERROR] Default plan selection cannot be switched to ~w~n",
           [PLANSELECTION]),
    print_debug(STRING, error).


set_substitution_selection(SUBSTITUTIONSELECTION):-
    reasoning_method(SUBSTITUTIONSELECTION),             	
    retractall(active_substitution_selection( _ )),
    assert(active_substitution_selection(SUBSTITUTIONSELECTION)),
    print_debug("[SYSDBG] Setting substitution selection method to ", 
                systemdbg),
    println_debug(SUBSTITUTIONSELECTION, systemdbg).


set_substitution_selection(SUBSTITUTIONSELECTION):-
	format(atom(String), 
	       "[ERROR] Substitution selection cannot be switched to ~w~n",
	       [SUBSTITUTIONSELECTION]),
	print_debug(String, error).
	

set_default_substitution_selection(SUBSTITUTIONSELECTION):-
    reasoning_method(SUBSTITUTIONSELECTION),
    retractall(default_substitution_selection( _ )),
    assert(default_substitution_selection(SUBSTITUTIONSELECTION)),
    print_debug("[SYSDBG] Setting default decision method to ", systemdbg),
    println_debug(SUBSTITUTIONSELECTION, systemdbg).

set_default_substitution_selection(SUBSTITUTIONSELECTION):-
    format(atom(String), 
           "[ERROR] Default substitution selection cannot be switched to ~w~n",
           [SUBSTITUTIONSELECTION]),
   print_debug(String, error).


set_reasoning(Reasoning):-
    reasoning_method(Reasoning),
	set_intention_selection(Reasoning),
    set_plan_selection(Reasoning),
	set_substitution_selection(Reasoning).

set_reasoning(Reasoning):-
	format(atom(String), "[ERROR] Reasoning cannot be switched to ~w~n",
	       [Reasoning]),
	print_debug(String, error).

set_default_reasoning(Reasoning):-
  	reasoning_method(Reasoning),
	set_default_intention_selection(Reasoning),
        set_default_plan_selection(Reasoning),
	set_default_substitution_selection(Reasoning).

set_default_reasoning(Reasoning):-
	format(atom(String), 
	       "[ERROR] Default reasoning cannot be switched to ~w~n",
	       [Reasoning]),
	print_debug(String, error).



get_default_reasoning(INTENTIONSELECTION, Plan_Selection, 
                      SUBSTITUTIONSELECTION):-
    default_intention_selection(INTENTIONSELECTION),
	default_plan_selection(Plan_Selection),
	default_substitution_selection(SUBSTITUTIONSELECTION).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


update_models2([]).

update_models2([Model| Models]):-
    update_model(Model),			% v jednotlivych reasoninzich
    update_models2(Models).		

update_models:-
    active_intention_selection(Intention_Selection),
    active_plan_selection(Plan_Selection),
    active_substitution_selection(Substitution_Selection),
    list_to_set([Intention_Selection, Plan_Selection, Substitution_Selection], 
                Models),
    !,
    update_models2(Models).  

update_models.




get_intention(INTENTIONS, intention(INTENTIONINDEX, CONTEXT, PLANSTACK)):-
    active_intention_selection(AIS),
    get_intention(AIS, INTENTIONS, intention(INTENTIONINDEX, CONTEXT, PLANSTACK)),	
    %	intention(INTENTIONINDEX, CONTEXT, PLANSTACK2),
    loop_number(LOOP),
    format(atom(STRING), 
           "[RSNDBG] GET INTENTION [~w / ~w] -> ~w~n", 
               [LOOP,AIS, intention(INTENTIONINDEX, CONTEXT, PLANSTACK)]),
    print_debug(STRING, reasoningdbg).
	
	
	
get_intended_means(MEANS, EVENT, INTENDED_MEANS):- 
    active_plan_selection(APS),
    get_plan(APS, EVENT, MEANS, INTENDED_MEANS),
    loop_number(LOOP),
    format(atom(STRING), 
           "[RSNDBG] GET PLAN [~w / ~w] -> FOR ~w ~n[......] -> PLAN ~w~n", 
		   [LOOP, APS, EVENT, INTENDED_MEANS]),
    print_debug(STRING, reasoningdbg).                               


  %  decide_context(action atom, context, variables in action, chosen substitutions)

decide_context( _, _, [], []).		% no vars / nothing to decide
	
decide_context(ACTIONATOM, CONTEXT, VARS, NCTX):-
    active_substitution_selection(ASSL),
    get_substitution(ASSL, ACTIONATOM, CONTEXT, VARS, NCTX),
    loop_number(LOOP),
    format(atom(STRING),
           "[RSNDBG] GET DECISION [~w / ~w] ->~n[......] FOR ~w ~w ~n[......] DECISION -> ~w~n", 
		   [LOOP, ASSL, ACTIONATOM, CONTEXT, NCTX]),
	print_debug(STRING, reasoningdbg).                               



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	FRAg Methods
%


%
%	BROAD UNIFICATION
%	briadUnification(GOAL,BASE,SUBSTITUTIONSET)
% 	SUBSTITUTIONSET = BU(GOAL,BASE) =def {SUBSTITUTION : BELIEF from BASE, SUBSTITUTION = mgu(GOAL,BELIEF)}
%

remove_renamings([],[]).

remove_renamings([A=B|T],T2):-
    var(A),var(B),
    remove_renamings(T,T2).

remove_renamings([H|T],[H|T2]):-
    remove_renamings(T,T2).


broad_unification2(_ ,[], []).

broad_unification2(G, [BELIEF| TBELIEFS], [SUBSTITUTION2|T]):-
    unifiable(G, BELIEF, SUBSTITUTION),             % SUBSTITUTION = mgu(G,BELIEF)
    remove_renamings(SUBSTITUTION, SUBSTITUTION2),	% SUBSTITUTION2 is SUBSTITUTION without renamings
    broad_unification2(G, TBELIEFS, T).           	% next mgu for the next belief

broad_unification2(GOAL, [_ |BELIEFS], T):-
    broad_unification2(GOAL, BELIEFS, T).

broadUnification(GOAL, BELIEFBASE, SUBS2):-
    broad_unification2(GOAL, BELIEFBASE, SUBS),
    sort(SUBS,SUBS2).

%
%	Reasoning methods (plan / intention / substitution selections)
%



%
%     INSTANCE SET, predicate + context -> list of predicates
%					nesmi se ale zlikvidovat promenne v kontextu
%
% vstupem jsou substituce [[A->a],[B->b] ...] a ty jsou postupne provadeny

apply_substitutions([]).                             		%

apply_substitutions([Binding| Bindings]):-
    Binding,
    apply_substitutions(Bindings).


instance_set(_ ,[],[]).

instance_set(Atom, [Substitution| Substitutions], Instance_Set):-
    copy_term([Atom| Substitution], [New_Atom| New_Substitution]),
    apply_substitutions(New_Substitution),
    instance_set(Atom, Substitutions, Substitutions2),
    sort([New_Atom| Substitutions2], Instance_Set).

%
%	SHORT  // neodpovida clanku, tady se z PUS jen vytahnou promenne
%       musi se , vzit promenne, vzit PUS a vytvorit novy PUS a s novymi promennymi
%       pokud mame PUS s prazdnymi unifikatory, udelame z toho jen jedno PUS [[],[],...] -> [[]]
% 	

setEmptyPUS([[]|_], [[]]).

setEmptyPUS(PUS,PUS).

% 	memberVar(A=B,VARS) 
% 	is A from the variable list VARS?


memberVar(A=_,[C|_]):- A==C.                                        

memberVar(BIND,[_|T]):- memberVar(BIND,T).              


delete_binding([], _, []).

delete_binding([A=B| TBINDINGS], C=D, TBINDINGSOUT):-
    A==C, B==D, 
    delete_binding(TBINDINGS, C=D, TBINDINGSOUT).

delete_binding([BINDING | TBINDINGS], BINDING2, [BINDING | TBINDINGSOUT]):-
    delete_binding(TBINDINGS, BINDING2, TBINDINGSOUT).			  


subsubstitution([], _).

subsubstitution(SUBSTITUTION, [BINDING | TBINDINGS]):-
    delete_binding(SUBSTITUTION, BINDING, SUBSTITUTION2),
    subsubstitution(SUBSTITUTION2, TBINDINGS).	

%  	shorting(SUBSTITUTIONS,VARLIST, S
%  	basic shorting: substitution x list of variables -> substitutions just for these variables

                                                                                                                                                                        
shorting([],_,[]). 					% empty context remains empty context
shorting(_,[],[]).					% no variable -> empty context
		                                     	% shorts one substitution due to the variables in VARS
shorting([BIND|T],VARS,[BIND|T2]):-                    	% [A->a,B->,D->d,F->d],[A,D] -> [A->a,D->d]
    memberVar(BIND,VARS),
    shorting(T,VARS,T2).

shorting([_|T],VARS,T2):-
    shorting(T,VARS,T2).

shorting_pus([],_,[]).

% shorts every substitution from the first list with respect with the list of 
% variables V (only V-pairs remains)

shorting_pus([H1|T1],V,[H2|T2]):-             
    shorting(H1,V,H2),
    shorting_pus(T1,V,T2).

%
% 	FRAg shorting
% 	shorting(vstupnicil1, vystpynicil , vstupni PUS, vstupni promenne, vystupni PUS, vystupni promenne).
% 	vstupnicl -> vystupnicil   , ten samy cil ale s radne prejmenovanymi promennymi
%
% 	no variables -> empty PUS (bez toho to tuhne, coz by nemelo)
% 	shorting(_,_,IPUS,[],[[]],[]).
%

shorting(G,G2,IPUS,IVARS,OPUS,OVARS):-
    shorting_pus(IPUS,IVARS,SPUS),      	% nashortujeme IPUS podle promennych v IV, vysledek v SPUS
    setEmptyPUS(SPUS,SPUS2),   			% pokud je vystup [[],[],....] udelame z nej pouze [[]]
    copy_term([G,SPUS2],[G2,OPUS]),     	% musime prejmenovat, abychom ziskali 'fresh' jmena promennych
    term_variables(OPUS,OVARS).  		% a vezmem jen promenne, ktere jsou v novem PUS  (promennych bylo vic, nez bylo ve vstupnim PUS) shorting [[A=a],[B=b]],[A,C] ->  [[A=a]],[A]


%
%	After execution PUS may include weird tubles constant=constant even for a pair with distinc constants
%	these should be reducet, or better PUS should be reduced only to those mapping variables to a term 
%	shortNoVars(PUS, PUS). 
%


shortNoVars2([],_,[]).

shortNoVars2([Substitution| Substitutions], Variables, [PUS| PUSs]):-
    shorting(Substitution, Variables, PUS),
    shortNoVars2(Substitutions, Variables, PUSs).

shortNoVars([Substitution| Substitutions], PUSs):-
    term_variables(Substitution, Variables),
    shortNoVars2([Substitution| Substitutions], Variables, PUS),
    sort(PUS, PUSs).


%
%	DECISIONING
%

% PUS , pro mnozinu promennych vybere z jednoho prvku PUS prirazeni, restriction na tyto prirazeni a aplikace



% takes the first PUS from the context / simple reasoning
% selects one substitution from the context due to requestet variebles 'to ground' 
% all the substitutions in the context must soud to the variables bindings in the selected context

% uses reasoning method due to active_reasoning_method(-Method)
%



decisioning(ACTIONTERM, CONTEXT, ContextOut):-
    term_variables(ACTIONTERM, ACTIONVARIABLES),
    decide_context(ACTIONTERM, CONTEXT, ACTIONVARIABLES, Context2),
    restrict(CONTEXT, [Context2], ContextOut),
    apply_substitutions(Context2).


%
%  	MERGING
%       PUMerged = PU1 m PU2 =def ... see [1]
%	merging(PU1,PU2,PUMerged).
%

appendNE([[]], List, List).
appendNE(List, [[]], List).
appendNE(List1, List2, List3) :- append(List1, List2, List3).


% merging3(substitutionsList, substitions) is true, when the same variables in 
% both substitutions are mapped to the same terms/atoms

merging3([],_).

merging3([A=B|T1],C=D):-
    A==C,!,	
    B=D,
    merging3(T1,C=D).

merging3([_|T1],C=D):-
    merging3(T1, C=D).


merging2(_,[]).

merging2(L,[H|T]):-
    merging3(L,H),
    merging2(L,T).


merging(PU1,PU2,PUOUT):-
    merging2(PU1,PU2),
    append(PU1,PU2,PU3),
    sort(PU3,PUOUT).

merging(_,_,[]).

%
%	RESTRICTION
%	REST(PU1,PU2,RESTRICTION)
%       RESTRICTION = REST(PU1, PU2) =def ... see [1] eq ???.
%

restrict2(_,[],[[]]).

 
restrict2(PU1,[PU2|TPUS2],PUS):-
    merging(PU1,PU2,PUS2),
    restrict2(PU1,TPUS2,PUS3),
    appendNE([PUS2],PUS3,PUS).


restrict([[]],[[]],[[]]).    % empty PUS's restriction

restrict([H|T], L, PUS):-
    restrict2(H, L, PUS2),
    restrict(T, L, PUS3),
    appendNE(PUS2, PUS3, PUS).

restrict( _, _, []).

%
%	INTERSECTION   (1)
%	goal1,context ~ goal2 =def BU(IS(Goal1,Context),Goal2)
%	intersectionF(Goal1, Context, Goal2, 'Goal1,Context ~ Goal2')
%

intersectionF(G1,CTX,G2,ISEC2):-
    instance_set(G1,CTX,IS),
    broadUnification(G2,IS,ISEC),
    term_variables(G2,G2VARS),
    shorting_pus(ISEC,G2VARS,ISEC2).

%
%	INTERSECTION   (2)
%       goal1,context ~ goal2, PUS =def REST(BU(IS(goal1,context),goal2),PUS)
%	
%

intersectionF(G1,CTX,G2,PUS,ISEC2):-
    intersectionF(G1,CTX,G2,ISEC),
    restrict(ISEC,PUS,ISEC2).

%
%	Queries
%
               
% it failed
simulate_early_bindings(_, [], []). 			
 
% late bindings are set, so do not simulate early bindings
simulate_early_bindings(_, CONTEXT, CONTEXT):-
    late_bindings(true).				

simulate_early_bindings(GOAL, CONTEXTIN, CONTEXTOUT):-
    decisioning(GOAL, CONTEXTIN, CONTEXTOUT).



substract_subsets2([], _, []).

substract_subsets2([SUBSTITUTION | TSUBSTITUTIONS], SUBSTITUTION2, SUBSTITUTIONSOUT):-
    subsubstitution(SUBSTITUTION, SUBSTITUTION2),
    substract_subsets2(TSUBSTITUTIONS, SUBSTITUTION2, SUBSTITUTIONSOUT).

substract_subsets2([SUBSTITUTION | TSUBSTITUTIONS], SUBSTITUTION2, [SUBSTITUTION | SUBSTITUTIONSOUT]):-
    substract_subsets2(TSUBSTITUTIONS, SUBSTITUTION2, SUBSTITUTIONSOUT).


substract_subsets(PUS, [], PUS).

substract_subsets(PUS, [SUBSTITUTION | TSUBSTITUTIONS], PUSSUBSTRACTEDOUT):-
    substract_subsets2(PUS, SUBSTITUTION, PUSSUBSTRACTED),	
    substract_subsets(PUSSUBSTRACTED, TSUBSTITUTIONS, PUSSUBSTRACTEDOUT).


%
%  not query
%

query(not(QUERY), CONTEXT, CONTEXTOUT):-
    %  writeln(query(not(QUERY), CONTEXT, CONTEXTOUT)),
    query(QUERY, CONTEXT, CONTEXT2),
    % not published yet ... query succeeded, but may be just for some contextes ...
    substract_subsets(CONTEXT, CONTEXT2, CONTEXTOUT).

query(not( _ ), Context, Context).   % query to QUERY failed (no answer)


query(Query, Context, Context_Out):-    
    bagof(fact(Query), fact(Query), Answers),
    broadUnification(fact(Query), Answers, Context2),
    simulate_early_bindings(Query, Context2, Context3),
    restrict(Context, Context3, Context_Out).
                        
query( _, _, []).   

