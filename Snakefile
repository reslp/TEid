configfile: "data/config.yaml"

files = os.listdir("data/assemblies")
files = [file.split("_sorted")[0] for file in files]
print(files)

#samples = list_assemblies

rule all:
	input:
		expand("results/{sp}/repeatmodeler/checkpoint.done", sp=files)	


include: "rules/repeatmodeler_repeatmasker.smk"
