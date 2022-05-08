# ML-Explainability

Shared drive files [here](https://drive.google.com/drive/folders/17yneYJ8NzbSN5tS2RLCpaxA35sVmoP5h?usp=sharing).

## First time running jobs on HPC

1. First complete singularity and conda setup
2. In your `$HOME` directory run `git clone git@github.com:rds-research-group/ml-explainability.git`
3. `cd ml-explainability`
4. `./scripts/run_job.sh <EMAIL> <NOTEBOOK_FILE_NAME> <JOB_TIME>`

## Testing jupyter notebooks locally

1. Start a slurm interactive job
2. Start a singularity container
3. In the container run `jupyter notebook --no-browser --port 8870` (make sure container has deps)
4. On local machine run `ssh -NfL 8870:localhost:8870 <NET_ID>@greene.hpc.nyu.edu`
5. Open brower tab with localhost address/port (in container log statements)

## Connecting to a postgres database job

1. Make sure there is a slurm job running postgres (run `run_job.sh`)
2. Start a new interactive job `srun -c8 --nodes=1 -t1:00:00 --job-name=db --mem=4GB --pty /bin/bash`
3. Load postgres module `module load postgresql/intel/13.2`
4. Run `psql -h cs011 explainability_db`, `cs011` is the slurm job running postgres
5. Enter postgres db password

## Tunneling to a slurm job node

Run `ssh -t -t <NET_ID>@greene.hpc.nyu.edu -L <PORT>:localhost:<PORT> ssh <NODELIST> -L <PORT>:localhost:<PORT>`

- Common ports **postgres:** 5432 and **jupyter:** 8870
- Run `squeue -u $USER` to find `<NODELIST>`

## Singularity and conda setup

1. Check to see singularity is installed `which singularity`
2. Check version `singularity version`
3. Copy the gzipped overlay image into your `home/<NET_ID>` directory `cp -rp /scratch/work/public/overlay-fs-ext3/overlay-5GB-200K.ext3.gz .`
4. Unzip image `gunzip overlay-5GB-200K.ext3.gz`
5. Launch container interactively `singularity exec --overlay overlay-5GB-200K.ext3 /scratch/work/public/singularity/cuda11.0-cudnn8-devel-ubuntu18.04.sif /bin/bash`
6. Inside container, install miniconda into /ext3/miniconda3 `wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh`
   1. `sh Miniconda3-latest-Linux-x86_64.sh -b -p /ext3/miniconda3`
   2. `export PATH=/ext3/miniconda3/bin:$PATH`
   3. `conda update -n base conda -y`
7. Setup pathing run `bash`
   1. Run/reload file `source /ext3/miniconda3/etc/profile.d/conda.sh`
   2. Export path to `.bash_profile` by running `export PATH=/ext3/miniconda3/bin:$PATH`
      1. Troubleshooting, this may not work and you may need to set this manually
      2. Manually set path, in home root `vi .bash_profile`
      3. Add `export PATH=/ext3/miniconda3/bin:$PATH` to file (vim cheatsheet here: https://vim.rtorr.com/)
      4. After saving and quiting reload file `source .bash_profile`
8. Exit container
9. Relaunch Container `singularity exec --overlay overlay-5GB-200K.ext3 /scratch/work/public/singularity/cuda10.1-cudnn7-devel-ubuntu18.04.sif /bin/bash`
10. source `/ext3/env.sh` or source `.bash_profile` depending on how you resolved pathing
11. Test to see dependencies are installed correctly `which python`
12. Check version `python --version`
13. Update version `conda install python`
14. Install additional dependencies in singularity container `pip install jupyter pandas matplotlib scipy scikit-learn seaborn`
15. Profit

### Helpful slurm commands

- Cancel all jobs `squeue -u $USER | awk '{print $1}' | tail -n+2 | xargs scancel`, Ex. `squeue -u $USER -n postgres` to cancel jobs named postgres
- Get details into your jobs `sacct --format=User,JobID,Jobname,partition,state,time,start,end,elapsed,AveCPU,MaxRss,MaxVMSize,nnodes,ncpus,nodelist -u $USER`

### NYU HPC (updating / archiving files)

- Touch all files on HPC `find . -exec touch -c {} \;`
- Zip scratch directory `zip -r "scratch-$(date +"%Y-%m-%d").zip" /scratch/<NET_ID>`
