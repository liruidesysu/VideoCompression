% Image compression funtion
function [dcencoded_Y,acencoded_Y,dcencoded_U,acencoded_U,dcencoded_V,acencoded_V,reco_image] = IFrame_Compress_Decompress(orig_image)

RGB=orig_image;
%下面是对RGB三个分量进行分离 
R=RGB(:,:,1);  
G=RGB(:,:,2);  
B=RGB(:,:,3); 

%RGB->YUV  
Y=0.299*double(R)+0.587*double(G)+0.114*double(B); 
[xm, xn] = size(Y);
U=-0.169*double(R)-0.3316*double(G)+0.5*double(B);  
V=0.5*double(R)-0.4186*double(G)-0.0813*double(B);  

%产生一个8*8的DCT变换矩阵  
T=dctmtx(8);
%进行DCT变换 BY BU BV是double类型  
BY=blkproc(Y,[8 8],'P1*x*P2',T,T');  
BU=blkproc(U,[8 8],'P1*x*P2',T,T');  
BV=blkproc(V,[8 8],'P1*x*P2',T,T'); 

%% 量化
%低频分量量化表   
a=[
	16 11 10 16 24 40 51 61;  
	12 12 14 19 26 58 60 55;  
	14 13 16 24 40 57 69 55;  
	14 17 22 29 51 87 80 62;  
	18 22 37 56 68 109 103 77;  
	24 35 55 64 81 104 113 92;  
	49 64 78 87 103 121 120 101;  
	72 92 95 98 112 100 103 99;

];  
%高频分量量化表    
  b=[17 18 24 47 99 99 99 99;  
     18 21 26 66 99 99 99 99;  
     24 26 56 99 99 99 99 99;  
     47 66 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;];  
     
 %使用量化表对三个分量进行量化
 BY2=blkproc(BY,[8 8],'round(x./P1)',a);  
 BU2=blkproc(BU,[8 8],'round(x./P1)',b);  
 BV2=blkproc(BV,[8 8],'round(x./P1)',b);  
 
%调用压缩函数
[dcencoded_Y,acencoded_Y,TCM_Q_Rec_Y]=compress_decompress(BY2,1);
[dcencoded_U,acencoded_U,TCM_Q_Rec_U]=compress_decompress(BU2,2);
[dcencoded_V,acencoded_V,TCM_Q_Rec_V]=compress_decompress(BV2,3);

%反量化
TCM_Rec_Y=blkproc(TCM_Q_Rec_Y,[8,8],'round( x.*P1)',a);
TCM_Rec_U=blkproc(TCM_Q_Rec_U,[8,8],'round( x.*P1)',b);
TCM_Rec_V=blkproc(TCM_Q_Rec_V,[8,8],'round( x.*P1)',b);

%反DCT变换
fun2=@idct2;
YI=blkproc(TCM_Rec_Y,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到YI
UI=blkproc(TCM_Rec_U,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到UI
VI=blkproc(TCM_Rec_V,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到VI
%ReconImage=double(ImageSub_Rec_Y)+128;
% YI=uint8(ImageSub_Rec_Y);
% UI=uint8(ImageSub_Rec_U);
% VI=uint8(ImageSub_Rec_V);

%YUV转为RGB
RI=YI-0.001*UI+1.402*VI;  
GI=YI-0.344*UI-0.714*VI;  
BI=YI+1.772*UI+0.001*VI;

%经过DCT变换和量化后的YUV图像 
RGBI=cat(3,RI,GI,BI); 
RGBI=uint8(RGBI);  
reco_image = RGBI;