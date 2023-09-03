
del examples\logs\*.mcts


for /L %%n in (1,1,100) do swipl -l FragPL.pl -g frag('../examples/adam/adam') -g halt




