#!/bin/bash
#SBATCH --mem=20G
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 70:00:00
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=sub-PA112_ses-V2W2

# Output file for the batch
output_file="sub-PA112_ses-V2W2.txt"

# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file


singularity exec   -B /ocean/projects/med220004p/jclucas/data/vannucci/bids_raw/:/input_dir:ro   -B /ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs/sub-PA112/ses-V2W2:/output_dir   -B "/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/license.txt":/opt/freesurfer/license.txt   --env FS_LICENSE="/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/license.txt"   /ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif   recon-all   -s "sub-PA112"   -i /input_dir/"sub-PA112/ses-V2W2/anat/sub-PA112_ses-V2W2_acq-MPR_rec-vNavNorm_T1w.nii.gz"   -all   -sd /output_dir   -parallel   -openmp 4
  -all

echo "Job finished for subject sub-PA112"
