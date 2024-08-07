using CairoMakie

kmeans_cluster, steady_states = get_crisp_clusters(3)

function plot_cluster_centroids!(ax, kmeans_clusters)
    centers = kmeans_clusters.centers'
    scatter!(ax, centers[:, 1], centers[:, 2])
end

function plot_clusters(ax, clusters, steady_states)
    n_clusters = size(clusters.assignments, 1)
    cluster_points = [steady_states[:, clusters.assignments .== i] for i in 1:n_clusters]

    for i in 1:n_clusters
        scatter!(ax, cluster_points[i][1, :], cluster_points[i][2, :]; label="Cluster $i")
    end
end

fig = Figure()
ax = Axis(fig[1, 1])
plot_clusters(ax, kmeans_clusters, steady_states)
fig