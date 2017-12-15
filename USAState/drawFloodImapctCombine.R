#rm(list=ls())#分省洪水、随机打击、局部打击（shell）下的最大连通交叉路口数变化情况
require(igraph)
require(ggplot2)

require(reshape2)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")
iTersum=20;
#runoffNameList=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")
runoffTotal="USAEachState";
#runoffTotal="USATotalThree"
#runoffTotal="ChinaTotalThree";
#runoffTotal="ChinaTotal";
runoffNameList=c("China")
#runoffNameList=c("AmericaState")
runoffNameList=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")
finalRes=data.frame(c())
for(kIter in 1:length(runoffNameList)){
  runoffName=runoffNameList[kIter]
  Res1=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByFlood.csv")))
  Res1=Res1[,2];
  Res2=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByFlood.csv")))
  Res2=Res2[,2]
  afterAttackRandomSum=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByRandom.csv")));
  afterAttackRandomSum=afterAttackRandomSum[,2]
  afterAttackRandomTotal1=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByRandom.csv")))
  afterAttackRandomTotal1=afterAttackRandomTotal1[,2]
  afterAttackRandomTotal1=afterAttackRandomTotal1*iTersum;
  
  afterAttackRandomShellTotal1=read.csv(paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByLocal.csv")))
  afterAttackRandomShellTotal1=afterAttackRandomShellTotal1[,2]
  afterAttackRandomShellTotal1=afterAttackRandomShellTotal1*iTersum;
  
  

  Res=data.frame(Res1,Res2,"Blue",runoffName);
  names(Res)=c("x","y","AType","Name")
  AttackRandom=data.frame(afterAttackRandomSum,afterAttackRandomTotal1/iTersum,"Red",runoffName);
  names(AttackRandom)=c("x","y","AType","Name")
  AttackShell=data.frame(afterAttackRandomSum,afterAttackRandomShellTotal1/iTersum,"Green",runoffName);
  names(AttackShell)=c("x","y","AType","Name")
  
  finalRes=rbind(finalRes,Res,AttackRandom,AttackShell);
}
tempP=ggplot();
tempP=tempP+geom_line(data=finalRes,aes(x=x,y=y,group=AType,colour=AType))
tempfianlRes=finalRes[which(finalRes$AType=="Blue"),]
tempP=tempP+ geom_point(data=tempfianlRes,aes(x=x,y=y),shape=19, alpha=0.5,size=2,color="Blue")

tempP=tempP+facet_wrap(~Name,scales="free")
tempP=tempP+labs(x="Attacked road intersections",y="Giant connected components")+scale_color_manual(name="",values = c("blue", "red","green"), labels =c("Flooding","Random attack","Localized attack"))

#tempP=tempP+theme_bw()+theme(panel.grid=element_blank())

tempP=tempP+ggtitle(paste0("Combine","RoadUnderAttacks"))
print(tempP)
ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"CombineRoadUnderAttacks.pdf")))
ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"CombineRoadUnderAttacks.tiff")))



