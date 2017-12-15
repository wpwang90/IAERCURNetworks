#rm(list=ls())#对于一个国家3个Runoff与连通数
require(igraph)
setwd("C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\")
source(".\\程序\\produceNetwork.R")
source(".\\程序\\attackPointGenerater.R")
source(".\\程序\\attackShellLocalGenerater.R")
iTersum=20;
maxGCSNum=15599;

#maxGCSNum=235962;
#runoffTotal="ChinaEachPro";
runoffTotal="FinalChinaTotal";

#runoffTotal="USATotal";

runoffName=c("China")
#runoffName=c("AmericaState")

finalRes=data.frame();
#test=c(1:9,c(1:30)*10);
test=c(2:58)*5;
for(i in 1:length(runoffName)){
  ###############################################################################
  Res1=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadNodesAttackedByFlood.csv")))
  Res1=Res1[,2];
  tempRes=data.frame(test,Res1,runoffName[i],"RoadNodes")
  names(tempRes)=c("Runoff","value","Name","Type")
  finalRes=rbind(finalRes,tempRes);
  
  Res2=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedByFlood.csv")))
  Res2=Res2[,2]
  tempRes=data.frame(test,Res2,runoffName[i],"RoadGiantCs")
  names(tempRes)=c("Runoff","value","Name","Type")
  finalRes=rbind(finalRes,tempRes);
  
  #Res2=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedTotalRateByFlood.csv")))
  #Res2=Res2[,2]
  tempRes=data.frame(test,Res2/maxGCSNum,runoffName[i],"RoadGiantCsRate")
  names(tempRes)=c("Runoff","value","Name","Type")
  finalRes=rbind(finalRes,tempRes);
  
}

#tempP=ggplot(data=finalRes,aes(x=Runoff,y=value,group=Name,colour=Name));
tempP=ggplot(data=finalRes,aes(x=Runoff,y=value,group=Name));

tempP=tempP+geom_line(color="Blue")

#tempP=tempP+ geom_point(alpha=0.5,size=2)
tempP=tempP+geom_point(color="Blue",shape=19, alpha=0.5,size=2)
tempP=tempP+facet_wrap(~Type,scales="free")
tempP=tempP+labs(x="Runoff",y="Connected components")

#tempP=tempP+theme_bw()+theme(panel.grid=element_blank())

tempP=tempP+ggtitle(paste0("Combine","RoadUnderAttacks"))
print(tempP)

ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"RoadNodesandGiantCsAttackedByFlood.pdf")))
ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"RoadNodesandGiantCsAttackedByFlood.tiff")))
