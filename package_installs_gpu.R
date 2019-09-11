# ============ CONFIGURATION ============ 
# Add conda executables to PATH
Sys.setenv(PATH=paste0("/opt/conda/envs/r-gpu/bin:", Sys.getenv("PATH")))

# Set CRAN repo
r = getOption("repos")
r["CRAN"] = "https://cloud.r-project.org/"
options(repos = r)

install.packages("devtools")
library(devtools)

# ============ IMAGE LIBRARIES ============ 
install.packages("opencv")
install.packages("OpenImageR")

install_github("bnosac/image", subdir = "image.CornerDetectionF9", build_vignettes = F)
install_github("bnosac/image", subdir = "image.CornerDetectionHarris", build_vignettes = F)
install_github("bnosac/image", subdir = "image.LineSegmentDetector", build_vignettes = F)
install_github("bnosac/image", subdir = "image.ContourDetector", build_vignettes = F)
install_github("bnosac/image", subdir = "image.Otsu", build_vignettes = F)
install_github("bnosac/image", subdir = "image.dlib", build_vignettes = F)
install_github("bnosac/image", subdir = "image.darknet", build_vignettes = F)
install_github("bnosac/image", subdir = "image.DenoiseNLMeans", build_vignettes = F)
install_github("bnosac/image", subdir = "image.libfacedetection", build_vignettes = F)
install_github("bnosac/image", subdir = "image.OpenPano", build_vignettes = F)

# ============ DEEP LEARNING ============ 
library(tensorflow)
install_tensorflow(method="conda", envname="r-gpu", version="1.14.0-gpu")

library(keras)
use_condaenv("r-gpu")
install_keras(method="conda", tensorflow="1.14.0-gpu")