ncfile='D:\runoffData\CMCC-CESM\mrro_day_CMCC-CM_rcp45_r1i1p1_20110101-20111231.nc';
first=datenum(2010, 12, 31);
nt=365;
outfilepath='G:\testRunoff\ELSE_GPCC\wRoff';
adjustValue=86400;
runoffname='mrro';
%ncInttoOne(ncfile,first,nt,outfilepath,adjustValue,runoffname);