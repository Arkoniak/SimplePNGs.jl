module BasnTest
using SimplePNGs
using Test

include("common.jl")
using .TestCommon: load_json

pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

@testset "Basic format test files (non-interlaced)" begin
    @testset "black & white" begin
        img1 = load_json("basn0g01")
        img2 = pl("basn0g01")
        @test img1 == img2
    end

    @testset "2 bit (4 level) grayscale" begin
        img1 = load_json("basn0g02")
        img2 = pl("basn0g02")
        @test img1 == img2
    end

    @testset "4 bit (16 level) grayscale" begin
        img1 = load_json("basn0g04")
        img2 = pl("basn0g04")
        @test img1 == img2
    end

    @testset "8 bit (256 level) grayscale" begin
        img1 = load_json("basn0g08")
        img2 = pl("basn0g08")
        @test img1 == img2
    end

    @testset "16 bit (64k level) grayscale" begin
        img1 = load_json("basn0g16")
        img2 = pl("basn0g16")
        @test img1 == img2
    end

    @testset "3x8 bits rgb color" begin
        img1 = load_json("basn2c08")
        img2 = pl("basn2c08")
        @test img1 == img2
    end

    @testset "3x16 bits rgb color" begin
        img1 = load_json("basn2c16")
        img2 = pl("basn2c16")
        @test img1 == img2
    end

    @testset "1 bit (2 color) paletted" begin
    end

    @testset "2 bit (4 color) paletted" begin
    end

    @testset "4 bit (16 color) paletted" begin
    end

    @testset "8 bit (256 color) paletted" begin
    end

    @testset "8 bit grayscale + 8 bit alpha-channel" begin
    end

    @testset "16 bit grayscale + 16 bit alpha-channel" begin
    end

    @testset "3x8 bits rgb color + 8 bit alpha-channel" begin
    end

    @testset "3x16 bits rgb color + 16 bit alpha-channel" begin
    end
end

end # module
