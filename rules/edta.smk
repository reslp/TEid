rule edta:
	input: 
		assembly = get_assembly_path
	output:
		check = "results/{species}/{species}_edta.done"
	params:
		args = get_edta_parameters,
		add_args = "--overwrite 1 --anno 1 --force 1",
		sp = "{species}"
	log:
		"logs/{species}_edta.log"
	benchmark:
		"results/{species}/{species}_benchmark.bench"
	shadow:
		"shallow"
	singularity:
		"docker://reslp/edta:1.9.6"	
	threads: 12
	shell:
		"""
		export LC_ALL=C
		name=$(basename {input.assembly})
		cat {input.assembly} | awk '{{if ($1 ~ /^>/) {{print $1}} else {{print toupper($1)}}}}' > $name
		
		EDTA.pl --genome {input.assembly} {params.add_args} {params.args} --threads {threads} &> {log}
		
		#copy output to results folder
		cp -rf ./$name* results/{params.sp}/
		touch {output.check}
		"""

