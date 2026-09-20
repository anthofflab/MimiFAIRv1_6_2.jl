@testitem "Monte Carlo Simulation" begin

    using Mimi
    using CSVFiles
    using DataFrames

    # run_mcs needs at least two trials because of a Mimi SampleStore restriction
    @test_throws ErrorException MimiFAIRv1_6_2.run_mcs(trials = 1)

    mktempdir() do output_dir

        results = MimiFAIRv1_6_2.run_mcs(trials = 3, output_dir = output_dir, save_trials = true)

        @test results isa Mimi.MonteCarloSimulationInstance

        @test isfile(joinpath(output_dir, "trials.csv"))
        @test isfile(joinpath(output_dir, "results", "temperature_T.csv"))
        @test isfile(joinpath(output_dir, "results", "co2_cycle_co2.csv"))

        temperature = DataFrame(load(joinpath(output_dir, "results", "temperature_T.csv")))

        @test sort(unique(temperature.trialnum)) == [1, 2, 3]
        @test all(isfinite, temperature.T)
    end
end
