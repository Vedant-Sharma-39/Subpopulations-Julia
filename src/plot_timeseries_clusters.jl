using CairoMakie

clusters, time_series = get_time_series_clustering(3)

function plot_clusters_medoids!(ax, clusters, time_series)
    n_clusters = size(clusters.medoids, 1)
    n_dim = size(time_series[1], 1)

    colors = Makie.to_colormap(:Set2_6)[1:(n_clusters)]
    line_styles = [:dash, :solid, :dot]

    ls = []

    for (i, cluster_index) in enumerate(clusters.medoids)

        # Keep the colour same for all dimensions of a cluster
        # But change the colour for each cluster
        # While changing the line style for each dimension

        for dim in 1:n_dim
            line = lines!(
                ax,
                time_series[cluster_index][dim, :];
                color=colors[i],
                linestyle=line_styles[dim],
            )

            if dim == 1
                push!(ls, line)
            end
        end
    end

    axislegend(ax, ls, ["Cluster $i" for i in 1:n_clusters])

end

function plot_time_series_clusters(time_series, clusters)
    f = Figure()
    ax = Axis(f[1, 1])
    plot_clusters_medoids!(ax, clusters, time_series)
    return f
end

plot_time_series_clusters(time_series, clusters)
