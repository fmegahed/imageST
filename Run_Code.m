clc;clear;warning off all;fclose all;close all
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\Parameters////////////////////////////////%
pixs=[250;250]; %Number of Pixels to Reshape Image
num_images_baseline=1000; %Number of Good Images
init_size=22; %Initial size (width and height) of serveillence region
grids=[10;10]; %Number of Section to scan...x and y directions
increment_size=4;   %Increment size of serveillence region....increase in width and height
m=10; %History Window
Sim_Image_and_Baseline(pixs,init_size,grids,increment_size,num_images_baseline,m);
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Notice !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%Make Sure pixs./grids is int
%Make Sure init_size & increment_size & fault_size is even
%__________________________________________________________________________


%__________________________________________________________________________
%Video (Therefore, not needed for ARL calculations)
% num_images_good=20;
% num_images_bad=10; %Number of Bad Images
% fault=[10,0,75,75,112.5,112.5]; % Fault --> mean,std,xsize,ysize,xcent,ycent
% Spat_Temp(num_images_good,num_images_bad,fault);
