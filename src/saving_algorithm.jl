include("read_tevrp.jl")

using LinearAlgebra

function clarke_weight_savings_algorithm(instance::TEVRP_Instance, routes::Vector{Int64})
    savings = []
    # distance matrix : (24, 24). depot = 1, satellites = 2:3, customers = 4:24
    k = size(instance.depot, 2) + size(instance.satellites, 1)
    for i in k+1:k+size(instance.customers, 1)
        for j in k+1:k+size(instance.customers, 1)
            if i == j
                continue
            end
            save = instance.distance_matrix[1, i] + instance.distance_matrix[1, j] - instance.distance_matrix[i, j]
            push!(savings, (save, i, j))
        end
    end
    sorted_savings = sort(savings, by = x -> -x[1])

    # routes = [[i] for i in 1:size(instance.customers, 1)]
    # routes = [[i] for i in k+1:k+size(instance.customers, 1)]
    @show routes
    route_loads = [customer[3] for customer in instance.customers]
    route_loads = route_loads[routes]
    @show route_loads
    @show length(routes), length(route_loads)

    # Merge routes based on savings
    for (save, i, j) in sorted_savings
        route_i = find_route(routes, i - k)
        route_j = find_route(routes, j - k)

        if route_i != route_j && route_loads[route_i] + route_loads[route_j] <= instance.cf_cap
            # Merge routes
            append!(routes[route_i], routes[route_j]) ## Error
            route_loads[route_i] += route_loads[route_j]
            deleteat!(routes, route_j)
            deleteat!(route_loads, route_j)
        end
    end

    return routes
end

function find_route(routes, customer)
    for (l, route) in enumerate(routes)
        if customer in route
            return l
        end
    end
    return 0  # should not happen
end

instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
clarke_weight_savings_algorithm(instance, [1, 2, 4, 5, 7, 8, 9, 10, 15, 21])
