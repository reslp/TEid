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

rule repeatmasker_wrepmod:
	input:
		assembly =  "data/assemblies/{sample}_sorted.fas",
		repmod_libraries = rules.repeatmodeler.output.fasta
	output:
		checkpoint = "results/{sample}/repeatmasker/repmas_mod.done"
	params:
                sample="{sample}",
		wd = os.getcwd()
	threads: 10
        singularity:
                "docker://dfam/tetools:1.2"
	log:
		stdout = "logs/repmas_mod_{sample}.stdout.txt",
		stderr = "logs/repmas_mod_{sample}.stderr.txt"
	shell:
		"""
			cd results/{params.sample}/repeatmasker/
			{params.wd}/bin/RepeatMasker/RepeatMasker -engine hmmer -pa {threads} -lib {params.wd}/{input.repmod_libraries} -noisy -dir denovo -gff -xm {params.wd}/{input.assembly}  1> {params.wd}/{log.stdout} 2> {params.wd}/{log.stderr}
			touch {params.wd}/{output.checkpoint}
		"""

rule repeatmasker:
        input:
                assembly =  "data/assemblies/{sample}_sorted.fas"
	output:
		checkpoint = "results/{sample}/repeatmasker/repmas_full.done"
	params:
		sample="{sample}",
		wd = os.getcwd()
	threads: 8
	singularity:
		"docker://dfam/tetools:1.2"
	shadow:
		"shallow"
	log:
		stdout = "logs/repmas_{sample}.stdout.txt",
		stderr = "logs/repmas_{sample}.stderr.txt"
	shell:
        	"""
			#cd results/{params.sample}/repeatmasker/
                        cp -pfr /opt/RepeatMasker/ $(pwd)
			rm $(pwd)/RepeatMasker/Libraries/RepeatMaskerLib.h5
			ln -s $(pwd)/RepeatMasker/Libraries/Dfam.h5 $(pwd)/RepeatMasker/Libraries/RepeatMaskerLib.h5
			export LIBDIR=$(pwd)/RepeatMasker/Libraries
			$(pwd)/RepeatMasker/RepeatMasker -engine hmmer -pa {threads} -qq -s -species eukaryota -noisy -dir full -gff -xm {params.wd}/{input.assembly}  1> {params.wd}/{log.stdout} 2> {params.wd}/{log.stderr}
			cp -r full results/{params.sample}/repeatmasker
			touch {params.wd}/{output.checkpoint}
                """

		
