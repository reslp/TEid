#!/bin/bash

set -e

usage() { 
	echo "Welcome to the TEid pipeline submission script. A script helps to perform Transposable Element identification on SLURM and SGE clusters with snakemake and singularity"
	echo
	echo "Usage: $0 [-v] [-c <cluster_config_file>] [-s <snakemke_args>]" 
	echo
	echo "Options:"
	echo "	-t <submission_system> Specify available submission system. Options: sge, slurm, local (no submission system). Default: Automatic detection."
	echo "	-c <cluster_config_file> Path to cluster config file in YAML format (mandatory). "
	echo "	-s \"<snakemake_args>\" Additional arguments passed on to the snakemake command (optional). snakemake is run with --immediate-submit -pr --notemp --latency-wait 600 --use-singularity --jobs 1001 by default." 
	echo "	-i \"<singularity_args>\" Additional arguments passed on to singularity (optional). Singularity is run with -B /tmp:/usertmp by default."
	echo
	echo "Additional parameters:"
	echo "	--dry dryrun, without actual job submission"
	1>&2; exit 1; }
	
version() {
	echo "$0 v0.1"
	exit 0
}

CLUSTER=""
DRY=""
while getopts ":v:t:c:s:i:-:" option;
	do
		case "${option}"
		in
			v) version;;
			t) CLUSTER=${OPTARG};;
			c) CLUSTER_CONFIG=${OPTARG};;
			s) SM_ARGS=${OPTARG};;
			i) SI_ARGS=${OPTARG};;
			-) LONG_OPTARG="${OPTARG#*}"
				case $OPTARG in
					dry) DRY="-n";;
					'' ) break ;;
					*) echo "Illegal option --$OPTARG" >&2; usage; exit 2 ;;
				esac ;;
			*) echo "Illegal option --$OPTARG\n" >&2; usage;;
			?) echo "Illegal option --$OPTARG\n" >&2 usage;;
		esac
	done
if [ $OPTIND -eq 1 ]; then usage; fi

# Determine submission system:
if [[ $CLUSTER == "sge" ]]; then
	echo "SGE (Sun Grid Engine) submission system specified. Will use qsub to submit jobs."
elif [[ $CLUSTER == "slurm" ]]; then
	echo "SLURM submission system specified. Will use sbatch to submit jobs."
elif [[ $CLUSTER == "local" ]]; then
  echo "Local execution without job submission specified."
else
	echo "No or unknown submission system specified, will try to detect the system automatically."
	CLUSTER=""
	command -v qsub >/dev/null 2>&1 && { echo >&2 "SGE detected, will use qsub to submit jobs."; CLUSTER="sge"; }
	command -v sbatch >/dev/null 2>&1 && { echo >&2 "SLURM detected, will use sbatch to submit jobs."; CLUSTER="slurm"; }
  if [[ $CLUSTER == "" ]]; then
    echo "Submission system could not be detected. You may be able to run the pipeline without job submission."
    exit 1
  fi
fi

echo "Additional arguments passed on to singularity: $SI_ARGS"
echo "Additional arguments passed on to snakemake: $SM_ARGS"

if [ $CLUSTER = "slurm" ]; then
	export CONDA_PKGS_DIRS="$(pwd)/.conda_pkg_tmp"
	mkdir -p .conda_pkg_tmp
	snakemake --use-conda --use-singularity --singularity-args "-B /tmp:/usrtmp -B $(pwd):/data -B $(pwd)/bin:/usr/local/external $SI_ARGS" --jobs 1001 --cluster-config $CLUSTER_CONFIG --cluster '$(pwd)/bin/immediate-submit/immediate_submit.py {dependencies} slurm' --immediate-submit -pr --notemp --latency-wait 600 $SM_ARGS $DRY
	unset CONDA_PKGS_DIRS
elif [ $CLUSTER = "sge" ]; then
	snakemake --use-conda --use-singularity --singularity-args "-B /tmp:/usertmp $SI_ARGS" --jobs 1001 --cluster-config $CLUSTER_CONFIG --cluster "$(pwd)/bin/immediate-submit/immediate_submit.py '{dependencies}' sge" --immediate-submit -pr --notemp --latency-wait 600 $SM_ARGS $DRY
elif [ $CLUSTER = "local" ]; then
	snakemake --use-conda --use-singularity --singularity-args "-B /tmp:/usertmp $SI_ARGS" -pr --notemp --latency-wait 600 $SM_ARGS $DRY
else
	echo "Submission system not recognized"
	exit 1
fi
