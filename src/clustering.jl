using Clustering, JLD2
using DifferentialEquations
using DynamicAxisWarping, Distances
using DataFrames

function get_ode_time_series()
    if !isfile("Data/time_series.jld2")
        include("run_ensemble.jl")
        time_series = run_ensemble_simulations(
            make_ODE_ensemble_problem(model, make_parameter_mesh())
        )
        @save "Data/time_series.jld2" time_series
    else
        time_series = load("Data/time_series.jld2")["time_series"]
    end
    return time_series
end

function get_distance_matrix()
    ode_time_series = get_ode_time_series()

    function calculate_distance_matrix(time_series)
        distance_matrix = [dtw(ts1, ts2)[1] for ts1 in time_series, ts2 in time_series]
        return distance_matrix
    end

    if !isfile("Data/distance_matrix.jld2")
        distance_matrix = calculate_distance_matrix(ode_time_series)
        @save "Data/distance_matrix.jld2" distance_matrix
    else
        distance_matrix = load("Data/distance_matrix.jld2")["distance_matrix"]
    end
    return distance_matrix
end

function get_time_series_clustering(n_clusters)
    if !isfile("Data/time_series_$(n_clusters)_clusters.jld2")
        clusters = kmedoids(get_distance_matrix(), n_clusters)
        @save "Data/time_series_$(n_clusters)_clusters.jld2" clusters
    else
        clusters = load("Data/time_series_$(n_clusters)_clusters.jld2")["clusters"]
    end
    return clusters, get_ode_time_series()
end

function get_steady_states()
    if !isfile("Data/steady_states.jld2")
        include("get_steady_states.jl")
    else
        steady_states = load("Data/steady_states.jld2")["steady_states"]
    end
    return steady_states
end


function get_crisp_clusters(n_clusters)
    steady_states = get_steady_states()
    if !isfile("Data/steady_state_$(n_clusters)_clusters.jld2")
        clusters = kmeans(steady_states, n_clusters)
        @save "Data/steady_state_$(n_clusters)_clusters.jld2" clusters
    else
        clusters = load("Data/steady_state_$(n_clusters)_clusters.jld2")["clusters"]
    end
    return clusters, steady_states
end

## Fuzzy Cluster the steady states

function get_fuzzy_clusters(n_clusters, fuzziness=4)
    steady_states = get_steady_states()
    if !isfile("Data/fuzzy_steady_state_$(n_clusters)_clusters.jld2")
        fuzz = fuzzy_cmeans(steady_states, n_clusters, fuzziness)
        @save "Data/fuzzy_steady_state_$(n_clusters)_clusters.jld2" fuzz
    else
        fuzz = load("Data/fuzzy_steady_state_$(n_clusters)_clusters.jld2")["fuzz"]
    end
    return fuzz, steady_states
end