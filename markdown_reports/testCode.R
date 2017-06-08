library("Biostrings")


csv <- read.table("test_data/A01_1/Analysis_Results/m170511_233724_42145_c101219842550000001823278510171700_s1_p0.sts.csv",sep=",", header=T, as.is=T)


table(csv$ZmwType)

#ANTIHOLE ANTIMIRROR      FDZMW   FIDUCIAL OUTSIDEFOV SEQUENCING 
#250        260        912      10552       1216     150292 

reads <- csv$ZmwType=="SEQUENCING" ## count == Polymerase reads

table(csv$ZmwType,csv$ProductivityLabel)

#             Empty  Other Productive
#ANTIHOLE      250      0          0
#ANTIMIRROR    260      0          0
#FDZMW         834     52         26
#FIDUCIAL    10524     15         13
#OUTSIDEFOV   1204      3          9
#SEQUENCING 132833   2291      15168

table(csv[csv$ZmwType == "SEQUENCING" & csv$ProductivityLabel== "Productive","ReadLength"] > 50) ## Trues == filtered Polymerase reads

table(csv[reads,]$Productivity) ## produces bottom loading table

fa1 <- readDNAStringSet("test_data/A01_1/Analysis_Results/m170511_233724_42145_c101219842550000001823278510171700_s1_p0.1.subreads.fasta")
fa2 <- readDNAStringSet("test_data/A01_1/Analysis_Results/m170511_233724_42145_c101219842550000001823278510171700_s1_p0.2.subreads.fasta")
fa3 <- readDNAStringSet("test_data/A01_1/Analysis_Results/m170511_233724_42145_c101219842550000001823278510171700_s1_p0.3.subreads.fasta")

fa <- c(fa1,fa2,fa3)

outreads <- data.frame(matrix(unlist(strsplit(names(fa),split="/| RQ=")),ncol = 4,byrow = T),stringsAsFactors = F)
colnames(outreads) <- c("run","zmw","range","quality")
outreads <- data.frame(outreads,width=width(fa))

ffa <- readDNAStringSet("test_data/017293/data/filtered_subreads.fasta")

hist(csv[csv$ZmwType == "SEQUENCING" & csv$ProductivityLabel== "Productive","ReadLength"],breaks=500)
hist(csv[csv$ZmwType == "SEQUENCING" & csv$ProductivityLabel== "Productive","ReadScore"],breaks=500)
hist(csv[csv$ZmwType == "SEQUENCING" & csv$ProductivityLabel== "Productive","InsertReadLen"],breaks=500)

hist(log10(csv$MedianInsertLength[csv$MedianInsertLength >1]),breaks=100,xlim=c(0,4))

library(XML)
x <- xmlParse("test_data/A01_1/m170511_233724_42145_c101219842550000001823278510171700_s1_p0.metadata.xml")
l <- xmlToList(xmlRoot(x))

