/*───────────────────────────────────────────────────────────────────────────
  py2pl.pl  –  Converts the Key-Value pairs Janus gives us into clean Prolog compounds
 ───────────────────────────────────────────────────────────────────────────*/

/* EXAMPLE with seller - py{seller0:cd9-138} -> this is what comes back from python via Janus
normalize_pairs([ seller - py{seller0:cd9-138} ], Terms).
    Key = seller,
    Value = py{seller0:cd9-138},
    Rest = []

normalize_pair(seller, py{seller0:cd9-138}, Fixed) :-
    is_dict(py{seller0:cd9-138}, py), -> success
    atomize(seller, Functor),
    Pairs = [ seller0-(cd9-138) ]
    findall(Term,
        ( member(Name-Data, Pairs),                     -> picks Name = seller0, Data = cd9-138
          atomize(Name, NameAtom),                      -> NameAtom = seller0
          flatten_dash(Data, Flat),                     -> cd9-138 -> [cd9, 138] => Flat = [cd9, 138].
          maplist(normalize_scalar, Flat, ArgsData),    -> ArgsData = [cd9, 138]
          Term =.. [seller, NameAtom | ArgsData]        -> Term =.. [seller, seller0, cd9, 138] => seller(seller0, cd9, 138).

        ),
        Terms
    ).

*/
:- module(py2pl, [normalize_pairs/2]).

/*  normalize_pairs(+Pairs, -Terms)
    Pairs   list of Key-Value pairs (Key-Value) coming from Python environment via Janus prolog library
    Terms   flattened list of Key(…) terms, with all dicts expanded
*/

normalize_pairs([], []) :- !.
normalize_pairs([Key-Value|Rest], Terms) :-
    normalize_pair(Key, Value, Fixed),
    normalize_pairs(Rest, More),
    append(Fixed, More, Terms).

/*──────────────────────── dispatch on Value’s shape ──────────────────────*/

normalize_pair(Key, Val, [Out]) :-  % Returning a list with 1 item
    \+ is_dict(Val),                % If not a dictionary
    scal_or_tuple(Key, Val, Out).   % it is either a scalar or a tuple


% Example seller()
normalize_pair(Key, Dict, Terms) :-
    is_dict(Dict, py),                    % dictionaries have 'py' flag
    atomize(Key, Functor),                % outer functor

    dict_pairs(Dict, py, Pairs),          % Pairs contain pairs of Name-Data from dictionary
    % for example
    /*[ seller123-cd2-27,
        seller456-cd5-10,
        seller999-cd1-42
      ]*/

    findall(Term,
        ( member(Name-Data, Pairs),       % Associates one member of Pairs with Name-Data
          atomize(Name, NameAtom),        % inner key as first arg - in our example "seller123" and converts string to atom
          flatten_dash(Data, Flat),       % split A-B chains
          maplist(normalize_scalar, Flat, ArgsData),
          Term =.. [Functor, NameAtom | ArgsData]
        ),
        Terms).

%──────────────────── convert Key + scalar/tuple into a term
% If Val is a compound whose functor is '-' (and has more than one argument)
% treat it as a “tuple” and turn it directly into Key0(Arg1,Arg2,…)
scal_or_tuple(Key0, Val, Term) :-
    compound(Val),                % Val must be a compound term
    functor(Val, '-', N),         % whose functor is '-'
    N > 1,                        % with arity > 1
    Val =.. [_Minus|Args],        % extract its arguments into the list Args
    atomize(Key0, F),             % convert the Key0 (string or atom) into atom F
    Term =.. [F|Args],            % build F(Arg1,Arg2,…) as the output term
    !.                            % cut: if it matches -> commit


% if Val is A-B, split on the dash (possibly nested)
% if it’s not a dash-term at all, treat it as a plain scalar
scal_or_tuple(Key0, Val, Term) :-
    atomize(Key0, Key),                   % Key must be atom
    ( Val = A-B                           % check if Val matches a dash-pair
    -> ( B = C-D                          % if nested (A-(B-C)), then three parts
       -> maplist(atomize, [A,C,D], As),  % atomize each piece
          Term =.. [Key|As]               % build Key(A,C,D)
       ;  atomize(A, A1),                 % else simple A-B → two parts
          Term =.. [Key, A1, B]           % build Key(A,B)
       )
    ;                                     % if Val is not a dash‐compound at all:
       normalize_scalar(Val, V1),         % convert booleans/strings as needed
       Term =.. [Key, V1]                 % build Key(V1)
    ).

%──────────────────── flatten any A-B or nested A-(B-C) chains
% If Term is not a '-' compound -> wrap it in a singleton list.
flatten_dash(Term, [Term]) :-
    ( \+ compound(Term)             % not a compound at all (atom or number)
    ; functor(Term, F, _), F \= '-' % or a compound whose functor isn’t '-'
    ).

% For a compound, recursivelly flatten
flatten_dash(A-B, Flat) :-
    flatten_dash(A, FA),
    flatten_dash(B, FB),
    append(FA, FB, Flat).


%──────────────────── normalize booleans & strings
% do not touch True/False boolean values
normalize_scalar(true,  true).
normalize_scalar(false, false).

% normalize strings to atoms IF the value is a string (otherwise )
normalize_scalar(Val, Atom) :-
    atomize(Val, Atom).

%──────────────────── coerce strings to atoms
atomize(X, A) :-
    % If we got a string -> Change it to a Term
    % if not, simply return
    ( string(X) -> atom_string(A, X)
    ; A = X ).
