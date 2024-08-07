include("run_ensemble.jl")

function get_param_ranges()
    rx_range = 0.1:0.25:1.5
    ry_range = 0.1:0.25:1.5
    a_range = 0.1:0.25:1.0
    b_range = 0.1:0.25:1.0
    c_range = 1:0.5:5.0
    d_range = 1:0.5:5.0

    return [rx_range, ry_range, a_range, b_range, c_range, d_range]
end

function make_steady_state_ensemble_problem(
    model, parameter_mesh, initial_conditions=[0.01, 0.01]
)
    u0 = initial_conditions
    dummy_params = [1.0, 1.0, 0.1, 0.1, 1.0, 1.0]

    change_params_problem_function = make_change_param_problem_function(parameter_mesh)

    ssprob = SteadyStateProblem(model, u0, dummy_params)
    ensemble_problem = EnsembleProblem(ssprob; prob_func=change_params_problem_function)
    return ensemble_problem
end

parameter_mesh = make_parameter_mesh()
steady_states = run_ensemble_simulations(
    make_steady_state_ensemble_problem(model, parameter_mesh), length(parameter_mesh)
)

@save "Data/parameter_mesh.jld2" parameter_mesh
@save "Data/steady_states.jld2" steady_states


# # Effect of perturbations on the different parameters on the steady states
# # 1. Perturb the transition rates
# # 2. Peturb the growth rates
# # 3. Peturb both the transition and growth rates

# # define various types of perturbations
# unbiased_increase_transition_perturbation = [0, 0, 0.05, 0.05, 0, 0]
# unbiased_decrease_transition_perturbation = [0, 0, -0.05, -0.05, 0, 0]
# biased_transition_perturbation = [0, 0, 0.1, -0.1, 0, 0]

# unbiased_increase_growth_perturbation = [0.1, 0.1, 0, 0, 0, 0]
# unbiased_decrease_transition_perturbation = [-0.1, -0.1, 0, 0, 0, 0]
# biased_growth_perturbation = [0.1, -0.1, 0, 0, 0, 0]

# problem_function = make_prob_function(unbiased_increase_transition_perturbation)
# ensemble_prob = EnsembleProblem(prob; prob_func=problem_function)
# sim = solve(
#     ensemble_prob, Tsit5(), EnsembleThreads(); saveat=1, trajectories=100, progress=true
# )

# # Calculate the steady states
# u0 = [0.01, 0.01]
# dummy_params = [1.0, 1.0, 0.1, 0.1, 1.0, 1.0]
# ssprob = SteadyStateProblem(model, u0, dummy_params)
# perturbation = unbiased_decrease_transition_perturbation

# steady_states_after_perturbation = [
#     solve(remake(ssprob; p=mesh[i] .+ perturbation), DynamicSS()).u for i in eachindex(mesh)
# ]
# steady_states_after_perturbation = hcat(steady_states_after_perturbation...)
# Δss = steady_states_after_perturbation .- steady_states

# function save_files()
#     @save "Data/parameter_mesh.jld2" parameter_mesh
#     @save "Data/time_series.jld2" time_series
#     @save "Data/steady_states.jld2" steady_states
#     @save "Data/steady_states_after_perturbation.jld2" Δss

#     h5open("Data/ensemble_ts.h5", "w") do file
#         for i in 1:length(time_series)
#             write(file, "ts_$i", ts[i])
#         end
#     end
# end