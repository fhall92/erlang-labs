%Compile with c(modulename)
%Run function with modulename:functionName()

-module(nspace).

-export([runAll/0, sendMsg/2]).

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
        From!{ok},
        namespace(State);
    {From,[],getPid} ->
        %Self() function returns own Pid
        From!{getPid,self()},
        namespace(State)

end.

reg(Namespace,Pid,Name) ->
    ns!{self(),Namespace,{regNS,Pid,Name}},
receive
    {ok} ->
        io:format("success ~p \n", [Name])
end.

hello(SecretKey) ->
    receive
        {From,[],getKey} ->
            From!{key, SecretKey},
            hello(SecretKey)
end.

sendMsg(Namespaces,MSG) ->
    ns!{self(),Namespaces,MSG},
    receive
        {key,Answer} ->
            io:format("Secret key is ~p",[Answer])
end.

runAll() ->
    startns(),
    PidOpen = spawn(fun()->namespace(theopenspace) end),
    PidProp=spawn(fun() -> namespace(thepropspace) end),
    reg([],PidOpen,open),
    reg([],PidProp,prop),
    PidSware1=spawn(fun() -> namespace(anotherspace) end),
    PidSware2=spawn(fun() -> namespace(fred) end),
    reg([open],PidSware1,sware),
    reg([prop],PidSware2,sware),
    PidKey1=spawn(fun()->hello(joeIsCool) end),
    PidKey2=spawn(fun()->hello(erlangAlsoCool) end),
    reg([open,sware],PidKey1,key),
    reg([prop,sware],PidKey2,key).


    