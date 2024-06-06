using LinearAlgebra

# Clarke-Wright Savings Algorithm in Julia

function clarke_wright_savings_algorithm(distances::Matrix{Float64}, depot::Int, demands::Vector{Float64}, capacity::Float64)
    n = size(distances, 1) - 1  # number of customers
    savings = []

    # Calculate savings
    for i in 1:n
        for j in i+1:n
            save = distances[depot, i+1] + distances[depot, j+1] - distances[i+1, j+1]
            push!(savings, (save, i+1, j+1))
        end
    end

    # Sort savings in descending order
    sorted_savings = sort(savings, by = x -> -x[1])

    # Initialize routesㄴ
    routes = [[i+1] for i in 1:n]
    route_loads = deepcopy(demands[2:end])

    # Merge routes based on savings
    for (save, i, j) in sorted_savings
        route_i = find_route(routes, i)
        route_j = find_route(routes, j)
        
        if route_i != route_j && route_loads[route_i] + route_loads[route_j] <= capacity
            # Merge routes
            append!(routes[route_i], routes[route_j])
            route_loads[route_i] += route_loads[route_j]
            deleteat!(routes, route_j)
            deleteat!(route_loads, route_j)
        end
    end

    return routes
end

# Helper function to find which route a customer belongs to
function find_route(routes, customer)
    for (k, route) in enumerate(routes)
        if customer in route
            return k
        end
    end
    return 0  # should not happen
end

# Example usage with a more complex example
distances = [
    0.0 2.0 9.0 10.0 7.0;
    2.0 0.0 6.0 4.0 3.0;
    9.0 6.0 0.0 8.0 5.0;
    10.0 4.0 8.0 0.0 6.0;
    7.0 3.0 5.0 6.0 0.0
]
depot = 1
demands = [0.0, 1.0, 2.0, 2.0, 1.0]
capacity = 4.0

routes = clarke_wright_savings_algorithm(distances, depot, demands, capacity)
println("Optimized Routes: ", routes)
