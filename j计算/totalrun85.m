clear;clc
Files = dir(fullfile('D:\testRunoff\MIROCESM\RCP85result','flddph*.bin'));
LengthFiles = length(Files);
Data={};
nyear=1989;
for jF = 1:LengthFiles
binfilename=['D:\testRunoff\MIROCESM\RCP85result\', Files(jF).name];
first=datenum(nyear, 12, 31);
yearDays=datenum(nyear+1, 12, 31)-datenum(nyear, 12, 31);
totalData=zeros(1440,720);
totalI={};
first=first+1;
file_name=[binfilename,'.ctl'];
fid=fopen(file_name,'w');
fprintf(fid,'dset  %s\n',binfilename);
fprintf(fid,'undef -9999\ntitle\noptions yrev little_endian\n');
fprintf(fid,'xdef 1440 linear -179.875   0.250000\n');
fprintf(fid,'ydef 720 linear -89.875  0.250000\n');
fprintf(fid,'tdef %d linear 00:00Z%s%s 1dy\n',yearDays,datestr(first,7),lower(datestr(first,28)));
fprintf(fid,'zdef 1 linear 1 1\n');
fprintf(fid,'vars 1\n');
fprintf(fid,'Df 1 99       ** Floodplain Area [mm]\n');
fprintf(fid,'ENDVARS\n');
fclose(fid);
totalData=zeros(1440,720);
totalTlength=yearDays;
for it=1:totalTlength
[data,header]=read_grads(file_name,'Df','z',[1,1],'lon',[-179.875,179.875],'lat',[-89.875,89.875],'t',[it,it]); 
temp=data(:,:,1,1);
[m,n]=size(temp);
mValue=max(max(temp));
 for i=1:m
     for j=1:n
         if abs(temp(i,j)-mValue)<0.001
             temp(i,j)=0;
         end
     end
 end
totalData=max(totalData,temp);
end

tData=totalData;
[m,n]=size(totalData);
for i=1:m
    for j=1:n
        tData(i,(n-j+1))=totalData(i,j);
    end
end
R = georasterref('RasterSize', [720 1440], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [-89.875 89.875], 'Lonlim', [-179.875 179.8750], ...
       'ColumnsStartFrom', 'north');
   
geotiffwrite([binfilename,'max.tif'],tData',R);
Data{jF}=tData';
nyear=nyear+1;
end

save MIROCESM_RCP85.mat Data