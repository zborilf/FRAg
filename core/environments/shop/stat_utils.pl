
:-module(stat_utils, 
    [
        get_discount / 2,
        new_events_number / 2
     ]
).


factorial(0, 1).
factorial(N, F) :- 
    N > 0, 
    M is N - 1, 
    factorial(M,T), 
    F is N * T.

poisson(Lambda, X, Y):-
%  (Lambda^X * exp(-Lambda)) / X!
    factorial(X, XF),
    LX is Lambda ** X,
    EL is exp(-Lambda),
    Y is (LX*EL) / XF.
  

new_events_number2(Events, _, S, X, Events2):-
    S>X,
    Events2 is Events -1.

new_events_number2(N, Lambda, S, X, Events):-
    poisson(Lambda, N, X2),
    S2 is S+X2,
    N2 is N+1,
    new_events_number2(N2, Lambda, S2, X, Events).
                     
new_events_number(Lambda, Events):-
    random(0.0, 1.0, X),
    new_events_number2(0, Lambda, 0, X, Events).


get_discount(Mean, Discount):-
% should be something like log normal distribution
    random(0, Mean, Discount).



g(_, 0).

g(L, X):-
    new_event_number(L, N),
    writeln(N),
    X2 is X-1,
    g(L, X2).


