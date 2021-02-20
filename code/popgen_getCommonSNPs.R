# this script should be used to gather the common SNPs for estimating contemporary Ne


setwd("/Users/pliocene/Desktop/work/smelt/DS_history/popgen_getMAFs/")
install.packages(c('tidyverse', 'reshape2'))
require(tidyverse)
library(reshape2)

# read in data for each year & combine chromosome and position number for comparison
mafs_files <- list.files(path=".", pattern='Ht.*\\.mafs.gz', full.names=TRUE)
mafs_col <- c('chromo',	'position',	'major', 'minor',	'freq',	'puEM',	'nInd')
mafs_raw <- tibble(file=mafs_files) %>% 
  mutate(data=map(file, read_tsv, col_names=mafs_col, skip=1)) %>%
  mutate(basename=basename(file))  %>%
  extract(basename, into='year', 'Ht_(.*)\\_getMAF.mafs.gz', convert=TRUE) %>%
  unnest(data) 

# first take out years with not enough individuals (n<20)
mafs <- mafs_raw %>% filter(nInd>=20)


# filter SNPs by how many years have NA for MAF estimation
df <- mafs %>% select(-file, -major, -minor, -nInd, -puEM) 
dfreq <- df %>% spread(year, freq)
dfreq$na_count <- apply(is.na(dfreq), 1, sum)
ggplot(dfreq, aes(x=na_count)) +
  geom_histogram(breaks=seq(0, as.numeric(ncol(dfreq)-3), by=1), color="black", fill="light grey") +
  labs(title="Histogram of NAs for all SNPs w/nInd >= 20 for each year", x="NA Count", y="Frequency") +
  scale_y_continuous(label=scales::comma)
ggsave("PLOT_Histogram_NAcountBySNP.allSNP.nInd20.pdf", plot=last_plot())

dfreq_filt <- dfreq %>% filter(na_count<=2)
yearNAs <- as.data.frame(sapply(dfreq_filt[ ,3:as.numeric(ncol(dfreq_filt)-1)], function(x) sum(length(which(is.na(x))))))
yearNAs$year <- rownames(yearNAs)
yearNAs <- rename(yearNAs, "num_NA"="sapply(dfreq_filt[, 3:as.numeric(ncol(dfreq_filt) - 1)], function(x) sum(length(which(is.na(x)))))")
ggplot(yearNAs, aes(y=num_NA, x=year)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title="Histogram of the number of NAs per year for final SNP set", y="Total NA Count", x="Year")
ggsave("PLOT_Histogram_NAcountByYear.nInd20.pdf", plot=last_plot())



# save table of the loci for input into ANGSD
write.table(dfreq_filt[,1:2], file="DS_history_lociForNe.nInd20.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
