# This library implements functionality of FRAgPLEnvironmentUtils.pl in python

from Agent import Agent

_env_pointer = None # Global variable for storing the base/main environment to which clones can be attached

# Register an environment
def register_environment(env_obj):
    global _env_pointer
    _env_pointer = env_obj
    return _env_pointer


# Register a clone of an environment
def register_clone(candidate_clone):
    for clone in _env_pointer.get_clones():
        if candidate_clone == clone.get_name():
            return
     
    new_clone = (candidate_clone, True)
    _env_pointer.append_clone_env(new_clone)


# Retutns environment with a given name if it exists
def get_environment_by_name(name:str):
    global _env_pointer
    root_env = _env_pointer
    if root_env.get_name() == name:
        return root_env
    else:
        for clone_env in root_env.get_clones():
            if clone_env.get_name() == name:
                return clone_env
    return None


# Places agent in a modular environment with Structure
def situate_agent_modenv_s(agent_name:str, env) -> Agent:
    room_name:str = env.get_agent_spawn(agent_name)
    agent:Agent =  env.place_agent(agent_name, env.get_inner_structure().get_cell_by_uid(room_name))
    return agent


# Places agent in a modular environment with Grid
def situate_agent_modenv_g(agent_name:str, env) -> Agent:
    x, y = env.get_agent_spawn(agent_name)
    agent:Agent = env.place_agent(agent_name, env.get_inner_structure().get_cell_by_index(x,y))
    return agent


# Used for debugging from prolog side
def print_msg(msg:str) -> None:
    print(msg)