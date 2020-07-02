clc; clear all; close all
n=100;
sum=0;
sum=double(sum);
for r=1:n
    x=n-r;
    sum=sum+((factorial(n))/((factorial(x))*factorial(r)));
end
sum
    