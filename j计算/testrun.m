ncfile='D:\CaMa-Flood_v3.6.2_20140909\inp\ELSE_GPCC\runoff_nc\runoff1990.nc';
ncid =netcdf.open(ncfile,'nowrite');
ncdisp(ncfile);
latData= ncread(ncfile,'lat');
lonData=ncread(ncfile,'lon');
runoffData= ncread(ncfile,'runoff');
nt=365;
ny=360;%lat
nx=720;%lon
first=datenum(1989, 12, 31);
for it=1:nt
    tempT=first+it;
    tt=datestr(tempT,30);
    fid=fopen(['D:\testRunoff\runtest\wRoff',tt(1:8),'.one'],'w');
	for j=1:ny
        for i=1:2:nx
        count= fwrite(fid,(runoffData(i,(ny-j+1),it)+runoffData(i+1,(ny-j+1),it))/2,'float');%根据例子这里用原始的数据
        end
    end
    tt
    fclose(fid);
    
end
