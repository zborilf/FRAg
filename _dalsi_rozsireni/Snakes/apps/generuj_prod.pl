

cont(N,N,_,_):-format(".~n",[]).
cont(FROM,TO,CN,TN):-format(";~n",[]),gencust(FROM,TO,CN,TN).

gencust(N,N,_,_).

gencust(FROM,TO,CN,TN):-random(1,CN,CUSTOMERN),
			random(1,TN,TASKN),
			format(".send(producent,achieve,task(~w,c~w))",[TASKN,CUSTOMERN]),
			FROM2 is FROM+1,
			cont(FROM2,TO,CN,TN).
			
		


goc(FROM,TO,CN,TN):-     format(atom(FN),"customer.asl",[]),
			tell(FN),
			format("!do.~n+!do<-~n",[]),
			gencust(FROM,TO,CN,TN),
			told.



%
%	producent
%

pp:-

format("~n+!task(T,CS) : method(T,m1)                                         ~n"),
format("		<- 	                                            ~n"),
format("			?manual(m1,MN);read(MN);                    ~n"),
format("			?resource(m1,R);resource(m1,R);             ~n"),
format("			prepare(R);read(MN);?process(M,C);do(C,R);  ~n"),
format("			?transport(CS,TR);deliver(T,TR).            ~n~n"),

format("+!task(T,CS) : method(T,m2)                                                        ~n"),
format("		<- 	                                                           ~n"),
format("			do(prepare);?manual(m2,MN);read(MN);do(prepare);           ~n"),
format("			?resource(m2,R);resource(m2,R);                            ~n"),
format("			?process(m2,C);do(prepare);do(C,R);do(prepare);do(C,R);    ~n"),
format("			?transport(CS,TR);deliver(T,TR).                           ~n~n"),

format("+!task(T,CS) : method(T,m3)                                                         ~n"),
format("		<- 	                                                            ~n"),
format("			?manual(m3,MN);read(MN);do(prepare);                        ~n"),
format("			?resource(m3,R);resource(m3,R);                             ~n"),
format("			?process(m3,C);do(prepare);do(C,R);                         ~n"),
format("			?transport(CS,TR);deliver(T,TR).                            ~n~n"),

format("+!task(T,CS) : method(T,m4)                                        	 	~n"),
format("		<- 	                                       		 	~n"),
format("			do(prepare);?manual(m4,MN);read(MN);			~n"),
format("			?resource(m4,R);resource(T,R);do(prepare);		~n"),
format("			?process(m4,C);do(C,R);resource(M,R);do(prepare);do(C,R);~n"),
format("			?transport(CS,TR);deliver(T,TR).~n").




customer2transport(M2MP,CN,CN,T,T).
customer2transport(M2MP,CN,CN,T,TN):-T2 is T+1, customer2transport(M2MP,1,CN,T2,TN).
customer2transport(M2MP,C,CN,T,TN):-
			random(1,100,RND),customer2transport(M2MP,C,CN,T,TN,RND).
customer2transport(M2MP,C,CN,T,TN,RND):-
			M2MP<RND, C2 is C+1, customer2transport(M2MP,C2,CN,T,TN). 			
customer2transport(M2MP,C,CN,T,TN,RND):-
			format("transport(c~w,t~w).~n",[C,T]),C2 is C+1, customer2transport(M2MP,C2,CN,T,TN).



method2process(M2MP,5,PN,PN).
method2process(M2MP,5,P,PN):-P2 is P+1, method2process(M2MP,1,P2,PN).
method2process(M2MP,M,P,PN):-
			random(1,100,RND),method2process(M2MP,M,P,PN,RND).
method2process(M2MP,M,P,PN,RND):-
			M2MP<RND,M2 is M+1, method2process(M2MP,M2,P,PN). 			
method2process(M2MP,M,P,PN,RND):-
			format("process(m~w,p~w).~n",[M,P]),M2 is M+1, method2process(M2MP,M2,P,PN).



method2resource(M2MP,5,UG,UG).
method2resource(M2MP,5,UG,UGN):-UG2 is UG+1, method2resource(M2MP,1,UG2,UGN).
method2resource(M2MP,M,UG,UGN):-
			random(1,100,RND),method2resource(M2MP,M,UG,UGN,RND).
method2resource(M2MP,M,UG,UGN,RND):-
			M2MP<RND,M2 is M+1, method2resource(M2MP,M2,UG,UGN). 			
method2resource(M2MP,M,UG,UGN,RND):-
			format("resource(m~w,r~w).~n",[M,UG]),M2 is M+1, method2resource(M2MP,M2,UG,UGN).



method2manual(M2MP,5,UG,UG).
method2manual(M2MP,5,UG,UGN):-UG2 is UG+1, method2manual(M2MP,1,UG2,UGN).
method2manual(M2MP,M,UG,UGN):-
			random(1,100,RND),method2manual(M2MP,M,UG,UGN,RND).
method2manual(M2MP,M,UG,UGN,RND):-
			M2MP<RND,M2 is M+1, method2manual(M2MP,M2,UG,UGN). 			
method2manual(M2MP,M,UG,UGN,RND):-
			format("manual(m~w,ug~w).~n",[M,UG]),M2 is M+1, method2manual(M2MP,M2,UG,UGN).

task2method(_,T,T,5).
task2method(T2MP,T,TN2,5):-T2 is T+1, task2method(T2MP,T2,TN2,1).
task2method(T2MP,T,TN2,M):-
			random(1,100,RND),task2method(T2MP,T,TN2,M,RND).
task2method(T2MP,T,TN2,M,RND):-T2MP<RND,M2 is M+1, task2method(T2MP,T,TN2,M2).
task2method(T2MP,T,TN2,M,RND):-format("method(~w,m~w).~n",[T,M]),M2 is M+1, task2method(T2MP,T,TN2,M2).

gop(TASK2METHODP,TN,METHOD2MANUALP,MN,METHOD2RESOURCEP,RS,METHOD2PROCESSP,PR,CUSTOMER2TRANSPORTP,CS,TR)
			:-    	format(atom(FN),"producent.asl",[]),
				tell(FN),
				task2method(TASK2METHODP,1,TN,1),!,
				method2manual(METHOD2MANUALP,1,1,MN),!,
				method2resource(METHOD2RESOURCEP,1,1,RS),!,
				method2process(METHOD2PROCESSP,1,1,PR),!,
				customer2transport(CUSTOMER2TRANSPORTP,1,CS,1,TR),
				pp,
				told.

