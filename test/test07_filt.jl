module FilterTest
using SimplePNGs
using Test

include("common.jl")
using .TestCommon: load_json

pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

@testset "Filtering test files" begin
    @testset "grayscale, no interlacing, filter-type 0" begin
        img1 = load_json("f00n0g08")
        img2 = pl("f00n0g08")
        @test img1 == img2
    end

    @testset "grayscale, no interlacing, filter-type 1" begin
        img1 = load_json("f01n0g08")
        img2 = pl("f01n0g08")
        @test img1 == img2
    end

    @testset "grayscale, no interlacing, filter-type 2" begin
        img1 = load_json("f02n0g08")
        img2 = pl("f02n0g08")
        @test img1 == img2
    end

    @testset "grayscale, no interlacing, filter-type 3" begin
        img1 = load_json("f03n0g08")
        img2 = pl("f03n0g08")
        @test img1 == img2
    end

    @testset "colour, no interlacing, filter-type 0" begin
        img1 = load_json("f00n2c08")
        img2 = pl("f00n2c08")
        @test img1 == img2
    end

    @testset "colour, no interlacing, filter-type 1" begin
        img1 = load_json("f01n2c08")
        img2 = pl("f01n2c08")
        @test img1 == img2
    end

    @testset "colour, no interlacing, filter-type 2" begin
        img1 = load_json("f02n2c08")
        img2 = pl("f02n2c08")
        @test img1 == img2
    end

    @testset "colour, no interlacing, filter-type 3" begin
        img1 = load_json("f03n2c08")
        img2 = pl("f03n2c08")
        @test img1 == img2
    end
end

end # module
