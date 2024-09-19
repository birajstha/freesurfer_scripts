#!/bin/bash

output_batch_script="$1"
shift  # Remove the first argument

# Array containing the subjects for this batch
batch_subjects=("$@")
# Print the entire array
echo "${batch_subjects[@]}"

# Print only the first element
echo "${batch_subjects[0]}"

# Create the batch script
cat > "$output_batch_script" <<EOL
#!/bin/bash
#SBATCH --mem=20G
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 70:00:00
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=batch_${batch_subjects[0]}_to_${batch_subjects[-1]}

# Output file for the batch
output_file="${batch_subjects[0]}_to_${batch_subjects[-1]}.txt"


# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file
license_file="/ocean/projects/med220004p/agutierr/freesurfer-license/license.txt"

# Set the path to your dataset
dataset_path="/ocean/projects/med220004p/shared/data_raw/vannucci/bids_raw"
FREESURFER_THREADS=4

subjects=(${batch_subjects[@]})

# Iterate over subjects in the batch
for subject in "\${subjects[@]}"; do
    input_image="\${dataset_path}/\${subject}/ses-V1W1/anat/\${subject}_ses-V1W1_acq-MPR_rec-Norm_T1w.nii.gz"
    
    if [ ! -f "\$input_image" ]; then
        echo "Error: File not found - \$input_image" >> "\${output_file}"
        continue
    fi

    singularity exec \
        --env SUBJECTS_DIR=/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs \
        -B /ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs:/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs \
        -B "\${dataset_path}":/ocean/projects/med220004p/bshresth/vannucci/dataset_5_subjects \
        -B "\${license_file}":/opt/freesurfer/license.txt \
        --env FS_LICENSE="\${license_file}" \
        "\${singularity_image}" recon-all \
        -i "\$input_image" \
        -s "\${subject}" \
        -parallel -openmp \${FREESURFER_THREADS} \
        -all

    # Check the exit status of the last command and save to the output file
    if [ $? -eq 0 ]; then
        echo "Subject \${subject} processing complete." >> "\${output_file}"
    else
        echo "Subject \${subject} processing incomplete. Time limit exceeded." >> "\${output_file}"
    fi
done

echo "Processing complete for batch \${batch_subjects[0]} to \${batch_subjects[-1]}. Check \${output_file} for details."
EOL

chmod +x "$output_batch_script"
