% Initilization and loading all the needed Baseline Variables
clc;clear all;warning off all;fclose all;
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
load Spa_Temp_Baseline
k=4.288;
N=pixs(1)*pixs(2);
mus2=mus.^2;
fault_pat=zeros(pixs(1),pixs(2));
X_sum=zeros([size(mus),m]);
lratconst=1/2/vars;
mfiller=zeros([size(mus),1]);
mflag=0;
%%%%%%%%%%%%%%%
Nom=imread('Nonwoven_Nom.bmp');
Nomd=double(Nom);
Delta= [-10 -5 -3 -2 -1 1 2 3 5 10 -10 -5 -3 -2 -1 1 2 3 5 10 -10 -5 -3 -2 -1 1 2 3 5 10];
nos=1000; 
SS_Number=20;
fault=[0,0,50,50,125,125];
UCL=mean_rats+k*std_rats;
RL=zeros(1,nos);
ARL=zeros(1,length(Delta));
MRL=zeros(1,length(Delta));
coverage=zeros(length(Delta),nos);
fault_square=zeros(pixs(1),pixs(2));
fault_square((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=ones(fault(3)+1,fault(4)+1);
% clear mean_rats std_rats
Fadel=1;
while Fadel<=length(Delta) %CHECK%
    if Fadel > 10 && Fadel<=20
        fault(5)=188;
        falut(6)=206;
    elseif Fadel>=21
            fault(5)=158;
            fault(6)=78;
    end
    fault(1)=Delta(Fadel);
    if Delta(Fadel)==0
        SSnow=0;
    else
        SSnow=SS_Number;
    end
    jj=0;
    while jj < nos
        counter=0;
        flag=1;
        FaultPattern=zeros(pixs(1),pixs(2));
        while flag==1                
            counter=counter+1;
            ratio=-inf;
            if counter>SSnow && Delta(Fadel)~=0
                FaultPattern((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=normrnd(fault(1),fault(2),fault(3)+1,fault(4)+1);
            end
            if counter > m
                mflag=counter-m;
                X_sum(:,:,:,1:m-1)=X_sum(:,:,:,2:m);
                X_sum(:,:,:,m)=mfiller;
            else
                mflag=0;
            end
            I=imnoise(Nom,'Poisson');
            I=Nomd-double(I)+FaultPattern;
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
                            fault_time_temp=counter-SSnow-1;
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
                                    fault_time_temp=counter_retro-SSnow-1;
                                    locate=[i,j,stepper];
                                elseif rat<0
                                    break;
                                end
                            end
                        end
                    end
                end
            end
            if ratio > UCL
                if counter <= SSnow
                    break;
                else
                    jj=jj+1;
                    fault_time(Fadel,jj)=fault_time_temp;
                    if Delta(Fadel)~=0
                        region_square=zeros(pixs(1),pixs(2));
                        region_square(center(locate(1),locate(2),1)-steps{locate(1),locate(2)}(locate(3))/2:center(locate(1),locate(2),1)+steps{locate(1),locate(2)}(locate(3))/2, center(locate(1),locate(2),2)-steps{locate(1),locate(2)}(locate(3))/2:center(locate(1),locate(2),2)+steps{locate(1),locate(2)}(locate(3))/2)=ones(steps{locate(1),locate(2)}(locate(3))+1,steps{locate(1),locate(2)}(locate(3))+1);
                        Overlap=region_square.*fault_square;
%                         coverage(Fadel,jj)=sum(sum(Overlap))^2/X_count2(locate(1),locate(2),locate(3))/((fault(3)+1)*(fault(4)+1));
                        coverage(Fadel, jj)= 2*sum(sum(Overlap))/ (X_count2(locate(1),locate(2),locate(3))+((fault(3)+1)*(fault(4)+1)));
                    end
                    RL(jj)=counter-SSnow;
                    clc;
                    fprintf('The Current ARL = %6.4f, MRL = %6.4f, after %d simulations when delta = %6.4f',mean(RL(1:jj)),median(RL(1:jj)),jj,Delta(Fadel));
                    flag=0;
                end
            end
        end
    end
    if Delta(Fadel)==0
        if median(RL)<146
            k=k+0.005*(150-median(RL));
            UCL=mean_rats+k*std_rats;
            Fadel=0;
        elseif median(RL)>154
            k=k-0.005*(median(RL)-150);
            UCL=mean_rats+k*std_rats;
            Fadel=0;
        end
    end  
    if Fadel>0
    ARL(Fadel)=mean(RL);MRL(Fadel)=median(RL);
    end
Fadel=Fadel+1;
end
%_________________________________________________________________________
% Spatiotemporal Performance metrics for the Simulations
Coverage_Median=median(coverage, 2);
Coverage_Mean= mean(coverage, 2);
Coverage_Std=std(coverage,0,2);
ErrorinTime=fault_time;
ErrorinTime_median= median(ErrorinTime,2);
ErrorinTime_mean= mean(ErrorinTime,2);
ErrorinTime_std=std(ErrorinTime,0,2);
for i = 1:length(Delta)
C1(i)=numel(find(ErrorinTime(i,:)==0));
C2(i)=numel(find(abs(ErrorinTime(i,:))<=2))-C1(i);
C3(i)=numel(find(ErrorinTime(i,:)<=-3));
C4(i)=numel(find(ErrorinTime(i,:)>=3));
C1(i)=(C1(i)/nos)*100;
C2(i)=(C2(i)/nos)*100;
C3(i)=(C3(i)/nos)*100;
C4(i)=(C4(i)/nos)*100;
end
%__________________________________________________________________________
save ('ARLMeanShift50SqST', 'ARL', 'MRL','Delta','fault_time','SS_Number','k',...
      'Coverage_Median', 'Coverage_Mean', 'Coverage_Std', 'ErrorinTime',...
      'ErrorinTime_median','ErrorinTime_mean', 'ErrorinTime_std', ....
      'C1', 'C2', 'C3', 'C4', 'coverage');