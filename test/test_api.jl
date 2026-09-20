@testitem "API" begin

    using Mimi

    # The six IPCC AR6 emissions scenarios get_model accepts.
    scenarios = ["ssp119", "ssp126", "ssp245", "ssp460", "ssp370", "ssp585"]

    warming = Dict{String, Float64}()

    for scenario in scenarios
        m = MimiFAIRv1_6_2.get_model(ar6_scenario = scenario)
        run(m)

        years = Mimi.time_labels(m)
        @test years[1] == 1750
        @test years[end] == 2300

        T = m[:temperature, :T]
        @test length(T) == length(years)
        @test all(isfinite, T)

        # warming in 2100 relative to the 1850-1900 mean, the usual AR6 baseline
        baseline = 1850:1900
        base = sum(T[indexin(collect(baseline), years)]) / length(baseline)
        warming[scenario] = T[findfirst(==(2100), years)] - base
    end

    # `scenarios` is listed in order of increasing forcing, so the 2100 warming
    # should come out in the same order.
    @test issorted([warming[s] for s in scenarios])

    # All six land in a physically plausible range for 2100.
    for scenario in scenarios
        @test 1.0 < warming[scenario] < 6.0
    end
end

@testitem "Truncated time horizon" begin

    using Mimi

    # Running to 2100 should reproduce the first 351 years of the run to 2300
    # exactly: nothing about the model depends on how far into the future it
    # is asked to go.
    m_2100 = MimiFAIRv1_6_2.get_model(ar6_scenario = "ssp245", start_year = 1750, end_year = 2100)
    run(m_2100)

    m_2300 = MimiFAIRv1_6_2.get_model(ar6_scenario = "ssp245", start_year = 1750, end_year = 2300)
    run(m_2300)

    T_2100 = m_2100[:temperature, :T]
    T_2300 = m_2300[:temperature, :T]

    @test Mimi.time_labels(m_2100) == collect(1750:2100)
    @test length(T_2100) == 351
    @test T_2100 == T_2300[1:351]
end
