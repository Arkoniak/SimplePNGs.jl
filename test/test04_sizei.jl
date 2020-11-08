module SizeInterlacedTest
using SimplePNGs
using Test

include("common.jl")
using .TestCommon: load_json

pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

@testset "Size test files" begin
    @testset "1x1 paletted file, interlaced" begin
        img1 = load_json("s01n3p01")
        img2 = pl("s01i3p01")
        @test img1 == img2
    end

    @testset "2x2 paletted file, interlaced" begin
        img1 = load_json("s02n3p01")
        img2 = pl("s02i3p01")
        @test img1 == img2
    end

    @testset "3x3 paletted file, interlaced" begin
        img1 = load_json("s03n3p01")
        img2 = pl("s03i3p01")
        @test img1 == img2
    end

    @testset "4x4 paletted file, interlaced" begin
        img1 = load_json("s04n3p01")
        img2 = pl("s04i3p01")
        @test img1 == img2
    end
    
    @testset "5x5 paletted file, interlaced" begin
        img1 = load_json("s05n3p02")
        img2 = pl("s05i3p02")
        @test img1 == img2
    end

    @testset "6x6 paletted file, interlaced" begin
        img1 = load_json("s06n3p02")
        img2 = pl("s06i3p02")
        @test img1 == img2
    end

    @testset "7x7 paletted file, interlaced" begin
        img1 = load_json("s07n3p02")
        img2 = pl("s07i3p02")
        @test img1 == img2
    end

    @testset "8x8 paletted file, interlaced" begin
        img1 = load_json("s08n3p02")
        img2 = pl("s08i3p02")
        @test img1 == img2
    end
    
    @testset "9x9 paletted file, interlaced" begin
        img1 = load_json("s09n3p02")
        img2 = pl("s09i3p02")
        @test img1 == img2
    end
    
    @testset "32x32 paletted file, interlaced" begin
        img1 = load_json("s32n3p04")
        img2 = pl("s32i3p04")
        @test img1 == img2
    end

    @testset "33x33 paletted file, interlaced" begin
        img1 = load_json("s33n3p04")
        img2 = pl("s33i3p04")
        @test img1 == img2
    end

    @testset "34x34 paletted file, interlaced" begin
        img1 = load_json("s34n3p04")
        img2 = pl("s34i3p04")
        @test img1 == img2
    end

    @testset "35x35 paletted file, interlaced" begin
        img1 = load_json("s35n3p04")
        img2 = pl("s35i3p04")
        @test img1 == img2
    end

    @testset "36x36 paletted file, interlaced" begin
        img1 = load_json("s36n3p04")
        img2 = pl("s36i3p04")
        @test img1 == img2
    end

    @testset "37x37 paletted file, interlaced" begin
        img1 = load_json("s37n3p04")
        img2 = pl("s37i3p04")
        @test img1 == img2
    end

    @testset "38x38 paletted file, interlaced" begin
        img1 = load_json("s38n3p04")
        img2 = pl("s38i3p04")
        @test img1 == img2
    end
    
    @testset "39x39 paletted file, interlaced" begin
        img1 = load_json("s39n3p04")
        img2 = pl("s39i3p04")
        @test img1 == img2
    end

    @testset "40x40 paletted file, interlaced" begin
        img1 = load_json("s40n3p04")
        img2 = pl("s40i3p04")
        @test img1 == img2
    end
end

end # module
