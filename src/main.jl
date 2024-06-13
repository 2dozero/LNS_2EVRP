include("population.jl")
include("read_tevrp.jl")
include("destroy_operator.jl")
include("repair_operator.jl")
include("2-opt/2_opt_algorithm.jl")
include("2-opt/calculate.jl")
include("2-opt/generate.jl")

instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
first_level_routes, second_level_routes = initial_solution(instance)
customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
# @show second_level_routes
# @show customer_pool
first_level_routes, second_level_routes = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
@show second_level_routes
s_prime = []
for routes in second_level_routes
    for route in routes
        result = two_opt_algorithm_all_possible(instance, "direct", route)
        push!(s_prime, result)
        @show s_prime
    end
end
@show s_prime