:- use_module(library(janus)), py_import(llm_pok2, []).

t(X):-py_call(llm_pok2:connect_chat(),X).
