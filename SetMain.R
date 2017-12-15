rm(list=ls())#Supra Matrix
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")

#########################对于河流#####################
dataRiver=read.table(".\\数据\\river.txt",header = TRUE)
gRiver=produceNetwork(dataRiver)
dataRoad=read.table(".\\数据\\road.txt",header = TRUE)
gRoad=produceNetwork(dataRoad)
dataRailway=read.table(".\\数据\\railway.txt",header = TRUE)
gRailway=produceNetwork(dataRailway)


histRiver=hist(degree(gRiver$g),breaks=20)
indexFlag=which(histRiver$counts>0)
temp=histRiver$counts/sum(histRiver$counts)
Degree=histRiver$breaks[indexFlag]+ (histRiver$breaks[2]-histRiver$breaks[1])/2;
Frequency=temp[indexFlag];
plot(Degree,Frequency,ylim=c(0.001,101),log="y",ylab="Frequeny of Degree in River Network")

histRiver=hist(degree(gRoad$g),breaks=20)
indexFlag=which(histRiver$counts>0)
temp=histRiver$counts/sum(histRiver$counts)
Degree=histRiver$breaks[indexFlag]+ (histRiver$breaks[2]-histRiver$breaks[1])/2;
Frequency=temp[indexFlag];
plot(Degree,Frequency,ylim=c(0.001,101),log="y",ylab="Frequeny of Degree in Road Network")

histRiver=hist(degree(gRiver$g),breaks=20)
indexFlag=which(histRiver$counts>0)
temp=histRiver$counts/sum(histRiver$counts)
Degree=histRiver$breaks[indexFlag]+ (histRiver$breaks[2]-histRiver$breaks[1])/2;
Frequency=temp[indexFlag];
plot(Degree,Frequency,ylim=c(0.001,101),log="y",ylab="Frequeny of Degree in Railway Network")

hist(degree(gRiver$g),xlab="Degree in River Network")
hist(degree(gRoad$g),xlab="Degree in Road Network")
hist(degree(gRailway$g),xlab="Degree in Railway Network")