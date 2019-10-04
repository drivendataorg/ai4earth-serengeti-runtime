# Hakuna Ma-data: Identify Wildlife on the Serengeti with AI for Earth

This repository contains runtime configuration for the [Hakuna Ma-data: Identify Wildlife on the Serengeti with AI for Earth]() competition, as well as example benchmark solutions.

## Adding dependencies to runtime configuration

We accept contributions to add additional dependencies to the runtime environment. To do so, fork this repository, make your changes, and open a pull request.

### Python

We use conda to manage Python dependencies.

Add your new dependencies to `py-cpu.yml` and `py-gpu.yml`.

Please also add your dependencies to `test-installs.py`, below the line `## ADD ADDITIONAL REQUIREMENTS BELOW HERE ##`.

### R

We prefer to use conda to manage R dependencies. Add your new dependencies to `r-cpu.yml` and `r-gpu.yml`.

If your dependencies are not available from the `conda-forge` or `defaults` channels, you can also add installation code to the install scripts `package-installs-cpu.R` and `package-installs-gpu.R`.

Please also add your dependencies to `test-installs.R`, below the line `## ADD ADDITIONAL REQUIREMENTS BELOW HERE ##`.

## Testing submission with benchmark model

First, to prepare necessary files for submission, run:

```bash
bash prep.sh
```

You can also directly specify whether to prepare the Python or R benchmark solutions with `bash prep.sh py` or `bash prep.sh r`, respectively.

Next, build and run the Docker container with

```bash
bash run.sh
```
