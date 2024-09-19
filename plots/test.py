import nibabel as nib
import matplotlib.pyplot as plt
import os
import plotly.graph_objects as go
import numpy as np

# Load the white matter surface (lh.white) from the FreeSurfer output directory
subject = "sub-PA002"
data_dir = "/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/outputs"

# Load the white matter surfaces for both hemispheres
lh_vertices, lh_faces = nib.freesurfer.io.read_geometry(os.path.join(data_dir, subject, 'surf/lh.pial'))
rh_vertices, rh_faces = nib.freesurfer.io.read_geometry(os.path.join(data_dir, subject, 'surf/rh.pial'))
# Read curvature data for the left hemisphere
lh_curvature = nib.freesurfer.io.read_morph_data(os.path.join(data_dir, subject, 'surf/lh.curv'))

# Read curvature data for the right hemisphere
rh_curvature = nib.freesurfer.io.read_morph_data(os.path.join(data_dir, subject, 'surf/rh.curv'))

# Create a Plotly 3D mesh plot with curvature-based color
fig = go.Figure()

# Add a 3D mesh trace for the left hemisphere with gradient colors based on curvature
fig.add_trace(go.Mesh3d(
    x=lh_vertices[:, 0],
    y=lh_vertices[:, 1],
    z=lh_vertices[:, 2],
    i=lh_faces[:, 0],
    j=lh_faces[:, 1],
    k=lh_faces[:, 2],
    intensity=lh_curvature,
    colorscale='Viridis',
    colorbar=dict(title='Curvature')
))

# Add a 3D mesh trace for the right hemisphere with gradient colors based on curvature
fig.add_trace(go.Mesh3d(
    x=rh_vertices[:, 0],
    y=rh_vertices[:, 1],
    z=rh_vertices[:, 2],
    i=rh_faces[:, 0],
    j=rh_faces[:, 1],
    k=rh_faces[:, 2],
    intensity=rh_curvature,
    colorscale='Inferno',
    colorbar=dict(title='Curvature')
))

# Update layout for better visualization
fig.update_layout(
    scene=dict(
        xaxis=dict(nticks=4, range=[-100, 100]),
        yaxis=dict(nticks=4, range=[-100, 100]),
        zaxis=dict(nticks=4, range=[-100, 100]),
    ),
    scene_aspectmode='manual',
    scene_aspectratio=dict(x=1, y=1, z=1),
    scene_camera=dict(
        center=dict(x=0, y=0, z=0),
        eye=dict(x=1.25, y=1.25, z=1.25)
    )
)

# Save the interactive HTML visualization
fig.write_html(f'/ocean/projects/med220004p/bshresth/vannucci/freesurfer_runs/plots/{subject}_mesh.html')
