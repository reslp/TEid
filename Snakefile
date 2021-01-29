configfile: "data/config.yaml"
include: "rules/functions.smk"

#files = os.listdir("data/assemblies")
#files = [file.split("_sorted")[0] for file in files]
#print(files)

#samples = [sample.replace(" ", "_") for sample in sample_data["species"].tolist()] 

rule all:
	input:
		#expand("results/{sp}/repeatmodeler/checkpoint.done", sp=files),	
		#expand("results/{sp}/repeatmasker/repmas_full.done", sp=files)
		#expand("results/{sp}/repeatmasker/repmas_mod.done", sp=files)
		directory(expand("results/{sp}",sp=species_names))

include: "rules/repeatmodeler_repeatmasker.smk"
include: "rules/edta.smk"
