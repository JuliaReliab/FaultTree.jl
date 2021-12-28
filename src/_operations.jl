import Base

function Base.:*(x::AbstractFTNode, y::AbstractFTNode)
    and(x, y)
end

function Base.:&(x::AbstractFTNode, y::AbstractFTNode)
    and(x, y)
end

function Base.:+(x::AbstractFTNode, y::AbstractFTNode)
    or(x, y)
end

function Base.:|(x::AbstractFTNode, y::AbstractFTNode)
    or(x, y)
end

function Base.:!(x::AbstractFTNode)
    not(x)
end

function Base.:~(x::AbstractFTNode)
    not(x)
end

function and(x::Vararg{AbstractFTNode})
    args = [y for y = x]
    FTOperation(:AND, args)
end

function or(x::Vararg{AbstractFTNode})
    args = [y for y = x]
    FTOperation(:OR, args)
end

function not(x::AbstractFTNode)
    FTOperation(:NOT, [x])
end

function kofn(k::Int, x::Vararg{AbstractFTNode})
    args = [y for y = x]
    FTKoutofN(:KofN, k, args)
end
