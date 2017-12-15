rm(list=ls())#Supra Matrix
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")

#dataRoad=read.table(".\\数据\\mainroad.txt",header = TRUE)
#gRoad=produceNetwork(dataRoad)

#zz=data.frame(gRoad$xx,gRoad$yy)

#write.csv(zz,file=".\\数据\\fldRes\\pointXYUSA.csv")

#Ggroad=gRoad$g
#save(gRoad, file = paste0(".\\结果\\gRoadChina.Rdata"))


#################################################可重复性Code#############################
load(paste0(".\\结果\\gRoadChina.Rdata"))
#Ggroad=gRoad$g



temp=components(Ggroad);
maxCize=max(temp$csize)
tempIndex=which(temp$membership!=which.max(table(temp$membership)))
#write.table(zz[tempIndex,],file=".\\数据\\notInLGUSA.csv")

#######################################Read runoff#######################
#RandomTypeName='PearsonIII';
RandomTypeName='Random';
#runoffName='China';
NameList='ChinaPro';
tempName='ABCDEFGHIJKLMNOPQRSTUVWXYZ';

#test=c(1:9,c(1:30)*10);
test=c(2:58)*5;

runoffNameList=c("Guangxi","Henan","Hunan","Sichuan","Zhejiang")

runoffNameList=c("Guangxi")
#runoffNameList=c("Florida","Illinois","Iowa","Michigan","Minnesota","NewYork","Ohio","Tennessee","Texas")
#runoffNameList=c("AmericaState")

for(kIter in 1:length(runoffNameList)){
runoffName=runoffNameList[kIter];
totalAttackFlood=0;
afterAttackFloodTotal1=0;
afterAttackFloodTotal2=0;
totalIterNum=20;
for(totalIterRoff in 1:totalIterNum){
Res1=c();
Res21=c();
Res22=c();

fileNameTemp=paste0('D:\\Csv\\',NameList,runoffName,RandomTypeName,substr(tempName,totalIterRoff,totalIterRoff),'.csv')
tdata=read.csv(fileNameTemp,sep = ",",header = FALSE)

#wwdim=dim(wchoice)
for(i in 1:length(test)){
  tempSelect=which(tdata[(i+3),]>0);
  if(length(tempSelect)>0){
    wchoice=tdata[1,(which(tdata[(i+3),]>0))]+1;
  }else{wchoice=c();}
  wtemptemp=setdiff(wchoice,intersect(wchoice,tempIndex))
  Res1=c(Res1,length(wtemptemp))
  gAfter=delete.vertices(Ggroad,union(wchoice,tempIndex))
  temp=components(gAfter);
  #maxCizeAfter=max(temp$csize)
  maxCizeAfter=sort(temp$csize,decreasing = TRUE)
  Res21=c(Res21,maxCizeAfter[1])
  Res22=c(Res22,maxCizeAfter[2])
  #maxCizeAfter[2]
}
Res22[which(is.na(Res22))]=0;
totalAttackFlood=totalAttackFlood+Res1;
afterAttackFloodTotal1=afterAttackFloodTotal1+Res21;
afterAttackFloodTotal2=afterAttackFloodTotal2+Res22;
}

fileNameTemp=paste0(".\\数据\\淹没结果\\",NameList,"\\",runoffName);
fileNameTemp=paste0(fileNameTemp,"\\");
fileNameTemp=paste0(fileNameTemp,runoffName);
fileNameTemp=paste0(fileNameTemp,"TotalRoad.txt")
wTotalRoad=read.table(fileNameTemp,sep = ",",header = TRUE)
wTotalRoad=wTotalRoad[,2]
wTotalRoad=setdiff(wTotalRoad,intersect(wTotalRoad,tempIndex))

write.csv(totalAttackFlood/totalIterNum,paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedByFlood.csv")))
write.csv(afterAttackFloodTotal1/totalIterNum,paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedByFlood.csv")))
write.csv(afterAttackFloodTotal2/totalIterNum,paste0(".\\结果\\",paste0(runoffName,"RoadSecondCsAttackedByFlood.csv")))
write.csv(totalAttackFlood/(wTotalRoad*totalIterNum),paste0(".\\结果\\",paste0(runoffName,"RoadNodesAttackedRateByFlood.csv")))
write.csv(afterAttackFloodTotal1/(15599*totalIterNum),paste0(".\\结果\\",paste0(runoffName,"RoadGiantCsAttackedTotalRateByFlood.csv")))

}

save.image(paste0(".\\结果\\",RandomTypeName,runoffName,".RData"))
