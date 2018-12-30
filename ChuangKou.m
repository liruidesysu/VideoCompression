function  [a,b,c,d]=ChuangKou(Z,i,j,m,n,X)
if (i-X*Z)<1
    a=i-1;
else a=X*Z;
end;
if (j-X*Z)<1
    c=j-1;
else c=X*Z;
end;
if (i+X*Z+2)<m
    b=Z*X+3;
else b=m-i;
end;

if (j+X*Z+2)<n
    d=Z*X+3;
else d=n-j;
end;
end