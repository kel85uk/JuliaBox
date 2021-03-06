
using JuMP, Plasmo, MPI

println("Hola")
# Comment out this line if you want to run in serial
MPI.Init()

xi = [[7,7] [11,11] [13,13]]

# create empty Plasmo model
graph = GraphModel()
master = Model()
master_node = add_node(graph,master)

@variable(master, 0 <= x[i=1:2] <= 5, Int)
@objective(master, Min, -1.5 * x[1] - 4 * x[2])
children_nodes = Array{NodeOrEdge}(3)
for s = 1:3
    # create a JuMP.Model block linked to m with id s and probability 1/3
    blk = Model()
    child_node = add_node(graph,blk)
    children_nodes[s] = child_node
    @variable(blk, y[j=1:4], Bin)
    @objective(blk, Min, -16 * y[1] + 19 * y[2] + 23 * y[3] + 28 * y[4])
    @linkconstraint(graph, 2 * y[1] + 3 * y[2] + 4 * y[3] + 5 * y[4] <= xi[1,s] - master[:x][1])
    @linkconstraint(graph, 6 * y[1] + y[2] + 3 * y[3] + 2 * y[4] <= xi[2,s] - master[:x][2])
end

solve_types = [:Dual, :Benders, :Extensive]
status = dsp_solve(graph,master_node,children_nodes,solve_type = solve_types[2])  #probabilities are 1/NS by default
#solve_type = solve_types[1])# param = "myparam.txt")

getobjectivevalue(master)

# Comment out this line if you want to run in serial
MPI.Finalize()
