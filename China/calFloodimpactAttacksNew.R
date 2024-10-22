rm(list=ls())#Supra Matrix
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")



#################################################可重复性Code#############################
load(paste0(".\\结果\\gRoadChina.Rdata"))

temp=components(Ggroad);
maxCize=max(temp$csize)
tempIndex=which(temp$membership!=which.max(table(temp$membership)))
#write.table(zz[tempIndex,],file=".\\数据\\notInLGUSA.csv")

#######################################Read runoff#######################
#runoffNameList=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")
#runoffNameList=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")
runoffNameList=c("China")

for(kIter in 1:length(runoffNameList)){
  
runoffName=runoffNameList[kIter]
test=c(1:9,c(1:30)*10);
Res1=c();
Res21=c();#LG
Res22=c();#LG2

fileNameTemp=paste0("C:\\Users\\woqie\\Desktop\\test\\",runoffName);
fileNameTemp=paste0(fileNameTemp,"test2.csv")
tdata=read.csv(fileNameTemp,sep = ",",header = FALSE)

#wwdim=dim(wchoice)
for(i in 1:length(test)){
  tempSelect=which(tdata[(i+3),]>0);
  if(length(tempSelect)>0){
    wchoice=tdata[1,(which(tdata[(i+3),]>0))]+1;
  }
  else{wchoice=c();}
  wtemptemp=setdiff(wchoice,intersect(wchoice,tempIndex))
  Res1=c(Res1,length(wtemptemp))
  gAfter=delete.vertices(Ggroad,union(wchoice,tempIndex))
  temp=components(gAfter);
  #maxCizeAfter=max(temp$csize)
  maxCizeAfter=sort(temp$csize,decreasing = TRUE)
  Res2=c(Res2,maxCizeAfter[1])
  #maxCizeAfter[2]
}

############################Read runoff######################################
gRoad$g=delete.vertices(Ggroad,tempIndex)
V(gRoad$g)$name=c(1:gorder(gRoad$g))
plot(degree.distribution(gRoad$g), xlab="node degree")
lines(degree.distribution(gRoad$g))


afterAttackRandomTotal1=0;#LG
afterAttackRandomShellTotal1=0;
afterAttackRandomTotal2=0;#LG2
afterAttackRandomShellTotal2=0;

iTersum=20;
for(iIter in 1:iTersum){
  gRoad$g=Ggroad;
  gRoad$g=delete.vertices(gRoad$g,tempIndex)
  V(gRoad$g)$name=c(1:gorder(gRoad$g))
  
  attackRandom=attackPointGenerater(gRoad$g,gRoad$g,1)#1随机＿蓄意＿
  attackRandomShell=attackShellLocalGenerater(gRoad$g,gRoad$g,3)
  
  afterAttackRandom1=c();#LG
  afterAttackRandomShell1=c();
  afterAttackRandom2=c();#LG2
  afterAttackRandomShell2=c();
  
  afterAttackRandomSum=c();
 
  for(i in 1:(max(Res1)+10)){
    if(i%%10==1){
      gAfter=delete.vertices(gRoad$g,attackRandom$twchoice[1:i])
      temp=components(gAfter);
      #maxCizeAfter=max(temp$csize)
      
      maxCizeAfter=sort(temp$csize,decreasing = TRUE)
      afterAttackRandom1=c(afterAttackRandom1,maxCizeAfter[1]);
      afterAttackRandom2=c(afterAttackRandom2,maxCizeAfter[2]);
      
      gAfter=delete.vertices(gRoad$g,attackRandomShell$twchoice[1:i])
      temp=components(gAfter);
      
      maxCizeAfter=sort(temp$csize,decreasing = TRUE)
      afterAttackRandomShell1=c(afterAttackRandomShell1,maxCizeAfter[1]);
      afterAttackRandomShell2=c(afterAttackRandomShell2,maxCizeAfter[2]);
      
      
      
      afterAttackRandomSum=c(afterAttackRandomSum,i);
    }
  }
  afterAttackRandomTotal1=afterAttackRandomTotal1+afterAttackRandom1;
  afterAttackRandomShellTotal1=afterAttackRandomShellTotal1+afterAttackRandomShell1;
  
  afterAttackRandomTotal2=afterAttackRandomTotal2+afterAttackRandom2;
  afterAttackRandomShellTotal2=afterAttackRandomShellTotal2+afterAttackRandomShell2;
}

afterAttackRandomTotal2[which(is.na(afterAttackRandomTotal2))]=0;
afterAttackRandomShellTotal2[which(is.na(afterAttackRandomShellTotal2))]=0;
Res22[which(is.na(Res22))]=0;

write.csv(Res1,paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByFlood.csv")))
write.csv(Res21,paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByFlood.csv")))
write.csv(afterAttackRandomSum,paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByRandom.csv")))
write.csv(afterAttackRandomTotal1/iTersum,paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByRandom.csv")))
write.csv(afterAttackRandomSum,paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByLocal.csv")))
write.csv(afterAttackRandomShellTotal1/iTersum,paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByLocal.csv")))
write.csv(Res22,paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByFlood.csv")))
write.csv(afterAttackRandomTotal2/iTersum,paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByRandom.csv")))
write.csv(afterAttackRandomShellTotal2/iTersum,paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByLocal.csv")))
write.csv(Res1/15599,paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedRateByFlood.csv")))
write.csv(Res21/15599,paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedTotalRateByFlood.csv")))
}
