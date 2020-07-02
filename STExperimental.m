clear all; close all; clc; warning off; 
% Parameters Similiar to Simulation Code
pixs=[250;250]; %Number of Pixels to Reshape Image
num_images_baseline=40; %Number of Good Images
init_size=22; %Initial size (width and height) of serveillence region
grids=[10;10]; %Number of Section to scan...x and y directions
increment_size=4;   %Increment size of serveillence region....increase in width and height
m=10; %History Window
spaces=pixs./grids;

%Creating Nominal Tile
I=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_00000.jpg']);
if isgray(I)==0
    I=rgb2gray(I);
end
I=I(160:2300, 740:2880);
I=imresize(I,pixs');
I=imadjust(I, [0.2 0.8], []);
imwrite(I,'Tile_Nom.jpg');
clear I

% Loading Nominal Image
Nom=imread('Tile_Nom.jpg');
Nomd=double(Nom);

Counter1=0;
for pic=1:num_images_baseline %In Control Images w/ Noise
    Counter1=Counter1+1;
    if pic<=9
        I=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_0000' num2str(pic) '.jpg']);
    else
        I=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_000' num2str(pic) '.jpg']);
    end
    if isgray(I)==0
        I=rgb2gray(I);
    end
    I=I(160:2300, 740:2880);
    I=imresize(I,pixs');
    I=imadjust(I, [0.2 0.8], []);
    I=Nomd-double(I);
    for i = 1:grids(1) %Run through x locations for center(i,j} of serveillance box
        for j = 1:grids(2) %Run through y locations for center(i,j} of serveillance box
            if Counter1 ==1;
                center(i,j,:)=[spaces(1)/2+(i-1)*spaces(1);spaces(2)/2+(j-1)*spaces(2)]; %Current center(i,j} of serveillance box
                min_dis(i,j)=min([squeeze(center(i,j,:))-init_size/2-1;pixs-squeeze(center(i,j,:))-init_size/2-1]); %Find Nearest Edge...Maximum amount the box can increase
                tempsteps=[init_size:increment_size:init_size+min_dis(i,j)*2]; % Size Increments of the box
                max_steps(i,j)=length(tempsteps);
                steps{i,j}=tempsteps;
            end
            for stepper=1:max_steps(i,j)
                if stepper==1
                    if Counter1==1
                        I_2_test1_reg{i,j,stepper}=[center(i,j,1)-steps{i,j}(stepper)/2,center(i,j,1)+steps{i,j}(stepper)/2,center(i,j,2)-steps{i,j}(stepper)/2,center(i,j,2)+steps{i,j}(stepper)/2];
                    end
                    I_2_test=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                    number_of_pixs=numel(I_2_test);
                    I_2_test_reshape=reshape(I_2_test,1,number_of_pixs); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,Counter1)=sum(I_2_test_reshape); %Collect sums of diffs
                    X2_sum(i,j,stepper,Counter1)=sum(I_2_test_reshape.^2); %Collect sums of diffs
                    if Counter1==1
                        X_count(i,j,stepper)=number_of_pixs; %Collect nums of diffs
                        X_count2(i,j,stepper)=number_of_pixs;
                    end
                else
                    if Counter1==1
                        I_2_test1_reg{i,j,stepper}=[center(i,j,1)-steps{i,j}(stepper)/2,center(i,j,1)-steps{i,j}(stepper)/2+increment_size/2-1,center(i,j,2)-steps{i,j}(stepper)/2,center(i,j,2)+steps{i,j}(stepper)/2];
                        I_2_test2_reg{i,j,stepper}=[center(i,j,1)+steps{i,j}(stepper)/2-increment_size/2+1,center(i,j,1)+steps{i,j}(stepper)/2,center(i,j,2)-steps{i,j}(stepper)/2,center(i,j,2)+steps{i,j}(stepper)/2];
                        I_2_test3_reg{i,j,stepper}=[center(i,j,1)-steps{i,j}(stepper)/2+increment_size/2,center(i,j,1)+steps{i,j}(stepper)/2-increment_size/2,center(i,j,2)-steps{i,j}(stepper)/2,center(i,j,2)-steps{i,j}(stepper)/2+increment_size/2-1];
                        I_2_test4_reg{i,j,stepper}=[center(i,j,1)-steps{i,j}(stepper)/2+increment_size/2,center(i,j,1)+steps{i,j}(stepper)/2-increment_size/2,center(i,j,2)+steps{i,j}(stepper)/2-1,center(i,j,2)+steps{i,j}(stepper)/2+increment_size/2-2];
                    end
                    I_2_test1=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                    I_2_test2=I(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                    I_2_test3=I(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                    I_2_test4=I(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                    I_2_test=[I_2_test1 I_2_test2 I_2_test3' I_2_test4']; %Take Pixels on edge of box
                    number_of_pixs=numel(I_2_test);
                    I_2_test_reshape=reshape(I_2_test,1,number_of_pixs); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,Counter1)=sum(I_2_test_reshape)+X_sum(i,j,stepper-1,Counter1); %Collect sums of diffs
                    X2_sum(i,j,stepper,Counter1)=sum(I_2_test_reshape.^2)+X2_sum(i,j,stepper-1,Counter1); %Collect sums of diffs
                    if Counter1==1
                        X_count(i,j,stepper)=number_of_pixs; %Collect nums of diffs
                        X_count2(i,j,stepper)=number_of_pixs+X_count2(i,j,stepper-1);
                    end
                end
            end
        end
    end
end
X_sum_pics=sum(X_sum,4);
X2_sum_pics=sum(X2_sum,4);
X_count_pics=num_images_baseline*X_count2;
mus=X_sum_pics./X_count_pics;
vars=X2_sum_pics./X_count_pics-mus.^2;
max_ratio=zeros(1,num_images_baseline);
X_sum_temp=X_sum;
X_sum=X_sum_temp(:,:,:,1:m);
lratconst=1/2/vars;
mflag=0;
Counter2=0;
for pic=1:num_images_baseline
    Counter2=Counter2+1;
        ratio=-inf; %The statistic....we Look for the maximum.... set initial value to -inf
    if Counter2 > m
        mflag=Counter2-m;
        X_sum(:,:,:,1:m-1)=X_sum(:,:,:,2:m);
        X_sum(:,:,:,m)=X_sum_temp(:,:,:,Counter2);
    end
    for i = 1:grids(1) %Run through x locations for center of serveillance box
        for j = 1:grids(2) %Run through y locations for center of serveillance box
            for stepper=1:max_steps(i,j)
                mu_est=X_sum(i,j,stepper,Counter2-mflag)/X_count2(i,j,stepper); %Sample mean from box
                rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mu_est-mus(i,j,stepper))^2;
                rat_hist(i,j,stepper,Counter2)=rat;
                if rat>ratio %If the statistic is bigger than previous one
                    ratio=rat; %New statistic
                end
                for pic_retro=Counter2-1:-1:1+mflag
                    X_counttemp=(Counter2-pic_retro+1)*X_count2(i,j,stepper);
                    X_sum(i,j,stepper,pic_retro-mflag)=X_sum(i,j,stepper,pic_retro-mflag)+X_sum(i,j,stepper,Counter2-mflag);
                    mu_est=X_sum(i,j,stepper,pic_retro-mflag)/X_counttemp; %Sample mean from box
                    rat=lratconst(i,j,stepper)*X_counttemp*(mu_est-mus(i,j,stepper))^2;
                    if rat>ratio
                        ratio=rat;
                    elseif rat<0
                        break;
                    end
                end
            end
        end
    end
max_ratio(Counter2)=ratio;
end
mean_rats=mean(max_ratio); std_rats=std(max_ratio);
mean_init_rats=mean(rat_hist,4);
save('STExpBaseline','mus','vars','X_count','X_count2','center','steps','max_steps','I_2_test1_reg','I_2_test2_reg','I_2_test3_reg','I_2_test4_reg','mean_rats','std_rats','mean_init_rats','m','pixs','init_size','grids','increment_size');