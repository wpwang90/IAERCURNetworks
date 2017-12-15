load('MIROCESM_RCP85.mat')
N=20;
[m,n]=size(Data{1});
ilag=1;
maxRe=0.01;
reResult2030=zeros(m,n);
for i=1:m
    for j=1:n
        tempData=[];
        for Qi=(ilag):(ilag+N-1)
            tData=Data{Qi};
            tempData=[tempData tData(i,j)];
        end
            M100=mean(tempData);
            M110=0;
            for im=1:N
                M110=M110+(im-1)/(N-1)*tempData(im);
            end
            M110=M110/N;
            L1=M100;
            L2=2*M110-M100;
            alfa=L2/log(2);
            kesi=L1-alfa*0.57721;
            X = evinv(1-maxRe,kesi,alfa);
            if isnan(X)
            reResult2030(i,j)=0;
            else
            reResult2030(i,j)=X;
            end
    end
end
        
R = georasterref('RasterSize', [720 1440 ], ...
       'RasterInterpretation', 'cells', ...
       'Latlim', [-89.875 89.875], 'Lonlim', [-179.875 179.8750], ...
       'ColumnsStartFrom', 'north')
   
geotiffwrite('reResult2030_85.tif',reResult2030,R)