using TestItems

@testitem "generate_ts.jl" default_imports = false begin
    include("test_setup.jl")
    @test parameter_mesh == make_param_list(get_param_ranges())
end