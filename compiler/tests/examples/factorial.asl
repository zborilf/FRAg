!print_fact(5).
+!print_fact(N)<-!fact(N,F);.print("Factorial of ",N," is ",F).
+!fact(N,1):N==0.
+!fact(N,F):N>0<-!fact(N-1,F1);F=F1*N.
