
:- include('stats.pl').


:- dynamic obrat/3.


pridej(sold(Who, Number), Number_Total):-
    obrat(Who, Number2, Number_Total2),
    retract(obrat(Who, Number2, Number_Total2)),
    Number3 is Number + Number2,
    Number_Total3 is Number_Total + Number_Total2,
    assert(obrat(Who, Number3, Number_Total3)).

pridej(sold(Who, Number), Number_Total):-
    assert(obrat(Who, Number, Number_Total)).

g2([], _).

g2([Trade|Trades], B):-
    writeln(B),
    writeln(Trade),
    pridej(Trade, B),
    g2(Trades, B).


report([]).

report([obrat(Who, N, NT) | Obraty]):-
    P is N * 100 / NT,
    format(" ~w : ~w~n", [Who, P]),
    report(Obraty).


g1([]).

g1([Stat|Stats]):-
    member(buyers(B), Stat),
    member(sold(Trades), Stat),
    g2(Trades, B),
    g1(Stats).

g:-
   bagof(Stat, stats_(Stat), Stats),
   g1(Stats),
   bagof(obrat(Who, N, NT), obrat(Who, N, NT), Obraty),
   report(Obraty).




