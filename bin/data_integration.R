#!/usr/bin/env Rscript
library(Seurat)

args <- commandArgs(trailingOnly=TRUE)

#Input dir containing all rds files
input_dir   <- args[1]
#output directory
output_dir  <- args[2]
#load all rds files
rds_files <- list.files(input_dir, pattern = "\\.rds$", full.names = TRUE)
rds_objects <- lapply(rds_files, readRDS)
# Perform normalization and HVG selection
 rds_objects <- lapply(rds_objects, function(x) {
    x <- NormalizeData(x)
    x <- FindVariableFeatures(x, selection.method = "vst", nfeatures = 2000)
   return(x)
 })

# select features that are repeatedly variable across datasets for integration
features <- SelectIntegrationFeatures(object.list = rds_objects)
#Perform integration
#Integrate all rds using identified anchors
 anchors <- FindIntegrationAnchors(object.list = rds_objects, anchor.features = features)
 # this command creates an 'integrated' data assay
 integrated_data <- IntegrateData(anchorset = anchors)

 
 dir.create(basename(dirname(output_dir)), showWarnings = FALSE)

saveRDS(integrated_data, file = output_dir)

yaml::write_yaml(
list(
    'MTX_TO_SEURAT'=list(
        'Seurat' = paste(packageVersion('Seurat'), collapse='.')
    )
),
"versions.yml"
)