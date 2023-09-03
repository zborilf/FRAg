%
%	Reasoning methods - the simple ones
%	Frantisek Zboril jr. 2022
%

%
%	Should define
%                    	get_intention(+Reasoning_type, +Intentions, -Intention).
%                       get_substitution(+Reasoning_type, +ActionTerm, +SubstitutionList, +VariableList,-SubstitutionList).
%                       get_plan(+Reasoning_type, +Event, +RelAppPlans, -IntendedMeans).
%

%	This module is loaded / included in the FRAgAgent file



  reasoning_method(simple_reasoning).


% First active

  %
  %  Takes the first active intention
  %

% sort it by id
  get_intention(simple_reasoning, [intention(INDEX, CONTENT, active)|_], intention(INDEX, CONTENT, active)).

  get_intention(simple_reasoning, [ _ | TINTENTIONS], INTENTION):-
	get_intention(simple_reasoning, TINTENTIONS, INTENTION).


  get_substitution(simple_reasoning, _, [CONTEXTH| _ ], VARS, CONTEXT):-
	shorting(CONTEXTH, VARS, CONTEXT).	% from file FRAgPLFRAg

% sort it by id
  get_plan(simple_reasoning, _, [INTENDED_MEANS| _ ], INTENDED_MEANS).

  update_model(simple_reasoning).
				
  init_reasoning(simple_reasoning).

