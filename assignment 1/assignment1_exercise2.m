%clear;
steps = [0.05,0.01,0.001];
stdevs = [0,0.1,0.3];
hiddens = [5,20,50]; 
repeat_count = 10;
trainAlgs = {'traingd', 'traingda', 'traincgf', 'traincgp', 'trainbfg', 'trainlm', 'trainbr'};
data = cell(size(steps, 2) * size(stdevs, 2) * size(hiddens, 2) * repeat_count * size(trainAlgs, 2), 8);
counter = 1;

for step=steps
    x=0:step:3*pi;
    y=sin(x.^2);
    for stdev=stdevs
        ynoisy = y + stdev*randn(size(x));

        %plot(x, y);
        %hold on;
        %plot(x, ynoisy, '*');
        
        for hidden_count=hiddens
            firstnet = feedforwardnet(hidden_count, 'traingd');
            for trainAlg=trainAlgs
                trainFc = char(trainAlg);
                for j=1:repeat_count
                    net = feedforwardnet(hidden_count, trainFc);
                    net.iw{1,1}=firstnet.iw{1,1};  %set the same weights and biases for the networks 
                    net.lw{2,1}=firstnet.lw{2,1};
                    net.b{1}=firstnet.b{1};
                    net.b{2}=firstnet.b{2};
                    net.trainParam.showWindow = false;
                    %net.trainParam.goal = 0.001;
                    tic;
                    [net, tr] = train(net, x, ynoisy);
                    time = toc;
                    y_hat = sim(net, x);
                    %plot(x2, yresult, '--');
                    %figure;
                    [m,b,r] = postreg(y_hat,ynoisy);
                    % computes root mean squared error   
                    rmse = sqrt(mean((y_hat - ynoisy).^2)); 

                    data{counter,1} = trainFc;
                    data{counter,2} = r;
                    data{counter,3} = rmse;
                    data{counter,4} = tr.epoch(end);
                    data{counter,5} = time; %sum(tr.time);
                    data{counter,6} = size(x, 2);
                    data{counter,7} = stdev;
                    data{counter,8} = hidden_count;
                    counter = counter + 1;
                    fprintf('%-10s\t%2.3f\t%2.3f\t%4i\t%8.3f\t%2.3f\t%2.3f\t%3i\n', trainFc, r,rmse, tr.epoch(end), time, size(x, 2), stdev, hidden_count);
                end
            end
        end
    end
end

tbl = cell2table(data, 'VariableNames', {'train_algo', 'r','rmse', 'epochs', 'time', 'num_samples', 'std_noise', 'hidden_neurons'});
writetable(tbl, 'data/tbl.xlsx');
stats = grpstats(tbl, {'num_samples', 'std_noise', 'hidden_neurons', 'train_algo'}, {'min', 'median', 'max', 'std'});
disp(stats);
writetable(stats, 'data/stats.xlsx');


