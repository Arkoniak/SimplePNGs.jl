module BasiTest
using FileIO
using SimplePNGs
using Test

fl(name) = load(joinpath("PngSuite", name*".png"))
pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

function testload(name)
    img1 = fl(name)
    img2 = pl(name)
    @test img1 == img2
end

@testset "Basic format test files (non-interlaced)" begin
    # black & white
    testload("basn0g01")

    # 2 bit (4 level) grayscale 
    testload("basn0g02")

    # 4 bit (16 level) grayscale
    testload("basn0g04")

    # 8 bit (256 level) grayscale
    testload("basn0g08")

    # 16 bit (64k level) grayscale
    testload("basn0g16")

    # 3x8 bits rgb color 
    testload("basn2c08")

    # 3x16 bits rgb color
    testload("basn2c16")

    # 1 bit (2 color) paletted
    testload("basn3p01")

    # 2 bit (4 color) paletted
    testload("basn3p02")

    # 4 bit (16 color) paletted
    testload("basn3p04")

    # 8 bit (256 color) paletted
    testload("basn3p08")

    # 8 bit grayscale + 8 bit alpha-channel
    testload("basn4a08")

    # 16 bit grayscale + 16 bit alpha-channel
    testload("basn4a16")

    # 3x8 bits rgb color + 8 bit alpha-channel
    testload("basn6a08")

    # 3x16 bits rgb color + 16 bit alpha-channel
    testload("basn6a16")
end

@testset "Basic format test files (Adam-7 interlaced)" begin
    
end

end # module
