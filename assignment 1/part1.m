clear;
warning('off');

%%
steps = [0.05,0.01, 0.002];
sds = [0,0.1,0.2,0.3];
hidden_sizes = [5, 20, 50, 100]; 
k_fold = 10; % K for cross validation
train_algos = {'traingd', 'traingda', 'traincgf', 'traincgp', 'trainbfg', 'trainlm', 'trainbr'};
data = cell(size(steps, 2) * size(sds, 2) * size(hidden_sizes, 2)...
            * k_fold * size(train_algos, 2), 11);
counter = 1;
%%
for step=steps
    x = 0:step:3*pi;
    y = sin(x.^2);
    for sd=sds
        % add noise
        y_noise = y + sd*randn(size(y));
        % K fold stratisfied cross validation
        cvo = cvpartition(y_noise,'kfold',k_fold);
        for hidden_size = hidden_sizes
            for train_algo = train_algos
                for k = 1:cvo.NumTestSets 
                    
                    idx = 1:size(y_noise,2);
                    tr_idx = cvo.training(k);
                    val_idx = cvo.test(k);
                    
                    net = feedforwardnet(hidden_size, char(train_algo));
                    net.divideFcn = 'divideind';
                    % this is to ensure we obtain the mse for the trainbr on
                    % the validation data (is disabled by default)
                    net.divideParam.trainInd = idx(tr_idx);               
                    net.divideParam.valInd = idx(val_idx); 
                    net.trainParam.showWindow = false; 
                    net.trainParam.max_fail = 20; 
                    
                    % train the net and also time this
                    tic;
                    % trains the network and returns the trained network (net2),
                    % and a training record (tr)
                    [net, tr] = train(net, x, y_noise);
                    % save time training
                    time = toc;
                    % simulate training and validation data
                    y_hat_tr = sim(net, x(tr_idx));
                    y_hat_val = sim(net, x(val_idx));
                    % m - slope of the linear regression
                    % y - intercept of the linear regression
                    % r - correlation coefficient
                    [m_tr,b_tr,r_tr] = postreg(y_hat_tr,y_noise(tr_idx));
                    [m_val,b_val,r_val] = postreg(y_hat_val,y_noise(val_idx));
                      
                    % store statistics
                    data{counter,1} = char(train_algo);
                    data{counter,2} = k; % fold
                    data{counter,3} = r_tr;
                    data{counter,4} = r_val;
                    data{counter,5} = tr.best_perf; % training performance (mse)
                    data{counter,6} = tr.best_vperf; % validation performance (mse)
                    data{counter,7} = tr.epoch(end);
                    data{counter,8} = time; 
                    data{counter,9} = size(x, 2);
                    data{counter,10} = sd;
                    data{counter,11} = hidden_size;
                    counter = counter + 1;
                    % print every 10 iterations
                    if mod(counter,50)==1
                         fprintf('%-10s\t%3i\t%2.3f\t%2.3f\t%2.3f\t%2.3f\t%4i\t%8.3f\t%2.3f\t%2.3f\t%3i\n',...
                            char(train_algo),counter - 1, r_tr, r_val, tr.best_perf, tr.best_vperf,... 
                            tr.epoch(end), time, size(x, 2), sd, hidden_size);
                    end                
                end
            end
        end
    end
end
%%
tbl = cell2table(data, 'VariableNames', {'train_algo','fold','r_tr','r_val','mse_tr',...
                 'mse_val', 'nr_epoch', 'time', 'num_samples', 'sd', 'hidden_size'});
writetable(tbl, 'output/part1.xlsx');
