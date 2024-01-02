using Test
include("../src/blockvectors.jl")

function test_blockvector_construction()
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n_blocks = 3
    bv = BlockVector(data, m, n_blocks)
    @test bv.data == data
    @test bv.m == m
    @test bv.row_idxs == [1, 3, 5, 7]
end

function test_blockvector_default_construction()
    m = 2
    n_blocks = 3
    bv = BlockVector(m, n_blocks)
    @test bv.data == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    @test bv.m == m
    @test bv.row_idxs == [1, 3, 5, 7]
end

function test_blockvector_setindex()
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n_blocks = 3
    bv = BlockVector(data, m, n_blocks)
    vals = [7.0, 8.0]
    block_num = 2
    setindex!(bv, vals, block_num)
    @test bv.data == [1.0, 2.0, 7.0, 8.0, 5.0, 6.0]
end

function test_blockvector_getindex()
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n_blocks = 3
    bv = BlockVector(data, m, n_blocks)
    block_num = 2
    vals = getindex(bv, block_num)
    @test vals == [3.0, 4.0]
end

function test_blockvector_addition()
    data1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    data2 = [7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
    m = 2
    n_blocks = 3
    bv1 = BlockVector(data1, m, n_blocks)
    bv2 = BlockVector(data2, m, n_blocks)
    bv_sum = bv1 + bv2
    @test bv_sum.data == [8.0, 10.0, 12.0, 14.0, 16.0, 18.0]
end

function test_blockvector_scalar_multiplication()
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n_blocks = 3
    bv = BlockVector(data, m, n_blocks)
    α = 2.0
    bv_scaled = α * bv
    @test bv_scaled.data == [2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
end

function test_blockvector_subtraction()
    data1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    data2 = [7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
    m = 2
    n_blocks = 3
    bv1 = BlockVector(data1, m, n_blocks)
    bv2 = BlockVector(data2, m, n_blocks)
    bv_diff = bv1 - bv2
    @test bv_diff.data == [-6.0, -6.0, -6.0, -6.0, -6.0, -6.0]
end

function test_blockvector_negation()
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    m = 2
    n_blocks = 3
    bv = BlockVector(data, m, n_blocks)
    bv_neg = -bv
    @test bv_neg.data == [-1.0, -2.0, -3.0, -4.0, -5.0, -6.0]
end

