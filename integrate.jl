using Distributed
using Printf
using ProgressMeter
using Measurements
#addprocs(2, exeflags="--project=$(Base.active_project())")
#addprocs(4)

@everywhere using Distributions
@everywhere include("mandelbrot.jl")

#MAX_SAMPLE_SIZE = 50000
#MAX_STRATIFIED_SAMPLING_RECURSION = 6

#MAX_RECURSION = 8

function get_sub_box(box, s)
	xmin, xmax, ymin, ymax = box

	if length(s) == 0
		return box
	end

	xlen = xmax - xmin
	ylen = ymax - ymin
	xcen = (xmin + xmax)/2
	ycen = (ymin + ymax)/2

	cases = Dict(
		     '1' => (+1, +1),
		     '2' => (-1, +1),
		     '3' => (-1, -1),
		     '4' => (+1, -1),
		     )

	c = s[1]
	sign_x, sign_y = cases[c]
	xmax_new = xcen + max(0, sign_x * xlen/2)
	xmin_new = xcen + min(0, sign_x * xlen/2)
	ymax_new = ycen + max(0, sign_y * ylen/2)
	ymin_new = ycen + min(0, sign_y * ylen/2)
	box_new = [xmin_new, xmax_new, ymin_new, ymax_new]
	s_new = s[2:end]

	return get_sub_box(box_new, s_new)
end

function is_inside_box(c, box)
	xmin, xmax, ymin, ymax = box
	a = real(c)
	b = imag(c)
	return (xmin <= a < xmax) && (ymin <= b < ymax)
end

#=
function filter(sample_points, box)
	u = Vector{Bool}(undef, length(box))
	for i = 1:length(box)
		u[i] = is_inside_box(sample_points[i], box)
	end
end
=#

function integrate(threshold, box, sample_size)
	xmin, xmax, ymin, ymax = box

	N_I = 0
	N_T = sample_size
	N_I = @distributed (+) for _ = 1:N_T
		x = rand(Uniform(xmin, xmax))
		y = rand(Uniform(ymin, ymax))
		c = x + y * im

		Int(is_mandelbrot(c, threshold))
	end

	q = N_I / N_T
	u_q = sqrt(q * (1 - q)) / sqrt(N_T)
	A_T = (xmax - xmin) * (ymax - ymin)
	A_I = q * A_T
	u_A_I = u_q * A_T

	return [A_I, u_A_I]
end

#=
function probe_structure(threshold, box, sample_size,
		target_uncertainty_factor, box_code)
	xmin, xmax, ymin, ymax = box
	A_T = (xmax - xmin) * (ymax - ymin)
	q, u_q = integrate(threshold, box, sample_size) / A_T

	if q * (1 - q) < target_uncertainty_factor^2
		return [box_code]
	elseif length(box_code) >= MAX_RECURSION
		return [box_code]
	else
		u = []
		for s in ["1", "2", "3", "4"]
			new_box = sub_box(box, s)
			v = probe_structure(threshold, new_box, sample_size,
					    target_uncertainty_factor,
					    box_code * s)
			push!(u, v...)
		end
		return u
	end
end
=#

#=
function stratified_sampling(threshold, box, sample_size, target_uncertainty)
	A, u_A = integrate(threshold, box, sample_size)

	if u_A < target_uncertainty
		return [A, u_A]
	end

	sum = 0
	for s in ["1", "2", "3", "4"]
		new_box = sub_box(box, s)
		new_A, new_u_A = stratified_sampling(threshold, new_box,
						     sample_size,
						     target_uncertainty/2)
		sum += measurement(new_A, new_u_A)
	end

	new_A = Measurements.value(sum)
	new_u_A = Measurements.uncertainty(sum)

	return [new_A, new_u_A]
end
=#

#define X_MIN (-2)
#define X_MAX (0.58)
#define Y_MIN (0)
#define Y_MAX (1.20)
