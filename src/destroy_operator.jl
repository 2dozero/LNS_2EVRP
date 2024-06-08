using Random

function random_removal(instance::TEVRP_Instance, second_level_routes::Vector{Any}, q::Int64)
    customer_pool = []

    all_customers = []
    for routes in second_level_routes
        for route in routes
            append!(all_customers, route)
        end
    end

    remove_customers = randperm(length(all_customers))[1:q]
    selected_customers = all_customers[remove_customers]
    # @show selected_customers
    for customer in selected_customers
        for routes in second_level_routes
            for route in routes
                if customer in route
                    deleteat!(route, findfirst(isequal(customer), route))
                    break
                end
            end
        end
    end
    append!(customer_pool, selected_customers)
    # @show customer_pool
    return customer_pool, second_level_routes
end

# feroute = Any[[[1], [2]]]
# seroute = Any[[[1, 3, 11, 12, 18], [2, 9, 4, 5, 8, 7]], [[6, 14, 10, 13, 16, 15], [17, 19, 20, 21]]]
# random_removal(instance, seroute, 3)