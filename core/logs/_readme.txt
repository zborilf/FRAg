
File numbering is ...
1st number is how many steps the real agent has already taken, from this step 
it is simulated 2nd number goes 'backwards' as the simulator expands the tree, 
then all runs are listed in each file

TODO, improve
As far as the environment is concerned, it must be restored for the step
(1st digit) of the agent for each run before it the path from the MCTS root 
to the current state