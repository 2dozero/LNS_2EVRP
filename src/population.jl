include("read_tevrp.jl")

function roulette_wheel_selection(probabilities)
    cumulative_sum = cumsum(probabilities)
    random_number = rand()
    for i in 1:length(cumulative_sum)
        if cumulative_sum[i] > random_number
            return i
        end
    end
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
    return customer_assign_chromosome
end



instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
initial_solution(instance)
