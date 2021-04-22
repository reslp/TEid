import pandas as pd
import numpy as np

samples = pd.read_csv(config["sample_data"]).set_index("species", drop=False)
species_names = [sample.replace(" ", "_") for sample in samples["species"].tolist()]
#print(samples)

def get_assembly_path(wildcards):
	return samples.loc[wildcards.species, ["assembly"]].to_list()

def get_contig_prefix(wildcards):
        return samples.loc[wildcards.species, ["contig_prefix"]].to_list()

#def get_species_name(wildcards):
#	return [name.replace(" ", "_") for name in sample_data.loc[sample_data["species"] == wildcards.species, "species"].to_list()]

def get_species_names(wildcards):
	names = [name.replace(" ", "_") for name in samples.loc["species"].to_list()]
	names= " ".join(names)
	return names

def get_edta_parameters(wildcards):
	args_string = ""
	if str(samples.loc[wildcards.species, "exclude"]) != "nan":
		args_string += "--exclude %s " % str(samples.loc[wildcards.species, "exclude"])
	if str(samples.loc[wildcards.species, "cds"]) != "nan":
		args_string += "--cds %s " % str(samples.loc[wildcards.species, "cds"])
	return args_string
