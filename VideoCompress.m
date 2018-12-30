%实现帧内编码依次对所定I帧进行帧内预测、DCT变换、量化、zigzag扫描、哈夫曼编码、
%解码、反zigzag扫描、反量化、反DCT变换。
tic
clc;clear all;


%% 图像文件夹路径  
file_path =  'DragonBaby\img\';

%获取该文件夹中所有bmp格式的图像  
img_path_list = dir(strcat(file_path,'*.jpg'));


% 获取图像总数量 
img_num = length(img_path_list);
Image=cell(1,img_num);
if img_num > 0 %有满足条件的图像          
    for j = 1:img_num %逐一读取图像              
        image_name = img_path_list(j).name;% 图像名              
        image =  imread(strcat(file_path,image_name));              
        Image{j}=image;
        % 显示正在处理的图像名      
        fprintf(' %d %s\n',j,strcat(file_path,image_name));
    end
end



%% 设定运动补偿窗口数据
X=2;    %('请输入窗口大小:   ');
Z=5;    %('请输入搜索窗口半径大小:   ');
Y=4;    %('请输入相邻I帧的间隔：');
% X=input('请输入窗口大小:   ');
% Z=input('请输入搜索窗口半径大小:   ');

%% 视频压缩编码
% 第一帧I帧位置就是视频的第一帧
I_location = 1;

for k = 1:img_num %读取数据
%     frame = rgb2ycbcr(Image{k});
%     frameI = rgb2ycbcr(Image{I_location});
    frame = Image{k};
    frameI = Image{I_location};
    if ~(mod(k-1,Y)) %进行帧内预测
        
        if k+Y<img_num
            I_location=k+Y;
        else
            I_location=k;
        end

        % I帧压缩&解压
        [dcencoded_Y,acencoded_Y,dcencoded_U,acencoded_U,dcencoded_V,acencoded_V,reco_image] = IFrame_Compress_Decompress(Image{I_location});

        %I帧解压
        %s_image = Decompress(dcencoded_Y,dcdict_Y,acencoded_Y,acdict_Y,Num_col_Y,dcencoded_U,dcdict_U,acencoded_U,acdict_U,Num_col_U,dcencoded_V,dcdict_V,acencoded_V,acdict_V,Num_col_V);
        %I帧解压后存在output文件夹下面
        k
        saveName = ['IFrame_out\',num2str(k), '.jpg'];
        imwrite(reco_image,saveName);
        compression_ratio = (size(dcencoded_Y)+size(acencoded_Y)+size(dcencoded_U)+size(acencoded_U)+size(dcencoded_V)+size(acencoded_V))/(360*640*3)
    else   
        k1=k;
        k1
        %P帧压缩&解压
        %FrameI=frameI;
        %frame = Image{k};
        %[Pzhen,QQQ]=PzhenGuJi(frame,FrameI,X,Z);
        tic
        [Pzhen,QQQ]=PFrame_Compress_Decompress(Image{k},Image{k-1},X,Z);
        toc
        %YASUOLV(k)=QQQ;%压缩率
        saveName = ['PFrame_out\',num2str(k), '.jpg'];
        imwrite(Pzhen,saveName);
    end
end
toc
%%
% [comp_image_Y,comp_image_U,comp_image_V] = IFrameCompress(Image{I_location});
% s_image = Decompress(comp_image_Y,comp_image_U,comp_image_V);
% comp_size = comp_image_Y.realsize+comp_image_U.realsize+comp_image_V.realsize;



