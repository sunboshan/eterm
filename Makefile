ERL_INCLUDE_PATH=/usr/local/Cellar/erlang/20.1.1/lib/erlang/erts-9.1.1/include

priv/eterm.so : src/eterm.c
	gcc -fPIC -undefined dynamic_lookup -dynamiclib \
		src/eterm.c -o priv/eterm.so -I $(ERL_INCLUDE_PATH)
