%____________________Initilization_________________________________________
clear all; close all; clc; warning off;
pixs=[250;250];
load('STExpBaseline.mat');
% load('Ras.mat')
Nom=imread('Tile_Nom.jpg');
Nomd=double(Nom);
%__________________________________________________________________________
k=10; m=10;
N=pixs(1)*pixs(2);
mus2=mus.^2;
fault_pat=zeros(pixs(1),pixs(2));
X_sum=zeros([size(mus),m]);
lratconst=1/2/vars;
mfiller=zeros([size(mus),1]);
mflag=0;
UCL=mean_rats+k*std_rats;
% UCL=400;
counter=0;
ra1=randsample(40,20); % Saved the one for our experiment in the
% Initilization
for lc=1:length(ra1)
    ratio=-inf;
    counter=counter+1;
    if counter > m
        mflag=counter-m;
        X_sum(:,:,:,1:m-1)=X_sum(:,:,:,2:m);
        X_sum(:,:,:,m)=mfiller;
    else
        mflag=0;
    end
    if ra1(lc)<10
        temp=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_0000' num2str(ra1(lc)) '.jpg']);
    else
        temp=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_000' num2str(ra1(lc)) '.jpg']);
    end
    temp=temp(160:2300, 740:2880);
    if isgray(temp)==0
        temp=rgb2gray(temp);
    end
    temp=imresize(temp,pixs');
    temp=imadjust(temp, [0.2 0.8], []);
    I=Nomd-double(temp);
    for i = 1:grids(1) %Run through x locations for center of serveillance box
        for j = 1:grids(2) %Run through y locations for center of serveillance box
            for stepper=1:max_steps(i,j)
                if stepper==1
                    I_2_test=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,counter-mflag)=sum(I_2_test_reshape); %Collect sums of diffs
                else
                    I_2_test1=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                    I_2_test2=I(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                    I_2_test3=I(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                    I_2_test4=I(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                    I_2_test=[I_2_test1 I_2_test2 I_2_test3' I_2_test4']; %Take Pixels on edge of box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,counter-mflag)=sum(I_2_test_reshape)+X_sum(i,j,stepper-1,counter-mflag); %Collect sums of diffs
                end
                mu_est=X_sum(i,j,stepper,counter-mflag)/X_count2(i,j,stepper); %Sample mean from box
                rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mu_est-mus(i,j,stepper))^2;
                if rat>ratio %If the statistic is bigger than previous one
                    ratio=rat; %New statistic
                    locate=[i,j,stepper];
                end
                
                if rat>mean_init_rats(i,j,stepper)
                    for counter_retro=counter-1:-1:1+mflag
                        X_counttemp=(counter-counter_retro+1)*X_count2(i,j,stepper);
                        X_sum(i,j,stepper,counter_retro-mflag)=X_sum(i,j,stepper,counter_retro-mflag)+X_sum(i,j,stepper,counter-mflag);
                        mu_est=X_sum(i,j,stepper,counter_retro-mflag)/X_counttemp; %Sample mean from box
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
    end
    RatioC(counter)=ratio;
end

%__________________________________________________________________________

%__________________________________________________________________________
%F1 Scotch Square 1.8cm
RatioC1(1)=RatioC(counter);
counter1=counter;
flag1=0;
X_sumF1=X_sum;
ra2=randsample(29,29);
ra2=40+ra2;
for lc=1:length(ra2)
    ratio=-inf;
    counter1=counter1+1;
    if counter1 > m
        mflag=counter1-m;
         X_sumF1(:,:,:,1:m-1)=X_sumF1(:,:,:,2:m);
         X_sumF1(:,:,:,m)=mfiller;
    else
        mflag=0;
    end
    temp=imread(['E:\My Documents\VT\Research\2010\Image Spatiotemporal\Code\Pics\Tile_Image_000' num2str(ra2(lc)) '.jpg']);
    temp=temp(160:2300, 740:2880);
    if isgray(temp)==0
        temp=rgb2gray(temp);
    end
    temp=imresize(temp,pixs');
    temp=imadjust(temp, [0.2 0.8], []);
    I=Nomd-double(temp);
    for i = 1:grids(1) %Run through x locations for center of serveillance box
        for j = 1:grids(2) %Run through y locations for center of serveillance box
            for stepper=1:max_steps(i,j)
                if stepper==1
                    I_2_test=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                     X_sumF1(i,j,stepper,counter1-mflag)=sum(I_2_test_reshape); %Collect sums of diffs
                else
                    I_2_test1=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                    I_2_test2=I(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                    I_2_test3=I(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                    I_2_test4=I(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                    I_2_test=[I_2_test1 I_2_test2 I_2_test3' I_2_test4']; %Take Pixels on edge of box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                     X_sumF1(i,j,stepper,counter1-mflag)=sum(I_2_test_reshape)+ X_sumF1(i,j,stepper-1,counter1-mflag); %Collect sums of diffs
                end
                mu_est= X_sumF1(i,j,stepper,counter1-mflag)/X_count2(i,j,stepper); %Sample mean from box
                rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mu_est-mus(i,j,stepper))^2;
                if rat>ratio %If the statistic is bigger than previous one
                    ratio=rat; %New statistic
                    fault_time_temp=counter1;
                    locate=[i,j,stepper];
                end
                
                if rat>mean_init_rats(i,j,stepper)
                    for counter_retro=counter1-1:-1:1+mflag
                        X_counttemp=(counter1-counter_retro+1)*X_count2(i,j,stepper);
                        X_sumF1(i,j,stepper,counter_retro-mflag)= X_sumF1(i,j,stepper,counter_retro-mflag)+ X_sumF1(i,j,stepper,counter1-mflag);
                        mu_est= X_sumF1(i,j,stepper,counter_retro-mflag)/X_counttemp; %Sample mean from box
                        rat=lratconst(i,j,stepper)*X_counttemp*(mu_est-mus(i,j,stepper))^2;
                        if rat>ratio
                            ratio=rat;
                            fault_time_temp=counter_retro;
                            locate=[i,j,stepper];
                        elseif rat<0
                            break;
                        end
                    end
                end
            end
        end
    end
    RatioC1(counter1-counter)=ratio;
    if ratio>UCL && flag1==0
        fault_time1=fault_time_temp
        locate1=locate;
        flag1=1;
    end
end
figure(1)
AB=length([1:counter1]);
plot([1:counter1], UCL*ones(1,AB),'r')
hold on
plot([1:counter1],[RatioC, RatioC1])
figure(2)
imshow(temp)
hold on
% rectangle('position',[center(locate1(1),locate1(2),2)-steps{locate1(1),locate1(2)}(locate1(3))/2  center(locate1(1),locate1(2),1)-steps{locate1(1),locate1(2)}(locate1(3))/2 steps{locate1(1),locate1(2)}(locate1(3)) steps{locate1(1),locate1(2)}(locate1(3))], 'LineWidth',4,'LineStyle','--','EdgeColor','b','DisplayName','Region that Maximizes Statistic'); 
%__________________________________________________________________________