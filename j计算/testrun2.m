ncfile='G:\runoffData\CMCC-CESM\mrro_day_CMCC-CM_rcp45_r1i1p1_20110101-20111231.nc';
ncid =netcdf.open(ncfile,'nowrite');
ncdisp(ncfile);
latData= ncread(ncfile,'lat');
lonData=ncread(ncfile,'lon');
runoffData= ncread(ncfile,'mrro');
timeData=ncread(ncfile,'time');
temp=runoffData(:,:,5)*86400;
R = georasterref('RasterSize', [240 480], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [-89.4271 89.4271], 'Lonlim', [-179.625 179.625], ...
       'ColumnsStartFrom', 'north')
   
geotiffwrite('G:\testRunoff\3Roff19900102.tif',temp',R)

nt=365;
ny=240;%2.5*2.5格点的
nx=480;%2.5*2.5格点的
first=datenum(2010, 12, 31);
for it=1:nt
    tempT=first+it;
    tt=datestr(tempT,30);
    fid=fopen(['G:\testRunoff\ELSE_GPCC\wRoff',tt(1:8),'.one'],'w');
	for j=1:ny
        for i=1:nx
        count= fwrite(fid,runoffData(i,(ny-j+1),it),'float');%根据例子这里用原始的数据
        end
    end
    fclose(fid)
end