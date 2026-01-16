

!do_it_a.
precond(a).


+!do_it_a:true<-.println("a solving");!do_it_b;.println("a solved").
+!do_it_a:true.

+!do_it_b:precond(X) & X<3<-.println("b solving");.println("b solved").
+!do_it_c:true<-.println("c solving");+precond(a);.println("c solved").
