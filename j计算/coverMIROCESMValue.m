ncfile='D:\runoff数据下载\mrro_day_MIROC-ESM_rcp26_r1i1p1_20060101-21001231.nc';
first=datenum(2005, 12, 31);
nt=datenum(2100, 12, 31)-first;
outfilepath='I:\testRunoff\MIROC-ESM\RCP26_1\wRoff';
adjustValue=86400;
runoffname='mrro';
ncInttoOne(ncfile,first,nt,outfilepath,adjustValue,runoffname);

ncfile='D:\runoff数据下载\mrro_day_MIROC-ESM_rcp45_r1i1p1_20060101-21001231.nc';
first=datenum(2005, 12, 31);
nt=datenum(2100, 12, 31)-first;
outfilepath='I:\testRunoff\MIROC-ESM\RCP45\wRoff';
adjustValue=86400;
runoffname='mrro';
ncInttoOne(ncfile,first,nt,outfilepath,adjustValue,runoffname);

ncfile='D:\runoff数据下载\mrro_day_MIROC-ESM_rcp85_r1i1p1_20060101-21001231.nc';
first=datenum(2005, 12, 31);
nt=datenum(2100, 12, 31)-first;
outfilepath='I:\testRunoff\MIROC-ESM\RCP85\wRoff';
adjustValue=86400;
runoffname='mrro';
ncInttoOne(ncfile,first,nt,outfilepath,adjustValue,runoffname);