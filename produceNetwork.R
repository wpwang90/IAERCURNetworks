produceNetwork=function(dataRiver){
wdim=dim(dataRiver)
xx=c();
yy=c();
zz=c();
Num=1;
for(i in 1:wdim[1]){
  temp1=intersect(which(xx==dataRiver[i,2]),which(yy==dataRiver[i,3]));
  if(length(temp1)==0){temp1=Num;Num=Num+1;xx=c(xx,dataRiver[i,2]);yy=c(yy,dataRiver[i,3])}
  temp2=intersect(which(xx==dataRiver[i,4]),which(yy==dataRiver[i,5]));
  if(length(temp2)==0){temp2=Num;Num=Num+1;xx=c(xx,dataRiver[i,4]);yy=c(yy,dataRiver[i,5])}
  zz=c(zz,temp1,temp2)
}
gRiver <- make_empty_graph(n = (Num-1),directed = FALSE)
gRiver=add_edges(gRiver,zz)
return(list(g=gRiver,xx=xx,yy=yy))
}