"""
todot

Create dot file
"""

export todot

import DD: todot
using UUIDs: uuid1

function todot(top::AbstractFaultTreeNode)
    io = IOBuffer()
    visited = Set{AbstractFaultTreeNode}()
    println(io, "digraph { layout=dot; overlap=false; splines=true; node [fontsize=10];")
    _todot!(top, visited, io)
    println(io, "}")
    return String(take!(io))
end

function _todot!(f::FaultTreeEvent, visited::Set{AbstractFaultTreeNode}, io::IO)
    id = uuid1()
    println(io, "\"$(id)\" [shape = circle, label = \"$(f.var)\"];")
    id
end

function _todot!(f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode}, io::IO)
    id = "obj$(objectid(f))"
    (f in visited) && return id
    push!(visited, f)
    println(io, "\"$(id)\" [shape = square, label = \"$(f.op)\"];")
    for x = f.args
        dest = _todot!(x, visited, io)
        println(io, "\"$(id)\" -> \"$(dest)\";")
    end
    id
end

function _todot!(f::FaultTreeKoutofN, visited::Set{AbstractFaultTreeNode}, io::IO)
    id = "obj$(objectid(f))"
    (f in visited) && return id
    push!(visited, f)
    println(io, "\"$(id)\" [shape = square, label = \"$(f.op) $(f.k)\"];")
    for x = f.args
        dest = _todot!(x, visited, io)
        println(io, "\"$(id)\" -> \"$(dest)\";")
    end
    id
end
