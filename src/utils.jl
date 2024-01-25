Base.size(A::RawBlockSparse) = (A.m * A.n_blocks[1], A.n * A.n_blocks[2])

function Base.size(A::RawBlockSparse, dim::Int)
    if dim == 1
        return A.m * A.n_blocks[1]
    elseif dim == 2
        return A.n * A.n_blocks[2]
    else
        error("Dimension must be 1 or 2")
    end 
end

