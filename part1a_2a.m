%this script does both part1a and part2a

%this script gets RR,t,indicators from physionet

clear all
clc
run([pwd filesep 'startup.m'])

ekgFile = ([pwd filesep 'data' filesep 'ekgPeaks.mat']);
newFile = ([pwd filesep 'data' filesep 'physionetInfo.mat']);
load(ekgFile)

numFiles = length(ekgPeaks);
physioInfo = struct('fileName', NaN, ...
                    'pnInfo',NaN,'pnPNRRMeasures', NaN, ...
                    'utsaInfo', NaN,'pnUTSARRMeasures', NaN,'errorMsg', NaN);    
pnInfo = struct('peaks',NaN,'RRs',NaN,'Time',NaN);
utsaInfo = struct('peaks',NaN,'RRs',NaN,'Time',NaN);
physioInfo(numFiles) = physioInfo;
HRVparams = InitializeHRVparams('Demo');

for k = 1:numFiles
    try
        HRVparams.Fs = ekgPeaks(k).srate;
        physioInfo(k) = physioInfo(end);
        physioInfo(k).fileName = ekgPeaks(k).fileName;
        [measures,info] = getMeasuresRRpn(ekgPeaks(k).ekg,pnInfo,HRVparams);
        physioInfo(k).pnPNRRMeasures = measures;
        physioInfo(k).pnInfo = info;
        [measures,info] = getMeasuresRRutsa(ekgPeaks(k),utsaInfo,HRVparams);
        physioInfo(k).pnUTSARRMeasures = measures;
        physioInfo(k).utsaInfo = info;
    catch EX
        physioInfo(k).errorMsg = EX.message;
        warning('Invalid Data. Skipping');
        continue;
    end
end
save(newFile,'physioInfo')

function [finalMeasures,pnInfo] = getMeasuresRRpn(ekgPeaks,pnInfo,HRVparams)
   
    [t,rr,jqrs_ann,~,~] = ConvertRawDataToRRIntervals(ekgPeaks,HRVparams, '00');
    pnInfo.peaks = jqrs_ann;
    pnInfo.RRs = rr;
    pnInfo.Time = t;
    [~, ~,measures] = Main_HRV_Analysis(rr,t,'RRIntervals',HRVparams,'101');
    finalMeasures = convertStruct(measures);
    
end

function [finalMeasures,utsaInfo] = getMeasuresRRutsa(ekgPeaks,utsaInfo,HRVparams)
    [rrs,t] = getRRs(ekgPeaks.peakFrames, ekgPeaks.srate);
    utsaInfo.peaks = ekgPeaks.peakFrames;
    utsaInfo.RRs = rrs;
    utsaInfo.Time = t;
    [~, ~,measures] = Main_HRV_Analysis(rrs,t,'RRIntervals',HRVparams);
    finalMeasures = convertStruct(measures);
    
end

function [rrs,t] = getRRs(peakFrames, srate)
    rrs = (peakFrames(2:end) - peakFrames(1:end-1))/srate;
    t = (peakFrames-1)/srate;
    t = t(2:end);
end

function rrMeasures = convertStruct(pnMeasures)
    %assuming rrMeasure is in .mat struct
    [pnStruct, rrMeasures] = getEmptyStructs();
    i = 1;
    %put first row of data from pnIndicators and put into known struct we
    %created
    for fn = fieldnames(pnStruct)'
       pnStruct.(fn{1}) = pnMeasures(1,i);
       i = i + 1;
    end
    %match and replace info into new struct
    % automate if has the same name...
    for fnRR = fieldnames(rrMeasures)'
        for fnPN = fieldnames(pnStruct)'
            if strcmp(fnRR,fnPN)
               rrMeasures.(fnRR{1}) = pnStruct.(fnPN{1});

            end  
        end
    end

    
end

function [pnStruct, rrMeasures] = getEmptyStructs()
%original struct
% pnStruct = struct('patID', NaN, 't_start', NaN, ...
%                   't_end', NaN, 'NNmean', NaN, ...
%                   'NNmedian', NaN, 'NNmode', NaN, 'NNvarianc', NaN, ...
%                   'NNskew', NaN, 'NNkurt', NaN, 'NNiqr', NaN, ...
%                   'SDNN', NaN, 'RMSSD', NaN, 'pnn50', NaN, ...
%                   'btsdet', NaN, 'avgsqi', NaN, ...
%                    'tdflag', NaN, 'ulf', NaN,   'vlf', NaN, ...
%                    'lf', NaN, 'hf', NaN, 'lfhf', NaN, ...
%                    'ttlpwr', NaN, 'fdflag', NaN, 'ac', NaN, ...
%                    'dc', NaN, 'SD1', NaN, 'SD2', NaN, ...
%                    'SD1SD2', NaN, 'SampEn', NaN, 'ApEn', NaN); 
             
    pnStruct = struct('t_start', NaN, ...
                      't_end', NaN, 'meanRR', NaN, ...
                      'medianRR', NaN, 'NNmode', NaN, 'NNvarianc', NaN, ...
                      'skewRR', NaN, 'kurtosisRR', NaN, 'iqrRR', NaN, ...
                      'SDNN', NaN, 'RMSSD', NaN, 'pNN50', NaN, ...
                      'btsdet', NaN, 'avgsqi', NaN, ...
                       'tdflag', NaN, 'ulf', NaN,   'VLF', NaN, ...
                       'LF', NaN, 'HF', NaN, 'LFHFRatio', NaN, ...
                       'totalPower', NaN, 'fdflag', NaN, 'ac', NaN, ...
                       'dc', NaN, 'SD1', NaN, 'SD2', NaN, ...
                       'SDSD', NaN, 'SampEn', NaN, 'ApEn', NaN); 

    rrMeasures = struct('startMinutes', NaN, 'blockMinutes', NaN, ...
                      'numRRs', NaN, 'numBadRRs', NaN, ...
                      'meanHR', NaN, 'meanRR', NaN, 'medianRR', NaN, ...
                      'trendSlope', NaN, 'SDNN', NaN, 'SDSD', NaN, ...
                      'RMSSD', NaN, 'NN50', NaN, 'pNN50', NaN, ...
                      'spectrumType', NaN, 'totalPower', NaN, ...
                       'VLF', NaN, 'LF', NaN,   'LFnu', NaN, ...
                       'HF', NaN, 'HFnu', NaN, 'LFHFRatio', NaN, ...
                       'PSD', NaN, 'F', NaN);      
end
