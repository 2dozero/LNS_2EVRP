using LinearAlgebra
function calculate_distance_matrix(nodes::Vector{Vector{Int64}})
    n = length(nodes)
    distance_matrix = Array{Float64, 2}(undef, n, n)
    for i = 1:n
        for j = 1:n
            distance_matrix[i, j] = norm(nodes[i] - nodes[j])
        end
    end
    return distance_matrix
end

struct TEVRP_Instance
    trucks_num::Int64
    trucks_cap::Int64
    trucks_cost_dist::Int64
    trucks_fixcost::Int64
    cf_max_sat::Int64
    cf_num::Int64
    cf_cap::Int64
    cf_cost_dist::Int64
    cf_fixcost::Int64
    depot::Vector{Int64}
    satellites::Vector{Vector{Int64}}
    customers::Vector{Vector{Int64}}
    distance_matrix:: Array{Float64, 2}
end

function read_tevrp(file_name)
    f = open(file_name)
    lines = readlines(f)

    # Parse trucks
    line = split(lines[3], ",")
    trucks_num, trucks_cap, trucks_cost_dist, trucks_fixcost = parse(Int64, line[1]), parse(Int64, line[2]), parse(Int64, line[3]), parse(Int64, line[4]) 

    # Parse city freighters
    line = split(lines[6], ",")
    cf_max_sat, cf_num, cf_cap, cf_cost_dist, cf_fixcost = parse(Int64, line[1]), parse(Int64, line[2]), parse(Int64, line[3]), parse(Int64, line[4]), parse(Int64, line[5])

    # Parse stores
    line = split(lines[9], "  ")
    N = length(line)
    depot = Vector{Int64}(undef, 2)
    satellites = [Vector{Int64}(undef, 2) for _ in 1:N-1]
    for i = 1:N
        if i == 1
            depot = [parse(Int64, s) for s in split(line[i], ",")]
        else
            satellites[i-1] = [parse(Int64, s) for s in split(line[i], ",")]
        end
    end

    # Parse customers
    line = split(lines[12], "  ")
    N = length(line) # 왜 101개로 잡히지? check 필요
    customers = [Vector{Int64}(undef, 3) for _ in 1:N]
    for i = 1:N
        customers[i] = [parse(Int64, s) for s in split(line[i], ",")]
    end

    # Distance matrix
    total_nodes = [[depot]; satellites; [customer[1:2] for customer in customers]]
    # @show total_nodes
    # @show typeof(total_nodes)
    distance_matrix = calculate_distance_matrix(total_nodes)
    # @show size(distance_matrix)
    return TEVRP_Instance(trucks_num, trucks_cap, trucks_cost_dist, trucks_fixcost, cf_max_sat, cf_num, cf_cap, cf_cost_dist, cf_fixcost, depot, satellites, customers, distance_matrix)
end

# instance = read_tevrp("benchmark_instances/E-n22-k4-s6-17.txt")