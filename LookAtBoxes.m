[filename, filepath] = uigetfile('*.mat','Training Images Dictionnaries','MultiSelect','on') ;

N = numel(filename) ;
bboxes = zeros(1,4) ;
c = 0 ;
for k = 1:N
    table = load([filepath,filename{k}]) ;
    M = height(table.TTable) ;
    for o = 1:M
        try
            c = c + 1 ;
            bboxes(c,:) = table.TTable.USV{o};
        catch
        end
    end
end

%%

bboxes = bboxes(:,3:4) ;

%%

histogram(bboxes(:,2)) ; % Width Histogram