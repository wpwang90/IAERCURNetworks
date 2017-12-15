#rm(list=ls())#Supra Matrix
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")
iTersum=20;
#runoffTotal="ChinaEachPro";
runoffTotal="USAEachState";
#runoffName=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")
runoffName=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")



TotalRes1=c();
TotalRes2=c();
for(i in 1:length(runoffName)){
  ###############################################################################
  Res1=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedTotalRateByFlood.csv")))
  Res1=Res1[,2];
  
  TotalRes1=c(TotalRes1,Res1)
}


pdf(file=paste0(".\\结果\\",paste0(runoffTotal,"RoadGiantCsAttackedTotalRateByFlood.pdf")))

xLaels=c(1:9,c(1:30)*10);

plot(xLaels,TotalRes1[1:39],pch=1,ylab="Affected road nodes rate in Province",ylim=c(0.9999*min(TotalRes1),1.0001*max(TotalRes1)), xlab="runoff")
lines(xLaels,TotalRes1[1:39],pch=1)
for(i in 2:length(runoffName)){
  
  points(xLaels,TotalRes1[((i-1)*39+1):(i*39)],pch=i)
  lines(xLaels,TotalRes1[((i-1)*39+1):(i*39)],pch=i)
  
}


legend("bottomleft", runoffName,pch = c(1:length(runoffName)),cex=1)
dev.off()



