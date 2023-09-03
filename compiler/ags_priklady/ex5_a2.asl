value(1)[deadline(120)].
!do_it.
+!do_it:value(X)[deadline(D)]<-.my_name(Y);.println(Y,"...",X);
					-value(X);+value(X+1)[deadline(D)];X<D;!do_it.
