clear
clc
close all
rng default
%%
% ---------------------------------------------------------
% 1) Load training and validation data
% ---------------------------------------------------------

% all training data
train_data = load('data/lasertrain.dat');
% make train and validation split (90 % train, 10 % validation)

% load test data
val_data = load('data/laserpred.dat');

% visualize data
subplot(1,2,1)
plot(train_data)
xlabel("Discrete time index")
ylabel("Amplitute")
title("Training Set")

subplot(1,2,2)
plot(val_data)
xlabel("Discrete time index")
ylabel("Amplitute")
title("Validation Set")

sizex = 20;
sizey = 5;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/lstm/figure1.png');

%%
%--------------------------------------------------------
% 2) Standardize data
%--------------------------------------------------------

% 1) training data
% first transform data (if necessary)
% apply transformation if necessary
train_data_trans = train_data;
% estimate mean and sd
mu_train = mean(train_data_trans);
sd_train = std(train_data_trans);
% apply standardize
train_stand = (train_data_trans - mu_train) / sd_train;

% 2) validation data
% apply transformation if necessary
val_data_trans = val_data;
% standardize
val_stand = (val_data_trans - mu_train) / sd_train;

%% 
% ---------------------------------------------------------
% 3) monte carlo simulation to find good parameters
% ---------------------------------------------------------

% tuning parameters:
% 1) number of lags
% 2) number of neurons in the hidden layer
% repeat 5 times for every parameter combination (results seem to fluctuate
% quite a lot)

nr_lags = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90];
hidden_sizes = [10, 20, 30, 40, 50, 60, 70]; 
repeat_count = 5;
output = cell(size(nr_lags, 2) * size(hidden_sizes, 2) * repeat_count, 6);
batch = 0;         
counter = 1;
for lag=nr_lags
        % train
        X_train = getTimeSeriesTrainData(train_stand,lag);
        Y_train = train_stand(lag+1:end)';

        % validation
        X_val = getTimeSeriesTrainData(([train_stand(end-(lag-1):end)',val_stand']'),lag);
        Y_val = val_stand';
        
        for hidden=hidden_sizes
                batch = batch + 1;
                for j=1:repeat_count
           
                layers = [ ...
                    sequenceInputLayer(lag)
                    lstmLayer(hidden)
                    fullyConnectedLayer(1)
                    regressionLayer];

                    options = trainingOptions('adam', ...
                        'MaxEpochs',150, ...
                        'ValidationData',{X_val,Y_val}, ...
                        'ValidationFrequency',5, ...
                        'GradientThreshold',1, ...
                        'InitialLearnRate',0.005, ...
                        'LearnRateSchedule','piecewise', ...
                        'LearnRateDropPeriod',50, ...
                        'LearnRateDropFactor',0.2, ...
                        'Verbose',0);

                        tic;
                        net_grid_search = trainNetwork(X_train,Y_train,layers,options);
                        time = toc;

                        %% predictions on validation set
                        net_grid_search = predictAndUpdateState(net_grid_search,X_train);
                        % get predictors for validation set (last lags of the training set)
                        val_X_window = train_stand(end-(lag-1):end);  
                        [net_grid_search,Y_hat_val] = predictAndUpdateState(net_grid_search,val_X_window);
                        % predictors
                        if lag > 1
                            val_X_window = [val_X_window(2:end)',Y_hat_val]';
                        % lags =  1
                        else
                            val_X_window = Y_hat_val;
                        end
                        forecast_horizon = numel(val_data);
                        for i = 2:forecast_horizon
                            % make predictions
                            [net_grid_search,Y_hat_val(i)] = predictAndUpdateState(net_grid_search,...
                                                 val_X_window,'ExecutionEnvironment','cpu');
                            % update predictor matrix: remove oldest value and add latest predictions
                            if lag >1
                                val_X_window = [val_X_window(2:end)',Y_hat_val(i)]';
                            else
                                val_X_window = Y_hat_val(i);
                            end
                        end
                        % back to original scale
                        Y_hat_val_orig_unit = sd_train*Y_hat_val + mu_train; 
                        % store output
                        output{counter,1} = batch;
                        output{counter,2} = lag;
                        output{counter,3} = hidden;
                        output{counter,4} = mean((Y_hat_val_orig_unit-val_data').^2); %mse
                        output{counter,5} = sqrt(mean((Y_hat_val_orig_unit-val_data').^2)); %rmse
                        output{counter,6} = time;
                        % print every n iterations a sign of life
                        if mod(counter,5)==1
                            fprintf('%2.0f\n',counter)
                        end
                        % update
                        counter = counter +1;
                end
        end
end


% format output
output_tbl = cell2table(output, 'VariableNames', {'batch','lag','hidden_size','mse_val',...
                 'rmse_val', 'time'});

% save output
writetable(output_tbl, 'output/part2/lstm/part2_lstm.xlsx');
% read in table
output_tbl = readtable('output/part2/lstm/part2_lstm.xlsx');

% group stats together and visualize             
group_stats  = grpstats(output_tbl, {'lag','hidden_size'}, {@median});            

surf(nr_lags, hidden_sizes, reshape(group_stats.median_rmse_val,... 
     length(hidden_sizes),length(nr_lags)));

figure
surf(nr_lags, hidden_sizes, reshape(group_stats.median_rmse_val,... 
     length(hidden_sizes),length(nr_lags)));
%colorbar;
xlabel('Number of Lags');
ylabel('Size Hidden Layer');
zlabel('RMSE');
set(gca,'ZScale','log');
%caxis([0 15])

sizex = 20;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/lstm/figure2.png');
             

%% 
% --------------------------------------------------------
% 4) Verify optimal parameters on validation set visually
% ---------------------------------------------------------

% create X and Y matrix for train/validation and all_train
lags = 70;
% train
X_train = getTimeSeriesTrainData(train_stand,lags);
Y_train = train_stand(lags+1:end)';

% validation
X_val = getTimeSeriesTrainData(([train_stand(end-(lags-1):end)',val_stand']'),lags);
Y_val = val_stand';


numFeatures = lags;
numResponses = 1;
numHiddenUnits = 50;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];


options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'ValidationData',{X_val,Y_val}, ...
    'ValidationFrequency',5, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',50, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(X_train,Y_train,layers,options);

%%  predictions on validation set
net = predictAndUpdateState(net,X_train);
% get predictors for validation set (last lags of the training set)
val_X_window = train_stand(end-(lags-1):end);  
[net,Y_hat_val] = predictAndUpdateState(net,val_X_window);
% predictors
if lags > 1
    val_X_window = [val_X_window(2:end)',Y_hat_val]';
% lags =  1
else
    val_X_window = Y_hat_val;
end
forecast_horizon = numel(val_data);
for i = 2:forecast_horizon
    % make predictions
    [net,Y_hat_val(i)] = predictAndUpdateState(net,val_X_window,'ExecutionEnvironment','cpu');
    % update predictor matrix: remove oldest value and add latest predictions
    if lags >1
        val_X_window = [val_X_window(2:end)',Y_hat_val(i)]';
    else
        val_X_window = Y_hat_val(i);
    end
end

Y_hat_val_orig_unit = sd_train*Y_hat_val + mu_train; 
mse_val = mean((Y_hat_val_orig_unit-val_data').^2)
rmse_val = sqrt(mean((Y_hat_val_orig_unit-val_data').^2))

figure
subplot(2,1,1)
plot(val_data)
ylim([0 300]);
hold on
plot(Y_hat_val_orig_unit,'.-')
hold off
legend(["Observed" "Forecast"])
ylabel("Amplitute")
%xlabel("Discrete time index")
%title("Forecast")

subplot(2,1,2)
stem(Y_hat_val_orig_unit - val_data')
xlabel("Discrete time index")
ylabel("Residuals")
title("RMSE = " + rmse_val)             
             
sizex = 10;
sizey = 15;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/lstm/figure3.png');


