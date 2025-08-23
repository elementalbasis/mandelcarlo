function iterate(z, c)
	return z^2 + c
end

function is_mandelbrot(c, threshold)
	if is_cardioid(c) || is_bulb(c)
		return true
	end

	z = 0
	for _ = 1:threshold
		z = iterate(z, c)

		if abs(z) > 2
			return false
		end
	end

	return true
end

function is_cardioid(c)
	s = c - 1/4
	r = abs(s)
	x = real(s)

	return (2 * r^2 < r - x)
end

function is_bulb(c)
	s = c + 1
	r = abs(s)
	
	return (r < 1/4)
end
