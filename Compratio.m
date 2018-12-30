% Calculate the compression ratio 
% between the original images and the compressed images;
function comp_ratio = Compratio(orig_image, comp_image)

% Calculate how many bits should be used to represented the original images
% and store it in the variable B0
clear tempmatr1;
tempmatr1 = ceil(log2(orig_image+1));
clear sizevector1;
sizevector1 = size(orig_image);
[rownum, colnum] = size(sizevector1);
while colnum >1
    clear tempmatr2;
    tempmatr2 = sum(tempmatr1);
    clear tempmatr1;
    tempmatr1 = tempmatr2;
    colnum = colnum -1;
end
B0 = sum(tempmatr1);

% Calculate how many bits should be used to represented the compressed images
% and store it in the variable B1
clear tempvec1;
tempvec1 = find(comp_image<0);
clear tempmatr1;
if sum(tempvec1) == 0
    tempmatr1 = ceil(log2(comp_image+1));
else
    tempmatr1 = ceil(log2(abs(comp_image)+1))+1;
end
clear sizevector1;
sizevector1 = size(comp_image);
[rownum, colnum] = size(sizevector1);
while colnum >1
    clear tempmatr2;
    tempmatr2 = sum(tempmatr1);
    clear tempmatr1;
    tempmatr1 = tempmatr2;
    colnum = colnum -1;
end
B1 = sum(tempmatr1);
comp_ratio = B0/B1;
