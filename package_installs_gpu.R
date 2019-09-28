# ============ CONFIGURATION ============ 
# Add conda executables to PATH
Sys.setenv(PATH=paste0("/opt/conda/envs/r-gpu/bin:", Sys.getenv("PATH")))

# Set CRAN repo
r = getOption("repos")
r["CRAN"] = "https://cloud.r-project.org/"
options(repos = r)

install.packages("devtools", quiet = T)
library(devtools)

# ============ IMAGE LIBRARIES ============ 
install.packages("opencv", quiet = T)
install.packages("OpenImageR", quiet = T)

install_github("bnosac/image", subdir = "image.ContourDetector", build_vignettes = F, quiet = T)
install_github("bnosac/image", subdir = "image.darknet", build_vignettes = F, quiet = T)
install_github("bnosac/image", subdir = "image.OpenPano", build_vignettes = F, quiet = T)