function [temp,header]=ctltoRaster(Df,Latlim,Lonlim,xx,yy,outfile)
%file_name='D:\testRunoff\ELSE_GPCC_result\flddph2011.ctl';
tempS=Df(:,:,1,:);
temp=mean(tempS,4);
[m,n]=size(temp);
mValue=max(max(temp));
 for i=1:m
     for j=1:n
         if abs(temp(i,j)-mValue)<0.001
             temp(i,j)=0;
         end
     end
 end
 %[x,y] = meshgrid([72:0.005:135.9950],[-179.875:0.25:179.8750]);
 
% surf(x,y, temp)
% 
% [Plg,Plt]=meshgrid([-89.875:0.25:89.875],[-179.875:0.25:179.8750]);
% 
% m_proj('hammer-aitoff','clongitude',-150);
% m_pcolor(Plg,Plt,temp);shading flat;
% hold on;
% m_coast('patch',[.6 1 .6]);
% m_grid('xaxis','middle');
% 
% % add a standard colorbar.
% h=colorbar('h');
% set(get(h,'title'),'string','AVHRR SST Nov 1999');
% 
% hold off
 
R = georasterref('RasterSize', [xx yy ], ...
       'RasterInterpretation', 'cells', ...
       'Latlim',Latlim,'Lonlim',Lonlim, ...
       'ColumnsStartFrom', 'north');
geotiffwrite(outfile,temp',R)