import os
import shutil

csv_file =  os.getcwd() + '/log.csv'
base_path = "/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs"
# read the csv file and print last columns
with open(csv_file, 'r') as f:
    for line in f:
        subject = line.split(',')[0]
        completed = line.split(',')[-1][2:-3]
        
        # list folders in the base path + subject
        source_path = os.path.join(base_path, subject, "completed")
        
        # check source_path if empty dir and if yes delete
        if os.path.exists(source_path):
            if not os.listdir(source_path):
                os.rmdir(source_path)
        
