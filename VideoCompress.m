%ʵ��֡�ڱ������ζ�����I֡����֡��Ԥ�⡢DCT�任��������zigzagɨ�衢���������롢
%���롢��zigzagɨ�衢����������DCT�任��
tic
clc;clear all;


%% ͼ���ļ���·��  
file_path =  'DragonBaby\img\';

%��ȡ���ļ���������bmp��ʽ��ͼ��  
img_path_list = dir(strcat(file_path,'*.jpg'));


% ��ȡͼ�������� 
img_num = length(img_path_list);
Image=cell(1,img_num);
if img_num > 0 %������������ͼ��          
    for j = 1:img_num %��һ��ȡͼ��              
        image_name = img_path_list(j).name;% ͼ����              
        image =  imread(strcat(file_path,image_name));              
        Image{j}=image;
        % ��ʾ���ڴ����ͼ����      
        fprintf(' %d %s\n',j,strcat(file_path,image_name));
    end
end



%% �趨�˶�������������
X=2;    %('�����봰�ڴ�С:   ');
Z=5;    %('�������������ڰ뾶��С:   ');
Y=4;    %('����������I֡�ļ����');
% X=input('�����봰�ڴ�С:   ');
% Z=input('�������������ڰ뾶��С:   ');

%% ��Ƶѹ������
% ��һ֡I֡λ�þ�����Ƶ�ĵ�һ֡
I_location = 1;

for k = 1:img_num %��ȡ����
%     frame = rgb2ycbcr(Image{k});
%     frameI = rgb2ycbcr(Image{I_location});
    frame = Image{k};
    frameI = Image{I_location};
    if ~(mod(k-1,Y)) %����֡��Ԥ��
        
        if k+Y<img_num
            I_location=k+Y;
        else
            I_location=k;
        end

        % I֡ѹ��&��ѹ
        [dcencoded_Y,acencoded_Y,dcencoded_U,acencoded_U,dcencoded_V,acencoded_V,reco_image] = IFrame_Compress_Decompress(Image{I_location});

        %I֡��ѹ
        %s_image = Decompress(dcencoded_Y,dcdict_Y,acencoded_Y,acdict_Y,Num_col_Y,dcencoded_U,dcdict_U,acencoded_U,acdict_U,Num_col_U,dcencoded_V,dcdict_V,acencoded_V,acdict_V,Num_col_V);
        %I֡��ѹ�����output�ļ�������
        k
        saveName = ['IFrame_out\',num2str(k), '.jpg'];
        imwrite(reco_image,saveName);
        compression_ratio = (size(dcencoded_Y)+size(acencoded_Y)+size(dcencoded_U)+size(acencoded_U)+size(dcencoded_V)+size(acencoded_V))/(360*640*3)
    else   
        k1=k;
        k1
        %P֡ѹ��&��ѹ
        %FrameI=frameI;
        %frame = Image{k};
        %[Pzhen,QQQ]=PzhenGuJi(frame,FrameI,X,Z);
        tic
        [Pzhen,QQQ]=PFrame_Compress_Decompress(Image{k},Image{k-1},X,Z);
        toc
        %YASUOLV(k)=QQQ;%ѹ����
        saveName = ['PFrame_out\',num2str(k), '.jpg'];
        imwrite(Pzhen,saveName);
    end
end
toc
%%
% [comp_image_Y,comp_image_U,comp_image_V] = IFrameCompress(Image{I_location});
% s_image = Decompress(comp_image_Y,comp_image_U,comp_image_V);
% comp_size = comp_image_Y.realsize+comp_image_U.realsize+comp_image_V.realsize;



