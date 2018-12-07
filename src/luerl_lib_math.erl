%% Copyright (c) 2013 Robert Virding
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

%% File    : luerl_lib_math.erl
%% Author  : Robert Virding
%% Purpose : The math library for Luerl.

-module(luerl_lib_math).

-include("luerl.hrl").

-export([install/1,fmod/2,frexp/2]).

-import(luerl_lib, [lua_error/2,badarg_error/3]).	%Shorten this

%% Use the correct random number module.

-ifdef(NEW_RAND).
-define(RAND_UNIFORM(S), rand:uniform_s(S)).
-define(RAND_UNIFORM(L, S), rand:uniform_s(L, S)).
-define(RAND_SEED(), rand:seed_s(exs1024)).
-define(RAND_SEED(S1,S2,S3), rand:seed_s(exs1024, {S1,S2,S3})).
-else.
-define(RAND_UNIFORM(S), random:uniform_s(S)).
-define(RAND_UNIFORM(L, S), random:uniform_s(L, S)).
-define(RAND_SEED(), random:seed0()).
-define(RAND_SEED(S1,S2,S3),			%Naughty, copied from source
	{(abs(S1) rem (30269-1) + 1),		%PRIME1
	 (abs(S2) rem (30307-1) + 1),		%PRIME2
	 (abs(S3) rem (30323-1) + 1)}).		%PRIME3
-endif.

install(St0) ->
    St1 = St0#luerl{rand=?RAND_SEED()},		%Default initial random seed
    luerl_emul:alloc_table(table(), St1).

table() ->
    [{<<"abs">>,#erl_func{code=fun abs/2}},
     {<<"acos">>,#erl_func{code=fun acos/2}},
     {<<"asin">>,#erl_func{code=fun asin/2}},
     {<<"atan">>,#erl_func{code=fun atan/2}},
     {<<"atan2">>,#erl_func{code=fun atan2/2}},
     {<<"ceil">>,#erl_func{code=fun ceil/2}},
     {<<"cos">>,#erl_func{code=fun cos/2}},
     {<<"cosh">>,#erl_func{code=fun cosh/2}},
     {<<"deg">>,#erl_func{code=fun deg/2}},
     {<<"exp">>,#erl_func{code=fun exp/2}},
     {<<"floor">>,#erl_func{code=fun floor/2}},
     {<<"fmod">>,#erl_func{code=fun fmod/2}},
     {<<"frexp">>,#erl_func{code=fun frexp/2}},
     {<<"huge">>,1.7976931348623157e308},	%From the specs
     {<<"ldexp">>,#erl_func{code=fun ldexp/2}},
     {<<"log">>,#erl_func{code=fun log/2}},
     {<<"log10">>,#erl_func{code=fun log10/2}},	%For 5.1 backwards compatibility
     {<<"max">>,#erl_func{code=fun max/2}},
     {<<"min">>,#erl_func{code=fun min/2}},
     {<<"modf">>,#erl_func{code=fun modf/2}},
     {<<"pi">>,math:pi()},
     {<<"pow">>,#erl_func{code=fun pow/2}},
     {<<"rad">>,#erl_func{code=fun rad/2}},
     {<<"random">>,#erl_func{code=fun random/2}},
     {<<"randomseed">>,#erl_func{code=fun randomseed/2}},
     {<<"sin">>,#erl_func{code=fun sin/2}},
     {<<"sinh">>,#erl_func{code=fun sinh/2}},
     {<<"sqrt">>,#erl_func{code=fun sqrt/2}},
     {<<"tan">>,#erl_func{code=fun tan/2}},
     {<<"tanh">>,#erl_func{code=fun tanh/2}}
    ].

%% abs(Args, State) -> {[Ret],State}.

abs(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[abs(N)],St};
	_ -> badarg_error(abs, As, St)
    end.

acos(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:acos(N)],St};
	nil -> badarg_error(acos, As, St)
    end.

asin(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:asin(N)],St};
	_ -> badarg_error(asin, As, St)
    end.

atan(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:atan(N)],St};
	_ -> badarg_error(atan, As, St)
    end.

atan2(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N1,N2|_] -> {[math:atan2(N1, N2)],St};
	_ -> badarg_error(atan2, As, St)
    end.

ceil(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] when round(N) == N -> {[round(N)],St};
	[N|_] -> {[(round(N + 0.5))],St};
	_ -> badarg_error(ceil, As, St)
    end.

cos(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:cos(N)],St};
	_ -> badarg_error(cos, As, St)
    end.

cosh(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:cosh(N)],St};
	_ -> badarg_error(cosh, As, St)
    end.

deg(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[180.0*N/math:pi()],St};
	_ -> badarg_error(deg, As, St)
    end.

exp(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:exp(N)],St};
	_ -> badarg_error(exp, As, St)
    end.

floor(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] when round(N) == N -> {[N],St};
	[N|_] -> {[(round(N - 0.5))],St};
	_ -> badarg_error(floor, As, St)
    end.

fmod(As, St) ->
    case luerl_lib:tonumbers(As) of
	[X,Y|_] ->
	    Div = (trunc(X/Y)),
	    Rem = X - Div*Y,
	    {[Rem],St};
	_ -> badarg_error(fmod, As, St)
    end.

frexp(As, St) ->				%M,E such that X = M*2^E
    case luerl_lib:tonumbers(As) of
	[X|_] ->
	    <<_:1,E0:11,M0:52>> = <<X/float>>,	%The sneaky bit!
	    Two52 = 1 bsl 52,
	    M1 = (M0 bor Two52)/Two52,
	    if M1 >= 1.0 -> M2 = M1/2, E1 = E0 - 1022; %Export M2, E1
	       M1 < 0.5 -> M2 = M1*2, E1 = E0 - 1024;
	       true -> M2 = M1, E1 = E0 - 1023
	    end,
	    {[(M2),(E1)],St};
	_ -> badarg_error(frexp, As, St)
    end.

ldexp(As, St) ->
    case luerl_lib:conv_list(As, [lua_number,lua_integer]) of
	[M,E] ->
	    {[M*math:pow(2, E)],St};
%% 	    <<X/float>> = <<0:1,E:11,M:52>>,
%% 	    {[X],St};
	_ -> badarg_error(ldexp, As, St)
    end.

log(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N] -> {[math:log(N)],St};
	[N,10.0|_] -> {[math:log10(N)],St};	%Seeing it is builtin
	[N1,N2|_] ->
	    {[math:log(N1)/math:log(N2)],St};
	_ -> badarg_error(log, As, St)
    end.

log10(As, St) ->				%For 5.1 backwards compatibility
    case luerl_lib:tonumbers(As) of
	[0|_] -> {[-500],St};		%Bit hacky
	[N|_] -> {[math:log10(N)],St};
	_ -> badarg_error(log10, As, St)
    end.

max(As, St) ->
    case luerl_lib:tonumbers(As) of
	[_|_]=Ns -> {[lists:max(Ns)],St};
	_ -> badarg_error(max, As, St)
    end.

min(As, St) ->
    case luerl_lib:tonumbers(As) of
	[_|_]=Ns -> {[lists:min(Ns)],St};
	_ -> badarg_error(min, As, St)
    end.

modf(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] ->
	    I = (trunc(N)),		%Integral part
	    {[I,N-I],St};
	_ -> badarg_error(modf, As, St)
    end.

pow(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N1,N2|_] -> {[math:pow(N1, N2)],St};
	_ -> badarg_error(pow, As, St)
    end.

rad(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:pi()*N/180.0],St};
	_ -> badarg_error(sinh, As, St)
    end.

random(As, #luerl{rand=S0}=St) ->
    case luerl_lib:to_ints(As) of
	[] ->					%0.0 - 1.0
	    {R,S1} = ?RAND_UNIFORM(S0),
	    {[R],St#luerl{rand=S1}};
	[M] when M >= 1 ->
	    {R,S1} = ?RAND_UNIFORM(M, S0),
	    {[(R)],St#luerl{rand=S1}};
	[M,N] when N >= M ->
	    {R,S1} = ?RAND_UNIFORM(N - M + 1, S0),
	    {[(R + M - 1)],St#luerl{rand=S1}};
	_ -> badarg_error(random, As, St)
    end.

randomseed(As, St) ->
    case luerl_lib:tonumbers(As) of
	[S|_] ->
	    %% Split float-64 into three integers.
	    <<A1:24,A2:24,A3:16>> = <<S/float>>,
	    {[],St#luerl{rand=?RAND_SEED(A1, A2, A3)}};
	_ -> badarg_error(randomseed, As, St)
    end.

sin(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:sin(N)],St};
	_ -> badarg_error(sin, As, St)
    end.

sinh(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:sinh(N)],St};
	_ -> badarg_error(sinh, As, St)
    end.

sqrt(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:sqrt(N)],St};
	_ -> badarg_error(sqrt, As, St)
    end.

tan(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:tan(N)],St};
	_ -> badarg_error(tan, As, St)
    end.

tanh(As, St) ->
    case luerl_lib:tonumbers(As) of
	[N|_] -> {[math:tanh(N)],St};
	_ -> badarg_error(tanh, As, St)
    end.
