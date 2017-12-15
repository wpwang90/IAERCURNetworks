attackPointGenerater=function(roadN,railN,attackType)
{
require(igraph)
	
roadL=gorder(roadN);
railL=gorder(railN);
if(attackType==1){#随机打击
	twchoice=sample(roadL,roadL);
	trchoice=sample(railL,railL);
}
if(attackType==2){#蓄意打击
	twchoice=order(-betweenness(roadN));
	trchoice=order(-betweenness(railN));
}
return(list(twchoice=twchoice,trchoice=trchoice));
}