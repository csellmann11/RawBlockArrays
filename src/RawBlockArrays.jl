module RawBlockArrays
    using SparseArrays

    include("blockarrays2d.jl")
    include("blockvectors.jl")
    include("indexing.jl")
    include("utils.jl")


    export BlockVector, RawBlockSparse, EyeRawBlockSparse, size, rand
end # module RawBlockArrays


