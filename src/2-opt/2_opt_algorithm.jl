include("calculate.jl")
include("generate.jl")

function swap_arc(i, j, route)
    i_index = findall(x -> x == i, route)[1]
    j_index = findall(x -> x == j, route)[1]
    if i_index > j_index
        i_index, j_index = j_index, i_index
    end
    route[i_index:j_index] = reverse(route[i_index:j_index])
    n = length(route)
    tour = [(route[i], route[i % n + 1]) for i in 1:n]
    return tour, route
end

function two_opt_algorithm_all_possible(instance::TEVRP_Instance, calc_method, route)
    n = length(route)
    tour = [(route[i], route[i % length(route) + 1]) for i in 1:length(route)]
    improvement = true
    while improvement
        improvement = false
        best_delta = 0
        best_i, best_j = 1, 1  # Initialize best_i and best_j
        for i in 2:n
            for j in i+2:n
                if abs(i - j) < 2 || abs(i - j) >= n - 1
                    continue
                else
                    if calc_method == "direct"
                        delta = cal_cost_swap_arc(tour[i-1], tour[j], instance.distance_matrix)
                    else
                        tour_length = calc_tour_length(tour, instance.distance_matrix)
                        new_route = copy(route)
                        new_tour, new_route = swap_arc(route[i], route[j], new_route)
                        new_tour_length = calc_tour_length(new_tour, instance.distance_matrix)
                        delta = new_tour_length - tour_length
                    end
                    if delta < best_delta
                        best_delta = delta
                        best_i = i
                        best_j = j
                    end
                end
            end
        end
        if best_delta < 0
            tour, route = swap_arc(route[best_i], route[best_j], route)
            improvement = true
        end
    end
    return route
end

# include("../read_tevrp.jl")
# instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")
# route = [12, 6, 7, 9, 10, 15, 18, 17]
# @show route
# r1 = two_opt_algorithm_all_possible(instance, "direct", route)
# @show r1
# r2 = two_opt_algorithm_all_possible(instance, "else", route)
# @show r2
