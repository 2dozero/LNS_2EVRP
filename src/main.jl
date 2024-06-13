include("population.jl")
include("read_tevrp.jl")
include("destroy_operator.jl")
include("repair_operator.jl")
include("2-opt/2_opt_algorithm.jl")
include("2-opt/calculate.jl")

# Vector{Vector{Vector{Int}}}()

# instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
# first_level_routes, second_level_routes = initial_solution(instance)
# @show second_level_routes
# customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
# @show second_level_routes
# @show customer_pool
# first_level_routes, second_level_routes = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
# @show second_level_routes

instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
first_level_routes, second_level_routes = initial_solution(instance)
i = 0
while true
    customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
    first_level_routes, second_level_routes = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
    if i == 15 # w
        s_p = localsearch(instance, second_level_routes)
        s = s_p
        i = 0
    elseif
        for routes in second_level_routes
            for route in routes
                dist = calculate_distance(instance, route)
                cum_dist += dist
            end
        end
        if cum_dist < 1.1 * best_dist
            s_p = localsearch(instance, second_level_routes)
        end
    end
    if calculate_distance(instance, s_p) < calculate_distance(instance, s)
        s = s_p
        i = 0
    else
        i += 1
    end
    if calculate_distance(instance, s) < best_dist
        best_dist = calculate_distance(instance, s)
