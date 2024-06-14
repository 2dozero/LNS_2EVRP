using Statistics

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
    count = 0
    update_count = 0

    first_level_routes, second_level_routes = initial_solution(instance)
    @show second_level_routes
    initial = deepcopy(second_level_routes)

    while count < 500
        customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
        first_level_routes, s_p = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
        
        s_p_val = calculate_total_cost(instance, second_level_routes)

        if i == 20
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
            update_count += 1
        end
        count += 1
        # @show second_level_routes
        @show count, best_dist
    end
    # @show update_count
    # @show second_level_routes
    return best_dist, update_count
end

# instance = read_tevrp("benchmark_instances/2a_E-n22-k4-s6-17.txt") # 2a
instance = read_tevrp("benchmark_instances/2b_E-n51-k5-s2-17.txt") # 2b-1
# instance = read_tevrp("benchmark_instances/2b_E-n51-k5-s2-4-17-46.txt") # 2b-2
# instance = read_tevrp("benchmark_instances/2c_E-n51-k5-s2-17.txt") # 2c-1
# instance = read_tevrp("benchmark_instances/2c_E-n51-k5-s2-4-17-46.txt") # 2c-2
# instance = read_tevrp("benchmark_instances/4b_Instance50-49.txt") # 4b
# instance = read_tevrp("benchmark_instances/5_100-5-1.txt") #5-1
# instance = read_tevrp("benchmark_instances/5_100-10-1.txt") #5-2
# instance = read_tevrp("benchmark_instances/5_200-10-1.txt") #5-3


times = Float64[]
best_dists = Float64[]
counts = Int64[]

for _ in 1:100
    run_time = @elapsed begin
        best_dist, update_count = LNS(instance)
        push!(best_dists, best_dist)
        push!(counts, update_count)
    end
    push!(times, run_time)
end

average_time = mean(times)
average_best_dist = mean(best_dists)
average_update_count = mean(counts)

println("Average time for each run: ", average_time, " seconds")
println("Average update count for each run: ", average_update_count)
println("Average best distance for each run: ", average_best_dist)


# best_route_distance = LNS(instance)
# println("Best route distance: ", best_route_distance)