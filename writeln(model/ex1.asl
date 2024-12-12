
b(Y).
c(8).
c(a,m).
c(b,n).
c(c,o).
d(b,a,d).
d(a,b,c).

!goF(x).

+!goF(x)<-?d(A,B,C);!goF(C,D);+vysledek(A,B,C,D).

+!goF(A,B)<-?c(A,B);.print(res(A,B)).


