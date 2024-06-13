include("read_tevrp.jl")
include("saving_algorithm.jl")

function roulette_wheel_selection(probabilities)
    cumulative_sum = cumsum(probabilities)
    random_number = rand() * cumulative_sum[end]
    for i in 1:length(cumulative_sum)
        if cumulative_sum[i] > random_number
            return i
        end
    end
    return length(cumulative_sum)
end

function initial_solution(instance::TEVRP_Instance)
    # every customer is first assigned to a satellite facility by a roulette wheel selection
    customer_assign_chromosome = Vector{Int64}(undef, size(instance.customers, 1))
    customer_satellite_distances = Array{Float64, 2}(undef, size(instance.customers, 1), size(instance.satellites, 1)) # (21 X 2)
    for i in 1:size(instance.customers, 1)
        for j in 1:size(instance.satellites, 1)
            customer_satellite_distances[i, j] = norm(instance.customers[i][1:2] - instance.satellites[j])
        end
    end

    selection_prob = 1 ./ customer_satellite_distances
    selection_prob ./= sum(selection_prob, dims=2)
    for i in 1:size(instance.customers, 1)
        customer_assign_chromosome[i] = roulette_wheel_selection(selection_prob[i, :])
    end

    satellite_index = [] # Int[]
    for i in 1:size(instance.satellites, 1)
        satellite_index = push!(satellite_index, findall(x -> x == i, customer_assign_chromosome))
    end
    # @show satellite_index
    # @show satellite_index[1]
    # @show satellite_index[2]

    # Generate second-level routes for each satellite(체크해보기)
    second_level_routes = []
    for i in 1:length(satellite_index)
        if !isempty(satellite_index[i])
            routes = satellite_index[i]
            # @show routes
            second_level_route = clarke_weight_savings_algorithm(instance, routes)
            push!(second_level_routes, second_level_route)
        else
            push!(second_level_routes, [])
        end
    end
    # @show second_level_routes

    # Generate first-level routes for each depot
    first_level_routes = []
    depot_index = [i for i in 1:size(instance.satellites, 1)]
    satellite_loads = []
    satellite_loads = []
    for i in 1:length(satellite_index)
        satellite_load = sum([instance.customers[j][3] for j in satellite_index[i]])
        push!(satellite_loads, satellite_load)
    end
    # @show satellite_loads
    first_level_route = clarke_weight_savings_algorithm(instance, depot_index, satellite_loads)
    push!(first_level_routes, first_level_route)
    # @show first_level_routes
    return first_level_routes, second_level_routes
end
