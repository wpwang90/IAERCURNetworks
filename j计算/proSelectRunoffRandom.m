%ncfile='D:\runoffData\CMCC-CESM\mrro_day_CMCC-CM_rcp45_r1i1p1_20110101-20111231.nc';
first=datenum(1989, 12, 31);
nt=365;

RandomTypePrintName='Uniform';
%RunoffName='Guangxi';
%NameList='ChinaPro';
NameList='USAState';
RandomTypeName='PearsonIII';
%runoffNameList={'Henan','Hunan','Sichuan','Zhejiang'};
runoffNameList={'USA','Florida','Illinois','Iowa','Michigan','Minnesota','NewYork','Ohio','Tennessee','Texas'};

for kIter=1:length(runoffNameList)
RunoffName=runoffNameList{kIter}
for totalIterRoff=1:20
temp=['A':'Z'];
outfilepath= ['D:\径流数据设定\',NameList,'\',RunoffName,RandomTypeName,'\','wRoff',RunoffName,RandomTypePrintName,temp(totalIterRoff)];

selectData=load(['D:\径流数据设定\',NameList,'\','Raster','\',RunoffName,'.txt']);
 selectData=selectData(find(selectData>0));
 xx=floor(selectData/360)+1;
 yy=mod(selectData,360);
 %setValue=[1:9,10:10:300];
 setValue=[20:5:300]
totalI={};
 for it=1:length(setValue)
     
    temp=zeros(180,360);
    tempT=first+it;
    tt=datestr(tempT,30);
    fid=fopen([outfilepath,tt(1:8),'.one'],'w');
    for i=1:length(xx)
     temp(xx(i),yy(i))=setValue(it)-rand*20;
    end
    totalI{it}=temp;
    nx=360;
    ny=180;
    temp1=temp';
    for j=1:ny
        for i=1:nx
        %count= fwrite(fid,double(temp1(i,(ny-j+1))),'float');%根据例子这里用原始的数据
        count= fwrite(fid,double(temp1(i,j)),'float');
        end
    end
    fclose(fid);
 end
end
end