function []=Spat_Temp(num_images_good,num_images_bad,fault)
load Spa_Temp_Baseline
num_images=num_images_good+num_images_bad;
Nom=imread('Nonwoven_Nom.bmp');
Nomd=double(Nom);
mus2=mus.^2;
fault_time=zeros(1,num_images);
max_ratio=zeros(1,num_images);
fault_pat=zeros(pixs(1),pixs(2));
X_sum=zeros([size(mus),m]);
lratconst=1/2/vars;
mfiller=zeros([size(mus),1]);
mflag=0;
%%%%%%%%%%%<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>
aviobj = avifile('SpaTempResults');
aviobj.quality = 100;
figure('Position',[1 41 1440 790])
%%%%%%%%%%%<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>
for pic=1:num_images
    ratio=-inf;
    if pic > m
        mflag=pic-m;
        X_sum(:,:,:,1:m-1)=X_sum(:,:,:,2:m);
        X_sum(:,:,:,m)=mfiller;
    end
    if pic <=num_images_good
    else
        fault_pat((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=normrnd(fault(1),fault(2),fault(3)+1,fault(4)+1);
    end
    I=imnoise(Nom,'Poisson');
    Id=Nomd-double(I)-fault_pat;
    for i = 1:grids(1) %Run through x locations for center of serveillance box
        for j = 1:grids(2) %Run through y locations for center of serveillance box
            for stepper=1:max_steps(i,j)
                if stepper==1
                    I_2_test=Id(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,pic-mflag)=sum(I_2_test_reshape); %Collect sums of diffs
                else
                    I_2_test1=Id(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                    I_2_test2=Id(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                    I_2_test3=Id(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                    I_2_test4=Id(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                    I_2_test=[I_2_test1 I_2_test2 I_2_test3' I_2_test4']; %Take Pixels on edge of box
                    I_2_test_reshape=reshape(I_2_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                    X_sum(i,j,stepper,pic-mflag)=sum(I_2_test_reshape)+X_sum(i,j,stepper-1,pic-mflag); %Collect sums of diffs
                end
                mu_est=X_sum(i,j,stepper,pic-mflag)/X_count2(i,j,stepper); %Sample mean from box
                rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mu_est-mus(i,j,stepper))^2;
                if rat>ratio %If the statistic is bigger than previous one
                    ratio=rat; %New statistic
                    fault_time(pic)=pic;
                    locate=[i,j,stepper];
                end
                
                if rat>mean_init_rats(i,j,stepper)
                    for pic_retro=pic-1:-1:1+mflag
                        X_counttemp=(pic-pic_retro+1)*X_count2(i,j,stepper);
                        X_sum(i,j,stepper,pic_retro-mflag)=X_sum(i,j,stepper,pic_retro-mflag)+X_sum(i,j,stepper,pic-mflag);
                        mu_est=X_sum(i,j,stepper,pic_retro-mflag)/X_counttemp; %Sample mean from box
                        rat=lratconst(i,j,stepper)*X_counttemp*(mu_est-mus(i,j,stepper))^2;
                        if rat>ratio
                            ratio=rat;
                            fault_time(pic)=pic_retro;
                            locate=[i,j,stepper];
                        elseif rat<0
                            break;
                        end
                    end
                end
            end
        end
    end
max_ratio(pic)=ratio;
annotation('textbox',[.13 .119 .15 .064557],'string','Region which Maximizes Statistic','FontSize',14,'LineWidth',4,'EdgeColor','b','LineStyle','--','HorizontalAlignment','Center');
annotation('textbox',[.312 .119 .15 .064557],'string','Location of Simulated Fault','FontSize',14,'LineWidth',4,'EdgeColor','r','LineStyle','--','HorizontalAlignment','Center');
% rectangle('position',[.13 .119 .15 .064557],'LineWidth',4,'EdgeColor','b');
% rectangle('position',[.312 .119 .15 .064557],'LineWidth',4,'EdgeColor','r');
h = subplot(2,2,[1 3]);
imshow(I)
rectangle('position',[center(locate(1),locate(2),2)-steps{locate(1),locate(2)}(locate(3))/2  center(locate(1),locate(2),1)-steps{locate(1),locate(2)}(locate(3))/2 steps{locate(1),locate(2)}(locate(3)) steps{locate(1),locate(2)}(locate(3))], 'LineWidth',4,'LineStyle','--','EdgeColor','b','DisplayName','Region that Maximizes Statistic'); 
if pic > num_images_good
    rectangle('position',[fault(6)-fault(3)/2 fault(5)-fault(4)/2 fault(3) fault(4)],'LineWidth',4,'LineStyle','--','EdgeColor','r');
end
subplot(2,2,2)
plot(1:pic,max_ratio(1:pic));
xlabel('Picture Number','FontSize',14);
ylabel('Statistic','FontSize',14);
subplot(2,2,4)
plot(1:pic,fault_time(1:pic),'*');
xlabel('Picture Number','FontSize',14);
ylabel('Estimated Change Point','FontSize',14);
pause(.1)
F = getframe(1);
aviobj = addframe(aviobj,F);
end
aviobj = close(aviobj);
fclose all;


    