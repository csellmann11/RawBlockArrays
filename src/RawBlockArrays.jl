module RawBlockArrays
    using SparseArrays

    include("blockarrays2d.jl")
    include("blockvectors.jl")
    include("indexing.jl")


    export BlockVector, RawBlockSparse, EyeRawBlockSparse
end # module RawBlockArrays


