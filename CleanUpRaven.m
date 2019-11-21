datafolder = 'G:\My Drive\Ole Miss\NCCHE\DeepWaves\TN' ;
loggerfolders = {'wlog1','wlog2'} ;
n = numel(loggerfolders) ;

for k = 1:n
   selectionfolder = [datafolder,filesep,loggerfolders{k},filesep,'Selections'] ;
   savefolder = [selectionfolder,'_cleaned'] ;
   mkdir(savefolder) ;
   
   % List files in directory
   listing = dir(selectionfolder) ;
   listing = listing(3:end) ;
   nfiles = numel(listing) ;
   
   for f = 1:nfiles
      
      fid = fopen([listing(f).folder,filesep,listing(f).name], 'r');
      fout = fopen([savefolder,filesep,listing(f).name], 'w');
      
      while true
          
          input_line = fgetl(fid) ;
          
          if ~ischar(input_line); break; end    %end of file
          
          if ~contains(input_line,'Waveform')
%               fwrite(fout, input_line) ;
            fprintf(fout, '%s\n', input_line');
          end
                    
      end
      
      fclose(fout);
      fclose(fid);
      
   end    
end

%%

fout = fopen([savefolder,filesep,listing(f).name], 'w');
fprintf(fout, '%s\n', ['Caca 123']);
fclose(fout) ;
