clear
clc
close all
rng default

%% Hopfield network

% -------------------------------------------------------------------------------------------------------------
%  based on script rep2 and rep3
% -------------------------------------------------------------------------------------------------------------

% A) Random
% -------------------------------------------------------------------------------------------------------------
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
    plot(start(1,1),start(2,1),'ro',record(1,:),record(2,:),'--m'); % plot evolution
    hold on;
    plot(record(1,50),record(2,50),'bs');  % plot the final point with a green circle
end
legend('Initial State','Time Evolution','Attractor','Location', 'northeast');
%title('Time evolution in the phase space of 2d Hopfield model');
hold off;
saveas(gcf, 'output/part1/rep23/figure1.png');



% 1) Is the number of real attractors bigger 
% than the number of attractors used to create the network?
% ==> Yes, 4 istead of 3

% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(conver_mat);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('# of steps till convergence');
set(gca,'xtick',[]);
hold off;
saveas(gcf, 'output/part1/rep23/figure2.png');
mean(conver_mat)
median(conver_mat)
std(conver_mat)

% B) symmetric
% -------------------------------------------------------------------------------------------------------------
T = [1 1; -1 -1; 1 -1]';
net = newhop(T);
n=50;
initial_state = [0 0; 0.5 0; 0 0.5; -0.4122 -0.6627; 0.9303 0.5157; -0.9142 -0.3143];
convergence = cell(n, 1);
for i=1:n
    r = randsample(length(initial_state),1);
    a = {initial_state(r,:)'};          % generate an initial point 
    [y,Pf,Af] = sim(net,{1 50},{},a);   % simulation of the network for 50 timesteps              
    record=[cell2mat(a) cell2mat(y)];   % formatting results                                     
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    start=cell2mat(a);                  % formatting results 
    plot(start(1,1),start(2,1),'ro',record(1,:),record(2,:),'--m'); % plot evolution
    hold on;
    plot(record(1,50),record(2,50),'bs');  % plot the final point with a green circle
end
legend('initial state','time evolution','attractor','Location', 'northeast');
%title('Time evolution in the phase space of 2d Hopfield model');
hold off;
saveas(gcf, 'output/part1/rep23/figure3.png');
% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(conver_mat);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('# of steps till convergence');
hold off;
saveas(gcf, 'output/part1/rep23/figure4.png');
mean(conver_mat)
median(conver_mat)
std(conver_mat)


%% Do the same for a three neuron Hopfield network. This time use script rep3.

% A) Random
% -------------------------------------------------------------------------------------------------------------
T = [1 1 1; -1 -1 1; 1 -1 -1]';
net = newhop(T);
n=50;
convergence = cell(n, 1);
for i=1:n
    a={rands(3,1)};                     % generate an initial point                 
    [y,Pf,Af] = sim(net,{1 200},{},a);       % simulation of the network  for 50 timesteps
    record=[cell2mat(a) cell2mat(y)];       % formatting results
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    start=cell2mat(a);                      % formatting results 
    plot3(start(1,1),start(2,1),start(3,1),'ro',record(1,:),record(2,:),record(3,:),'--m');  % plot evolution
    hold on;
    plot3(record(1,50),record(2,50),record(3,50),'bs');  % plot the final point with a green circle
end
grid on;
legend('initial state','time evolution','attractor','Location', 'northeast');
%title('Time evolution in the phase space of 3d Hopfield model');
hold off;
saveas(gcf, 'output/part1/rep23/figure5.png');

% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(conver_mat);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('# of steps till convergence');
hold off;
saveas(gcf, 'output/part1/rep23/figure6.png');
mean(conver_mat)
median(conver_mat)
std(conver_mat)

% B) symmetric
% -------------------------------------------------------------------------------------------------------------
T = [1 1 1; -1 -1 1; 1 -1 -1]';
net = newhop(T);
n=50;
initial_state = [1, -1, 1; 0 0 0; 0 0 0.5; 0.6627 -0.4122 0.6627; 0.6627 -0.9303 0.5157;0.5157 -0.9142 -0.3143];
convergence = cell(n, 1);
for i=1:n
    r = randsample(length(initial_state),1);
    a = {initial_state(r,:)'};                    
    [y,Pf,Af] = sim(net,{1 200},{},a);       % simulation of the network  for 50 timesteps
    record=[cell2mat(a) cell2mat(y)];       % formatting results
    convergence{i,1} = find_convergence(record); % find index nr where its converges
    start=cell2mat(a);                      % formatting results 
    plot3(start(1,1),start(2,1),start(3,1),'ro',record(1,:),record(2,:),record(3,:),'--m');  % plot evolution
    hold on;
    plot3(record(1,50),record(2,50),record(3,50),'bs');  % plot the final point with a green circle
end
grid on;
legend('initial state','time evolution','attractor','Location', 'northeast');
%title('Time evolution in the phase space of 3d Hopfield model');
hold off;
saveas(gcf, 'output/part1/rep23/figure7.png');

% How long does it typically take to reach the attractor?
conver_mat = cell2mat(convergence);
boxplot(conver_mat);
hold on;
scatter(ones(1,n)',conver_mat, 'filled','MarkerFaceAlpha',0.2','jitter','on','jitterAmount',0.1);
xlabel('Convergence');
ylabel('# of steps till convergence');
hold off;
saveas(gcf, 'output/part1/rep23/figure8.png');
mean(conver_mat)
median(conver_mat)
std(conver_mat)






