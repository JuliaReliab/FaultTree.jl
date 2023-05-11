
function _tsort(f::BDD.AbstractNode)
    check = Dict{BDD.NodeID,Int}()
    result = BDD.AbstractNode[]
    queue = BDD.AbstractNode[f]
    while length(queue) != 0
        x = pop!(queue)
        c = get!(check, BDD.id(x), 0)
        if c != 2
            _visit(x, check, result, queue)
        end
    end
    result
end

function _visit(x::BDD.AbstractNonTerminalNode, check::Dict{BDD.NodeID,Int},
    result::Vector{BDD.AbstractNode}, queue::Vector{BDD.AbstractNode})
    c = get!(check, BDD.id(x), 0)
    if c == 1
        throw(ErrorException("DAG has a closed path"))
    elseif c == 0
        check[BDD.id(x)] = 1
        b0 = BDD.get_zero(x)
        push!(queue, b0)
        _visit(b0, check, result, queue)
        b1 = BDD.get_one(x)
        push!(queue, b1)
        _visit(b1, check, result, queue)
        check[BDD.id(x)] = 2
        pushfirst!(result, x)
    end
end

function _visit(x::BDD.AbstractTerminalNode, check::Dict{BDD.NodeID,Int},
    result::Vector{BDD.AbstractNode}, queue::Vector{BDD.AbstractNode})
    c = get!(check, BDD.id(x), 0)
    if c == 1
        throw(ErrorException("DAG has a closed path"))
    elseif c == 0
        check[BDD.id(x)] = 2
        pushfirst!(result, x)
    end
end
