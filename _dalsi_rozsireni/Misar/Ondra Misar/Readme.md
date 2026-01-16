
# Installation of Python environment

In the folder 'core/MCTS_python/' there are environment and requirements files in order to install all the required python libraries.

## Anaconda

```aiignore
conda env create -f environment.yml
```

## Python pip

```aiignore
pip install -r requirements.txt
```


# Starting Python MCTS service

If the external architecture is used, first the external service that is located in 'core/' needs to be started as:

```aiignore
python mcts_service.py
```


# FRAg setting

Four new reasoning methods are added:

- mcts_reasoning_integrated_python for the integrated architecture version.
- mcts_reasoning_external_service_sequential for the external architecture version of basic MCTS method.
- mcts_reasoning_external_service_parallel for the external architecture version of parallel MCTS method.
- mcts_reasoning_online_learning for the external architecture version of online learning MCTS method.

In the agent setting file the "reasoning", "reasoning_params" and "python_interpreter" needs to be set, in order to use new MCTS reasoning methods.

Example of such an agent setting:

```aiignore
include_environment("environments/task_maze/task_maze.pl").

set_agents([(bindings, late),
        (reasoning, mcts_reasoning_external_service_parallel),
		(reasoning_params, mcts_params(5,5,60)),
		(python_interpreter, true),
	        (control, terminate(timeout, 25)),
                (environment, task_maze)]).
		

load("task_maze","../examples/task_maze/task_maze",1,[(debug, reasoningdbg), 
		(debug, mctsdbg_path), 
		(debug, mctsdbg), 
	        (debug, actdbg),
		(debug, interdbg), (debug, systemdbg)]).  
```

# Experiments

Two experiments are provided in 'core/' as "experiment1.py" and "experiment2.py".

In the main method of these files, the whole experiment routine is specified. Results are writen into 'examples/garden' or 'examples/task_maze' depending on the experiment.

Where each specified method is seperated in its own folder, example "mcts-external-parallel" for the configuration of agent setting and the results of MCTS method "mcts_reasoning_external_service_sequential".

Each experiment can then be started as:

```aiignore
python experiment1.py

python experiment2.py
```