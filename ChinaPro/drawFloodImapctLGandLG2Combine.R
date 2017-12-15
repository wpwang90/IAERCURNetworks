#rm(list=ls())#最大连通子图和第二连通子图
require(igraph)
require(ggplot2)
require(reshape2)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")



#################################################可重复性Code

#######################################Read runoff#######################
maxValueSize=235962;
#maxValueSize=15599;

#fileDisName="TotalUSA"
#fileDisName="TotalUSAState"
fileDisName="TotalChinaProvince"

runoffNameList=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")
#runoffNameList=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")
kIter=1;
runoffName=runoffNameList[kIter]
test=c(1:9,c(1:30)*10);

Res21=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedTotalRateByFlood.csv")))
Res22=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByFlood.csv")))


Res=Res21;
Res$Runoff=test
Res$variable="Gcs";
Res$Value=Res21$x
Res$Name=runoffNameList[kIter]

Restemp=Res21;
Restemp$Runoff=test;
Restemp$Value=Res22$x/maxValueSize;
Restemp$variable="Scs";
Restemp$Name=runoffName;
Res=rbind(Res,Restemp)



for(kIter in 2:length(runoffNameList)){
  runoffName=runoffNameList[kIter]
  test=c(1:9,c(1:30)*10);
  
  Res21=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedTotalRateByFlood.csv")))
  Res22=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByFlood.csv")))
  
  
  Restemp=Res21;
  Restemp$Runoff=test;
  Restemp$Value=Res21$x;
  Restemp$variable="Gcs";
  Restemp$Name=runoffName;
  Res=rbind(Res,Restemp)
  
  Restemp=Res21;
  Restemp$Runoff=test;
  Restemp$Value=Res22$x/maxValueSize;
  Restemp$variable="Scs";
  Restemp$Name=runoffName;
  Res=rbind(Res,Restemp)
  
}

#meltdata <- melt(Res[,c(3:6)], id = "Runoff")
#Res=Res[,c(3:6)]
#tempP=ggplot(Res)+facet_wrap(~Name)

Res=Res[,c(3:6)];

tempP=ggplot(Res,aes(x = Runoff, y = Value,color = variable))+geom_line() 

tempP=tempP+facet_grid(variable~Name,scales = "free_y")
tempP=tempP+ geom_point(shape=19, alpha=0.5,size=2)+labs(y="Connected components")
tempP=tempP
#+theme_bw()+theme(panel.grid=element_blank())
print(tempP)


ggsave(file=paste0(".\\结果\\",paste0(fileDisName,"RoadUnderAttackLGandSize.pdf")))
ggsave(file=paste0(".\\结果\\",paste0(fileDisName,"RoadUnderAttackLGandSiez.tiff")))


