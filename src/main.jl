include("population.jl")
include("read_tevrp.jl")
include("destroy_operator.jl")
include("repair_operator.jl")

instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
first_level_routes, second_level_routes = initial_solution(instance)
customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
@show second_level_routes
@show customer_pool
first_level_routes, second_level_routes = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
@show second_level_routes