using Revise
using SimplePNGs

includet("test/common.jl")

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

SimplePNGs.load("test/PngSuite/basn0g01.png") == load_json("basn0g01", false)
SimplePNGs.load("test/PngSuite/basn2c08.png") == load_json("basn2c08", false)
SimplePNGs.load("test/PngSuite/basn2c16.png") == load_json("basn2c16", false)
