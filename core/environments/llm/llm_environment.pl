

:-module(llm_environment,
    [
        llm_environment / 2,
	llm_environment / 3,			
	llm_environment / 4			
    ]
).


:-use_module('../FRAgPLEnvironmentUtils').   % interface for environments

llm_environment(perceive, _ , [], []). % no changes in Agent's BB
   
llm_environment(add_agent, Agent):-
    env_utils:situate_agent_environment(Agent, llm_environment).
   
llm_environment(add_agent, Agent, Clone):-
    env_utils:situate_agents_clone([Agent], llm_environment, Clone).


llm_environment(act, Agent, chat(Model, Prompt, Answer), true):-
   py_call(connect_chat:ask_gpt(Prompt), Answer).

llm_environment(act, Agent, silently_( _ ), true).

llm_environment(act, _, _, false).


llm_environment(clone, Clone):-
    clone_environment(llm_environment, Clone).
    

llm_environment(remove_clone, Clone):-
    remove_environment_clone(llm_environment, Clone).
 


llm_environment(reset_clone, Clone):-
    reset_environment_clone(llm_environment, Clone),
    get_all_situated(llm_environment, Clone, Agents),   
    init_beliefs(Agents).


llm_environment(save_state, Instance, State):-
    save_environment_instance_state(llm_environment, Instance, State).


llm_environment(load_state, Instance, State):-
    load_environment_instance_state(llm_environment, Instance, State).


llm_environment(remove_state, Instance, State):-
    remove_environment_instance_state(llm_environment, Instance, State).



g:-llm_environment(act, kecal1, chat(Model, 'opet, jen zkousim, zustan v klidu', Answer), true),writeln(Answer).
   

% Init, just register the environment name
:- env_utils:register_environment(llm_environment),
   use_module(library(janus)),
   py_import('environments.llm.connect_chat', [ask_gpt(Answer)]).


