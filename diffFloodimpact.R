rm(list=ls())#Supra Matrix
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")

dataRoad=read.table(".\\数据\\fldRes\\roadUSAFinal.txt",header = TRUE)
gRoad=produceNetwork(dataRoad)

zz=data.frame(gRoad$xx,gRoad$yy)

write.csv(zz,file=".\\数据\\fldRes\\pointXYUSA.csv")

Ggroad=gRoad$g

temp=components(gRoad$g);
maxCize=max(temp$csize)
tempIndex=which(temp$membership!=2)
write.table(zz[tempIndex,],file=".\\数据\\notInLG2.csv")

#######################################Read runoff#######################
test=c(9:30)*10;
Res1=c();
Res2=c();
for(i in 1:22){
  
  fileNameTemp=paste0(".\\数据\\淹没结果\\runoff",test[i]);
  fileNameTemp=paste0(fileNameTemp,".txt")
  wchoice=read.table(fileNameTemp,sep = ",",header = TRUE)
  wchoice=wchoice[(which(wchoice[,5]>0)),2];
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


afterAttackRandomTotal1=0;
afterAttackRandomShellTotal1=0;
afterAttackRandomTotal2=0;
afterAttackRandomShellTotal2=0;

iTersum=20;
for(iIter in 1:iTersum){
gRoad$g=Ggroad;
gRoad$g=delete.vertices(gRoad$g,tempIndex)
V(gRoad$g)$name=c(1:gorder(gRoad$g))

attackRandom=attackPointGenerater(gRoad$g,gRoad$g,1)#1随机＿蓄意＿
attackRandomShell=attackShellLocalGenerater(gRoad$g,gRoad$g,3)

afterAttackRandom1=c();
afterAttackRandomShell1=c();
afterAttackRandom2=c();
afterAttackRandomShell2=c();

afterAttackRandomSum=c();
for(i in 1:length(attackRandom$twchoice)){
  if(i%%10==0){
    gAfter=delete.vertices(gRoad$g,attackRandom$twchoice[1:i])
    temp=components(gAfter);
    #maxCizeAfter=max(temp$csize)
    
    maxCizeAfter=sort(temp$csize,decreasing = TRUE)
    afterAttackRandom1=c(afterAttackRandom1,maxCizeAfter[1]);
    afterAttackRandom2=c(afterAttackRandom2,maxCizeAfter[2]);
    
    gAfter=delete.vertices(gRoad$g,attackRandomShell$twchoice[1:i])
    temp=components(gAfter);
    #maxCizeAfter=max(temp$csize)
    
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

floodToRoadRes=read.csv(".\\数据\\floodToRoadRes.csv",header = TRUE)


#plot(floodToRoadRes$Submerged,floodToRoadRes$SGC,col="blue",pch=1,ylab="Giant connected components", xlab="Attacked road intersections")
#lines(floodToRoadRes$Submerged,floodToRoadRes$SGC,col="blue",pch=1)
#points(afterAttackRandomSum,afterAttackRandomTotal/iTersum,col="red",pch=2,cex=1)
#lines(afterAttackRandomSum,afterAttackRandomTotal2/iTersum,col="red",pch=2)
#points(afterAttackRandomSum,afterAttackRandomShellTotal/iTersum,col="green",pch=3,cex=1)
#lines(afterAttackRandomSum,afterAttackRandomShellTotal2/iTersum,col="green",pch=3)
#title("Barabasi-Albert Network")
#legend("topright", c("Flooding","Random attack","Localized attack"),pch = c(1, 2,3),col=c("blue","red","green"),cex=1)





plot(floodToRoadRes$Submerged2,floodToRoadRes$LGC2,col="blue",pch=1,ylab="Giant connected components", xlab="Attacked road intersections")
lines(floodToRoadRes$Submerged2,floodToRoadRes$LGC2,col="blue",pch=1)
#points(afterAttackRandomSum,afterAttackRandomTotal/iTersum,col="red",pch=2,cex=1)
lines(afterAttackRandomSum,afterAttackRandomTotal1/iTersum,col="red",pch=2)
#points(afterAttackRandomSum,afterAttackRandomShellTotal/iTersum,col="green",pch=3,cex=1)
lines(afterAttackRandomSum,afterAttackRandomShellTotal1/iTersum,col="green",pch=3)
#title("Barabasi-Albert Network")
legend("topright", c("Flooding","Random attack","Localized attack"),pch = c(1, 2,3),col=c("blue","red","green"),cex=1)


