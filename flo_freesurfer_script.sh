#!/bin/bash
#SBATCH --job-name=freesurfer_array
#SBATCH --output=freesurfer_array_%A_%a.out
#SBATCH --error=freesurfer_array_%A_%a.err
#SBATCH --array=1-100
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 12:00:00
#SBATCH --ntasks-per-node=8

DATA_ROOT="/ocean/projects/med220004p"

# Set the BIDS directory and output directory
BIDS_DIR="${DATA_ROOT}/shared/data_raw/ABCD/imaging"
OUTPUT_DIR="${DATA_ROOT}/rupprech/data/ABCD/freesurfer"

# File with the list of subject IDs
SUBJECT_IDS_FILE="${DATA_ROOT}/rupprech/data/abcd-ids.txt"

# Path to the FreeSurfer Singularity container
FREESURFER_CONTAINER="${DATA_ROOT}/rupprech/images/freesurfer-741.sif"
FREESURFER_LICENSE="${DATA_ROOT}/rupprech/data/freesurfer-license.txt"

# Number of threads for FreeSurfer
FREESURFER_THREADS=4

# Create the output directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

# Get the subject ID for this array task
subject_id=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ${SUBJECT_IDS_FILE})

# Set the session and run number
subject_ses="baselineYear1Arm1"
subject_run="01"

# Relative path to the subject's T1w image
t1w_path="sub-${subject_id}/ses-${subject_ses}/anat/\
sub-${subject_id}_ses-${subject_ses}_run-${subject_run}_T1w.nii"

# Check if the subject's T1w image exists
if [ ! -f ${BIDS_DIR}/"${t1w_path}" ]; then
  echo "T1w image not found for subject ${subject_id}"
  echo "Expected path: ${BIDS_DIR}/${t1w_path}"
  exit 1
fi

# Check if the subject's FreeSurfer directory already exists
if [ -d ${OUTPUT_DIR}/"${subject_id}" ]; then
  echo "FreeSurfer directory already exists for subject ${subject_id}"
  echo "Skipping subject"
  exit 0
fi

# Run FreeSurfer on the selected subject
# -parallel  : Will run hemispheres in parallel.
# -openmp    : Number of openmp threads (actual number of threads will be 2x)
singularity exec \
  -B ${BIDS_DIR}:/input_dir:ro \
  -B ${OUTPUT_DIR}:/output_dir \
  -B ${FREESURFER_LICENSE}:/fslicense.txt:ro \
  --env FS_LICENSE=/fslicense.txt \
  --env SUBJECTS_DIR=/output_dir \
  ${FREESURFER_CONTAINER} \
  recon-all \
  -s "${subject_id}" \
  -i /input_dir/"${t1w_path}" \
  -all \
  -sd /output_dir \
  -parallel \
  -openmp ${FREESURFER_THREADS}

echo "Job finished for subject ${subject_id}"