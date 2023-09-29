
del examples\logs\*.mcts


for /L %%n in (1,1,20) do swipl -l FragPL.pl -g frag('../examples/trader2/trader') -g halt




