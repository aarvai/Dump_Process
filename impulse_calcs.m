clear all
close all
clc

%define constants
t_c=.01;
f=[.2,.2,.2,.2];
deg=pi/180;
A=[           0,          0,          0,           0;
   -sin(30*deg),sin(30*deg),sin(30*deg),-sin(30*deg);
    cos(30*deg),cos(30*deg),-cos(30*deg),-cos(30*deg)];

%% MCC Predictions

%load data
%load /home/mission/Backstop/Archive/2010/04_apr/APR1110B/output/APR1110B.mat
load /home/mission/Backstop/MAY0911A/output/MAY0911A.mat

%get dump counts
[momB,momI,wspds,solar,gravity,dumpResults]=getMomentum(appdata.maneuvers,appdata.ephemeris);
cnts_pre=dumpResults(1).counts;

%find quat at time of dump
t_dump=appdata.maneuvers.momentum.dumps.time(1);
[~,i]=max((t_dump<[appdata.maneuvers.t{:}]));
all_quats=[appdata.maneuvers.q{:}];
quat_pre=all_quats(:,i-1)';

%Compute the impulse in spacecraft coordinates
I_pre=sum(repmat(t_c*cnts_pre.*f,3,1).*A,2);

%Rotate to ECI and convert to RA and dec
I_pre_radec=vec2radec(quat2att(quat_pre')'*I_pre); %radians

%Convert magnitude from lbf-sec to N-sec
I_pre_mag=norm(I_pre)*4.4482216189;


%% Thruster Efficiency Post-Processing 

%load data
%load /home/pcad/matlab/Thruster_Efficiency/wEnvMom/npm2010103/npm2010103_mom.mat
load /home/pcad/matlab/Thruster_Efficiency/wEnvMom/npm2011129/npm2011129_mom.mat

%get dump counts
cnts_act=sum(momdata.thrcnt);

%find quat at time of dump
quat_act=momdata.Quat(momdata.DumpStartIndex,:);

%Compute the impulse in spacecraft coordinates
I_act=sum(repmat(t_c*cnts_act.*f,3,1).*A,2);

%Rotate to ECI and convert to RA and dec
I_act_radec=vec2radec(quat2att(quat_act')'*I_act); %radians

%Convert magnitude from lbf-sec to N-sec
I_act_mag=norm(I_act)*4.4482216189;

I_pre_mag
I_act_mag
I_pre_radec
I_act_radec