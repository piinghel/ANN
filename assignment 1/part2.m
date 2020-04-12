
close all;
clc;
%% read in data and build target
load('Data/Data_Problem1_regression.mat');

% Student Number
stud_nr='0789332';
% select first 5 digits in descending order
stud_nr5 = maxk(stud_nr,5);
% build new target
Y = ((stud_nr5(1)*T1 + stud_nr5(2)*T2 + stud_nr5(3)*T3 + stud_nr5(4)*T4 + stud_nr5(5)*T5)/sum(stud_nr5))';
X = [X1,X2]';

%% divide data in train/validation/train_validation)/test set
% randomly select  3000 data points
data_subset = randperm(size(X,2),3000);
train_idx = data_subset(1:1000);
val_idx = data_subset(1001:2000);
train_val_idx = data_subset(1:2000);
test_idx = data_subset(2001:3000);

% training set
train_X = X(:,train_idx);
train_Y = Y(train_idx);

% validation set
train_val_X = X(:,train_val_idx);
train_val_Y = Y(:,train_val_idx);

% train_validation set
val_X = X(:,val_idx);
val_Y = Y(:,val_idx);

% test set
test_X = X(:,test_idx);
test_Y = Y(:,test_idx);


%% 1) plot surface training data
[xq,yq] = meshgrid(0:0.01:1, 0:0.01:1);
zq_train = griddata(train_X(1,:),train_X(2,:),train_Y,xq,yq);
figure
mesh(xq,yq,zq_train);
hold on
plot3(train_X(1,:),train_X(2,:),train_Y,'.');
title('Training Data');
xlabel('X1');
ylabel('X2');
zlabel('Target (Tnew)')
legend('Actual Surface','Actual Points','Location','NorthWest')
hold off;
saveas(gcf,'output/fig8.png');


%% train different networks 

train_algos = {'traingd', 'traingda', 'traincgf', 'traincgp', 'trainbfg', 'trainlm', 'trainbr'}; 
hidden_sizes = [5, 25, 50, 100];
transfer_funcs = {'logsig', 'tansig'};
repeat_count = 10;
data = cell(size(train_algos, 2) * size(hidden_sizes, 2) * size(transfer_funcs, 2) * ...
            repeat_count, 8);
counter = 1;
batch = 0;
for hidden_size=hidden_sizes
    for train_algo=train_algos
        for transfer_func=transfer_funcs
            batch = batch + 1;
            for j=1:repeat_count
                
                net_train = feedforwardnet(hidden_size, char(train_algo));
                net_train.trainParam.showWindow = false;
                net_train.divideFcn = 'divideind';
                % this is to ensure we obtain the mse for the trainbr on
                % the validation data (is disabled by default)
                net_train.trainParam.max_fail = 20; 
                net_train.divideParam.trainInd = train_idx;
                net_train.divideParam.valInd = val_idx;
                net_train.layers{1}.transferFcn = char(transfer_func);
                %output layer transferFcn always purelin for regression purposes
                
                % time training of the network
                tic;
                [net_train, tr] = train(net_train,X,Y);   
                time = toc;
                  
                data{counter, 1} = train_algo;
                data{counter, 2} = batch;
                data{counter, 3} = hidden_size;               
                data{counter, 4} = transfer_func;
                data{counter, 5} = tr.epoch(end);
                data{counter, 6} = tr.best_perf;
                data{counter, 7} = tr.best_vperf;
                data{counter, 8} = time;

                counter = counter + 1;
                
                % print every 10 iterations
                if mod(counter,10)==1
                    fprintf('%3i\n', counter-1)
                end                   
            end
        end
    end
end

tbl = cell2table(data, 'VariableNames', {'train_algos', 'repetition', 'hidden_size', 'transfer_func',...
                 'nr_epochs','mse_train', 'mse_val','time'});

writetable(tbl, 'output/part2.xlsx');
%tbl = readtable('output/part2.xlsx');             

%% todo find best parameters

% train final selected network (with chosen parameters) on train_validation data
net_final=feedforwardnet(50,'trainbr'); %hiddenSizes 
%(Row vector of one or more hidden layer sizes (default = 10)
%Row vector of one or more hidden layer sizes (default = 10), Training function

net_final.divideFcn = 'divideind';
net_final.divideParam.trainInd = train_val_idx;
net_final.layers{1}.transferFcn = char('logsig');

%training and simulation
net_final.trainParam.epochs=1000;  % set the number of epochs for the training 
net_final=train(net_final,train_val_X,train_val_Y);   % train the networks
% predictions on test data
pred_test=sim(net_final,test_X);  % simulate the networks with the input vector p
mse_test = mean((pred_test - test_Y).^2);

% bootstrap the mse on the test set
B = 10000;
[bootstat,bootsam] = bootstrp(B,[],test_X');
% transpose
bootsam_ = bootsam';
boot_store = cell(B,1);
for b=1:B   
    % select indices
    boot_test_X = test_X(:, bootsam_(b,:));
    boot_test_y = test_Y(bootsam_(b,:));
    % predict on bootstrapped test set
    boot_pred = sim(net_final,boot_test_X);
    % calcualte mse and store
    boot_mse = mean((boot_pred - boot_test_y).^2);
    boot_store{b} = boot_mse;
    
end;

% percentile confidence intrvals
bootstrap_ci_perc = prctile(cell2mat(boot_store),[2.5 97.5],1)

% The'bias-corrected and accelerated' (BCa) confidence interval;
compute_mse = @(x,y) mean((sim(net_final,x')-y').^2);
bootstrap_ci_bca = bootci(B,compute_mse,test_X', test_Y')

hist(cell2mat(boot_store),50)
xlabel("Mean Squared Error")
title('Samples re-drawn from a single sample')
hold on
ylim = get(gca,'YLim');
h1=plot(bootstrap_ci_perc(1)*[1,1],ylim*1.05,'g-','LineWidth',2);
plot(bootstrap_ci_perc(2)*[1,1],ylim*1.05,'g-','LineWidth',2);
h2=plot(bootstrap_ci_bca(1)*[1,1],ylim*1.05,'r-','LineWidth',2);
plot(bootstrap_ci_bca(2)*[1,1],ylim*1.05,'r-','LineWidth',2);
legend([h1,h2],{'Percentile','Bca'});
hold off;
% save figure
saveas(gcf,'output/fig9.png');

% visualize performance of chosen model on test data
% 1) plot surface
zq_test = griddata(test_X(1,:),test_X(2,:),test_Y,xq,yq);
figure
mesh(xq,yq,zq_test);
hold on
plot3(test_X(1,:),test_X(2,:),pred_test,'.');
title('Test Data');
xlabel('X1');
ylabel('X2');
zlabel('Target (Tnew)')
legend('Actual Surface','Predicted Sample Points','Location','NorthWest')
hold off;
saveas(gcf,'output/fig10.png');



