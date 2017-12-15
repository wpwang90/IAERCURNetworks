clear;clc
binfilename='C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\数据\\径流数据设定\ChinaPro\\China.bin';
first=datenum(1989, 12, 31);
%setValue=[1:1:30];
setValue=[1:9,10:10:300];
nt=length(setValue);

totalI={};
%totalData=zeros(1440,720);
first=first+1;
it=1;
file_name=['C:\Users\woqie\Mac文档\研究\BU\河流公路铁路耦合系统\数据\temp\flddph1990_',num2str(it),'.ctl'];
fid=fopen(file_name,'w');
fprintf(fid,'dset  %s\n',binfilename);
fprintf(fid,'undef -9999\ntitle\noptions yrev little_endian\n');
fprintf(fid,'xdef 1440 linear -179.875   0.250000\n');
fprintf(fid,'ydef 720 linear -89.875  0.250000\n');
fprintf(fid,'tdef 365 linear 00:00Z%s%s 1dy\n',datestr(first,7),lower(datestr(first,28)));
fprintf(fid,'zdef 1 linear 1 1\n');
fprintf(fid,'vars 1\n');
fprintf(fid,'Df 1 99       ** Floodplain Area [mm]\n');
fprintf(fid,'ENDVARS\n');
fclose(fid);
Df=read_grads(file_name,'Df');

for it=1:nt
temp=Df(:,:,1,it);
[m,n]=size(temp);
mValue=max(max(temp));
 for i=1:m
     for j=1:n
         if abs(temp(i,j)-mValue)<0.001
             temp(i,j)=0;
         end
     end
 end
totalI{it}=temp;
tData=temp;
[m,n]=size(temp);
for i=1:m
    for j=1:n
        tData(i,j)=temp(i,(n-j+1));
    end
end
R = georasterref('RasterSize', [720 1440], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [-89.875 89.875], 'Lonlim', [-179.875 179.8750], ...
       'ColumnsStartFrom', 'north');
   
geotiffwrite(['C:\Users\woqie\Mac文档\研究\BU\河流公路铁路耦合系统\数据\fldRasterRes\China\flddphChina',num2str(setValue(it)),'.tif'],tData',R);
end