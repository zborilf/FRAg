%
%	Reasoning methods - the simple ones
%	Frantisek Zboril jr. 2023
%

%
%	Should define
%                    	get_intention(+Reasoning_type,+Intentions,-Intention).
%                       
%			not defined for:
%				 get_substitution(+Reasoning_type,+ActionTerm,+SubstitutionList, +VariableList,-SubstitutionList).
%                       	 get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%			if required, 'simple_reasoning' will be used.
%

%	This module is loaded / included in the FRAgAgent file


  reasoning_method(snakes_reasoning).

			
%
%	redirecting the other two to simple_reasoning
%

  get_intention(biggest_joint_reasoning, INTENTIONS, INTENTION).


%
%	TODO
%



%
%	redirecting the other two to simple_reasoning
%


  get_substitution(snakes_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION):-
	get_substitution(simple_reasoning, ACTION, CONTEXT, VARS, SUBSTITUTION)

  get_plan(biggest_joit_reasoning, EVENT, PLANS, INTENDED_MEANS):-
        get_plan(snakes_reasoning, EVENT, PLANS, INTENDED_MEANS).

	
  init_reasoning(snakes_reasoning).



