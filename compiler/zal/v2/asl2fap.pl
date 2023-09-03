




check_char(Stream,' ',Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).
check_char(Stream,'\n',Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).
check_char(Stream,Ch,Ch).
		
next_char(Stream,Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).

lx_is_alpha_spec(Char):-
			char_type(Char,alpha).

lx_is_alpha_spec('_').

lx_is_var_start(Char):-
			char_type(Char,upper).

lx_is_var_start('_').



lx_getAtom(Stream, Char, Char_next, Atom2):-
			lx_is_alpha_spec(Char),
			get_char(Stream,Char2),
			lx_getAtom(Stream, Char2, Char_next,Atom),
			concat(Char,Atom,Atom2).

lx_getAtom(_, Char, Char, "").

lx_get_number2(Stream,Char,Char_next2,Number2):-
			char_type(Char,digit(N)),
			next_char(Stream,Char_next),
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(Char,Number,Number2).

lx_get_number2(_, Char, Char, "").

lx_get_number(Stream,Char,Char_next2,Number2):-
			char_type(Char,digit(N)),
			next_char(Stream,Char_next),
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(Char,Number,Number2).

lx_get_number(Stream, '.', Char_next2, Number2):-
			next_char(Stream,Char_next),
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(".",Number,Number2).

lx_get_number(_, Char, Char, "").

lexem(Stream,'(',lxm_left_bracket,Char_next,'('):-
			next_char(Stream,Char_next).

lexem(Stream,')',lxm_right_bracket,Char_next,')'):-
			next_char(Stream,Char_next).

lexem(Stream,'.',lxm_dot,Char_next,'.'):-
			next_char(Stream,Char_next).

lexem(Stream,',',lxm_comma,Char_next,','):-
			next_char(Stream,Char_next).

lexem(Stream,'+',lxm_plus,Char_next,'+'):-
			next_char(Stream,Char_next).

lexem(Stream,'-',lxm_minus,Char_next,'-'):-
			next_char(Stream,Char_next).

lexem(Stream,'!',lxm_exclam,Char_next,'!'):-
			next_char(Stream,Char_next).

lexem(Stream,'?',lxm_question,Char_next,'?'):-
			next_char(Stream,Char_next).

lexem(Stream,'<',lxm_gt,Char_next,'<'):-
			next_char(Stream,Char_next).

lexem(Stream,'>',lxm_lt,Char_next,'>'):-
			next_char(Stream,Char_next).

lexem(Stream,'=',lxm_eq,Char_next,'='):-
			next_char(Stream,Char_next).

lexem(Stream,':',lxm_colon,Char_next,':'):-
			next_char(Stream,Char_next).

lexem(Stream,'&',lxm_ampersand,Char_next,'&'):-
			next_char(Stream,Char_next).

lexem(Stream,';',lxm_semicolon,Char_next,'&'):-
			next_char(Stream,Char_next).


lexem(Stream,end_of_file,lxm_end,null,null).

lexem(Stream,Char,lxm_atom,Char_next,Atom):-
			char_type(Char,lower),
			lx_getAtom(Stream,Char,Char_next,Atom).
%			writeln(Atom).

lexem(Stream,Char,lxm_variable,Char_next,Atom):-
			lx_is_var_start(Char),
			lx_getAtom(Stream,Char,Char_next,Atom).
%			writeln(Atom).

lexem(Stream,Char,lxm_number,Char_next,Number):-
			char_type(Char,digit(_)),
			lx_get_number(Stream,Char,Char_next,Number).
%			writeln(Number).                            


lexem(Stream,Ch,lxm_other,Char_next,''):-
                        next_char(Stream,Char_next).



% process2(Stream,lxm_end,Char).
%
% process2(Stream,Lexem,Char):-
%			writeln(Lexem),
%			lexem(Stream,Char,Lexem2,Char_next),
%			process2(Stream,Lexem2,Char_next).	
% 
% process(Stream):-
%			check_char(Stream,' ',Ch),
%			lexem(Stream,Ch,Lexem,Char_next),
%			process2(Stream,Lexem,Char_next).


/*
	S -> ATOMIC_FORMULA S
	S -> '!' ATOMIC FORMULA S
	S -> TRIGGERING_EVENG ':'
	S -> e
	ATOMIC_FORMULA -> 'ATOM' TERMS '.' S
	TERMS -> e
	TERMS -> '(' TERMS2
	TERMS2 -> 'TERM' TERMCONT
	TERMCONT-> ')'
	TERMCONT -> ',' TRERMS2
*/

nt_TERMCONT(Stream,Char,lxm_right_bracket,_,Char):-
			format(")").
			
nt_TERMCONT(Stream,Char,lxm_comma,_,Char_next):-
			format(","),
			lexem(Stream,Char,Lexem,Char2,Val),
        		nt_TERMS2(Stream,Char2,Lexem,Val,Char_next).



nt_TERMS2(Stream,Char,lxm_atom,Val,Char_next):-
			format("~w",[Val]),
			lexem(Stream,Char,Lexem,Char2,Val2),
        		nt_TERMCONT(Stream,Char2,Lexem,Val2,Char_next).

nt_TERMS2(Stream,Char,lxm_variable,Val,Char_next):-
			format("~w",[Val]),
			lexem(Stream,Char,Lexem,Char2,Val2),
        		nt_TERMCONT(Stream,Char2,Lexem,Val2,Char_next).

nt_TERMS2(Stream,Char,lxm_number,Val,Char_next):-
			format("~w",[Val]),
			lexem(Stream,Char,Lexem,Char2,Val2),
        		nt_TERMCONT(Stream,Char2,Lexem,Val2,Char_next).


nt_TERMS(Stream,Char,lxm_left_bracket,_,Char3):-
			format("("),
			lexem(Stream,Char,Lexem,Char2,Val2),
        		nt_TERMS2(Stream,Char2,Lexem,Val2,Char3).

nt_TERMS(Stream,Char,lxm_dot,Val,Char):-writeln(atomicke).	

                        
nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char_out):-
			format("~w",[Val_in]),
			lexem(Stream,Char,Lexem,Char2,Val),          % tohle at si udela az nt_TERMS, pokud jsou argumenty pro AF, bez argumentu to nedela.
       			nt_TERMS(Stream,Char2,Lexem,Val,Char_out),
			format("AF skoncilo, Char_out je ~w~n",[Char_out]).

nt_ATOMIC_FORMULA(Stream,Char,Lexem,Val,Char):-
			format("~w",[Val]).


nt_TRIGGERING2(Stream,Char,lxm_exclam,Val_in,Char_out):-
			format("ach,"),
			lexem(Stream,Char,Lexem,Char2,Val),
			nt_ATOMIC_FORMULA(Stream,Char2,Lexem,Val,Char_out).	

nt_TRIGGERING2(Stream,Char,lxm_atom,Val_in,Char_out):-
                        format("add ,"),
			nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char_out). 		


nt_TRIGGERIN(Stream,Char,_,Val_in,Char_out):-
			lexem(Stream,Char,Lexem,Char2,Val),
	%		concat(Val_in,Val,Val2),
			nt_TRIGGERING2(Stream,Char2,Lexem,Val,Char_out).

/*
	Plan body
	---------
	PB -> '.' PBACT_INTERNAL
        PB -> '+' PBADD
	PB -> '-' PBDELETE
	PB -> '!' PBACHIEVE
	PB -> '?' PBTEST
	PB -> 'ATOM' PBACT_PROLOG(ATOM.Name)
	PB -> 'VAR' PBEXPRES(VAR.Name)
	PB -> 'NUMBER' PBEXPRES(NUMBER.Value)
*/

pb_copy_action(Stream,';',';').
pb_copy_action(Stream,'.','.').
pb_copy_action(Stream,Char,Char_out):-
                                format("~w",Char),
                                next_char(Stream,Char2),
				pb_copy_action(Stream,Char2,Char_out).


nt_PB_CONT(Stream,'.',Char_out):-
				lexem(Stream,'.',Lexem,Char_out,Value).

nt_PB_CONT(Stream,';',Char_out):-
				lexem(Stream,';',Lexem,Char,Value),
				lexem(Stream,Char,Lexem2,Char2,Value2),
				format(','),
				nt_PB(Stream,Char2,Lexem2,Value2,Char_out).


nt_PB(Stream,Char,lxm_dot,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("act(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB(Stream,Char,lxm_plus,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("add(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB(Stream,Char,lxm_minus,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("del(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB(Stream,Char,lxm_exclam,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("ach(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB(Stream,Char,lxm_question,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("test(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

/*
nt_PBACHIEVE():-

nt_PBTEST():-

nt_PBACT_PROLOG():-

nt_PBEXPRES():-

nt_PBEXPRES():-
*/

nt_ACTS(Stream,Char,lxm_dot,Value,Char).	% Konec tela planu, narazili jsme na tecku

nt_ACTS(Stream,Char,Lexem,Value,Char):-
                        nt_PB(Stream,Char,Lexem,Value,Char2).
	

%% CONDITIONS , (just simple_log_expr) 
%% simple_log_expr literal (atomic formula) nebo rel_expr s 

			
%  GUARDS -> : GUARD*
% nt_GUARDS2 strazce zkopiruje, jen & nahradi ,

nt_GUARDS3(Stream,'-'):-
			format('],').

nt_GUARDS3(Stream,Ch):-
                    	format('<~w',[Ch]),
			next_char(Stream,Ch2),
			nt_GUARDS2(Stream,Ch2).

nt_GUARDS2(Stream,'<'):-
			next_char(Stream,Ch),
			nt_GUARDS3(Stream,Ch).


nt_GUARDS2(Stream,'&'):-
			format(','),
			next_char(Stream,Ch),
			nt_GUARDS2(Stream,Ch).

nt_GUARDS2(Stream,Ch):-
			format('~w',[Ch]),
			next_char(Stream,Ch2),
			nt_GUARDS2(Stream,Ch2).



nt_GUARDS(Stream,Char,lxm_colon,Val_in,Char_out):-
			format(',['),
			nt_GUARDS2(Stream,Char),
			next_char(Stream,Char_out).


nt_S(Stream,Char,lxm_plus,Val_in,Char_out):-
                        format("plan("),
			nt_TRIGGERIN(Stream,Char,lxm_plus,Val_in,Char2),
			lexem(Stream,Char2,Lexem2,Char3,Val2),
			nt_GUARDS(Stream,Char3,Lexem2,Val2,Char4),
			lexem(Stream,Char4,Lexem3,Char5,Val3),
			format('['),
			nt_PB(Stream,Char5,Lexem3,Val3,Char6),
			format(']).~n'),
			lexem(Stream,Char6,Lexem4,Char7,Val4),
			nt_S(Stream,Char7,Lexem4,Val4,Char_out).
			
nt_S(Stream,Char,lxm_minus,Val_in,Char_out):-
                        format("plan("),
			nt_TRIGGERIN(Strean,Char,Lexem,Val_in,Char_out), % TODO dodelat
			lexem(Stream,Char,lxm_colon,Char2,_). 

nt_S(Stream,Char,lxm_atom,Val_in,Char_out):-
			format("fact("),
			nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char2),
			lexem(Stream,Char2,lxm_dot,Char3,Val2),
			format(").~n"),
			lexem(Stream,Char3,Lexem,Char4,Val3),
			nt_S(Stream,Char4,Lexem,Val3,Char_out).


nt_S(Stream,Char,lxm_exclam,Val_in,Char_out):-
			format("goal(ach,"),
			lexem(Stream,Char,Lexem,Char2,Val2),
			nt_ATOMIC_FORMULA(Stream,Char2,Lexem,Val2,Char3),
			lexem(Stream,Char3,lxm_dot,Char4,Val3),
			format(",null,[[]],active).~n"),
			lexem(Stream,Char4,Lexem2,Char5,Val4),
			nt_S(Stream,Char5,Lexem2,Val4,Char_out).

nt_S(_,_,lxm_end,_,_).


			

compile(FILENAME):-
			open(FILENAME,read,Stream,[]),
			check_char(Stream,' ',Char),
			lexem(Stream,Char,Lexem,Char_next,Val),
			nt_S(Stream,Char_next,Lexem,Val,_),
			close(Stream).





