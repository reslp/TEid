rule edta:
	input: 
		assembly = get_assembly_path
	output:
		dir = directory("results/{species}")
	params:
		args = get_edta_parameters,
		add_args = "--overwrite 1 --anno 1 --force 1"
	log:
		"logs/{species}_edta.log"
	benchmark:
		"results/{species}/{species}_benchmark.bench"
	shadow:
		"minimal"
	singularity:
		"docker://reslp/edta:1.9.6"	
	threads: 24
	shell:
		"""
		export LC_ALL=C
		echo {params.args}
		EDTA.pl --genome {input.assembly} {params.add_args} {params.args} &> {log}
		cp -rf ./* {output.dir}
		"""

