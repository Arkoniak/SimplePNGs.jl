module BasiTest
using SimplePNGs
using Test

include("common.jl")
using .TestCommon: load_json

pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

@testset "Basic format test files (Adam-7 interlaced)" begin
    @testset "black & white" begin
        img1 = load_json("basn0g01")
        img2 = pl("basi0g01")
        @test img1 == img2
    end

    @testset "2 bit (4 level) grayscale" begin
        img1 = load_json("basn0g02")
        img2 = pl("basi0g02")
        @test img1 == img2
    end

    @testset "4 bit (16 level) grayscale" begin
        img1 = load_json("basn0g04")
        img2 = pl("basi0g04")
        @test img1 == img2
    end

    @testset "8 bit (256 level) grayscale" begin
        img1 = load_json("basn0g08")
        img2 = pl("basi0g08")
        @test img1 == img2
    end

    @testset "16 bit (64k level) grayscale" begin
        img1 = load_json("basn0g16")
        img2 = pl("basi0g16")
        @test img1 == img2
    end

    @testset "3x8 bits rgb color" begin
        img1 = load_json("basn2c08")
        img2 = pl("basi2c08")
        @test img1 == img2
    end

    @testset "3x16 bits rgb color" begin
        img1 = load_json("basn2c16")
        img2 = pl("basi2c16")
        @test img1 == img2
    end

    @testset "1 bit (2 color) paletted" begin
        img1 = load_json("basn3p01")
        img2 = pl("basi3p01")
        @test img1 == img2
    end

    @testset "2 bit (4 color) paletted" begin
        img1 = load_json("basn3p02")
        img2 = pl("basi3p02")
        @test img1 == img2
    end

    @testset "4 bit (16 color) paletted" begin
        img1 = load_json("basn3p04")
        img2 = pl("basi3p04")
        @test img1 == img2
    end

    @testset "8 bit (256 color) paletted" begin
        img1 = load_json("basn3p08")
        img2 = pl("basi3p08")
        @test img1 == img2
    end

    @testset "8 bit grayscale + 8 bit alpha-channel" begin
        img1 = load_json("basn4a08")
        img2 = pl("basi4a08")
        @test img1 == img2
    end

    @testset "16 bit grayscale + 16 bit alpha-channel" begin
        img1 = load_json("basn4a16")
        img2 = pl("basi4a16")
        @test img1 == img2
    end

    @testset "3x8 bits rgb color + 8 bit alpha-channel" begin
        img1 = load_json("basn6a08")
        img2 = pl("basi6a08")
        @test img1 == img2
    end

    @testset "3x16 bits rgb color + 16 bit alpha-channel" begin
        img1 = load_json("basn6a16")
        img2 = pl("basi6a16")
        @test img1 == img2
    end
end

end # module
