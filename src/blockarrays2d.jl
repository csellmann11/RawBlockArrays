struct RawBlockSparse{T <: Real}
    m::Int
    n::Int
    row::Vector{Int}
    col::Vector{Int}
    vals::Vector{T}

    n_blocks::Tuple{Int,Int}
    row_idxs::Vector{Int}
    col_idxs::Vector{Int}

    next_index::Ref{Int} # next index to be filled
end


"""
    RawBlockSparse(nnz::Int, m::Int, n::Int, n_blocks_row::Int, n_blocks_col::Int)

Constructs an empty block sparse matrix in raw format.

# Arguments
- `nnz::Int`: The number of non-zero elements in the matrix.
- `m::Int`: The number of rows in each block.
- `n::Int`: The number of columns in each block.
- `n_blocks_row::Int`: The number of blocks in each row.
- `n_blocks_col::Int`: The number of blocks in each column.

# Returns
- `RawBlockSparse`: A block sparse matrix in raw format.

"""

function RawBlockSparse(row::Vector{Int}, col::Vector{Int}, 
    vals::Vector{T}, m::Int, n::Int, n_blocks_row::Int, n_blocks_col::Int
    ,next_index) where T <: Real
    row_idxs = [m * (i-1) + 1 for i in 1:n_blocks_row+1]
    col_idxs = [n * (i-1) + 1 for i in 1:n_blocks_col+1]

    n_blocks = (n_blocks_row,n_blocks_col)

    RawBlockSparse{T}(m,n,row,col,vals,n_blocks,row_idxs,col_idxs,Ref(next_index))
end

function RawBlockSparse(::Type{T},nnz::Int, m::Int, 
    n::Int, n_blocks_row::Int, n_blocks_col::Int) where T <: Real

    row = zeros(Int,nnz)
    col = zeros(Int,nnz)
    vals = zeros(T,nnz)

    return RawBlockSparse(row,col,vals,m,n,n_blocks_row,n_blocks_col,1)
end

RawBlockSparse(nnz::Int, m::Int, n::Int, n_blocks_row::Int, n_blocks_col::Int) = RawBlockSparse(Float64,nnz,m,n,n_blocks_row,n_blocks_col)


"""
    RawBlockSparse(nnz::Int, m::Int, n::Int, n_blocks::Int)

Constructs an empty square block sparse matrix in raw format.
"""

RawBlockSparse(nnz::Int,m::Int,n_blocks::Int) = RawBlockSparse(nnz,m,m,n_blocks,n_blocks)


###################################################################################################
# Base operations overloaded for RawBlockSparse
###################################################################################################
function (raw::RawBlockSparse)() 
    @assert raw.next_index[] == length(raw.row) + 1 "RawBlockSparse is not full"
    sparse(raw.row,raw.col,raw.vals,raw.m * raw.n_blocks[1],raw.n * raw.n_blocks[2])
end

function Base.:*(α::T, A::RawBlockSparse{T}) where T <: Real
    new_valss = α .* A.vals  # Multiply each element in the vals vector by the scalar α
    return RawBlockSparse{T}(A.m, A.n, A.row, A.col, new_valss, A.n_blocks, A.row_idxs, A.col_idxs, A.next_index)
end

Base.:*(A::RawBlockSparse{T}, α::T) where {T<:Number} = Base.*(α::T, A::RawSparse)

function Base.:-(A::RawBlockSparse{T}) where T <: Real
    new_valss = -A.vals  # Negate each element in the vals vector
    return RawBlockSparse{T}(A.m, A.n, A.row, A.col, new_valss, A.n_blocks, A.row_idxs, A.col_idxs, A.next_index)
end







###################################################################################################
# Some more constructors for special cases
###################################################################################################

"""
    RawBlockSparse(A::RawBlockSparse)

Constructs a block raw sparse matrix from an `RawBlockSparse` for debugging purposes.

# Arguments
- `A::RawBlockSparse`: The input sparse matrix.

# Returns
- `RawBlockSparse`: The constructed block raw sparse matrix.

"""
function RawBlockSparse(A::AbstractSparseArray{T}) where T <: Real
    row, col, valss = findnz(A)

    m,n = size(A)
    n_blocks_row,n_blocks_col = 1,1

    next_index = length(row) + 1

    return RawBlockSparse(row,col,valss,m,n,n_blocks_row,n_blocks_col,next_index)
end


"""
    RawBlockSparse(A::Array{Union{RawBlockSparse,Int}})
    
Constructs a `RawBlockSparse` matrix from a 2-dimensional array `A` containing blocks of type `RawBlockSparse` or integers.

# Arguments
- `A`: 2-dimensional array containing blocks of type `RawBlockSparse` or integers.
- `m`: The number of rows in each block.

# Returns
- `base`: Constructed `RawBlockSparse` matrix.

# Example
```julia
R = rand(100,100,0.1,2,2) #creates a random RawBlockSparse matrix
L::Array{Union{RawBlockSparse,Int64}} = [R 1; R 0]
LL = RawBlockSparse(L,n)

"""

function RawBlockSparse(A::Array{Union{Int,RawBlockSparse{T}}},m::Int) where T <: Real
    
    @assert size(A,1) == size(A,2) "A must be square"
    nnz = 0
    for i in eachindex(A)
        if isa(A[i],Int)
            @assert A[i] == zero(T) || A[i] == one(T) "The integer must be 0 or 1 since it represents a zero or eye block"
            A[i] == 1 ? A[i] = EyeRawBlockSparse(m) : continue
        end
        nnz += length(A[i].row)
    end

    n_blocks = size(A,1)

    base = RawBlockSparse(nnz,m,m,n_blocks,n_blocks)

    for i in 1:n_blocks
        for j in 1:n_blocks

            if isa(A[i,j],Int)
                continue
            end
            base[i,j] = A[i,j]        
        end
    end

    return base    
end

function EyeRawBlockSparse(m::Int)
    row = collect(1:m)
    col = collect(1:m)
    vals = ones(Float64,m)

    next_index = m + 1

    return RawBlockSparse(row,col,vals,m,m,1,1,next_index)
end




"""
    rand(m::Int, n::Int, nnz_perc::Float64, n_blocks_row::Int, n_blocks_col::Int)

Generate a random `RawBlockSparse` matrix with specified dimensions and sparsity.

# Arguments
- `m::Int`: Number of rows in each block.
- `n::Int`: Number of columns in each block.
- `nnz_perc::Float64`: Percentage of non-zero elements in the matrix.
- `n_blocks_row::Int`: Number of blocks in each row.
- `n_blocks_col::Int`: Number of blocks in each column.

# Returns
- `RawBlockSparse`: A randomly generated `RawBlockSparse` matrix.

"""
function Base.rand(m::Int, n::Int, nnz_perc::Float64, n_blocks_row::Int, n_blocks_col::Int)

    n_rows = m * n_blocks_row  
    n_cols = n * n_blocks_col

    nnz = Int(round(nnz_perc * n_rows * n_cols))

    row = Base.rand(1:n_rows,nnz)
    col = Base.rand(1:n_cols,nnz)

    vals = Base.rand(Float64,nnz)

    next_index = nnz + 1

    return RawBlockSparse(row,col,vals,m,n,n_blocks_row,n_blocks_col,next_index)
end

### creates a square block sparse matrix with random valsues
Base.rand(m,nnz_perc,n_blocks) = Base.rand(m,m,nnz_perc,n_blocks,n_blocks)