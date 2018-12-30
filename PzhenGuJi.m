function  [Pzhen,QQQ]=PzhenGuJi(frame,FrameI,X,Z)
[m n]=size(FrameI);
ShiLiang=zeros(m,n); 
for i=1:X:m-1
    for j=1:X:n-1
         K1=FrameI(i:i+X-1,j:j+X-1)-frame(i:i+X-1,j:j+X-1);
         K2=frame(i:i+X-1,j:j+X-1)-FrameI(i:i+X-1,j:j+X-1);
         K=K1+K2;
         CF=sum(abs(K(:)));
      if CF>20    %%%避免因为噪声等影响而造成错误估计             
          CF3=inf;  
          [a,b,c,d]=ChuangKou(Z,i,j,m,n,X);   %%%%%%%设定要求的窗口
          for ii=(i-a):X:(i+b)
              for jj=(j-c):X:(j+d) 
                KK1=FrameI(ii:ii+X-1,jj:jj+X-1)-frame(i:i+X-1,j:j+X-1);
                KK2=frame(i:i+X-1,j:j+X-1)-FrameI(ii:ii+X-1,jj:jj+X-1);
                KK=KK1+KK2;
                CF2=sum(abs(KK(:)));
                  if CF2<CF3
                      ShiLiang(i,j)=ii;       %%%存放运动矢量的行坐标
                      ShiLiang(i,j+1)=jj;     %%%%存放运动矢量的列坐标
                      CF3=CF2;            %%%%保证存的最小误差的运动矢量位置
                  end;
              end;
          end
      end
    end
end
C=FrameI;  
QQQ=(m*n)/(2*(length(find(ShiLiang~=0))));
%% 开始用运动矢量进行恢复
for i=1:X:m-1
    for j=1:X:n-1
        if ShiLiang(i,j)~=0
            C(i:i+X-1,j:j+X-1)=FrameI(ShiLiang(i,j),ShiLiang(i,j+1));
        end;
    end;
%Pzhen=uint8(C);
Pzhen=C;
end


