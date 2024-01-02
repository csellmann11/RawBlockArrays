using Test

include("../src/RawBlockArrays.jl")
using .RawBlockArrays

include("test_blockvectors.jl")
include("test_blockarrays2d.jl")

@testset "BlockVector Tests" begin
    @testset "Construction" begin
        test_blockvector_construction()
        test_blockvector_default_construction()
    end

    @testset "Indexing" begin
        test_blockvector_setindex()
        test_blockvector_getindex()
    end

    @testset "Operations" begin
        test_blockvector_addition()
        test_blockvector_scalar_multiplication()
        test_blockvector_subtraction()
        test_blockvector_negation()
    end
end

@testset "RawBlockSparse Tests" begin
    test_rawblocksparse_construction()
    test_rawblocksparse_default_construction()
    test_rawblocksparse_multiplication()
    test_rawblocksparse_negation()
    test_matrix_construction()
    # Add more test function calls here
end