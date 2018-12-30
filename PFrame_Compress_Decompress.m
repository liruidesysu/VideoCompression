function  [Pzhen,QQQ]=PFrame_Compress_Decompress(frame,FrameI,X,Z)

RGB=frame;
%下面是对RGB三个分量进行分离 
R=RGB(:,:,1);  
G=RGB(:,:,2);  
B=RGB(:,:,3); 

%RGB->YUV  
Y=0.299*double(R)+0.587*double(G)+0.114*double(B); 
[xm, xn] = size(Y);
U=-0.169*double(R)-0.3316*double(G)+0.5*double(B);  
V=0.5*double(R)-0.4186*double(G)-0.0813*double(B);  

%% DCT变换
% 产生一个8*8的DCT变换矩阵  
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
b=[
    17 18 24 47 99 99 99 99;  
    18 21 26 66 99 99 99 99;  
    24 26 56 99 99 99 99 99;  
    47 66 99 99 99 99 99 99;  
    99 99 99 99 99 99 99 99;  
    99 99 99 99 99 99 99 99;  
    99 99 99 99 99 99 99 99;  
    99 99 99 99 99 99 99 99;
    ];  
     
 %使用量化表对三个分量进行量化
BY2=blkproc(BY,[8 8],'round(x./P1)',a);  
BU2=blkproc(BU,[8 8],'round(x./P1)',b);    
BV2=blkproc(BV,[8 8],'round(x./P1)',b);  

%% FrameI
RGB=FrameI;
%下面是对RGB三个分量进行分离 
RI=RGB(:,:,1);  
GI=RGB(:,:,2);  
BI=RGB(:,:,3); 

%RGB->YUV  
YI1=0.299*double(RI)+0.587*double(GI)+0.114*double(BI); 
[xmI, xnI] = size(YI1);
UI1=-0.169*double(RI)-0.3316*double(GI)+0.5*double(BI);  
VI1=0.5*double(RI)-0.4186*double(GI)-0.0813*double(BI);  


%进行DCT变换 BY BU BV是double类型  
BYI=blkproc(YI1,[8 8],'P1*x*P2',T,T');  
BUI=blkproc(UI1,[8 8],'P1*x*P2',T,T');  
BVI=blkproc(VI1,[8 8],'P1*x*P2',T,T'); 


 %使用量化表对三个分量进行量化
BY2I=blkproc(BYI,[8 8],'round(x./P1)',a);  
BU2I=blkproc(BUI,[8 8],'round(x./P1)',b);    
BV2I=blkproc(BVI,[8 8],'round(x./P1)',b); 


%% 运动估计
[Yzhen,YYY]=PzhenGuJi(BY2,BY2I,X,Z);
[Uzhen,UUU]=PzhenGuJi(BU2,BU2I,X,Z);
[Vzhen,VVV]=PzhenGuJi(BV2,BV2I,X,Z);

%%
%反量化
TCM_Y=blkproc(Yzhen,[8,8],'round( x.*P1)',a);
TCM_U=blkproc(Uzhen,[8,8],'round( x.*P1)',b);
TCM_V=blkproc(Vzhen,[8,8],'round( x.*P1)',b);

%反DCT变换
fun2=@idct2;
YI1=blkproc(TCM_Y,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到ImageSub_Rec_Y
UI1=blkproc(TCM_U,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到ImageSub_Rec_U
VI1=blkproc(TCM_V,[8,8],fun2);% 使用idct2函数进行二维反DCT变换，得到ImageSub_Rec_V
%ReconImage=double(ImageSub_Rec_Y)+128;
% YI=uint8(ImageSub_Rec_Y);
% UI=uint8(ImageSub_Rec_U);
% VI=uint8(ImageSub_Rec_V);

%YUV转为RGB
RI1=YI1-0.001*UI1+1.402*VI1;  
GI1=YI1-0.344*UI1-0.714*VI1;  
BI1=YI1+1.772*UI1+0.001*VI1;

%经过DCT变换和量化后的YUV图像 
RGBI1=cat(3,RI1,GI1,BI1); 
RGBI1=uint8(RGBI1);  
Pzhen = RGBI1;
QQQ = 1;
 
 
%% 
% [m n]=size(FrameI);
% ShiLiang=zeros(m,n); 
% for i=1:X:m-1
%     for j=1:X:n-1
%          K1=FrameI(i:i+X-1,j:j+X-1)-frame(i:i+X-1,j:j+X-1);
%          K2=frame(i:i+X-1,j:j+X-1)-FrameI(i:i+X-1,j:j+X-1);
%          K=K1+K2;
%          CF=sum(abs(K(:)));
%       if CF>20    %%%避免因为噪声等影响而造成错误估计             
%           CF3=inf;  
%           [a,b,c,d]=ChuangKou(Z,i,j,m,n,X);   %%%%%%%设定要求的窗口
%           for ii=(i-a):X:(i+b)
%               for jj=(j-c):X:(j+d) 
%                 KK1=FrameI(ii:ii+X-1,jj:jj+X-1)-frame(i:i+X-1,j:j+X-1);
%                 KK2=frame(i:i+X-1,j:j+X-1)-FrameI(ii:ii+X-1,jj:jj+X-1);
%                 KK=KK1+KK2;
%                 CF2=sum(abs(KK(:)));
%                   if CF2<CF3
%                       ShiLiang(i,j)=ii;       %%%存放运动矢量的行坐标
%                       ShiLiang(i,j+1)=jj;     %%%%存放运动矢量的列坐标
%                       CF3=CF2;            %%%%保证存的最小误差的运动矢量位置
%                   end;
%               end;
%           end
%       end
%     end
% end
% C=FrameI;  
% QQQ=(m*n)/(2*(length(find(ShiLiang~=0))));
% %%%%%%%%%%%%%%%%%%%开始用运动矢量进行恢复
% for i=1:X:m-1
%     for j=1:X:n-1
%         if ShiLiang(i,j)~=0
%             C(i:i+X-1,j:j+X-1)=FrameI(ShiLiang(i,j),ShiLiang(i,j+1));
%         end;
%     end;
% Pzhen=uint8(C);
%end

%% 

