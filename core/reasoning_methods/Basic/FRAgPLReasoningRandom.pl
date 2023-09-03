%
%	Reasoning methods - Random selection
%	Frantisek Zboril jr. 2022
%

%
%	Should define
%                    	get_intention(+Reasoning_type, +Intentions, -Intention).
%                       get_substitution(+Reasoning_type, +ActionTerm, +SubstitutionList, +VariableList, -SubstitutionList).
%                       get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%

%	This module is loaded / included in the FRAgAgent file


% 	Selects allways randomly


                     
reasoning_method(random_reasoning).


get_intention(random_reasoning,INTENTIONS,intention(IDX,CONTENT,active)):-
    random_member(intention(IDX,CONTENT,active),INTENTIONS).

get_intention(random_reasoning,INTENTIONS, _):-
    get_intention(random_reasoning,INTENTIONS).


get_substitution(random_reasoning, _, CONTEXT, VARS, NEWCONTEXT):-
    random_member(SUBSTITUTION,CONTEXT),
    shorting(SUBSTITUTION,VARS,NEWCONTEXT).	% from file FRAgPLFRAg

 
get_plan(random_reasoning, _ , MEANS, INTENDEDMEANS):-
    random_member(INTENDEDMEANS, MEANS).


update_model(random_reasoning). 


init_reasoning(random_reasoning).
