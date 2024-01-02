struct BlockVector{T<:Real}
    data::Vector{T}
    m::Int
    row_idxs::Vector{Int}
end

function BlockVector(data::Vector{T}, m::Int, n_blocks::Int) where T<:Real
    row_idxs = [m * (i-1) + 1 for i in 1:n_blocks+1]
    BlockVector(data,m,row_idxs)
end

function BlockVector(m::Int, n_blocks::Int)
    data = zeros(Float64,m * n_blocks)
    return BlockVector(data,m,n_blocks)
end

function Base.setindex!(base::BlockVector, vals::Vector{Float64}, block_num)
    @assert block_num <= length(base.row_idxs) - 1 "n_blocks must be <= length(row_idxs)"
    @assert length(vals) == base.m "length of vals must be equal to m"
    row_idx = base.row_idxs[block_num]
    idx_range = row_idx:row_idx+length(vals)-1
    base.data[idx_range] = vals
end

Base.setindex!(base::BlockVector, vals::BlockVector, block_num) = Base.setindex!(base,vals.data,block_num)

function Base.getindex(base::BlockVector, block_num)
    @assert block_num <= length(base.row_idxs) "n_blocks must be <= length(row_idxs)"
    row_idx = base.row_idxs[block_num]
    idx_range = row_idx:row_idx+base.m-1
    return base.data[idx_range]
end

Base.:+(a::BlockVector, b::BlockVector)     = BlockVector(a.data + b.data, a.m, a.row_idxs)
Base.:+(a::BlockVector, b::Vector{Float64}) = BlockVector(a.data + b, a.m, a.row_idxs)
Base.:+(a::Vector{Float64}, b::BlockVector) = BlockVector(a + b.data, b.m, b.row_idxs)

Base.:*(α::T, a::BlockVector) where T<:Real = BlockVector(α * a.data, a.m, a.row_idxs)
Base.:*(a::BlockVector, α::T) where T<:Real = BlockVector(a.data * α, a.m, a.row_idxs)
Base.:-(a::BlockVector, b::BlockVector)     = BlockVector(a.data - b.data, a.m, a.row_idxs)

Base.:-(a::BlockVector) = BlockVector(-a.data, a.m, a.row_idxs)