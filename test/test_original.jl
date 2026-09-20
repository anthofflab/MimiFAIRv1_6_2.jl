# `get_model_original` is the RCP-driven variant of FAIR kept around for testing
# against the original Python implementation. It is a different model from
# `get_model`, driven by different emissions, so the two are not expected to
# agree numerically; these tests check it runs and behaves sensibly.

@testitem "Original" begin

    using Mimi

    # The four RCP scenarios get_model_original accepts, in order of increasing
    # forcing.
    scenarios = ["RCP26", "RCP45", "RCP60", "RCP85"]

    final_warming = Dict{String, Float64}()

    for scenario in scenarios
        m = MimiFAIRv1_6_2.get_model_original(rcp_scenario = scenario)
        run(m)

        years = Mimi.time_labels(m)
        @test years[1] == 1765
        @test years[end] == 2500

        T = m[:temperature, :T]
        @test length(T) == length(years)
        @test all(isfinite, T)
    end

    # Compare the scenarios over a common, shorter horizon.
    for scenario in scenarios
        m = MimiFAIRv1_6_2.get_model_original(rcp_scenario = scenario, start_year = 1765, end_year = 2300)
        run(m)

        years = Mimi.time_labels(m)
        @test years == collect(1765:2300)

        T = m[:temperature, :T]
        @test length(T) == 536
        @test all(isfinite, T)

        final_warming[scenario] = T[end]
    end

    @test issorted([final_warming[s] for s in scenarios])
end
