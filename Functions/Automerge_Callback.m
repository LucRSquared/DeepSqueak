function Calls = Automerge_Callback(Calls1,Calls2,AudioFile)
%% Merges two detection files into one

Calls=[Calls1; Calls2];

% Audio info
audio_info = audioinfo(AudioFile);

%% Merge overlapping boxes
try
    Calls = merge_boxes(Calls.Box, Calls.Score, Calls.Type, Calls.Power, audio_info, 1, 0, 0);
catch % LUC
    Calls = table('Size',[1, 14], 'VariableTypes',...
    {'double',...
    'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double',...
    'double',...
    'cell',...
    'categorical',...
    'double',...
    'logical'},...
    'VariableNames',...
    {'Rate',...
    'Box1', 'Box2', 'Box3', 'Box4',...
    'RelBox1', 'RelBox2', 'RelBox3', 'RelBox4',...
    'Score',...
    'Audio',...
    'Type',...
    'Power',...
    'Accept'});
    Calls = mergevars(Calls,{'Box1', 'Box2', 'Box3', 'Box4'},'NewVariableName','Box');
    Calls = mergevars(Calls,{'RelBox1', 'RelBox2', 'RelBox3', 'RelBox4'},'NewVariableName','RelBox');
end
