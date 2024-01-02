using Test

function test_rawblocksparse_construction()
    row = [1, 2, 3, 4, 5, 6]
    col = [1, 2, 3, 4, 5, 6]
    vals = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n = 2
    n_blocks_row = 3
    n_blocks_col = 3
    next_index = 7
    rbs = RawBlockSparse(row, col, vals, m, n, n_blocks_row, n_blocks_col, next_index)
    @test rbs.row == row
    @test rbs.col == col
    @test rbs.vals == vals
    @test rbs.m == m
    @test rbs.n == n
    @test rbs.n_blocks == (n_blocks_row, n_blocks_col)
    @test rbs.row_idxs == [1, 3, 5, 7]
    @test rbs.col_idxs == [1, 3, 5, 7]
    @test rbs.next_index[] == next_index
end

function test_rawblocksparse_default_construction()
    nnz = 6
    m = 2
    n = 2
    n_blocks_row = 3
    n_blocks_col = 3
    rbs = RawBlockSparse(nnz, m, n, n_blocks_row, n_blocks_col)
    @test rbs.row == zeros(Int, nnz)
    @test rbs.col == zeros(Int, nnz)
    @test rbs.vals == zeros(Float64, nnz)
    @test rbs.m == m
    @test rbs.n == n
    @test rbs.n_blocks == (n_blocks_row, n_blocks_col)
    @test rbs.row_idxs == [1, 3, 5, 7]
    @test rbs.col_idxs == [1, 3, 5, 7]
    @test rbs.next_index[] == 1
end

function test_rawblocksparse_multiplication()
    row = [1, 2, 3, 4, 5, 6]
    col = [1, 2, 3, 4, 5, 6]
    vals = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n = 2
    n_blocks_row = 3
    n_blocks_col = 3
    next_index = 7
    rbs = RawBlockSparse(row, col, vals, m, n, n_blocks_row, n_blocks_col, next_index)
    α = 2.0
    rbs_scaled = α * rbs
    @test rbs_scaled.row == row
    @test rbs_scaled.col == col
    @test rbs_scaled.vals == α * vals
    @test rbs_scaled.m == m
    @test rbs_scaled.n == n
    @test rbs_scaled.n_blocks == (n_blocks_row, n_blocks_col)
    @test rbs_scaled.row_idxs == [1, 3, 5, 7]
    @test rbs_scaled.col_idxs == [1, 3, 5, 7]
    @test rbs_scaled.next_index[] == next_index
end

function test_rawblocksparse_negation()
    row = [1, 2, 3, 4, 5, 6]
    col = [1, 2, 3, 4, 5, 6]
    vals = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n = 2
    n_blocks_row = 3
    n_blocks_col = 3
    next_index = 7
    rbs = RawBlockSparse(row, col, vals, m, n, n_blocks_row, n_blocks_col, next_index)
    rbs_neg = -rbs
    @test rbs_neg.row == row
    @test rbs_neg.col == col
    @test rbs_neg.vals == -vals
    @test rbs_neg.m == m
    @test rbs_neg.n == n
    @test rbs_neg.n_blocks == (n_blocks_row, n_blocks_col)
    @test rbs_neg.row_idxs == [1, 3, 5, 7]
    @test rbs_neg.col_idxs == [1, 3, 5, 7]
    @test rbs_neg.next_index[] == next_index
end

function test_matrix_construction()
    # create a random block raw sparse
    n_blocks = 2
    n = 3
    R = RawBlockArrays.rand(n,0.1,n_blocks)

    RR::Matrix{Union{RawBlockSparse{Float64},Int}} = [R 1;0 R]

    check_vals_vec = [R.vals; ones(n*n_blocks); R.vals]

    @test check_vals_vec == RawBlockSparse(RR, n*n_blocks).vals
end

# Add more tests as needed

