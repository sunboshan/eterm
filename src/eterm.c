#include <stdio.h>
#include <erl_nif.h>

ERL_NIF_TERM format(ErlNifEnv *env, ERL_NIF_TERM term)
{
	char address[19];
	sprintf(address, "0x%0.16lx", term);
	return enif_make_string(env, address, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM parse(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	if (!(argv[0] & 2)) {
		/* list */
		ERL_NIF_TERM tag = enif_make_atom(env, "list");
		ERL_NIF_TERM handle = format(env, (ERL_NIF_TERM)argv[0]);
		ERL_NIF_TERM *objp = (ERL_NIF_TERM *)(argv[0] - 1);
		ERL_NIF_TERM car_k = format(env, (ERL_NIF_TERM)&objp[0]);
		ERL_NIF_TERM car_v = format(env, (ERL_NIF_TERM)objp[0]);
		ERL_NIF_TERM car = enif_make_tuple2(env, car_k, car_v);
		ERL_NIF_TERM cdr_k = format(env, (ERL_NIF_TERM)&objp[1]);
		ERL_NIF_TERM cdr_v = format(env, (ERL_NIF_TERM)objp[1]);
		ERL_NIF_TERM cdr = enif_make_tuple2(env, cdr_k, cdr_v);
		return enif_make_tuple4(env, tag, handle, car, cdr);
	} else if (!(argv[0] & 1)) {
		/* boxed */
		ERL_NIF_TERM tag = enif_make_atom(env, "boxed");
		ERL_NIF_TERM handle = format(env, (ERL_NIF_TERM)argv[0]);
		ERL_NIF_TERM *objp = (ERL_NIF_TERM *)(argv[0] - 2);
		ERL_NIF_TERM header_k = format(env, (ERL_NIF_TERM)&objp[0]);
		ERL_NIF_TERM header_v = format(env, (ERL_NIF_TERM)objp[0]);
		ERL_NIF_TERM header = enif_make_tuple2(env, header_k, header_v);
		int arity = objp[0] >> 6;
		ERL_NIF_TERM *ary = (ERL_NIF_TERM *)malloc(arity * sizeof(ERL_NIF_TERM));
		for(int i = 0; i < arity; i++) {
			ERL_NIF_TERM key = format(env, (ERL_NIF_TERM)&objp[i + 1]);
			ERL_NIF_TERM val = format(env, (ERL_NIF_TERM)objp[i + 1]);
			ary[i] = enif_make_tuple2(env, key, val);
		}
		ERL_NIF_TERM body = enif_make_list_from_array(env, ary, arity);
		free(ary);
		return enif_make_tuple4(env, tag, handle, header, body);
	} else {
		/* immediate */
		ERL_NIF_TERM tag = enif_make_atom(env, "immediate");
		ERL_NIF_TERM handle = format(env, (ERL_NIF_TERM)argv[0]);
		return enif_make_tuple2(env, tag, handle);
	}
}

static ErlNifFunc nif_funcs[] =
{
	{"parse", 1, parse}
};

ERL_NIF_INIT(Elixir.ETerm, nif_funcs, NULL, NULL, NULL, NULL)
