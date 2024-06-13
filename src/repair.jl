using LinearAlgebra
using Random

# include("read_tevrp.jl")
# include("population.jl")
# include("destroy_operator.jl")


function check_feasibility(instance::TEVRP_Instance, second_level_routes)
    first_level_feasible = true
    for (i, routes) in enumerate(second_level_routes)
        load = 0
        for route in routes
            for j in route
                load += instance.customers[j][3]
            end
        end
        if load > instance.trucks_cap
            first_level_feasible = false
            break
        end
    end
    return first_level_feasible
end

function calculate_distance(instance::TEVRP_Instance, route::Vector{Int64})::Float64
    depot = 1
    k = size(instance.depot, 2) + size(instance.satellites, 1)
    distance = 0.0
    # @show typeof(distance)
    # @show typeof(instance.distance_matrix[depot, route[1] + k])
    distance += instance.distance_matrix[depot, route[1] + k]
    # @show distance
    for i in 1:length(route) - 1
        distance += instance.distance_matrix[route[i] + k, route[i + 1] + k]
    end
    distance += instance.distance_matrix[route[end] + k, depot]
    return distance
end




function calculate_insertion_cost(instance::TEVRP_Instance, route, customer, pos)
    second_route = deepcopy(route)
    insert!(second_route, pos, customer)
    # before_distance, after_distance = 0.0, 0.0
    # depot = 1
    # k = size(instance.depot, 2) + size(instance.satellites, 1)

    before_distance = calculate_distance(instance, route)
    # before_distance += instance.distance_matrix[depot, route[1]+k]
    # for i in 1:length(route) - 1
    #     before_distance += instance.distance_matrix[route[i]+k, route[i + 1]+k]
    # end
    # before_distance += instance.distance_matrix[route[end]+k, depot]

    after_distance = calculate_distance(instance, second_route)
    # after_distance += instance.distance_matrix[depot, second_route[1]+k]
    # for i in 1:length(second_route) - 1
    #     after_distance += instance.distance_matrix[second_route[i]+k, second_route[i + 1]+k]
    # end
    # after_distance += instance.distance_matrix[second_route[end]+k, depot]
    insertion_cost = after_distance - before_distance
    return insertion_cost
end

function greedy_insertion(instance::TEVRP_Instance, customer_pool::Vector{Any}, first_level_routes::Vector{Any}, second_level_routes::Vector{Vector{Vector{Int64}}})
    # @show second_level_routes
    while !isempty(customer_pool)
        # @show customer_pool
        customer = pop!(customer_pool)
        # @show customer
        best_satellite = 0
        best_route = []
        best_cost = Inf
        best_pos = 0
        # @show second_level_routes

        for (sat_index, sat_routes) in enumerate(second_level_routes)
            for route in sat_routes
                if isempty(route)
                    continue
                end
                for pos in 1:(length(route) + 1)
                    cost = calculate_insertion_cost(instance, route, customer, pos)
                    if cost < best_cost
                        temp_route = deepcopy(route)
                        insert!(temp_route, pos, customer)
                        if check_feasibility(instance, temp_route)
                            best_cost = cost
                            best_route = route
                            best_satellite = sat_index
                            best_pos = pos
                        else
                            println("Found Infeasible")
                            continue
                        end
                    end
                end
            end
        end
        # @show best_cost, best_route, best_pos
        # if best_cost < Inf
        insert!(best_route, best_pos, customer)
        # else
        #     for sat_index in 1:length(second_level_routes)
        #         if length(second_level_routes[sat_index]) < instance.cf_max_sat
        #             push!(second_level_routes[sat_index], [1, customer, 1])
        #             break
        #         end
        #     end
        # end
        # @show best_route
    end
    return first_level_routes, second_level_routes
end


# instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
# first_level_routes, second_level_routes = initial_solution(instance)
# customer_pool, second_level_routes = random_removal(instance, second_level_routes, 3)
# first_level_routes, second_level_routes = greedy_insertion(instance, customer_pool, first_level_routes, second_level_routes)
# @show first_level_routes
# @show second_level_routes
