tData=zeros(180,360);
for i = 1:180
    for j = 1:360
        tData(i,j)=(i-1)*360+j;
    end
end

R = georasterref('RasterSize', [180 360], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [-89.5 89.5], 'Lonlim', [-179.5 179.5], ...
       'ColumnsStartFrom', 'north');
geotiffwrite('C:\Users\woqie\Mac文档\研究\BU\河流公路铁路耦合系统\数据\normGrid.tif',tData,R);


