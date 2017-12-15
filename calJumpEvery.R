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

test=c(1:9,c(1:30)*10);
TotalResJump=c();
TotalResJumpValue=c();
for(i in 1:length(runoffName)){
  ###############################################################################
  Res1=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedTotalRateByFlood.csv")))
  ww=c(0,Res1[,2])-c(Res1[,2],0)
  ww=ww[2:(length(ww)-1)];
  TotalResJump=c(TotalResJump,test[which(ww==max(ww))])
  
  TotalResJumpValue=c(TotalResJumpValue,max(ww));
}