#rm(list=ls())#四个Runoff与连通数
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

finalRes=data.frame();
test=c(1:9,c(1:30)*10);
for(i in 1:length(runoffName)){
###############################################################################
Res1=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadNodesAttackedByFlood.csv")))
Res1=Res1[,2];
tempRes=data.frame(test,Res1,runoffName[i],"RoadNodes")
names(tempRes)=c("Runoff","value","Name","Type")
finalRes=rbind(finalRes,tempRes);

Res2=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadNodesAttackedRateByFlood.csv")))
Res2=Res2[,2]
tempRes=data.frame(test,Res2,runoffName[i],"RoadNodesRate")
names(tempRes)=c("Runoff","value","Name","Type")
finalRes=rbind(finalRes,tempRes);

Res2=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedByFlood.csv")))
Res2=Res2[,2]
tempRes=data.frame(test,Res2,runoffName[i],"RoadGiantCs")
names(tempRes)=c("Runoff","value","Name","Type")
finalRes=rbind(finalRes,tempRes);

Res2=read.csv(paste0(".\\结果\\",paste0(runoffName[i],"RoadGiantCsAttackedTotalRateByFlood.csv")))
Res2=Res2[,2]
tempRes=data.frame(test,Res2,runoffName[i],"RoadGiantCsRate")
names(tempRes)=c("Runoff","value","Name","Type")
finalRes=rbind(finalRes,tempRes);

}

#tempP=ggplot(data=finalRes,aes(x=Runoff,y=value,group=Name,colour=Name));
tempP=ggplot(data=finalRes,aes(x=Runoff,y=value,group=Name));

tempP=tempP+geom_line(aes(color = factor(Name)))

#tempP=tempP+ geom_point(alpha=0.5,size=2)
tempP=tempP+geom_point(aes(color = factor(Name)))
tempP=tempP+facet_wrap(~Type,scales="free")
tempP=tempP+labs(x="Runoff",y="Connected components")

#tempP=tempP+theme_bw()+theme(panel.grid=element_blank())

tempP=tempP+ggtitle(paste0("Combine","RoadUnderAttacks"))
print(tempP)

ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"RoadNodesandGiantCsAttackedByFlood.pdf")))
ggsave(file=paste0(".\\结果\\",paste0(runoffTotal,"RoadNodesandGiantCsAttackedByFlood.tiff")))
