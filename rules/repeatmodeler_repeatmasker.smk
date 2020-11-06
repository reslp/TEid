rule repeatmodeler:
	input:
		"data/assemblies/{sample}_sorted.fas"
	output:
		done = "results/{sample}/repeatmodeler/checkpoint.done",
		fasta = "results/{sample}/repeatmodeler/{sample}-families.fa",
		stk = "results/{sample}/repeatmodeler/{sample}-families.stk"
	params:
		sample="{sample}"
	threads: 10
	singularity:
		"docker://dfam/tetools:1.2"
	log:
		stdout = "logs/repmod_{sample}.stdout.txt",
		stderr = "logs/repmod_{sample}.stderr.txt"
	shadow: "shallow"
	shell:
		"""
			BuildDatabase -name {params.sample} {input} 1> {log.stdout} 2> {log.stderr}
			RepeatModeler -pa {threads} -engine ncbi -database {params.sample} 1> {log.stdout} 2> {log.stderr}
			mv {params.sample}-families.fa {output.fasta}
			mv {params.sample}-families.stk {output.stk}
			touch {output.done}
			
		""" 

		
