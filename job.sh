#!/bin/bash
#SBATCH --mem=20G
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 70:00:00
#SBATCH --ntasks-per-node=20

# Output file
output_file="processing_status.txt"

# List of subjects
subjects=("sub-PA001" "sub-PA002" "sub-PA003" "sub-PA006" "sub-PA004" "sub-PA005")

# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file
license_file="/ocean/projects/med220004p/agutierr/freesurfer-license/license.txt"

# Set the path to your dataset
dataset_path="/ocean/projects/med220004p/bshresth/vannucci/dataset_5_subjects"
FREESURFER_THREADS=4

# Iterate over subjects
for subject in "${subjects[@]}"; do
    singularity exec \
        --env SUBJECTS_DIR=/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs \
        -B /ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs:/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs \
        -B "${dataset_path}":/ocean/projects/med220004p/bshresth/vannucci/dataset_5_subjects \
        -B "${license_file}":/opt/freesurfer/license.txt \
        --env FS_LICENSE="${license_file}" \
        "${singularity_image}" recon-all \
        -i "${dataset_path}/${subject}/ses-V1W1/anat/${subject}_ses-V1W1_acq-MPR_rec-Norm_T1w.nii.gz" \
        -s "${subject}" \
        -parallel -openmp ${FREESURFER_THREADS} \
        -all
    
    # Check the exit status of the last command and save to the output file
    if [ $? -eq 0 ]; then
        echo "Subject ${subject} processing complete." >> "${output_file}"
    else
        echo "Subject ${subject} processing incomplete. Time limit exceeded." >> "${output_file}"
    fi
done

echo "Processing complete. Check ${output_file} for details."
