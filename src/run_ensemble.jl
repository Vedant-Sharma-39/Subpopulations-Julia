using DifferentialEquations, ProgressLogging, SciMLBase
using JLD2, HDF5

function model(du, u, p, t)
    x, y = u
    rx, ry, a, b, c, d = p

    du[1] = rx * x * (1 - (x + c * y)) - a * x + b * y
    return du[2] = ry * y * (1 - (d * x + y)) + a * x - b * y
end


function make_parameter_mesh()
    function make_mesh_from_ranges(param_ranges::Vector{})
        return collect(Iterators.product(param_ranges...))
    end
    return make_mesh_from_ranges(get_param_ranges())
end

function format_steady_states_results(results::SciMLBase.EnsembleSolution)
    results = [solution.u for solution in (results.u)]
    results = hcat(results...)
    return results
end

function format_time_series_results(results::SciMLBase.EnsembleSolution)
    results =  [result.u for result in results.u]
    return [hcat(result...) for result in results]
end

function make_change_param_problem_function(parameter_mesh)
    return function change_params(prob::SciMLBase.AbstractSciMLProblem, i, repeat)
        param_set = parameter_mesh[i]
        return remake(prob; p=param_set)
    end
end

function run_ensemble_simulations(
    ensemble_problem::EnsembleProblem, num_trajectories::Int=100
)
    function run(ensemble_problem::EnsembleProblem{<:ODEProblem})
        results = solve(
            ensemble_problem,
            Tsit5();
            saveat=1,
            trajectories=num_trajectories,
            progress=true,
        )
        return format_time_series_results(results)
    end

    function run(ensemble_problem::EnsembleProblem{<:SteadyStateProblem})
        results = solve(
            ensemble_problem, DynamicSS(); trajectories=num_trajectories, progress=true
        )
        return format_steady_states_results(results)
    end

    return run(ensemble_problem)
end

