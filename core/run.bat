
del examples\logs\*.mcts


for /L %%n in (1, 1, 2) do swipl -l FragPL.pl -g frag('../examples/trader/trader') -g halt




