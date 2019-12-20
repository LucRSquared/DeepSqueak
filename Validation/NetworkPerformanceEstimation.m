[filename, filepath] = uigetfile('*.txt','Selection Files','MultiSelect','on') ;
%%
% path2detections = 'G:/My Drive/Ole Miss/NCCHE/DeepWaves/DeepSqueak/Detections/NetworkDetections/' ;
path2detections = 'G:/My Drive/Ole Miss/NCCHE/DeepWaves/DeepSqueak/Detections/' ;
s = dir(path2detections) ;
dfiles = {s(3:end).name} ;
dfilesOverlapRatios = cell(1) ;

if iscell(filename)
    N = numel(filename) ;
else
    N = 1 ;
end

c = 0 ;

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
    
    if ~any(dfiles_match)
        disp(['No Detection file for : ' thefile]) ;
    else
        
        try
            [tBegin, ~, fLow, ~, DT, DF] = importRavenBox([filepath,filename{k}]) ;
            thefile = filename{k} ;
        catch
            [tBegin, ~, fLow, ~, DT, DF] = importRavenBox([filepath,filename]) ;
            thefile = filename ;
        end
        
        xywh_truth = [tBegin, fLow/1000, DT, DF/1000] ; % Convert frequencies to kHz   
        
        for idx = idx_dfiles_match
            c = c + 1 ;
            dtct = load([path2detections,dfiles{idx}]) ;
            TentativeBoxes = dtct.Calls.Box ;
            overlapRatio = bboxOverlapRatio(xywh_truth, TentativeBoxes) ; 
            dfilesOverlapRatios{c,1} = overlapRatio ;
            dfilesOverlapRatios{c,2} = dfiles{idx} ;
        end
        
    end
    
    
end

%% Significant Numbers!

M = numel(dfilesOverlapRatios) ;

missedBoats = 0 ;
falsePositives = 0 ;
truePositives = 0 ;

threshold = 0.5 ;

for o = 1:M
    
    grid = dfilesOverlapRatios{o,1} ;
    grid(grid < threshold) = 0 ;
    
    sumOverRows = sum(grid,1) ;
    sumOverCols = sum(grid,2) ;
    
    numEmptyRows = sum(sumOverCols == 0) ;
    numEmptyCols = sum(sumOverRows == 0) ;
    nonZeroOverlaps = sum(grid ~= 0, 'all') ;
    
    missedBoats = missedBoats + numEmptyRows ;
    falsePositives = falsePositives + numEmptyCols ;
    truePositives = truePositives + nonZeroOverlaps ;
    
end

totalNumDetections = truePositives + falsePositives ;
totalRealBoats = missedBoats + truePositives ;


