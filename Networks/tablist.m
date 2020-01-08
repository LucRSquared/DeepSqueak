% Training with 70% of the data
data70 = load('DeeperShip_6390T_Tables.mat') ;

days70 = data70.TrainingTables.imageFilename ;
days70 = cellfun(@(x) x(17:33),days70,'UniformOutput',false) ;

% Training with 80% of the data
data80 = load('DeepShip_7303T_Tables.mat') ;

days80 = data80.TrainingTables.imageFilename ;
days80 = cellfun(@(x) x(17:33),days80,'UniformOutput',false) ;