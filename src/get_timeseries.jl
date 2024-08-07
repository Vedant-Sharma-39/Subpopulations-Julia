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


function make_ODE_ensemble_problem(
    model, parameter_mesh, initial_conditions=[0.01, 0.01], time_span=[0.0, 100.0]
)
    dummy_params = [1.0, 1.0, 0.1, 0.1, 1.0, 1.0]
    u0 = initial_conditions
    tspan = time_span

    change_params_problem_function = make_change_param_problem_function(parameter_mesh)

    ode_problem = ODEProblem(model, u0, tspan, dummy_params)
    ensemble_problem = EnsembleProblem(
        ode_problem; prob_func=change_params_problem_function
    )
    return ensemble_problem
end

time_series = run_ensemble_simulations(
    make_ODE_ensemble_problem(model, make_parameter_mesh())
);

@save "Data/time_series1.jld2" time_series

