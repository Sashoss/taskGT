library(data.table)
library(ggplot2)


gene_info <- fread("Homo_sapiens.gene_info.gz", select = c("Symbol", "chromosome")) #Open gz file using fread
gene_info <- gene_info[chromosome != '-' & !grepl("\\|", chromosome), ] #remove rows with chromosome "-" or is chromosome has |
custom_order <- c(as.character(1:22), "X", "Y", "MT", "Un") #Rearrange chromosome numbers to match the plot 
gene_info$chromosome <- factor(gene_info$chromosome, levels = custom_order)
gene_count <- gene_info[, .(gene_count = .N), by = .(chromosome)]


#Plot gene count data
p <- ggplot(gene_count, aes(x = chromosome, y = gene_count)) +
  geom_bar(stat = "identity", fill = "gray35") +  # set color to match plot
  labs(title = "Number of genes in each chromosome",  
       x = "Chromosomes",  
       y = "Gene count") +  
  theme_minimal() +  
  theme(
    text = element_text(size = 20),
    panel.grid.major = element_blank(),  # remove major grid lines
    panel.grid.minor = element_blank(),  # remove minor grid lines
    plot.title = element_text(hjust = 0.5),  # Center the plot title
    axis.line = element_line(color = "black", linewidth = 1),  # set line color and thickness to match the plot
    axis.ticks = element_line(color = "black", linewidth = 1)  # set tick color and thickness to match the plot
  ) +
  scale_x_discrete() +  
  scale_y_continuous(labels = scales::comma)  


print(p)
ggsave("Chromosome_geneCountPlot.pdf", plot = p, width = 10, height = 6) #save plot

