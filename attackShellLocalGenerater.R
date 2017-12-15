attackShellLocalGenerater=function(roadN,railN,attackType)
{
require(igraph)
	
roadL=gorder(roadN);
railL=gorder(railN);
rootroad=sample(roadL,1);
rootrail=sample(railL,1);
temp1=bfs(roadN,rootroad);
temp2=bfs(railN,rootrail);
	twchoice=temp1$order;
	trchoice=temp2$order;
	twchoice=as.numeric(names(twchoice));
	trchoice=as.numeric(names(trchoice));
return(list(twchoice=twchoice,trchoice=trchoice));
}