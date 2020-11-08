using Revise
using SimplePNGs

includet("../test/common.jl")

using .TestCommon: save_json, load_json

save_json("basn0g01")
load_json("basn0g01", false)

save_json("basn0g02")
load_json("basn0g02", false)

save_json("basn0g04")
load_json("basn0g04", false)

save_json("basn0g08")
load_json("basn0g08", false)

save_json("basn0g16")
load_json("basn0g16", false)

save_json("basn2c08")
load_json("basn2c08", false)

save_json("basn2c16")
load_json("basn2c16", false)

save_json("basn3p01")
load_json("basn3p01", false)

save_json("basn3p02")
load_json("basn3p02", false)

save_json("basn3p04")
load_json("basn3p04", false)

save_json("basn3p08")
load_json("basn3p08", false)

save_json("basn4a08")
load_json("basn4a08", false)

save_json("basn4a16")
load_json("basn4a16", false)

save_json("basn6a08")
load_json("basn6a08", false)

save_json("basn6a16")
load_json("basn6a16", false)

save_json("s01n3p01")
load_json("s01n3p01", false)

save_json("s02n3p01")
load_json("s02n3p01", false)

save_json("s03n3p01")
load_json("s03n3p01", false)

save_json("s04n3p01")
load_json("s04n3p01", false)

save_json("s05n3p02")
load_json("s05n3p02", false)

save_json("s06n3p02")
load_json("s06n3p02", false)

save_json("s07n3p02")
load_json("s07n3p02", false)

save_json("s08n3p02")
load_json("s08n3p02", false)

save_json("s09n3p02")
load_json("s09n3p02", false)

save_json("s32n3p04")
load_json("s32n3p04", false)

save_json("s33n3p04")
load_json("s33n3p04", false)

save_json("s34n3p04")
load_json("s34n3p04", false)

save_json("s35n3p04")
load_json("s35n3p04", false)

save_json("s36n3p04")
load_json("s36n3p04", false)

save_json("s37n3p04")
load_json("s37n3p04", false)

save_json("s38n3p04")
load_json("s38n3p04", false)

save_json("s39n3p04")
load_json("s39n3p04", false)

save_json("s40n3p04")
load_json("s40n3p04", false)

SimplePNGs.load("../test/PngSuite/basn0g01.png") == load_json("basn0g01", false)
SimplePNGs.load("../test/PngSuite/basn2c08.png") == load_json("basn2c08", false)
SimplePNGs.load("../test/PngSuite/basn2c16.png") == load_json("basn2c16", false)
SimplePNGs.load("../test/PngSuite/basn4a08.png") == load_json("basn4a08", false)
SimplePNGs.load("../test/PngSuite/basn4a16.png") == load_json("basn4a16", false)
SimplePNGs.load("../test/PngSuite/basn6a08.png") == load_json("basn6a08", false)
SimplePNGs.load("../test/PngSuite/basn6a16.png") == load_json("basn6a16", false)
