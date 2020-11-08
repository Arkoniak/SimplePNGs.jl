module SizeNonInterlacedTest
using SimplePNGs
using Test

include("common.jl")
using .TestCommon: load_json

pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

@testset "Size test files" begin
    @testset "1x1 paletted file, no interlacing" begin
        img1 = load_json("s01n3p01")
        img2 = pl("s01n3p01")
        @test img1 == img2
    end

    @testset "2x2 paletted file, no interlacing" begin
        img1 = load_json("s02n3p01")
        img2 = pl("s02n3p01")
        @test img1 == img2
    end

    @testset "3x3 paletted file, no interlacing" begin
        img1 = load_json("s03n3p01")
        img2 = pl("s03n3p01")
        @test img1 == img2
    end

    @testset "4x4 paletted file, no interlacing" begin
        img1 = load_json("s04n3p01")
        img2 = pl("s04n3p01")
        @test img1 == img2
    end
    
    @testset "5x5 paletted file, no interlacing" begin
        img1 = load_json("s05n3p02")
        img2 = pl("s05n3p02")
        @test img1 == img2
    end

    @testset "6x6 paletted file, no interlacing" begin
        img1 = load_json("s06n3p02")
        img2 = pl("s06n3p02")
        @test img1 == img2
    end

    @testset "7x7 paletted file, no interlacing" begin
        img1 = load_json("s07n3p02")
        img2 = pl("s07n3p02")
        @test img1 == img2
    end

    @testset "8x8 paletted file, no interlacing" begin
        img1 = load_json("s08n3p02")
        img2 = pl("s08n3p02")
        @test img1 == img2
    end
    
    @testset "9x9 paletted file, no interlacing" begin
        img1 = load_json("s09n3p02")
        img2 = pl("s09n3p02")
        @test img1 == img2
    end
    
    @testset "32x32 paletted file, no interlacing" begin
        img1 = load_json("s32n3p04")
        img2 = pl("s32n3p04")
        @test img1 == img2
    end

    @testset "33x33 paletted file, no interlacing" begin
        img1 = load_json("s33n3p04")
        img2 = pl("s33n3p04")
        @test img1 == img2
    end

    @testset "34x34 paletted file, no interlacing" begin
        img1 = load_json("s34n3p04")
        img2 = pl("s34n3p04")
        @test img1 == img2
    end

    @testset "35x35 paletted file, no interlacing" begin
        img1 = load_json("s35n3p04")
        img2 = pl("s35n3p04")
        @test img1 == img2
    end

    @testset "36x36 paletted file, no interlacing" begin
        img1 = load_json("s36n3p04")
        img2 = pl("s36n3p04")
        @test img1 == img2
    end

    @testset "37x37 paletted file, no interlacing" begin
        img1 = load_json("s37n3p04")
        img2 = pl("s37n3p04")
        @test img1 == img2
    end

    @testset "38x38 paletted file, no interlacing" begin
        img1 = load_json("s38n3p04")
        img2 = pl("s38n3p04")
        @test img1 == img2
    end
    
    @testset "39x39 paletted file, no interlacing" begin
        img1 = load_json("s39n3p04")
        img2 = pl("s39n3p04")
        @test img1 == img2
    end

    @testset "40x40 paletted file, no interlacing" begin
        img1 = load_json("s40n3p04")
        img2 = pl("s40n3p04")
        @test img1 == img2
    end
end

end # module
