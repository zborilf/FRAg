
/**

This file is part of the FRAg program. It is insluded into agent's file 
FRAgAgent.pl. It contains clauses that are applied to strategies for selecting 
intentions, plans and substitutions. Random reasoning always selects randomly 
from a set of provided options.

@author Frantisek Zboril
@version 2021 - 2022
@license GPL

*/


%!  reasoning_method(random_reasoning) is det
%  announces that the 'random_reasoning' decision strategy is available
                     
reasoning_method(random_reasoning).



%!  get_intention(random_reasoning, +Intentions, - Intention) is det
%  @arg Inention: list of elements from which to select one
%  @arg Intention: selected Intention, first one of the Intentions list

get_intention(random_reasoning, Intentions, intention(Intention_ID, Content, 
		active)):-
    random_member(intention(Intention_ID, Content, active), Intentions).

get_intention(random_reasoning, Intentions, _):-
    get_intention(random_reasoning, Intentions).



%!  get_substitution(random_reasoning, _, Context, Vars, Context_Out) is det
%   cz vybere nahodne jednu substituci a vytahne z ni Vars, toto je vysledek (!!!)
%   This clause is to select one of the set of substitutions that subsume a 
%   superset of Vars variables from ...
%  @arg Context_In:
%  @arg Vars:
%  @arg Context_Out

get_substitution(random_reasoning, _, Context_In, Vars, Context_Out):-
    random_member(Substitution, Context_In),
    shorting(Substitution, Vars, Context_Out).	% from file FRAgPLFRAg


%!  get_plan(random_reasoning, ...)     

get_plan(random_reasoning, _ , Means, Intended_Means):-
    random_member(Intended_Means, Means).



%!  update_model(random_reasoning) is det
%   No update is needed. This clause is assessed as valid without  
%   implementation of sub-goals

update_model(random_reasoning). 


%!  update_model(random_reasoning) is det
%   No initialization is needed. This clause is assessed as valid without  
%   implementation of sub-goals

init_reasoning(random_reasoning).


