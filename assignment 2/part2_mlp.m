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
subplot(2,1,1)
plot(train_data)
xlabel("Discrete time index")
ylabel("Amplitute")
title("Training Set")

subplot(2,1,2)
plot(val_data)
xlabel("Discrete time index")
ylabel("Amplitute")
title("Validation Set")

sizex = 20;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/mlp/figure1.png');

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

nr_lags = [1,10, 20, 30, 40, 50, 60];
hidden_sizes = [10, 20, 30, 40, 50, 60]; 
repeat_count = 5;
output = cell(size(nr_lags, 2) * size(hidden_sizes, 2) * repeat_count, 7);
batch = 0;         
counter = 1;

for lag=nr_lags
            
    % create X and Y matrix for train/validation and all_train
    % train
    X_train = getTimeSeriesTrainData(train_stand,lag);
    Y_train = train_stand(lag+1:end)';

    % validation
    X_val = getTimeSeriesTrainData(([train_stand(end-(lag-1):end)',val_stand']'),lag);
    Y_val = val_stand';

    % add X_train and X_val
    X_train_val = [X_train, X_val];
    Y_train_val = [Y_train, Y_val];

    for hidden=hidden_sizes
          batch = batch + 1;
          for j=1:repeat_count
                fprintf('%2.0f\n',counter)
                % train network
                net_grid_search = feedforwardnet(hidden_sizes, 'trainlm');
                net_grid_search.trainParam.showWindow = false;
                net_grid_search.divideFcn = 'divideind';
                % this is to ensure we obtain the mse for the trainbr on
                % the validation data (is disabled by default)
                net_grid_search.trainParam.max_fail = 10; 
                net_grid_search.trainParam.epochs=200;
                % indices for training
                net_grid_search.divideParam.trainInd = 1:size(X_train,2);
                % indices for validation
                net_grid_search.divideParam.valInd = size(X_train,2)+1:size(X_train,2)+size(X_val,2);
                %output layer transferFcn always purelin for regression purposes
                tic;
                [net_grid_search, tr] = train(net_grid_search,X_train_val,Y_train_val); 
                time = toc;

                %% predictions on validation set
                % get predictors for validation set (last lags of the training set)
                val_X_window = train_stand(end-(lag-1):end);  
                Y_hat_val = sim(net_grid_search,val_X_window);
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
                    Y_hat_val(i) = sim(net_grid_search, val_X_window);
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
                output{counter,2} = tr.best_epoch;
                output{counter,3} = lag;
                output{counter,4} = hidden;
                output{counter,5} = mean((Y_hat_val_orig_unit-val_data').^2); %mse 
                output{counter,6} = sqrt(mean((Y_hat_val_orig_unit-val_data').^2)); % rmse
                output{counter,7} = time;
                % print every n iterations a sign of life
                fprintf('%2.0f\n',counter)
                
                % update
                counter = counter +1;
          end
    end
end


% format output
output_tbl = cell2table(output, 'VariableNames', {'batch','best_epoch','lag','hidden_size','mse_val',...
                 'rmse_val', 'time'});
% save output
writetable(output_tbl, 'output/part2/mlp/part2_mlp.xlsx');
% read in table
%output_tbl = readtable('output/part2/mlp/part2_mlp.xlsx');

% group stats together and visualize             
group_stats  = grpstats(output_tbl, {'lag','hidden_size'}, {@median});            

figure
surf(hidden_sizes, nr_lags, reshape(group_stats.median_rmse_val,... 
     length(nr_lags),length(hidden_sizes)));
colorbar;
xlabel('Number of Lags');
ylabel('Size Hidden Layer');
zlabel('RMSE');
set(gca,'ZScale','log');
%caxis([0 15])

sizex = 20;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/mlp/figure2.png');

%% 
% --------------------------------------------------------
% 4) Verify optimal parameters on validation set visually
% ---------------------------------------------------------

% create X and Y matrix for train/validation and all_train
lags = 40;
% train
X_train = getTimeSeriesTrainData(train_stand,lags);
Y_train = train_stand(lags+1:end)';

% validation
X_val = getTimeSeriesTrainData(([train_stand(end-(lags-1):end)',val_stand']'),lags);
Y_val = val_stand';

% add X_train and X_val
X_train_val = [X_train, X_val];
Y_train_val = [Y_train, Y_val];

% train network
net_train = feedforwardnet(30, 'trainlm');
net_train.trainParam.showWindow = true;
net_train.divideFcn = 'divideind';
% this is to ensure we obtain the mse for the trainbr on
% the validation data (is disabled by default)
net_train.trainParam.max_fail = 10; 
net_train.trainParam.epochs=70;
% indices for training
net_train.divideParam.trainInd = 1:size(X_train,2);
% indices for validation
net_train.divideParam.valInd = size(X_train,2)+1:size(X_train,2)+size(X_val,2);
%output layer transferFcn always purelin for regression purposes
net_train = train(net_train,X_train_val,Y_train_val);   


%%  predictions on validation set
% get predictors for validation set (last lags of the training set)
val_X_window = train_stand(end-(lags-1):end);  
Y_hat_val = sim(net_train,val_X_window);
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
    Y_hat_val(i) = sim(net_train,val_X_window);
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
hold on
plot(Y_hat_val_orig_unit,'.-')
hold off
legend(["Observed" "Forecast"])
ylabel("Amplitute")
title("Forecast")

subplot(2,1,2)
stem(Y_hat_val_orig_unit - val_data')
xlabel("Discrete time index")
ylabel("Residuals")
title("RMSE = " + rmse_val)  

sizex = 20;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part2/mlp/figure3.png');
             
