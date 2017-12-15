clear;clc
binfilename='G:\\resultother\\1990-sp1\\flddph1990.bin';
first=datenum(1989, 12, 31);
totalData=zeros(1440,720);
totalI={};
first=first+1;
file_name=['G:\1990-sp1\temp\flddph1990.ctl'];
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
totalData=zeros(1440,720);
totalTlength=365;
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
totalData=totalData+temp;
end
