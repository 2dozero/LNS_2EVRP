using Statistics
using Plots
using FileIO

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

function plot_routes(instance::TEVRP_Instance, routes::Vector{Vector{Vector{Int64}}})
    plot()
    
    # Plot depot
    scatter!([instance.depot[1]], [instance.depot[2]], marker=:utriangle, label="Depot", color=:red)

    # Plot satellites (only label the first one)
    for (i, satellite) in enumerate(instance.satellites)
        scatter!([satellite[1]], [satellite[2]], marker=:rect, label=i == 1 ? "Satellite" : false, color=:blue)
    end

    # Plot customers with a label
    all_customers_x = [instance.customers[customer][1] for route in routes for tour in route for customer in tour]
    all_customers_y = [instance.customers[customer][2] for route in routes for tour in route for customer in tour]
    scatter!(all_customers_x, all_customers_y, marker=:circle, label="Customer", color=:green)

    # Plot routes
    for (i, route) in enumerate(routes)
        satellite = instance.satellites[i]
        for tour in route
            if !isempty(tour)
                x = [satellite[1]]  # Start at the satellite
                y = [satellite[2]]  # Start at the satellite
                append!(x, [instance.customers[customer][1] for customer in tour])
                append!(y, [instance.customers[customer][2] for customer in tour])
                push!(x, satellite[1])  # Return to the satellite
                push!(y, satellite[2])  # Return to the satellite
                plot!(x, y, label=false)
                scatter!(x, y, label=false)
            end
        end
    end
end

function LNS(instance::TEVRP_Instance)
    i = 0
    best_dist = Inf
    count = 0
    update_count = 0

    first_level_routes, second_level_routes = initial_solution(instance)
    @show second_level_routes
    initial = deepcopy(second_level_routes)

    anim = Animation()
    
    for count in 1:100
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

        @show count, best_dist

        # Plot the routes at this iteration
        plot_routes(instance, second_level_routes)
        frame(anim)
        # Save each frame to the 'frames' directory
        savefig("frames/frame_$(count).png")
    end

    # Add extra frames to create a delay at the end of the GIF
    for _ in 1:(10 * 5)  # 10 seconds delay at 5 fps
        plot_routes(instance, second_level_routes)
        frame(anim)
        # Save each frame to the 'frames' directory
        savefig("frames/frame_delay_$(count).png")
        count += 1
    end

    gif(anim, "routes_animation.gif", fps=5)  # Increase fps for faster GIF

    return best_dist, update_count
end

# Ensure the 'frames' directory exists to save the plots
if !isdir("frames")
    mkdir("frames")
end

# instance = read_tevrp("benchmark_instances/2a_E-n22-k4-s6-17.txt") # 2a
# instance = read_tevrp("benchmark_instances/2b_E-n51-k5-s2-17.txt") # 2b-1
instance = read_tevrp("benchmark_instances/2b_E-n51-k5-s2-4-17-46.txt") # 2b-2

best_route_distance = LNS(instance)
println("Best route distance: ", best_route_distance)
