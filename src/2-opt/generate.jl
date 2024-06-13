using Random

function generate_random_instance(n, seed = 1234)
    Random.seed!(seed)
    x = rand(n) .* 1000
    y = rand(n) .* 1000
    dist_matrix = zeros(n, n)
    for i in 1:n
        for j in i+1:n
            dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
            dist_matrix[j, i] = dist_matrix[i, j]
        end
    end
    return x, y, dist_matrix
end

function initial_tour(n)
    tour = [(i, i+1) for i in 1:n-1]
    push!(tour, (n, 1))
    return tour
end
