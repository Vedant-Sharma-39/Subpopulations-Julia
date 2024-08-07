using CairoMakie
using JLD2, Clustering
include("clustering.jl")

function extend_weighted_mean(colors, weights)
    color_mean = Makie.Colors.weighted_color_mean

    function normalise(w1, w2)
        return w1 / (w1 + w2)
    end

    function extend_mean((w1, c1), (w2, c2))
        return color_mean(normalise(w1, w2), c1, c2)
    end

    function partial_mean((w1, c1), (w2, c2))
        return (w1+w2, extend_mean((w1, c1), (w2, c2)))
    end

    return reduce(partial_mean, zip(weights, colors))[2]
end


function get_colours(weights)
    n_clusters = size(weights, 2)
    base_colors = Makie.categorical_colors(:seaborn_bright, n_clusters)
    colors = [extend_weighted_mean(base_colors, w) for w in eachrow(weights)]
    return colors
end

function plot_fuzzy_ss_clusters!(ax, centers, weights)
    scatter!(ax, centers[1, :], centers[2, :])
    scatter!(ax, steady_states[1, :], steady_states[2, :], color=get_colours(weights));
end

# fuzzy_clusters, steady_states = get_fuzzy_clusters(4)
# centers, weights = fuzzy_clusters.centers, fuzzy_clusters.weights

# f = Figure()
# ax = Axis(f[1, 1])
# plot_fuzzy_ss_clusters!(ax, centers, weights)
# f