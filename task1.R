library(data.table)


geneMap <- function(gene_info_file) {
  # Function to map all gene symbol and synonymns to gene id
  # Input: Gene info file Homo_sapiens.gene_info.gz
  # output: A list with mapped gene symbols/synonyms and gene ids
  
  cat("Processing gene_id - symbol mapping\n")
  gene_info_data <- fread(gene_info_file, select = c(2, 3, 5))
  mapping_data <- list()
  #I am adding progress bar here since its a large data and this takes few minutes 
  pb <- txtProgressBar(min = 0, max = nrow(gene_info_data), style = 3)
  for (row in 1:nrow(gene_info_data)) {
    # Add the symbol to the mapping
    mapping_data[[gene_info_data[row, Symbol]]] <- gene_info_data[row, GeneID] # Add Symbol 
    setTxtProgressBar(pb, row)
    # Process synonyms, if any
    synonyms <- unlist(strsplit(gene_info_data[row, Synonyms], "\\|")) #split synonyms using |
    for (synonym in synonyms) {
      mapping_data[[synonym]] <- gene_info_data[row, GeneID] # Add Synonyms
    }
  }

  close(pb)
  return(mapping_data)
}


# Function to replace symbols in GMT file with Entrez IDs
gmtDataProcessing <- function(gmt_path, output_path, mapping) {
  gmtData <- file(gmt_path, "r")
  output <- file(output_path, "w")
  
  while (TRUE) {
    line <- readLines(gmtData, n = 1, warn = FALSE)
    if (length(line) == 0) break
    lobj <- unlist(strsplit(line, "\t"))
    pathwayData <- lobj[1:2]
    gene_symbols <- lobj[-c(1:2)]
    
    # Replace symbols with Entrez IDs, keep original symbol if no ID is found
    entrez_ids <- sapply(gene_symbols, function(x) ifelse(!is.null(mapping[[x]]), mapping[[x]], x))
    
    # Write the modified line to the output file
    writeLines(paste(c(pathwayData, entrez_ids), collapse = "\t"), output)
  }
  
  close(gmtData)
  close(output)
}

# Main script
gene_info_path <- "Homo_sapiens.gene_info.gz"
gmt_path <- "h.all.v2023.1.Hs.symbols.gmt"
output_path <- "q1_output.gmt" #my output file


mapping <- geneMap(gene_info_path)
process_gmt_file(gmt_path, output_path, mapping)



