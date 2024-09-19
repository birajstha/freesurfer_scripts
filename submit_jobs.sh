#!/bin/bash

# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file
license_file="/ocean/projects/med220004p/agutierr/freesurfer-license/license.txt"

# Set the path to your dataset
dataset_path="/ocean/projects/med220004p/shared/data_raw/vannucci/bids_raw"

# Set the range of subjects (sub-PA001 to sub-PA341)
start_subject=7
end_subject=341

# Number of subjects to process at a time
batch_size=5

# Output directory for individual batch scripts
output_dir="batch_scripts"
mkdir -p "$output_dir"

# Iterate over subjects in batches of 5
for ((subject_num = start_subject; subject_num <= end_subject; subject_num += batch_size)); do
    batch_script="$output_dir/batch_${subject_num}_to_$((subject_num + batch_size - 1)).sh"

    # Array to store valid subjects for this batch
    batch_subjects=()

    for ((i = 0; i < batch_size; i++)); do
        subject_index=$((subject_num + i))
        subject_label=$(printf "sub-PA%03d" $subject_index)
        
        # Check if the subject directory exists
        if [ -d "${dataset_path}/${subject_label}" ]; then
            batch_subjects+=("${subject_label}")
        else
            echo "Subject ${subject_label} folder missing." >> "${batch_script}"  # Output error to the batch script
        fi
    done

    # Check if there are any subjects to process in this batch
    if [ ${#batch_subjects[@]} -eq 0 ]; then
        echo "No valid subjects for batch ${subject_num} to $((subject_num + batch_size - 1))."
        continue
    fi

    ./generate_batch_script.sh "$batch_script" "${batch_subjects[@]}"
    sbatch "$batch_script"
done
