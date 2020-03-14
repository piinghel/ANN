
close all;
clc;
% read in data
data = load('Data/Data_Problem1_regression.mat');

% Student Number
stud_nr='0789332';
% select first 5 digits in descending order
stud_nr5 = maxk(stud_nr,5);
% build new target
Y = ((stud_nr5(1)*data.T1 + stud_nr5(2)*data.T2 + stud_nr5(3)*data.T3 + stud_nr5(4)*data.T4 + stud_nr5(5)*data.T5)/sum(stud_nr5))';
X1 = data.X1;
X2 = data.X2;
X = [X1,X2]';

% split data
idx = randperm(size(Y,2),3000);

% 1) training
train_idx = 1:1000;
train_X = X(:,idx(train_idx));
train_Y = Y(idx(train_idx));

% scale training data and save parameters
[train_X_scaled,settings_train_X] = mapminmax(train_X);
[train_Y_scaled,settings_train_Y] = mapminmax(train_Y);

% validation
validation_idx = 1:1000;
validation_X = X(:,idx(validation_idx));
validation_Y = Y(idx(validation_idx));

% apply scaling estimated on training data to validation data
validation_X_scaled = mapminmax.apply(validation_X,settings_train_X);
validation_Y_scaled = mapminmax.apply(validation_Y,settings_train_Y);

% train and validation
train_val_idx = 1:2000;
train_val_X = X(:,idx(train_val_idx));
train_val_Y = Y(idx(train_val_idx));

% scale training validation data and save parameters
[train_val_X_scaled, settings_val_train_X] = mapminmax(train_val_X);
[train_val_Y_scaled, settings_val_train_Y] = mapminmax(train_val_Y);

% test
test_idx = 2001:3000;
test_X = X(:,idx(test_idx));
test_Y = Y(idx(test_idx));

% apply scaling estimated on train_validation data to test data
test_X_scaled = mapminmax.apply(test_X,settings_val_train_X);
test_Y_scaled = mapminmax.apply(test_Y,settings_val_train_Y);


% plot training data

% 1) plot surface
[xq_train,yq_train] = meshgrid(0:.1:1, 0:.1:1);
zq_train = griddata(train_X(1,:),train_X(2,:),train_Y_scaled,xq_train,yq_train);
figure
mesh(xq_train,yq_train,zq_train);
hold on
plot3(train_X(1,:),train_X(2,:),train_Y_scaled,'.');
title('Training Data');
zlabel('Tnew')
hold off;



% train the network on training set and make the decision on the validation
% set












