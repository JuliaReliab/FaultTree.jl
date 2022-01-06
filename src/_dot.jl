"""
todot

Create dot file
"""

import DD.BDD: todot

function todot(top::AbstractFTNode)
    io = IOBuffer()
    visited = Set{AbstractFTNode}()
    println(io, "digraph { layout=dot; overlap=false; splines=true; node [fontsize=10];")
    _todot!(top, visited, io)
    println(io, "}")
    return String(take!(io))
end

function _todot!(f::AbstractFTEvent, visited::Set{AbstractFTNode}, io::IO)
#    id = uuid1()
    id = "obj$(objectid(f))"
    println(io, "\"$(id)\" [shape = circle, label = \"$(f.label)\"];")
    id
end

function _todot!(f::AbstractFTOperation, visited::Set{AbstractFTNode}, io::IO)
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

function _todot!(f::FTKoutofN, visited::Set{AbstractFTNode}, io::IO)
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
