-module(prop_flake).

-behaviour(proper_statem).

-include_lib("proper/include/proper.hrl").

-export([initial_state/0, command/1, precondition/2, postcondition/3, next_state/3]).

% api
-export([correct/0, qc/0, exitcode/1]).

% wrappers
-export([id/0]).

initial_state() ->
    [].

next_state(S, V, {call, _, id, []}) ->
    [V|S].

precondition(_, _) ->
    true.

postcondition(Ids, {call, _, id, []}, Id) ->
    kordered_property(Id, Ids).

command(_S) ->
    oneof([
	   {call, ?MODULE, id, []}
	  ]).

correct() ->
    ?FORALL(
       Cmds, commands(?MODULE),
       begin
	   restart(flake),
	   {History, State, Result} = run_commands(?MODULE, Cmds),
	   ?WHENFAIL(
	      io:format("History: ~p~nState: ~p~nResult: ~p~n", [History, State, Result]),
	      Result =:= ok
	     )
       end).

qc() ->
    proper:quickcheck(correct(), [{numtests, 1000}]).

exitcode(true) ->
    halt(0);
exitcode(false) ->
    halt(1).


%%====================================================================
%% Properties
%%====================================================================
kordered_property(_Id, []) ->
    % Id is always > than nothing ;)
    true;
kordered_property(Id, [Hd|_]) ->
    % we don't have to test all the items in the Ids list because as long as the
    % property holds, the head will always be > that items in the tail.
    Id > Hd.
    
%%====================================================================
%% Wrappers
%% ====================================================================
%%
%% These wrappers help with extracting the needed data from the flake server's
%% return value
id() ->
    {ok, Id} = flake_server:id(),
    Id.

%%====================================================================
%% Internal functions
%%====================================================================
restart(App) ->
    case application:start(App) of
	{error, {already_started, App}} ->
	    application:stop(App),
	    application:start(App);
	ok ->
	    application:start(App)
    end.
