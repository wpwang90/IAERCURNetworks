function ncInttoOne(ncfile,first,nt,outfilepath,adjustValue,runoffname)
%ncfile='G:\CaMa-Flood_v3.6.2_20140909\inp\ELSE_GPCC\runoff_nc\runoff1990.nc';
%first=datenum(1989, 12, 31);
%nt=365;
%outfilepath='G:\testRunoff\runtest\wRoff';
ncid =netcdf.open(ncfile,'nowrite');
ncdisp(ncfile);
latData= ncread(ncfile,'lat');
lonData=ncread(ncfile,'lon');
runoffData= ncread(ncfile,runoffname);
[lon,lat]=meshgrid([-179.5:1:179.5],[-89.5:1:89.5]);
%afData=griddata(double(lonData),double(latData),runoffData(:,:,1)',lon,lat,'cubic');


ny=180;%lat
nx=360;%lon
for it=1:nt
    tempT=first+it;
    tt=datestr(tempT,30);
    fid=fopen([outfilepath,tt(1:8),'.one'],'w');
    %afData=griddata(double(lonData),double(latData),runoffData(:,:,it)'*adjustValue,lon,lat,'cubic');
    afData=griddata(double(lonData),double(latData),double(runoffData(:,:,it)')*adjustValue,lon,lat,'cubic');
    tData=afData';
	for j=1:ny
        for i=1:nx
        count= fwrite(fid,double(tData(i,(ny-j+1))),'float');%根据例子这里用原始的数据
        end
    end
    tt
    fclose(fid);
end