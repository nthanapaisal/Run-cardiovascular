%pass in RR interval to Main_HRV_Analysis
clear all
clc
run([pwd filesep 'startup.m'])

sessionNum = 3;

utsaRR = [pwd filesep 'data' filesep 'session_' int2str(sessionNum) filesep 'utsaRR.mat'];
utsaT = [pwd filesep 'data' filesep 'session_' int2str(sessionNum) filesep 'utsaTime.mat'];
pnData = [pwd filesep 'data' filesep 'session_' int2str(sessionNum) filesep 'physionetData.mat'];
Fs = 128;
HRVparams = InitializeHRVparams('Demo');
HRVparams.Fs = Fs;

temp = load(pnData);
physionetRR = temp.physionetData.rr;
physionetT = temp.physionetData.t;
%[HRVOUTpn, ResultsFileNamePn ] = Main_HRV_Analysis(physionetRR,physionetT,'RRIntervals',HRVparams,'3');

temp = load(utsaRR);
utsaRR = temp.RRs;
temp = load(utsaT);
utsaT = temp.utsaTime;

utsaT = utsaT(2:end);
% utsaMask = utsaTime < 300;
% utsaTime1 = utsaTime(utsaMask);
% utsaRR = RRs(utsaMask);
[HRVout, ResultsFileName ] = Main_HRV_Analysis(utsaRR,utsaT,'RRIntervals',HRVparams,'3');
