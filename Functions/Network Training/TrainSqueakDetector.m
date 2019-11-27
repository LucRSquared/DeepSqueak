function [detector, layers, options] = TrainSqueakDetector(TrainingTables,layers)

% Specify layers if not transfering from previous network
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
usetf = true ;

if usetf
    net = resnet101 ;
   
%     net = googlenet ;

    if isa(net,'SeriesNetwork') 
      lgraph = layerGraph(net.Layers); 
    else
      lgraph = layerGraph(net);
    end 

%     [learnableLayer,classLayer] = findLayersToReplace(lgraph);

    % Remove removable layers!
    lgraph = removeLayers(lgraph,{'fc1000','prob','ClassificationLayer_predictions'}) ;

    % Create Fully Connected Layer
    fclayer = fullyConnectedLayer(width(TrainingTables),'Name','fcend') ;
    lgraph = addLayers(lgraph,fclayer) ;
    
    % Create softmax layer
    smaxlayer = softmaxLayer('Name','smax') ;
    lgraph = addLayers(lgraph,smaxlayer) ;
    
    % Create classification layer
    clayer = classificationLayer('Name','class_boat') ;
    lgraph = addLayers(lgraph,clayer) ;    
    
    layers = lgraph.Layers ;    

    lgraph = connectLayers(lgraph,'pool5','fcend') ;
    lgraph = connectLayers(lgraph,'fcend','smax') ;
    lgraph = connectLayers(lgraph,'smax','class_boat') ;

    % Freeze Initial Layers
    layers = lgraph.Layers;
    connections = lgraph.Connections;

    layers(1:344) = freezeWeights(layers(1:344));
% 
    lgraph = createLgraphUsingConnections(layers,connections);
%     
    layers = lgraph.Layers;

    
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
    'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);

optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);

optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);

optionsStage4 = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);


options = [
    optionsStage1
    optionsStage2
    optionsStage3
    optionsStage4
    ];

detector = trainFasterRCNNObjectDetector(TrainingTables, layers, options, ...
    'NegativeOverlapRange', [0 0.4], ...
    'PositiveOverlapRange', [0.6 1], ...
    'BoxPyramidScale', 1.8,'NumStrongestRegions',Inf);
end

