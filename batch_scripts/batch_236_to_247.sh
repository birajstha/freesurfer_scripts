#!/bin/bash
#SBATCH --mem=20G
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 70:00:00
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=batch_sub-PA236_to_sub-PA247

# Output file for the batch
output_file="sub-PA236_to_sub-PA247.txt"


# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file
license_file="/ocean/projects/med220004p/agutierr/freesurfer-license/license.txt"

# Set the path to your dataset
dataset_path="/ocean/projects/med220004p/shared/data_raw/vannucci/bids_raw"
FREESURFER_THREADS=4

subjects=(sub-PA236 sub-PA245 sub-PA247)

session=ses-V2W2
# Iterate over subjects in the batch
for subject in "${subjects[@]}"; do
    input_image="${dataset_path}/${subject}/${session}/anat/${subject}_${session}_acq-MPR_rec-vNavNorm_T1w.nii.gz"
    
    if [ ! -f "$input_image" ]; then
        echo "Error: File not found - $input_image" >> "${output_file}"
        continue
    fi

    singularity exec         --env SUBJECTS_DIR=/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs         -B /ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs:/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs         -B "${dataset_path}":/ocean/projects/med220004p/bshresth/vannucci/dataset_5_subjects         -B "${license_file}":/opt/freesurfer/license.txt         --env FS_LICENSE="${license_file}"         "${singularity_image}" recon-all         -i "$input_image"         -s "${subject}"         -parallel -openmp ${FREESURFER_THREADS}         -all

    # Check the exit status of the last command and save to the output file
    if [ 0 -eq 0 ]; then
        echo "Subject ${subject} processing complete." >> "${output_file}"
    else
        echo "Subject ${subject} processing incomplete. Time limit exceeded." >> "${output_file}"
    fi
done

echo "Processing complete for batch ${batch_subjects[0]} to ${batch_subjects[-1]}. Check ${output_file} for details."
