rule prepare_assembly:
	input: 
		assembly = get_assembly_path
	output:
		reformatted_assembly = "results/{species}/{species}.assembly.fa"
	params:
		sp = "{species}",
		prefix = get_contig_prefix
	singularity:
		"docker://reslp/biopython_plus:1.77"
	shell:
		"""
		#all seqs upper case
		cat {input.assembly} | awk '{{if ($1 ~ /^>/) {{print $1}} else {{print toupper($1)}}}}' > results/{params.sp}/assembly_tmp.fa
		#shorten names
		python bin/rename_contigs.py results/{params.sp}/assembly_tmp.fa {params.prefix} > {output.reformatted_assembly}
		"""

rule edta:
	input: 
		assembly = rules.prepare_assembly.output.reformatted_assembly
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
		
		EDTA.pl --genome {input.assembly} {params.add_args} {params.args} --threads {threads} &> {log}
		
		#copy output to results folder
		cp -rf ./* results/{params.sp}/edta
		touch {output.check}
		"""

