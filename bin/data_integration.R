#!/usr/bin/env Rscript
library(Seurat)

args <- commandArgs(trailingOnly=TRUE)

input_dir   <- args[1]
output_dir  <- args[2]
rds_files <- list.files(input_dir, pattern = "\\.rds$", full.names = TRUE)
rds_objects <- lapply(rds_files, readRDS)
 rds_objects <- lapply(rds_objects, function(x) {
    x <- NormalizeData(x)
    x <- FindVariableFeatures(x, selection.method = "vst", nfeatures = 2000)
   return(x)
 })

 anchors <- FindIntegrationAnchors(object.list = rds_objects)
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