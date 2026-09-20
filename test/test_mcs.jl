@testitem "Monte Carlo Simulation" begin

    using Mimi
    using CSVFiles
    using DataFrames

    # run_mcs needs at least two trials because of a Mimi SampleStore restriction.
    # `trials` is typed `Integer` rather than `Int64` so that this reaches the
    # check rather than a TypeError on 32-bit platforms, where a literal is Int32.
    @test_throws ErrorException MimiFAIRv1_6_2.run_mcs(trials = 1)
    @test_throws ErrorException MimiFAIRv1_6_2.run_mcs(trials = Int32(1))
    @test_throws ErrorException MimiFAIRv1_6_2.run_mcs(trials = Int64(1))

    mktempdir() do output_dir

        results = MimiFAIRv1_6_2.run_mcs(trials = Int32(3), output_dir = output_dir, save_trials = true)

        @test results isa Mimi.MonteCarloSimulationInstance

        @test isfile(joinpath(output_dir, "trials.csv"))
        @test isfile(joinpath(output_dir, "results", "temperature_T.csv"))
        @test isfile(joinpath(output_dir, "results", "co2_cycle_co2.csv"))

        temperature = DataFrame(load(joinpath(output_dir, "results", "temperature_T.csv")))

        @test sort(unique(temperature.trialnum)) == [1, 2, 3]
        @test all(isfinite, temperature.T)
    end
end
