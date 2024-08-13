include("clustering.jl")
include("plot_fuzzy_ss_clusters.jl")

using CairoMakie
using DataFrames, DataFramesMeta
using JLD2

clustering, steady_states = get_fuzzy_clusters(2; fuzziness=3.5, reset_cache=false)
parameters = load("Data/parameter_mesh.jld2")["parameter_mesh"];

data = DataFrame(parameters)
data = rename(data, [:rx, :ry, :a, :b, :c, :d])

clustering.weights
for (index, weight) in enumerate(eachcol(clustering.weights))
    data[!, "cluster_$(index)_weight"] = weight
end

data[!, "steady_states_X"] = steady_states[1, :]
data[!, "steady_states_Y"] = steady_states[2, :]
data[!, "total_population"] = data.steady_states_X + data.steady_states_Y
data[!, "cell_fraction"] = data.steady_states_X ./ data.total_population
data[!, "bias"] = (data.b - data.a) ./ (data.a + data.b)
data[!, "trans"] = (data.a + data.b) ./ 2

data.colors = get_colours(clustering.weights);

low_c_low_d = @subset(data, :c .<= 2, :d .<= 2)
low_c_high_d = @subset(data, :c .<= 2, :d .>= 4)
high_c_low_d = @subset(data, :c .>= 4, :d .<= 2)
high_c_high_d = @subset(data, :c .>= 4, :d .>= 4)

cases = [low_c_high_d, high_c_low_d, low_c_low_d, high_c_high_d]

fig = Figure()
axes = [Axis(fig[i, j]) for i in 1:2, j in 1:2]
for (index, case) in enumerate(cases)
    scatter!(
        axes[index],
        case.total_population,
        case.cell_fraction;
        color=case.colors,
        alpha=0.008,
    )
end
fig

# Want to make sub-grids for the effect of 'a' and 'b' on the steady states
# bias = (b - a)/(a + b) 
# trans = (a+b)/2
# a = trans * (1 - bias), b = trans * (1 + bias)

function divide_data_in_cases(data, x, y, (x_low, y_low), (x_high, y_high))
    divided_data = Matrix{DataFrame}(undef, 2, 2)

    divided_data[1, 2] = @subset(data, data[:, x] .<= x_low, data[:, y] .<= y_low)
    divided_data[2, 1] = @subset(data, data[:, x] .>= x_high, data[:, y] .>= y_high)
    divided_data[1, 1] = @subset(data, data[:, x] .<= x_low, data[:, y] .>= y_high)
    divided_data[2, 2] = @subset(data, data[:, x] .>= x_high, data[:, y] .<= y_low)

    return divided_data
end

function plot_panel!(panel, data, x, y, color; colormap=:PiYG, alpha=0.6, markersize=3)
    n_grid = 9
    bottom_bar = Axis(panel[n_grid, 2:n_grid]; xticklabelsvisible=false)
    left_bar = Axis(panel[1:(n_grid - 1), 1]; yticklabelsvisible=false)
    panel = Axis(panel[1:(n_grid - 1), 2:n_grid])
    hidespines!(bottom_bar, :l, :r, :t)
    hidespines!(left_bar, :b, :t, :r)
    linkxaxes!(bottom_bar, panel)
    linkyaxes!(left_bar, panel)
    x = data[:, x]
    y = data[:, y]
    color = data[:, color]
    xlims!(panel, 0, 1)
    ylims!(panel, 0, 1)
    density!(left_bar, y; direction=:y)
    density!(bottom_bar, x)
    scatter!(
        panel,
        x,
        y;
        color=color,
        colormap=colormap,
        alpha=alpha,
        markersize=markersize,
        colorrange=(-1, 1),
    )

    return nothing
end

function make_square_layout(fig)
    return [
        fig[1, 1] fig[2, 1]
        fig[1, 2] fig[2, 2]
    ]
end

function powder_block_matrix(matrix)
    return reduce(hcat, reduce.(vcat, eachcol(matrix)))
end

with_theme(theme_dark()) do
    fig = Figure(; size=(1200, 1200))
    grid_grid = powder_block_matrix(make_square_layout.(make_square_layout(fig)))
    data_competition = divide_data_in_cases(data, :c, :d, (2, 2), (3, 3))
    data_competition_transition = powder_block_matrix(
        (
            data -> divide_data_in_cases(data, :a, :b, (0.25, 0.25), (0.75, 0.75))
        ).(data_competition),
    )

    f = (panel, data) -> plot_panel!(panel, data, :cell_fraction, :total_population, :bias)
    f_muted =
        (panel, data) ->
            plot_panel!(panel, data, :cell_fraction, :total_population, :bias; alpha=0.01)

    f.(grid_grid, data_competition_transition)

    data_competition_competition = repeat(data_competition; inner=(2, 2))

    f_muted.(grid_grid, data_competition_competition)

    fig

    save("Plots/poster_bias_ranged.png", fig)
end

data_competition = divide_data_in_cases(data, :c, :d, (2, 2), (3, 3))
data_competition_transition =
    (
        data -> divide_data_in_cases(data, :a, :b, (0.25, 0.25), (0.75, 0.75))
    ).(data_competition)

titles = ["Low C, High D" "High C, High D"; "Low C, Low D" "High C, Low D"]

with_theme(theme_dark()) do
    for (index, data) in enumerate(data_competition_transition)
        fig = Figure(; size=(800, 800))
        f =
            (panel, data) ->
                plot_panel!(panel, data, :cell_fraction, :total_population, :bias)
        f.(make_square_layout(fig), data)
        fig[0, :] = Label(fig, titles[index])
        save("Plots/poster_bias_ranged_$(index).png", fig)
    end
end