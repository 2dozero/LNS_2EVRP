function cal_cost_swap_arc(arc1, arc2, dist_matrix)
    (i, j) = arc1
    (k, l) = arc2
    cost = dist_matrix[i, k] + dist_matrix[j, l] - dist_matrix[i, j] - dist_matrix[k, l]
    return cost
end

function calc_tour_length(tour, dist_matrix)
    n = length(tour)
    tour_length = 0
    for i in 1:n
        tour_length += dist_matrix[tour[i][1], tour[i][2]]
    end
    return tour_length
end