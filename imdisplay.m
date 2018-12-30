% Display the gray-level image or color image based on immatrix

function imdisplay(immatrix)

minvalue = min(min(min(immatrix)));
maxvalue = max(max(max(immatrix)));
if maxvalue == minvalue
    dispim =0;
else
    dispim = 255*double(immatrix-minvalue)/double(maxvalue-minvalue);
end
imshow(dispim/255);
