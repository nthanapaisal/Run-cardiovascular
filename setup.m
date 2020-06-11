%this script will 
% 1. extract ekg from ekgPeaks.mat, 
% 2. get RR intervals and its time
% 3. time
clear all
clc
run([pwd filesep 'startup.m'])

sessionNum = 3;
sessionLoc = 223;
Fs = 128;
HRVparams = InitializeHRVparams('Demo');
HRVparams.Fs = Fs;

%get data from ekgPeaks.mat
fromData = [pwd filesep 'data' filesep 'ekgPeaks' '.mat'];
%new session directory
sessionDir = [pwd filesep 'data' filesep 'session_' int2str(sessionNum)];
%save signal
saveSignal = [pwd filesep 'data' filesep 'session_' int2str(sessionNum) filesep 'ekgSignal' '.mat'];
%saving our UTSA peaks into a file
savePeaks = [pwd filesep 'data' filesep 'session_' int2str(sessionNum) filesep 'ekgPeaks' '.mat'];

if ~exist(sessionDir, 'dir')
       mkdir(sessionDir);
end

%get ekg signal and utsa peak frames
load(fromData)
ekgSignal = ekgPeaks(sessionLoc).ekg;
utsaPeaks = ekgPeaks(sessionLoc).peakFrames;
save(saveSignal,'ekgSignal')
save(savePeaks,'utsaPeaks')

[HRVout1, ResultsFileName1] = Main_HRV_Analysis(ekgSignal,[],'ECGWaveform',HRVparams,'3');




