
:-module(frag_compiler,[
			frag_compile / 1
			]
	).

%
%	asl -> fap
%

check_char(Stream,' ',Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).
check_char(Stream,'\n',Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).
check_char(Stream,'\t',Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).


check_char(Stream,Ch,Ch).
		

next_char(Stream,Ch2):-
			get_char(Stream,Ch),
			check_char(Stream,Ch,Ch2).

lx_is_alpha_spec(Char):-
			char_type(Char,alnum).

lx_is_alpha_spec('_').

lx_is_var_start(Char):-
			char_type(Char,upper).

lx_is_var_start('_').



lx_getAtom(Stream, Char, Char_next, Atom2):-
			lx_is_alpha_spec(Char),
			get_char(Stream,Char2),			% bylo next_char
			lx_getAtom(Stream, Char2, Char_next,Atom),
			concat(Char,Atom,Atom2).

lx_getAtom(Stream, Char, Char2, ""):-
			check_char(Stream,Char,Char2).
			

lx_get_number2(Stream,Char,Char_next2,Number2):-
			char_type(Char,digit(N)),
			get_char(Stream,Char_next),		% bylo next_char
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(Char,Number,Number2).

lx_get_number2(Stream, Char, Char2, ""):-
			check_char(Stream,Char,Char2).
			

lx_get_number2(_, Char, Char, "").

lx_get_number(Stream,Char,Char_next2,Number2):-
			char_type(Char,digit(N)),
			get_char(Stream,Char_next),            % bylo next_char
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(Char,Number,Number2).

lx_get_number(Stream, '.', Char_next2, Number2):-
			get_char(Stream,Char_next),           % bylo next_char
			lx_get_number(Stream,Char_next,Char_next2,Number),
			concat(".",Number,Number2).

lx_get_number(_, Char, Char, "").

lx_get_number(Stream, Char, Char2, ""):-
			check_char(Stream,Char,Char2).
		

lexem(Stream,'(',lxm_left_bracket,Char_next,'('):-
			next_char(Stream,Char_next).

lexem(Stream,')',lxm_right_bracket,Char_next,')'):-
			next_char(Stream,Char_next).

lexem(Stream,'{',lxm_left_cbracket,Char_next,'{'):-
			next_char(Stream,Char_next).

lexem(Stream,'}',lxm_right_cbracket,Char_next,'}'):-
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

lexem(Stream,'@',lxm_at,Char_next,'@'):-
			next_char(Stream,Char_next).

lexem(Stream,'#',lxm_hash,Char_next,'#'):-
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




translate_action('println','writeln').
translate_action(A,A).



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



nt_TERMS(Stream,'(',_,_,Char_out):-
			format("("),
			lexem(Stream,'(',_,Char2,_),
			lexem(Stream,Char2,Lexem,Char3,Val),
        		nt_TERMS2(Stream,Char3,Lexem,Val,Char_out).

nt_TERMS(Stream,'.',_,_,'.').	

nt_TERMS(Stream,'<',_,_,'<').	   	% when +!plan<-

nt_TERMS(Stream,':',_,_,':').		% when +!plan:conds<-


%nt_TERMS(Stream,Char,lxm_left_bracket,_,Char3):-
%			format("("),
%			lexem(Stream,Char,Lexem,Char2,Val2),
%        		nt_TERMS2(Stream,Char2,Lexem,Val2,Char3).
%
%nt_TERMS(Stream,Char,lxm_dot,Val,Char):-writeln(atomicke).	

                        
nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char_out):-
			format("~w",[Val_in]),
%			lexem(Stream,Char,Lexem,Char2,Val),          % tohle at si udela az nt_TERMS, pokud jsou argumenty pro AF, bez argumentu to nedela.
      			nt_TERMS(Stream,Char,_,Val,Char_out).
%			format("~nAF skoncilo, Char_out je ~w~n",[Char_out]).

%			lexem(Stream,Char,Lexem,Char2,Val),          % tohle at si udela az nt_TERMS, pokud jsou argumenty pro AF, bez argumentu to nedela.
%      			nt_TERMS(Stream,Char2,Lexem,Val,Char_out),
%			format("AF skoncilo, Char_out je ~w~n",[Char_out]).

nt_ATOMIC_FORMULA(Stream,Char,Lexem,Val,Char):-
			format("~w",[Val]).

nt_TRIGGERING2(Stream,Char,lxm_exclam,Val_in,Char_out):-
			format("ach,"),
			lexem(Stream,Char,Lexem,Char2,Val),
			nt_ATOMIC_FORMULA(Stream,Char2,Lexem,Val,Char_out).	

nt_TRIGGERING2(Stream,Char,lxm_atom,Val_in,Char_out):-
                        format("add ,"),
			nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char_out). 		


nt_TRIGGERING(Stream,Char,_,Val_in,Char_out):-
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
                                get_char(Stream,Char2),
				pb_copy_action(Stream,Char2,Char_out).


nt_PB_CONT(Stream,'.',Char_out):-
				lexem(Stream,'.',Lexem,Char_out,Value).

nt_PB_CONT(Stream,';',Char_out):-
				lexem(Stream,';',Lexem,Char,Value),
				lexem(Stream,Char,Lexem2,Char2,Value2),
				format(','),
				nt_PB2(Stream,Char2,Lexem2,Value2,Char_out).

nt_PB2(Stream,Char,lxm_variable,Value,Char_out):-
		%		lexem(Stream,Char,Lexem,Char2,Value2),
				format("act(~w ",[Value]),				
				pb_copy_action(Stream,Char,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).


nt_PB2(Stream,Char,lxm_dot,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				translate_action(Value2,ValueAction),
				format("act(~w",[ValueAction]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB2(Stream,Char,lxm_plus,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("add(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB2(Stream,Char,lxm_minus,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("del(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB2(Stream,Char,lxm_exclam,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("ach(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB2(Stream,Char,lxm_question,Value,Char_out):-
				lexem(Stream,Char,Lexem,Char2,Value2),
				format("test(~w",[Value2]),				
				pb_copy_action(Stream,Char2,Char3),
				format(")"),
				nt_PB_CONT(Stream,Char3,Char_out).

nt_PB(Stream,Char,lxm_dot,_,Char).
                                
nt_PB(Stream,'.',_,_,Char_out):-        % Plan nema telo planu / prvnim znakem je '.'

				next_char(Stream,Char_out).

nt_PB(Stream,'-',_,_,Char_out):-        % Plan ma asi telo, zatim mame '<' a jeste musime sosnout '-'
               			lexem(Stream,'-',_,Char2,Val),
               			lexem(Stream,Char2,Lexem2,Char3,Val2),
				nt_PB2(Stream,Char3,Lexem2,Val2,Char_out).



nt_ACTS(Stream,Char,lxm_dot,Value,Char).	% Konec tela planu, narazili jsme na tecku

nt_ACTS(Stream,Char,Lexem,Value,Char):-
                        nt_PB(Stream,Char,Lexem,Value,Char2).
	

%% CONDITIONS , (just simple_log_expr) 
%% simple_log_expr literal (atomic formula) or rel_expr s 

			
%  GUARDS -> : GUARD*
%  nt_GUARDS2 strazce zkopiruje, jen & nahradi ,

nt_GUARDS3(Stream,'-',Lexem,'-'):-
			format('],').        % guards ended, found <-
			
nt_GUARDS3(Stream,Ch,Lexem,Char_out):-
                    	format('<~w',[Ch]),          % just the < symbol
			next_char(Stream,Ch2),
			nt_GUARDS2(Stream,Ch2,Lexem,Char_out).

nt_GUARDS2(Stream,'.',_,'.'):-
			format('],').		% guardi skoncili a neni zadne plan body
			
nt_GUARDS2(Stream,'<',Lexem,Char_out):-
			next_char(Stream,Ch),
			nt_GUARDS3(Stream,Ch,Lexem,Char_out).


nt_GUARDS2(Stream,'&',Lexem,Char_out):-
			format(','),
			next_char(Stream,Ch),
			nt_GUARDS2(Stream,Ch,Lexem,Char_out).

nt_GUARDS2(Stream,Ch,Lexem,Char_out):-
			format('~w',[Ch]),
			next_char(Stream,Ch2),
			nt_GUARDS2(Stream,Ch2,Lexem,Char_out).



nt_GUARDS(Stream,Char,lxm_colon,Val_in,Char_out):-
			format(',['),
			nt_GUARDS2(Stream,Char,_,Char_out).
			
nt_GUARDS(Stream,Char,lxm_gt,Val_in,Char):-
			format(',[],').

nt_GUARDS(Stream,Char,lxm_dot,Val_in,Char):-
			format(',[],').               % neni zadne plan body ani zadni guardi


%
%  S -> '+' { print( 'plan(' ) } TRIGGERING GUARDS { print( '[' ) }  PB { print( ']).' ) } S
%  S -> '-' { print( 'plan(' ) } TRIGGERING GUARDS PB S
%  S -> '@' $label S	// vyignoruje label, jinak by mel byt nejaky print
%  S -> $predicate_symbol { print( 'fact(' ) ) } ATOMIC_FORMULA { print ').' ) } S // belief
%  S -> '!' { print( 'goal(ach,' ) } ATOMIC FORMULA { print( ',null,[[]],active).' ) } S
%  S -> e
%

			
nt_S(Stream,Char,lxm_plus,Val_in,Char_out):-
                        format("plan("),
			nt_TRIGGERING(Stream,Char,lxm_plus,Val_in,Char2),
			lexem(Stream,Char2,Lexem2,Char3,Val2),
			nt_GUARDS(Stream,Char3,Lexem2,Val2,Char4),  % Lexem/Val : nebo . , Char3 nasledujici za : nebo .
			format('['),
			nt_PB(Stream,Char4,Lexem2,Val2,Char5),      % Lexem zatim nic, Char4 je bud '.', pak konec, nebo '-', jedeme dal
			format(']).~n'),
			lexem(Stream,Char5,Lexem3,Char6,Val4),
			nt_S(Stream,Char6,Lexem3,Val4,Char_out).
			

nt_S(Stream,Char,lxm_minus,Val_in,Char_out):-
                        format("plan(",[Val_in]),
			nt_TRIGGERING(Strean,Char,Lexem,Val_in,Char_out), % TODO dodelat
			lexem(Stream,Char,lxm_colon,Char2,_). 

nt_S(Stream,Char,lxm_at,Val_in,Char_out):-
			lexem(Stream,Char,_,Char2,Name),
			lexem(Stream,Char2,Lexem,Char3,_),
			nt_S(Stream,Char3,Lexem,Name,Char_out).



nt_S(Stream,Char,lxm_atom,Val_in,Char_out):-
			format("fact("),
			nt_ATOMIC_FORMULA(Stream,Char,lxm_atom,Val_in,Char2),
			lexem(Stream,Char2,lxm_dot,Char3,Val2),
			format(").~n"),
			lexem(Stream,Char3,Lexem,Char4,Val3),
			nt_S(Stream,Char4,Lexem,Val3,Char_out).


nt_S(Stream,Char,lxm_exclam,Val_in,Char_out):-
%			format("goal(ach,"),
			format("goal("),
			lexem(Stream,Char,Lexem,Char2,Val2),
			nt_ATOMIC_FORMULA(Stream,Char2,Lexem,Val2,Char3),
			lexem(Stream,Char3,lxm_dot,Char4,Val3),
			format(").~n"),
%			format(",null,[[]],active).~n"),
			lexem(Stream,Char4,Lexem2,Char5,Val4),
			nt_S(Stream,Char5,Lexem2,Val4,Char_out).

nt_S(_,_,lxm_end,_,_).


			

compile(INFILE,OUTFILE):-
			tell(OUTFILE),
			open(INFILE,read,Stream,[]),
			
			check_char(Stream,' ',Char),
			lexem(Stream,Char,Lexem,Char_next,Val),
			nt_S(Stream,Char_next,Lexem,Val,_),
			close(Stream),
			told.



compile_agent(FILENAME):-
			format(atom(FI),"~w.asl",[FILENAME]),
			format(atom(FO),"~w.fap",[FILENAME]),
			compile(FI,FO).

compile_agents([]).

compile_agents([AGENT|AGENTS]):-
		   	compile_agent(AGENT),
			compile_agents(AGENTS).

%
%	mas2j -> mas2fp		prelozi vsechny prislusne asl soubory a vytvori seznam tak, jak jej potrebujeme
%


%
% MAS <mas_name> {
%                    agents: 
%			<ag1_name> [<#count1>];
%			<ag2_name> [<#count2>];
%			...
%		}
%
% compiles to ->
%
% load(ag1_name,ag1_name.fap,number1).
% load(ag2_name,ag2_name.fap,number2).
% ...
%


%
%	Grammar: 
%
%	MAS -> 'MAS' $name  (  MPARAMS
%	MPARAMS -> $agentName AGENTS<$agentName>
%	MPARAMS -> '}'
%	NAME<$agentName> -> { print( 'load($agentName,$agentName.fap,1)' ) } ';' MPARAMS 
%       NAME<$agentName> -> '#' $number { print( 'load($agentName,$agentName.fap,$number)' ) } ';' MPARAMS
%

nt_AGENTS(Stream,';',lxm_atom,Val,Char_out,[Val|Agents]):-
			format("load(\"~w\",\"~w.fap\",1).~n",[Val,Val]),
                        lexem(Stream,';',lxm_semicolon,Char2,Val2),          	% reads the semicolon from the tape
	%		lexem(Stream,Char2,Lexem,Char3,Val3),
			nt_MPARAMS(Stream,Char2,Lexem,Val3,Char_out,Agents).     % toto funguje? nemelo by to jit zpet n nt_PARAMS???
			
nt_AGENTS(Stream,'#',lxm_atom,Val,Char_out,[Val|Agents]):-
			lexem(Stream,'#',lxm_hash,Char2,Val2),
			lexem(Stream,Char2,lxm_number,Char3,Val3),
			format("load(\"~w\",\"~w.fap\",~w).~n",[Val,Val,Val3]),
                        lexem(Stream,Char3,lxm_semicolon,Char4,Val4),
	%		lexem(Stream,Char4,Lexem,Char5,Val5),
			nt_MPARAMS(Stream,Char4,Lexem,Val6,Char_out,Agents).
			

nt_MPARAMS(Stream,'}',lxm_right_cbracket,Val,Char,[]).


nt_MPARAMS(Stream,Char,lxm_atom,'agents',Char_out,Agents):-                      % agent / file name (is the same in this case)
			lexem(Stream,Char,lxm_atom,Char2,Val),
			nt_AGENTS(Stream,Char2,lxm_atom,Val,Char3,Agents),	 
			lexem(Stream,Char3,Lexem,Char_out,Val4). 		 % next after semicolon



nt_MPARAMS(Stream,Char,lxm_right_cbracket,_,Char).


nt_MAS(Stream,Char,Lexem,Val,Char_out,Agents):-
			lexem(Stream,Char,lxm_variable,Char2,'MAS'),
                        lexem(Stream,Char2,lxm_atom,Char3,Val2),
			lexem(Stream,Char3,lxm_left_cbracket,Char4,Val3),
			lexem(Stream,Char4,Lexem2,Char5,Val4),                 % reads the next lexem on the tape for the following non-terminal
			nt_MPARAMS(Stream,Char5,Lexem2,Val4,Char_out,Agents).
			
%
%	Main rule
%

frag_compile(FILENAME):-
			format(atom(FM),"~w.mas2j",[FILENAME]),
			open(FM,read,Stream,[]),
			format(atom(FO),"~w.mas2fp",[FILENAME]),
			tell(FO),
			next_char(Stream,Char),
			nt_MAS(Stream,Char,Lexem,Val,Char2,Agents),
			compile_agents(Agents),
			told.







