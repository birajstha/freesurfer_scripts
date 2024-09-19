#!/bin/bash

# Monitor the completion of all jobs in the batch_scripts directory
# Adjust the path accordingly if it's different
batch_scripts_dir="batch_scripts"

while [ $(squeue -u bshresth | grep -c "batch_") -gt 0 ]; do
    sleep 60  # Adjust the sleep duration based on your job's expected runtime
done

echo "All jobs have completed."

# Optionally, you can check the output files of each batch script for more details
# Example: cat $batch_scripts_dir/batch_processing_status_* | less
