clear
clc
close all
rng('default')
%% Load data
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
        'nndatasets','DigitDataset');
imds = imageDatastore(digitDatasetPath, ...
        'IncludeSubfolders',true,'LabelSource','foldernames');

% look at some labels
figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end

%%
% Check the number of images in each category. 
CountLabel = imds.countEachLabel

% size of the images
img = readimage(imds,1);
size(img)


numTrainFiles = 500;
numValFiles = 250;
[imdsTrain,imdsValidation,imdsTest] = splitEachLabel(imds,numTrainFiles,numValFiles,'randomize');

%% define network
layers = [
    imageInputLayer([28 28 1],'Name','input')
    
    convolution2dLayer(3,8,'Padding','same','Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPool_1')
    
    convolution2dLayer(3,16,'Padding','same','Name','conv_2')
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPool_2')
    
    convolution2dLayer(3,32,'Padding','same', 'Name','conv_3')
    batchNormalizationLayer('Name','BN_3')
    reluLayer('Name','relu_3')
    
    fullyConnectedLayer(10, 'Name','fullyConnect')
    softmaxLayer('Name','prob')
    classificationLayer('Name','classiciation')];

% visulaize network
figure
lgraph = layerGraph(layers);
plot(lgraph)
camroll(-270)
sizex = 30;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part3_cnn/figure3', 'png');

% training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',15, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',10, ...
    'Verbose',false, ...
    'Plots','training-progress');

%% train network
net = trainNetwork(imdsTrain,layers,options);

%% performance on validation
YPred_val = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

% accuracy
accuracy_val = sum(YValidation == YValidation)/numel(YValidation)
accuracy_val = sum(YPred_val == YValidation)/numel(YValidation)
% confusion matirx
plotconfusion(YPred_val,YValidation);
% look at mistakes

%% performance on test set
YPred_test = classify(net,imdsTest);
YTest = imdsTest.Labels;
% accuracy
accuracy_test = sum(YPred_test == YTest)/numel(YTest)
% confusion matirx
plotconfusion(YPred_test,YTest);
% look at mistakes



