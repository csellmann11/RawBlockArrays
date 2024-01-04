using SparseArrays

include("utils.jl")
include("blockarrays2d.jl")
include("blockvectors.jl")
include("indexing.jl")


include("../test/test_blockarrays2d.jl")


w = Ref(2)

nb = 3
n = 10

nnz = 15

RBS = RawBlockSparse(nnz,n,nb)

test_matrix_construction()