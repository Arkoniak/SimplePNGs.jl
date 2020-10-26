module BasiTest
import FileIO
using SimplePNGs
using Colors
using Test

fl(name, corrected = false) = FileIO.load(joinpath("PngSuite", name * (corrected ? "_a" : "") * ".png"))
pl(name) = SimplePNGs.load(joinpath("PngSuite", name*".png"))

function testload(name; transform_palette = false, corrected = false)
    img1 = fl(name, corrected)
    img2 = pl(name)

    # For some reason default palette for grayscale in PNGFile is different
    # from wiki, gimp and other sources
    if corrected
        img1 = Gray.(red.(img1))
    end
    if transform_palette
        plt1 = sort(unique(img1))
        plt2 = sort(unique(img2))

        d = Dict(plt2 .=> plt1)
        for i in axes(img2, 1)
            for j in axes(img2, 2)
                img2[i, j] = d[img2[i, j]]
            end
        end
    end
    @test img1 == img2
end

@testset "Basic format test files (non-interlaced)" begin
    @testset "black & white" begin
        testload("basn0g01")
    end

    @testset "2 bit (4 level) grayscale" begin
        testload("basn0g02", transform_palette = true)
    end

    @testset "4 bit (16 level) grayscale" begin
        testload("basn0g04", transform_palette = true)
    end

    @testset "8 bit (256 level) grayscale" begin
        testload("basn0g08", corrected = true)
    end

    @testset "16 bit (64k level) grayscale" begin
        testload("basn0g16")
    end

    @testset "3x8 bits rgb color" begin
        testload("basn2c08")
    end

    @testset "3x16 bits rgb color" begin
        testload("basn2c16")
    end

    @testset "1 bit (2 color) paletted" begin
        testload("basn3p01")
    end

    @testset "2 bit (4 color) paletted" begin
        testload("basn3p02")
    end

    @testset "4 bit (16 color) paletted" begin
        testload("basn3p04")
    end

    @testset "8 bit (256 color) paletted" begin
        testload("basn3p08")
    end

    @testset "8 bit grayscale + 8 bit alpha-channel" begin
        testload("basn4a08")
    end

    @testset "16 bit grayscale + 16 bit alpha-channel" begin
        testload("basn4a16")
    end

    @testset "3x8 bits rgb color + 8 bit alpha-channel" begin
        testload("basn6a08")
    end

    @testset "3x16 bits rgb color + 16 bit alpha-channel" begin
        testload("basn6a16")
    end
end

end # module
