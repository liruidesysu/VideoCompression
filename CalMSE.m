% Calculate the MSE
function MSE = CalMSE(orig_image, reco_image)

clear dist_image;
dist_image = orig_image - reco_image;
sum_image = dist_image.*dist_image;
sumdist = sum(sum(sum(sum(sum_image))));
[rownum, colnum, dimension, imagenum] = size(orig_image);
MSE = sumdist/(rownum*colnum*dimension*imagenum);



