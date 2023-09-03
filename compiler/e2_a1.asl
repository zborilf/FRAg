

@f2 +!fact(X,Y):X<5 <- Z is X+1; W is Z* Y; +fact(Z,W).
@f3 +!fact(X,Y):X==5 <- .print("fact 5 ==", Y).


!count.

@start +!count:true<-+fact(0,1).

