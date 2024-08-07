include("clustering.jl")
include("plot_fuzzy_ss_clusters.jl")

using CairoMakie
using DataFrames, DataFramesMeta
using JLD2

clustering, steady_states = get_fuzzy_clusters(2)
parameters = load("Data/parameter_mesh.jld2")["parameter_mesh"];


data = DataFrame(parameters)
data = rename(data, [:rx, :ry, :a, :b, :c, :d])


data

clustering.weights
for (index,weight) in enumerate(eachcol(clustering.weights))
    data[!, "cluster_$(index)_weight"] = weight
end

data[!, "steady_states_X"] = steady_states[1, :]
data[!, "steady_states_Y"] = steady_states[1, :]
data.colors = get_colours(clustering.weights);


high_competition = @subset data begin
    :c .>= 4.5
    :d .>= 4.5
end

low_competition = @subset data begin
    :c .<= 1.5
    :d .<= 1.5
end

fig = Figure()

scatter!(Axis(fig[1,1:2]),data.a, data.b; color=data.colors)

scatter!(
    Axis(fig[2, 1]),
    high_competition.a,
    high_competition.b;
    color=high_competition.colors,
)
scatter!(
    Axis(fig[2, 2]),
    low_competition.a, 
    low_competition.b;
    color=low_competition.colors
)

fig

