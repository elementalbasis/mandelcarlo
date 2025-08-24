include("integrate.jl")

threshold = 10000
sample_size = 1000000
target_uncertainty = 0.0001
xmin = -2
xmax = 2
ymin = -2
ymax = 2
box = [xmin, xmax, ymin, ymax]
sub_box_address = ""

A, u_A = stratified_sampling(threshold, box, sub_box_address, sample_size, target_uncertainty)

println(A)
println(u_A)
