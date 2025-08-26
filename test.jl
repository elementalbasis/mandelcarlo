using ArgParse
using UUIDs

include("integrate.jl")

args = ArgParseSettings()
@add_arg_table args begin
	"--threshold"
		help = "number of Mandelbrot iterations"
		arg_type = Int
		default = 10000
	"--sample-size"
		help = "number of data points to use for Monte Carlo integration"
		arg_type = Int
		default = 10000
	"--target-uncertainty"
		help = "target uncertainty for recursive sampling"
		arg_type = Float64
		default = Inf
end

parsed_args = parse_args(args)
threshold = parsed_args["threshold"]
sample_size = parsed_args["sample-size"]
target_uncertainty = parsed_args["target-uncertainty"]
xmin = -2
xmax = 2
ymin = -2
ymax = 2
box = [xmin, xmax, ymin, ymax]
sub_box_address = ""
run_id = uuid4() #string(rand(UInt128), base=16, pad=32)

A, u_A = stratified_sampling(threshold, box, sub_box_address, sample_size, target_uncertainty, run_id)


println(join([run_id,
	      "M" * string(threshold),
	      "N" * string(sample_size),
	      "U" * string(target_uncertainty),
	      "TOTAL",
	      A, u_A, A/(xmax-xmin)/(ymax-ymin)], '\t'))

#println("A = ", A)
#println("u(A) = ", u_A)
