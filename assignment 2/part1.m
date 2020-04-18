
T = [1 1; -1 -1; 1 -1]';
net = newhop(T);
n=50;
convergence = cell(n, 1);
for i=1:n
    a={rands(2,1)};                     % generate an initial point 
    [y,Pf,Af] = sim(net,{1 50},{},a);   % simulation of the network for 50 timesteps              
    record=[cell2mat(a) cell2mat(y)];   % formatting results  
    start=cell2mat(a);                  % formatting results 
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    plot(start(1,1),start(2,1),'bx',record(1,:),record(2,:),'r'); % plot evolution
    hold on;
    plot(record(1,50),record(2,50),'gO');  % plot the final point with a green circle
end
legend('Initial State','Time Evolution','Attractor','Location', 'northeast');
title('Time evolution in the phase space of 2d Hopfield model');
hold off;

% 1) Is the number of real attractors bigger 
% than the number of attractors used to create the network?
% ==> Yes, 4 istead of 3

% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(convegence);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('Number of steps till convergence');
hold off;
mean(conver_mat)
median(conver_mat)
std(conver_mat)

%% Execute script rep2. Modify this script to start from some particular points (e.g. of high symmetry) 
% or to generate other numbers of points. Are the attractors always those stored in the network at creation?

T = [1 1; -1 -1; 1 -1]';
net = newhop(T);
n=50;
initial_state = [0 0; 0.5 0; 0 0.5; -0.4122 0.6627; -0.9303 0.5157; -0.9142 -0.3143];
convergence = cell(n, 1);
for i=1:n
    r = randsample(length(initial_state),1);
    a = {initial_state(r,:)'};          % generate an initial point 
    [y,Pf,Af] = sim(net,{1 50},{},a);   % simulation of the network for 50 timesteps              
    record=[cell2mat(a) cell2mat(y)];   % formatting results                                     
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    start=cell2mat(a);                  % formatting results 
    plot(start(1,1),start(2,1),'bx',record(1,:),record(2,:),'r'); % plot evolution
    hold on;
    plot(record(1,50),record(2,50),'gO');  % plot the final point with a green circle
end
legend('initial state','time evolution','attractor','Location', 'northeast');
title('Time evolution in the phase space of 2d Hopfield model');
hold off;
% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(conver_mat);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('Number of steps till convergence');
hold off;
mean(conver_mat)
median(conver_mat)
std(conver_mat)


%% Do the same for a three neuron Hopfield network. This time use script rep3.
T = [1 1 1; -1 -1 1; 1 -1 -1]';
net = newhop(T);
n=50;
initial_state = [1, -1, 1; 0 0 0; 0 0 0.5; 0.6627 -0.4122 0.6627; 0.6627 -0.9303 0.5157;0.5157 -0.9142 -0.3143];
convergence = cell(n, 1);
for i=1:n
    r = randsample(length(initial_state),1);
    a = {initial_state(r,:)'};                    
    [y,Pf,Af] = sim(net,{1 50},{},a);       % simulation of the network  for 50 timesteps
    record=[cell2mat(a) cell2mat(y)];       % formatting results
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    start=cell2mat(a);                      % formatting results 
    plot3(start(1,1),start(2,1),start(3,1),'bx',record(1,:),record(2,:),record(3,:),'r');  % plot evolution
    hold on;
    plot3(record(1,50),record(2,50),record(3,50),'gO');  % plot the final point with a green circle
end
grid on;
legend('initial state','time evolution','attractor','Location', 'northeast');
title('Time evolution in the phase space of 3d Hopfield model');

%%
repeat = 1000;
nums = zeros(repeat, 10);
for i=1:repeat
   nums(i,:) = hopdigit_own(4, 500);
end

hopdigit_own(20, 500);

pred = reshape(nums,size(nums,1)*size(nums,2),1);
true = repelem(0:9,repeat)';
fig = figure;
confusionchart(pred,true,'RowSummary','row-normalized','ColumnSummary','column-normalized');
fig_Position = fig.Position;
fig_Position(3) = fig_Position(3)*1.5;
fig.Position = fig_Position;

%%
repeat = 10;
sigmas = 0:4:20;
iterations = 10.^(0:3); %100:100:1000;

expected = repmat(0:9, repeat, 1);
failures = -1 * ones(repeat, 10);
total_correct = ones(size(sigmas, 2), size(iterations, 2));
total_failed = ones(size(sigmas, 2), size(iterations, 2));

for i=1:size(sigmas, 2)
    sigma = sigmas(i);
    for j=1:size(iterations, 2)
        num_iterations = iterations(j);
        nums = zeros(repeat, 10);
        for k=1:repeat
           nums(k,:) = hopdigit_own(sigma, num_iterations);
        end

        match_correct = nums == expected;
        count_correct = sum(match_correct);
        total_correct(i,j) = sum(count_correct);

        match_failed = nums == failures;
        count_failed = sum(match_failed);
        total_failed(i,j) = sum(count_failed);
    end
end

subplot(2, 1, 1);
surf(sigmas, iterations, total_correct');
colorbar;
xlabel('\sigma');
ylabel('Iterations');
zlabel('Success count');
set(gca,'YScale','log');
subplot(2, 1, 2);
surf(sigmas, iterations, total_failed');
colorbar;
xlabel('\sigma');
ylabel('Iterations');
zlabel('Failure count');
set(gca,'YScale','log');

sizex = 20;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'EffectSigmaIterations', 'pdf');

