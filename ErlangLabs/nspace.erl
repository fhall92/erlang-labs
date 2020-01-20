-module(nspace).

-export([]).

startns()->
    register(ns,spawn(fun()->namespace(top) end)).

namespace(State) ->
    receive
        {From,[Head|Tail],MSG} ->
            %deal with it!
            NextNSPid=get(Head),
            NextNSPid!{From,Tail,MSG},
        namespace(State);
    {From,[],{regNS,Pid,Name}} ->
        %Deal with it
        put(Name,Pid),
        namespace(State);
    {From,[],getPid} ->
        %Self() function returns own Pid
        From!{getPid,self()},
        namespace(State)

end.