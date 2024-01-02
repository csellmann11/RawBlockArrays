# only setindex supported

"""
    add_storrage(base::RawBlockSparse, nnz::Int)

Add storage to a `RawBlockSparse` object by appending zeros to its `row`, `col`, and `vals` fields.

# Arguments
- `base::RawBlockSparse`: The `RawBlockSparse` object to which storage will be added.
- `nnz::Int`: The number of zeros to append to each field of the `RawBlockSparse` object.

# Examples
```julia
base = RawBlockSparse(row=[1, 2], col=[3, 4], vals=[5.0, 6.0])
add_storrage(base, 2)
"""
function add_storrage(base::RawBlockSparse,nnz::Int)
    append!(base.row,zeros(Int,nnz))
    append!(base.col,zeros(Int,nnz))
    append!(base.vals,zeros(Float64,nnz))
end

"""
    _fill_in(base::RawBlockSparse, row::Vector{Int}, col::Vector{Int}, valss::Vector{Float64}, n_blocks_row::Int, n_blocks_col::Int)

Fill in the valsues of a RawBlockSparse matrix.

Arguments:
- `base`: The RawBlockSparse matrix to fill in.
- `row`: Vector of row indices.
- `col`: Vector of column indices.
- `valss`: Vector of valsues to fill in.
- `n_blocks_row`: Number of blocks in the row direction.
- `n_blocks_col`: Number of blocks in the column direction.
"""

function _fill_in(base::RawBlockSparse{T}, row::Vector{Int}, col::Vector{Int}, 
    valss::Vector{T}, n_blocks_row::Int, n_blocks_col::Int) where T <: Real

    row_idx = base.row_idxs[n_blocks_row]
    col_idx = base.col_idxs[n_blocks_col]


    idx_range = base.next_index[]:base.next_index[]+length(row)-1

    if base.next_index[] + length(row) - 1 > length(base.row)
        error("Base sparse storage is full. Consider preallocating
                    with add_storrage(base,nnz(vals)) for less gc time")
    end

    base.row[idx_range] = row_idx .+ row .- 1
    base.col[idx_range] = col_idx .+ col .- 1
    base.vals[idx_range] = valss

    base.next_index[] += length(row)
end


function Base.setindex!(base::RawBlockSparse{T}, vals::RawBlockSparse{T}, idx...) where T <: Real

    @assert length(idx) == 2 "so far only 2d indexing supported"
    n_blocks_row,n_blocks_col = idx
    @assert n_blocks_row <= base.n_blocks[1] "n_blocks_row must be <= n_blocks[1]"
    @assert n_blocks_col <= base.n_blocks[2] "n_blocks_col must be <= n_blocks[2]"

    _fill_in(base, vals.row, vals.col, vals.vals, n_blocks_row, n_blocks_col)
end

function Base.setindex!(base::RawBlockSparse{T}, vals::AbstractSparseArray{T}, idx...) where T <: Real
    n_blocks_row,n_blocks_col = idx
    @assert n_blocks_row <= base.n_blocks[1] "n_blocks_row must be <= n_blocks[1]"
    @assert n_blocks_col <= base.n_blocks[2] "n_blocks_col must be <= n_blocks[2]"

    row, col, valss = findnz(vals)

    _fill_in(base, row, col, valss, n_blocks_row, n_blocks_col)
end

function Base.setindex!(base::RawBlockSparse{T}, vals::T, idx...) where T <: Real
    n_blocks_row,n_blocks_col = idx
    @assert n_blocks_row <= base.n_blocks[1] "n_blocks_row must be <= n_blocks[1]"
    @assert n_blocks_col <= base.n_blocks[2] "n_blocks_col must be <= n_blocks[2]"

    row_idx = base.row_idxs[n_blocks_row]
    col_idx = base.col_idxs[n_blocks_col]

    if base.next_index[] > length(base.row)
        error("Base sparse already filled")
    else
        base.row[base.next_index[]] = row_idx
        base.col[base.next_index[]] = col_idx
        base.vals[base.next_index[]] = vals
    end
    base.next_index[] += 1
end
