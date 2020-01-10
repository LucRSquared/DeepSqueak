[filename, filepath] = uigetfile('*.txt','Selection Files','MultiSelect','on') ;
%%
% path2detections = 'G:\My Drive\Ole Miss\NCCHE\DeepWaves\DeepSqueak\Detections\08_0425_18\' ;
% path2detections = 'G:\My Drive\Ole Miss\NCCHE\DeepWaves\DeepSqueak\Detections\' ;
path2detections = 'G:\My Drive\Ole Miss\NCCHE\DeepWaves\DeepSqueak\Detections\08_0425_17_balanced_DeepShip_WLOG2\' ;
s = dir(path2detections) ;
dfiles = {s(3:end).name} ;
dfilesOverlapRatios = cell(1) ;


% Get the number of files to process
if iscell(filename)
    N = numel(filename) ;
else
    N = 1 ;
end


c = 0 ;
nw2 = 0 ;
for k = 1:N
    
    try
        thefile = filename{k} ;
        thefile = thefile(1:end-23) ;
    catch
        thefile = filename ;
        thefile = thefile(1:end-23) ;
    end
    
    
    
    dfiles_match = contains(dfiles,thefile) ;
    idx_dfiles_match = find(dfiles_match) ;
    
%     if ~any(dfiles_match)
%         disp(['No Detection file for : ' thefile]) ;
%     else
        
        try
            [tBegin, ~, fLow, ~, DT, DF] = importRavenBox([filepath,filename{k}]) ;
            thefile = filename{k} ;
        catch
            [tBegin, ~, fLow, ~, DT, DF] = importRavenBox([filepath,filename]) ;
            thefile = filename ;
        end
        
        xywh_truth = [tBegin, fLow/1000, DT, DF/1000] ; % Convert frequencies to kHz   
        
        nw2 = nw2 + size(xywh_truth,1) ;
        
%         for idx = idx_dfiles_match
%             c = c + 1 ;
%             dtct = load([path2detections,dfiles{idx}]) ;
%             TentativeBoxes = dtct.Calls.Box ;
%             overlapRatio = bboxOverlapRatio(xywh_truth, TentativeBoxes) ; 
%             dfilesOverlapRatios{c,1} = overlapRatio ;
%             dfilesOverlapRatios{c,2} = dfiles{idx} ;
%         end
        
%     end
    
    
end

%% Significant Numbers!

% Number of matches between selection files and detectionfiles
[M,~] = size(dfilesOverlapRatios) ;

% missedBoats = 0 ;
% falsePositives = 0 ;
% truePositives = 0 ;

thresholdhigh = 0.01 ;

VarNames = {'Day','BoxOverlapRatio','Threshold',...
            'TruePositives',...
            'FalsePositives','MissedBoats','TrueNumberOfBoats','SuccessRate',...
            'FalsePositiveRate','MissedRate'} ;

perftable  = cell2table(cell(0,numel(VarNames)), 'VariableNames',VarNames);

for o = 1:M

    grid = dfilesOverlapRatios{o,1} ;
    grid(grid <= threshold) = 0 ;
    
    % On every line if there are more than 2 set smallest value to 0
    [trueNumBoats,~] = size(grid) ; 
    for i = 1:trueNumBoats
       theline = grid(i,:) ;
       
       [themax,idxmax] = max(theline) ;
       
       grid(i,:) = 0 ;
       grid(i,idxmax) = themax ;
       
        
    end
    
    sumOverRows = sum(grid,1) ;
    sumOverCols = sum(grid,2) ;
    
    numEmptyRows = sum(sumOverCols == 0) ;
    numEmptyCols = sum(sumOverRows == 0) ;
    nonZeroOverlaps = sum(grid ~= 0, 'all') ;
    
    
    
    missedBoats = numEmptyRows ;
    falsePositives = numEmptyCols ;
    truePositives = nonZeroOverlaps ;
%     duplicateTruePositives = sum(sum(grid~=0,2)>1) ;
    
    r_successrate = truePositives/trueNumBoats ;
    r_fp = falsePositives/(truePositives+falsePositives) ;
    r_miss = missedBoats/trueNumBoats ;
    
    appendedLine = {dfilesOverlapRatios{o,2}(1:17), dfilesOverlapRatios{o,1}, ...
                    threshold, truePositives, falsePositives, missedBoats,...
                    trueNumBoats, r_successrate, r_fp, r_miss} ;
                
    perftable = [perftable ; appendedLine] ;
    
end


%% Total

TotalTruePositives = sum(perftable.TruePositives) ;
TotalFalsePositives = sum(perftable.FalsePositives) ;
TotalMissedBoats = sum(perftable.MissedBoats) ;
TotalTrueNumberOfBoats = sum(perftable.TrueNumberOfBoats) ;



successRate = TotalTruePositives/TotalTrueNumberOfBoats ;
falsePositiveRate = TotalFalsePositives/(TotalTruePositives + TotalFalsePositives) ;
missedRate = TotalMissedBoats/TotalTrueNumberOfBoats ;










