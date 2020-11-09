configfile: "data/config.yaml"

files = os.listdir("data/assemblies")
files = [file.split("_sorted")[0] for file in files]
print(files)

#samples = list_assemblies

rule all:
	input:
		#expand("results/{sp}/repeatmodeler/checkpoint.done", sp=files),	
		expand("results/{sp}/repeatmasker/repmas_full.done", sp=files)
		#expand("results/{sp}/repeatmasker/repmas_mod.done", sp=files)


include: "rules/repeatmodeler_repeatmasker.smk"
