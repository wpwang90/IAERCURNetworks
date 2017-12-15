file_name='G:\hires\reg.flddif.ctl';
[data,header]=read_grads(file_name,'all')
tempS=var(:,:,1,:);
temp=mean(tempS,4);
 [m,n]=size(temp);
 for i=1:m
     for j=1:n
         if abs(temp(i,j)-temp(m,n))<0.001
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
 tData=temp;
[m,n]=size(temp);
for i=1:m
    for j=1:n
        tData(i,(n-j+1))=temp(i,j);
    end
end
R = georasterref('RasterSize', [10200 12800 ], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [3 53.9950], 'Lonlim', [72 135.9950], ...
       'ColumnsStartFrom', 'north')
   
geotiffwrite('G:\1990-sp1\flddph1990.tif',tData',R)