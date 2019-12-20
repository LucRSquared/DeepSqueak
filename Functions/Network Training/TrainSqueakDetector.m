function [detector, layers, options] = TrainSqueakDetector(TrainingTables,layers)

% Specify layers if not transfering from previous network

rng(19921118) ;
NumSamples = height(TrainingTables) ;
% NumTraining = round(0.7*NumSamples) ;
NumTraining = round(0.8*NumSamples) ;

permu = randperm(NumSamples) ;

selectrain = permu(1:NumTraining) ;

ValidationTables = TrainingTables(permu(NumTraining+1:end),:) ;

TrainingTables = TrainingTables(selectrain,:) ;



if nargin == 1
%         layers = [
%             imageInputLayer([30 50 1])
%             
%             convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([3 3], 32)
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             maxPooling2dLayer(2, 'Stride',2)
%             
%             fullyConnectedLayer(64)
%             reluLayer()
%             fullyConnectedLayer(width(TrainingTables))
%             softmaxLayer()
%             classificationLayer()
%             ];

% Modified DeepShip 50x50
        layers = [
            imageInputLayer([50 50 1])
            
            convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            convolution2dLayer([3 3], 32)
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            maxPooling2dLayer(2, 'Stride',2)
            
            fullyConnectedLayer(64)
            reluLayer()
            fullyConnectedLayer(width(TrainingTables))
            softmaxLayer()
            classificationLayer()
            ];

% Modified Input DeepShip
%         layers = [
%             imageInputLayer([45 45 1])
%             
%             convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([3 3], 32)
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             maxPooling2dLayer(2, 'Stride',2)
%             
%             fullyConnectedLayer(64)
%             reluLayer()
%             fullyConnectedLayer(width(TrainingTables))
%             softmaxLayer()
%             classificationLayer()
%             ];
%         % LUC MODIFIED NETWORK DeeperShip
%         layers = [
%             imageInputLayer([40 40 1])
%             
%             convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([3 3], 32)
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             maxPooling2dLayer(2, 'Stride',2)
%             
%             fullyConnectedLayer(64)
%             reluLayer()
%             
%             fullyConnectedLayer(32)
%             reluLayer()
%             
%             fullyConnectedLayer(16)
%             reluLayer()
%             
%             fullyConnectedLayer(width(TrainingTables))
%             softmaxLayer()
%             classificationLayer()
%             ];
        
%                 % LUC MODIFIED NETWORK EvenDeeperShip
%         layers = [
%             imageInputLayer([40 40 1])
%             
%             convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             convolution2dLayer([3 3], 32)
%             batchNormalizationLayer
%             leakyReluLayer(0.1)
%             
%             maxPooling2dLayer(2, 'Stride',2)
%             
%             fullyConnectedLayer(64)
%             reluLayer()
%             
%             fullyConnectedLayer(32)
%             reluLayer()
%             
%             fullyConnectedLayer(32)
%             reluLayer()
%             
%             fullyConnectedLayer(16)
%             reluLayer()
%             
%             fullyConnectedLayer(16)
%             reluLayer()
%             
%             fullyConnectedLayer(8)
%             reluLayer()
%             
%             fullyConnectedLayer(width(TrainingTables))
%             softmaxLayer()
%             classificationLayer()
%             ];

end

% LUC Transfer learning 
usetf = false ;

if usetf
    
    net = vgg16 ;

    if isa(net,'SeriesNetwork') 
      lgraph = layerGraph(net.Layers); 
    else
      lgraph = layerGraph(net);
    end 
    
    layers2remove = {'fc8','prob','output'} ;
    

%     [learnableLayer,classLayer] = findLayersToReplace(lgraph);

    % Remove removable layers!
    lgraph = removeLayers(lgraph,layers2remove) ;

    % Create Fully Connected Layer
    fclayer = fullyConnectedLayer(width(TrainingTables),'Name','fcend') ;
%     fclayer = fullyConnectedLayer(4,'Name','fcend') ;
    lgraph = addLayers(lgraph,fclayer) ;
    
    % Create softmax layer
    smaxlayer = softmaxLayer('Name','smax') ;
    lgraph = addLayers(lgraph,smaxlayer) ;
    
    % Create classification layer
    clayer = classificationLayer('Name','class_boat') ;
    
    lgraph = connectLayers(lgraph,'drop7','fcend') ;
    lgraph = connectLayers(lgraph,'fcend','smax') ;
%     lgraph = connectLayers(lgraph,'smax','class_boat') ;
    
    layers = lgraph.Layers;
    
    % Edit input Dimensions
    layers(1) = imageInputLayer([48 48 3]);
    layers(32) = maxPooling2dLayer(2,'Name','pool5new') ;
    layers(33) = fullyConnectedLayer(4096,'Name','fc6') ;
    layers(41) = clayer ;
 

    % Freeze Initial Layers
    

%     layers(2:22) = freezeWeights(layers(2:22));
% 
%     lgraph = createLgraphUsingConnections(layers,Connections);%   
%     
%     layers = lgraph.Layers ;
    
    
end

% Matlab 2018b changed neural network training, so adjust the
% settings accordingly.
if verLessThan('matlab','9.5')
    MiniBatchSize = 32;
else
    MiniBatchSize = 1;
end


optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize,...
    'GradientThresholdMethod','global-l2norm','GradientThreshold',6);

optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize,...
    'GradientThresholdMethod','global-l2norm','GradientThreshold',6);

optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize,...
    'GradientThresholdMethod','global-l2norm','GradientThreshold',6);

optionsStage4 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-5,'MiniBatchSize',MiniBatchSize,...
    'GradientThresholdMethod','global-l2norm','GradientThreshold',6);


options = [
    optionsStage1
    optionsStage2
    optionsStage3
    optionsStage4
    ];


detector = trainFasterRCNNObjectDetector(TrainingTables, layers, options, ...
    'NegativeOverlapRange', [0 0.4], ...
    'PositiveOverlapRange', [0.6 1], ...
    'BoxPyramidScale', 1.8,'NumStrongestRegions',Inf,...
    'FreezeBatchNormalization',false);


end

