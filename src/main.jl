include("population.jl")
include("read_tevrp.jl")
include("destroy.jl")
include("repair.jl")
include("2-opt/2_opt.jl")
include("2-opt/calculate.jl")

function calculate_total_cost(instance::TEVRP_Instance, routes::Vector{Vector{Vector{Int64}}})
    total_cost = 0.0
    for route in routes
        for tour in route
            if !isempty(tour)
                total_cost += calculate_distance(instance, tour)
            end
        end
    end
    return total_cost
end

function LNS(instance::TEVRP_Instance)
    i = 0
    best_dist = Inf
    update_count = 0

    first_level_routes, second_level_routes = initial_solution(instance)
    @show second_level_routes
    initial = deepcopy(second_level_routes)

    while update_count < 100
        customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
        first_level_routes, s_p = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
        
        s_p_val = calculate_total_cost(instance, second_level_routes)

        if i == 20  # 특정 주기마다 로컬 검색을 수행합니다.
            s_p = localsearch(instance, second_level_routes)
            s = s_p
            i = 0
        end

        s_val = calculate_total_cost(instance, initial)

        if s_p_val < s_val
            s = deepcopy(s_p)
            i = 0
        else
            i += 1
        end

        if s_p_val < best_dist
            best_dist = s_p_val
        end
        update_count += 1
        # @show second_level_routes
        @show update_count, best_dist
    end
    @show second_level_routes
    return best_dist
end

instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
best_route_distance = LNS(instance)
println("Best route distance: ", best_route_distance)
