import os
import pandas as pd
import ast
import subprocess

csv_file =  os.getcwd() + '/log.csv'
base_path = "/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs"

data = "/ocean/projects/med220004p/jclucas/data/vannucci/bids_raw/"
license_file=os.path.join(os.getcwd() , "license.txt")
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

df = pd.read_csv(csv_file)
for index, row in df.iterrows():
    subject = row['Subject']
    session = row['Sessions Available']
    if session.startswith('"'):
        session = session[1:-1]
    session = set(ast.literal_eval(session))
    completed = row['Freesurfer Completed']

    completed = set(ast.literal_eval(completed))
    remaining = session - completed
    if len(remaining) > 0:
        print(f"Subject: {subject}, Remaining: {remaining}")
        for ses in remaining:
            print(f"Running: {ses}")
            output_dir = f"{base_path}/{subject}/{ses}"
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)
            # check if the dir is empty
            if os.listdir(output_dir):
                print(f"Directory not empty: {output_dir}")
                continue
           # print file contents of data + subject + ses
            if os.path.exists(f"{data}/{subject}/{ses}/anat"):
                try:
                    T1w = subprocess.check_output(f"ls {data}/{subject}/{ses}/anat | grep T1w.nii.gz | head -n 1", shell=True).decode('utf-8').strip()
                    print(T1w)
                    # write me a bash script and save it inside scripts folder for each subject and session
                    script = f"""#!/bin/bash
#SBATCH --mem=20G
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 70:00:00
#SBATCH --ntasks-per-node=20
#SBATCH --job-name={subject}_{ses}

# Output file for the batch
output_file="{subject}_{ses}.txt"

# Set path to your singularity image
singularity_image="/ocean/projects/med220004p/kenneall/sing_images/freesurfer_6.0.sif"

# Set the path to your license file


singularity exec \
  -B {data}:/input_dir:ro \
  -B {output_dir}:/output_dir \
  -B "{license_file}":/opt/freesurfer/license.txt \
  --env FS_LICENSE="{license_file}" \
  {singularity_image} \
  recon-all \
  -s "{subject}" \
  -i /input_dir/"{subject}/{ses}/anat/{T1w}" \
  -all \
  -sd /output_dir \
  -parallel \
  -openmp 4
  -all

echo "Job finished for subject {subject}"
"""
                    # save the script
                    with open(f"{os.getcwd()}/scripts/{subject}_{ses}.sh", 'w') as f:
                        f.write(script)
                    # submit the job
                    print(f"Submitting job for {subject}_{ses}")
                    subprocess.run(f"sbatch {os.getcwd()}/scripts/{subject}_{ses}.sh", shell=True)
                except subprocess.CalledProcessError as e:
                    print(f"Error executing command: {e}")
            else:
                print(f"Path does not exist: {data}/{subject}/{ses}/anat")
            