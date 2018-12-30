function [dcencoded,acencoded,TCM_Q_Rec] = compress_decompress( x,flag )
[am,an] = size(x);

% ��ÿ��8*8 ���ݿ������ϵ���ų����������õ�64* ���ݿ�������С�ľ���TCM_Q_col��
TCM_Q_col=im2col(x,[8,8],'distinct'); 
% �õ�TCM_Q_col�������������ݿ�ĸ���Num_col�� 
Num_col=size(TCM_Q_col,2);
%z���Ͷ�ȡ����˳���
order=[1 9 2 3 10 17 25 18 ...
11 4 5 12 19 26 33 41 ...
34 27 20 13 6 7 14 21 ...
28 35 42 49 57 50 43 36 ...
29 22 15 8 16 23 30 37 ...
44 51 58 59 52 45 38 31 ...
24 32 39 46 53 60 61 54 ...
47 40 48 55 62 63 56 64];

%��z ��ɨ�跽ʽ�Ա任ϵ��������������
TCM_Q_colZ=TCM_Q_col(order,:);

%% ����
%5.1ֱ�����룬dcΪֱ��ϵ����dcdpcmΪֱ����ֵ�����
dc=zeros(Num_col,1);
dcdpcm=zeros(Num_col,1);
for j=1:Num_col
dc(j)=TCM_Q_colZ(1,j); % ��DC ϵ�����е�һ��ʸ����
end
dcdpcm(1)=dc(1);
for j=2:Num_col
dcdpcm(j)=dc(j)-dc(j-1); % ��DC ϵ����DPCM ����
end
dcdmax=max(dcdpcm); %���ֱ��
dcdmin=min(dcdpcm); %��Сֱ��
dch=histc(dcdpcm,dcdmin:dcdmax); %ͳ�Ƹ���ֵ��ֱ��ͼ
dcnum=length(dcdpcm);
dcp=dch/dcnum; %�������ֵ�ĸ���
dcsymbols=dcdmin:dcdmax; %ֱ������ֵ
[dcdict,dcavglen]=huffmandict(dcsymbols,dcp); %�����ֵ�dcdict������ƽ���볤
dcencoded=huffmanenco(dcdpcm,dcdict); % ��DC ϵ����DPCM ����Huffman ���룬�õ�ֱ������dcencoded

%5.2��������
% ������ACԪ���������зŵ�ac��,ÿһ�о���eob ��Ϊ����,����count������Ԫ�� 
eob=max(x(:))+1; % ����һ�����������
num=numel(TCM_Q_colZ)+size(TCM_Q_col,2);
ac=zeros(num,1);
count=0;
for j=1:Num_col
i=max(find(TCM_Q_colZ(:,j)));%find ����ΪѰ��yy �����з���Ԫ�ص�λ�ã�max ����Ϊȡ��������ֵ�����޷���Ԫ�ػ���Ϊ�գ�����empty
if isempty(i)
i=1;
end
p=count+1;
q=p+i-1;
if i==1
ac(q)=eob;
end
ac(p:q)=[TCM_Q_colZ(2:i,j);eob];
count=q;
end
ac((count+1):end)=[];% ɾ��ac�е�����Ԫ��
acmax=max(ac); %�����
acmin=min(ac); %��С����
ach=histc(ac,[acmin:acmax]); %ͳ�Ƹ���ֵ��ֱ��ͼ
acnum=length(ac);
acp=ach/acnum; %�������ֵ�ĸ���
acsymbols=[acmin:acmax]; %��������ֵ
[acdict,acavglen]=huffmandict(acsymbols,acp); %�����ֵ�acdict������ƽ���볤
acencoded=huffmanenco(ac,acdict); % ��AC ϵ������Huffman���룬�õ���������acencoded


%% ����
dcdecoded=huffmandeco(dcencoded,dcdict); %ֱ��Huffman����
%����ֱ������ָ�ֱ��������������TCM_Q_colZ_Rec�ĵ�һ��
TCM_Q_colZ_Rec(1,1)=dcdecoded(1);
for i=2:Num_col
    TCM_Q_colZ_Rec(1,i)=TCM_Q_colZ_Rec(1,i-1)+dcdecoded(i); % �����i��ֱ������������ֱ����������TCM_Q_colZ_Rec�ĵ�i�е�1�С�
end
acdecoded=huffmandeco(acencoded,acdict); %����Huffman����
%���ݽ�������ָ���������������TCM_Q_colZ_Rec�ĵ�2-64��
j=1; %j������¼�ڼ���
k=2; %k������¼�ڼ���
maxk=1;
count=0; %count������¼����������eob�ĸ�������count=63ʱ����һ��eob����Ϊ�������������롣
for i=1:size(acdecoded)
    if acdecoded(i)==eob
        TCM_Q_colZ_Rec(k:64,j)=0;
        j=j+1;
        k=2;
    else
    TCM_Q_colZ_Rec(k,j)=acdecoded(i);
    k=k+1;
    end
end
%��Z��ɨ��
revorder=[
1 3 4 10 11 21 22 36 ...
2 5 9 12 20 23 35 37 ...
6 8 13 19 24 34 38 49 ...
7 14 18 25 33 39 48 50 ...
15 17 26 32 40 47 51 58 ...
16 27 31 41 46 52 57 59 ...
28 30 42 45 53 56 60 63 ...
29 43 44 54 55 61 62 64];

TCM_Q_col_Rec= TCM_Q_colZ_Rec(revorder,:); %�÷�z ��ɨ�跽ʽ�Ա任ϵ����������
TCM_Q_Rec=col2im(TCM_Q_col_Rec,[8,8],[am,an],'distinct'); % ��TCM_Q_col_Rec��ÿ���������ų�8*8���ݿ飬�������Ϊͼ��size��

%% 
% eob = max(TCM_Q_colZ(:)) + 1;               % ���ÿ�β������־
% r = zeros(numel(TCM_Q_colZ) + size(TCM_Q_colZ, 2), 1);
% count = 0;
% for j = 1:Num_col                       % ÿ�δ���һ����
%    i = max(find(TCM_Q_colZ(:, j)));         % �ҵ����һ������Ԫ��
%    if isempty(i)                   
%       i = 0;
%    end
%    p = count + 1;
%    q = p + i;
%    r(p:q) = [TCM_Q_colZ(1:i, j); eob];      % ����������־
%    count = count + i + 1;          % ����
% end
% 
% r((count + 1):end) = [];           % ɾ��r �в���Ҫ��Ԫ��
% [r1,r2]=size(r);
% TCM_Q_colZ           = struct;
% TCM_Q_colZ.realsize = r1;
% TCM_Q_colZ.size      = uint16([xm xn]);
% TCM_Q_colZ.numblocks = uint16(Num_col);
% TCM_Q_colZ.r   = r;
% TCM_Q_colZ.flag = flag;

end

