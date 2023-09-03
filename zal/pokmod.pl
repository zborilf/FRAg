

:- module(pokmod, [
		testpokmod /1
		]).         

a(b,2).
b(a,2).

testpokmod(X):-
	a(a,X).

testpokmod(X):-
	b(a,X).
