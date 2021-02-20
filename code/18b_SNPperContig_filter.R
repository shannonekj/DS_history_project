library(tidyverse)
# locally
setwd("/Users/pliocene/Desktop/work/smelt/DS_history/snps_per_contig_noPara")
# for farm use:
#setwd("/home/sejoslin/projects/DS_history/data/paralog_id/results_snp_per_contig_noPara")

#load in files for plotting
count_col_name <- c('contig', 'count')
dat10 <- read_table(file="DS_history.rand20.same.noParalogs.10.snp.count", skip=0, col_names=count_col_name)
dat29 <- read_table(file="DS_history.rand20.same.noParalogs.29.snp.count", skip=0, col_names=count_col_name)
datALL <- read_table(file="DS_history.wParalogs.snp.count", skip=0, col_names=count_col_name)
seqLength <- read_tsv(file="DS_history_contigs_250.seqLength", col_names = c('contig', 'sequence_length'))

### CUTOFF = 10 ###
# bind rows via contig_id
datALL <- merge(datALL, seqLength, all.y=FALSE)
datALL <- datALL %>%
  mutate(SNPperBP=count/sequence_length)

# grab loci with less than 0.05 SNPs per base pair
select_lociALL <- filter(datALL, SNPperBP <= 0.05)

summary(datALL$SNPperBP)
boxplot(datALL$SNPperBP)
sum(datALL$SNPperBP <= 0.05)

hist(select_lociALL$SNPperBP)
ggplot(data=datALL, aes(datALL$SNPperBP)) +
  geom_histogram(binwidth=0.01, col="black", fill="grey") + 
  labs(x="SNP per base pair", y="frequency") + 
  labs(title="Histogram for Paralog Cutoff of 10")

write.table(select_loci10[,1], "contigs_filtered_bySNPcount.withParalog.list", col.names = F, row.names = F, quote = F)




### CUTOFF = 10 ###
# bind rows via contig_id
dat10 <- merge(dat10, seqLength, all.y=FALSE)
dat10 <- dat10 %>%
  mutate(SNPperBP=count/sequence_length)

# grab loci with less than 0.05 SNPs per base pair
select_loci <- filter(dat10, SNPperBP <= 0.05)

summary(dat10$SNPperBP)
boxplot(dat10$SNPperBP)
sum(dat10$SNPperBP <= 0.05)

hist(select_loci$SNPperBP)
hist10 <- ggplot(data=dat10, aes(dat10$SNPperBP)) +
  geom_histogram(binwidth=0.01, col="black", fill="grey") + 
  labs(x="SNP per base pair", y="frequency") + 
  labs(title="Histogram for Paralog Cutoff of 10")
ggsave("PLOT_histogram_SNPperBP.10.pdf", plot = hist10, device="pdf")

write.table(select_loci10[,1], "contigs_filtered_bySNPcount.10.list", col.names = F, row.names = F, quote = F)


### CUTOFF = 29 ###
# bind rows via contig_id
dat29 <- merge(dat29, seqLength, all.y=FALSE)
dat29 <- dat29 %>%
  mutate(SNPperBP=count/sequence_length)

# grab loci with less than 0.05 SNPs per base pair
select_loci29 <- filter(dat29, SNPperBP <= 0.05)

summary(dat29$SNPperBP)
boxplot(dat29$SNPperBP)
sum(dat29$SNPperBP <= 0.05)
sum(dat29$SNPperBP > 0.05)

### PLOTS ###
#all
hist29 <- ggplot(data=dat29, aes(dat29$SNPperBP)) +
  geom_histogram(binwidth=0.01, col="black", fill="grey") + 
  labs(x="SNP per base pair", y="frequency") + 
  labs(title="Histogram for Paralog Cutoff of 29")
ggsave("PLOT_histogram_SNPperBP.29.pdf", plot = hist29, device="pdf")

write.table(select_loci29[,1], "contigs_filtered_bySNPcount.29.list", col.names = F, row.names = F, quote = F)
