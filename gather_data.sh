#!/bin/sh

ncores=$(nproc)
filename="test.jl"

min_sample_size=100
max_sample_size=100000
min_target_uncertainty=0.0001
max_target_uncertainty=0.01
min_threshold=100
max_threshold=10000

for i in {1..10}; do
	sample_size=$(shuf -i $min_sample_size-$max_sample_size -n 1)
	for j in {1..10}; do
		target_uncertainty=$(python -c "import random; print(random.uniform($min_target_uncertainty, $max_target_uncertainty))")
		for k in {1..10}; do
			threshold=$(shuf -i $min_threshold-$max_threshold -n 1)
			julia -p $ncores $filename --sample-size $sample_size --target-uncertainty $target_uncertainty --threshold $threshold
		done
	done
done
