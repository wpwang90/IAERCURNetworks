#rm(list=ls())#Supra Matrix
require(igraph)
require(ggplot2)
require(reshape2)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")



#################################################可重复性Code#############################
load(paste0(".\\结果\\TexasRoadGiantREsult.Rdata"))
Ggroad=gRoad$g



temp=components(Ggroad);
maxCize=max(temp$csize)
tempIndex=which(temp$membership!=which.max(table(temp$membership)))
#write.table(zz[tempIndex,],file=".\\数据\\notInLGUSA.csv")

#######################################Read runoff#######################
runoffNameList=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")
#runoffNameList=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")

for(kIter in 1:length(runoffNameList)){
  
  runoffName=runoffNameList[kIter]
  test=c(1:9,c(1:30)*10);
    
  Res21=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedTotalRateByFlood.csv")))
  Res22=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByFlood.csv")))
  
  
  Res=Res21;
  Res$Runoff=test
  Res$Gcs=Res$x;
  Res$Scs=Res22$x
  
  meltdata <- melt(Res[,c(3:5)], id = "Runoff")
  tempP=ggplot(meltdata,aes(x = Runoff, y = value,color = variable))+facet_grid(variable ~ ., scales = "free_y")
  tempP=tempP+geom_line() + geom_point(shape=19, alpha=0.5,size=4)+labs(y="Connected components")
  tempP=tempP+theme_bw()+theme(panel.grid=element_blank())
  print(tempP)
  ggsave(file=paste0(".\\结果\\",paste0(runoffName,"RoadUnderAttackLGand.pdf")))
  ggsave(file=paste0(".\\结果\\",paste0(runoffName,"RoadUnderAttackLGand.tiff")))
  
  }
