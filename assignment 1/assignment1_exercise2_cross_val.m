%clear;
warning('off');

steps = [0.05,0.01, 0.002];
sds = [0,0.1,0.2,0.3];
hidden_sizes = [20,50,100]; 
k_fold = 10; % K for cross validation
train_algos = {'traingd', 'traingda', 'traincgf', 'traincgp', 'trainbfg', 'trainlm', 'trainbr'};
data = cell(size(steps, 2) * size(sds, 2) * size(hidden_sizes, 2)...
            * k_fold * size(train_algos, 2), 10);
counter = 1;

for step=steps
    x = 0:step:3*pi;
    y = sin(x.^2);
    for sd=sds
        % add noise
        y_noise = y + sd*randn(size(y));
        % K fold stratisfied cross validation
        cvo = cvpartition(y_noise,'KFold',k_fold);
        for hidden_size = hidden_sizes
            net1 = feedforwardnet(hidden_size, 'traingd');
            for train_algo = train_algos
                train_func = char(train_algo);
                for k = 1:k_fold
                    % create indices for training and validation set
                    tr_idx = cvo.training(k);
                    val_idx = cvo.test(k);        
                    % create network
                    net2 = feedforwardnet(hidden_size, train_func);
                    %set the same weights and biases for the networks 
                    net2.iw{1,1} = net1.iw{1,1}; 
                    net2.lw{2,1} = net1.lw{2,1};
                    net2.b{1} = net1.b{1};
                    net2.b{2} = net1.b{2};
                    net2.trainParam.showWindow = false;
                    %net.trainParam.goal = 0.001;
                    % train the net and also time this
                    tic;
                    % trains the network and returns the trained network (net2),
                    % and a training record (tr)
                    [net2, tr] = train(net2, x(tr_idx), y_noise(tr_idx));
                    % save time training
                    time = toc;
                    % simulate training and validation data
                    y_hat_tr = sim(net2, x(tr_idx));
                    y_hat_val = sim(net2, x(val_idx));
                    % m - slope of the linear regression
                    % y - intercept of the linear regression
                    % r - correlation coefficient
                    [m_tr,b_tr,r_tr] = postreg(y_hat_tr,y_noise(tr_idx));
                    [m_val,b_val,r_val] = postreg(y_hat_val,y_noise(val_idx));
                    % computes root mean squared error 
                    rmse_tr = sqrt(mean((y_hat_tr - y_noise(tr_idx)).^2));
                    rmse_val = sqrt(mean((y_hat_val - y_noise(val_idx)).^2)); 
                    
                    % store statistics
                    data{counter,1} = train_func;
                    data{counter,2} = r_tr;
                    data{counter,3} = r_val;
                    data{counter,4} = rmse_tr;
                    data{counter,5} = rmse_val;
                    data{counter,6} = tr.epoch(end);
                    data{counter,7} = time; %sum(tr.time);
                    data{counter,8} = size(x, 2);
                    data{counter,9} = sd;
                    data{counter,10} = hidden_size;
                    counter = counter + 1;
                    fprintf('%-10s\t%3i\t%2.3f\t%2.3f\t%2.3f\t%2.3f\t%4i\t%8.3f\t%2.3f\t%2.3f\t%3i\n',...
                        train_func,counter - 1, r_tr, r_val, rmse_tr, rmse_val, tr.epoch(end), time, size(x, 2), sd, hidden_size);
                end
            end
        end
    end
end

tbl = cell2table(data, 'VariableNames', {'train_algo','r_tr','r_val','rmse_tr',...
    'rmse_val', 'epoch', 'time', 'num_samples', 'sd', 'hidden_size'});
writetable(tbl, 'data/tbl.xlsx');
stats = grpstats(tbl, {'num_samples', 'sd', 'hidden_size', 'train_algo'}, {'min', 'median', 'max', 'std'});
disp(stats);
writetable(stats, 'data/stats.xlsx');