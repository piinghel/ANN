clear
clc
close all
rng('default');
%%%%%%%%%%%
%algorlm.m
% A script comparing performance of 'trainlm' and 'traingd'
% traingd - batch gradient descent 
% trainlm - Levenberg - Marquardt
%%%%%%%%%%%

%generation of examples and targets
x=0:0.025:3*pi; y=sin(x.^2);
p=con2seq(x); t=con2seq(y); % convert the data to a useful format

% add gaussian noise
% y_noise=y + randn(size(y))/2;
% t=con2seq(y_noise);

%creation of networks
% traingd, traingda, traincgf, traincgp, trainbfg, trainlm
train_algo1='trainbfg';
train_algo2='trainlm';

net1=feedforwardnet(50,train_algo1); %hiddenSizes 
%(Row vector of one or more hidden layer sizes (default = 10)
%Row vector of one or more hidden layer sizes (default = 10), Training function
net2=feedforwardnet(50,train_algo2);
net2.iw{1,1}=net1.iw{1,1};  %set the same weights and biases for the networks 
net2.lw{2,1}=net1.lw{2,1};
net2.b{1}=net1.b{1};
net2.b{2}=net1.b{2};

epochs_1=1;
epochs_2=10;
epochs_3=1000;
%training and simulation
net1.trainParam.epochs=epochs_1;  % set the number of epochs for the training 
net2.trainParam.epochs=epochs_1;
net1=train(net1,p,t);   % train the networks
net2=train(net2,p,t);
a11=sim(net1,p); a21=sim(net2,p);  % simulate the networks with the input vector p

net1.trainParam.epochs=epochs_2;
net2.trainParam.epochs=epochs_2;
net1=train(net1,p,t);
net2=train(net2,p,t);
a12=sim(net1,p); a22=sim(net2,p);

net1.trainParam.epochs=epochs_3;
net2.trainParam.epochs=epochs_3;
net1=train(net1,p,t);
net2=train(net2,p,t);
a13=sim(net1,p); a23=sim(net2,p);

%plots
figure
subplot(3,3,1);
plot(x,y,'bx',x,cell2mat(a11),'r',x,cell2mat(a21),'g'); % plot the sine function and the output of the networks
title('1 epoch');
legend('target',train_algo1, train_algo2,'Location','north');
subplot(3,3,2);
postregm(cell2mat(a11),y); % perform a linear regression analysis and plot the result
subplot(3,3,3);
postregm(cell2mat(a21),y);
%
subplot(3,3,4);
plot(x,y,'bx',x,cell2mat(a12),'r',x,cell2mat(a22),'g');
title('10 epochs');
legend('target',train_algo1, train_algo2,'Location','north');
subplot(3,3,5);
postregm(cell2mat(a12),y);
subplot(3,3,6);
postregm(cell2mat(a22),y);
%
subplot(3,3,7);
plot(x,y,'bx',x,cell2mat(a13),'r',x,cell2mat(a23),'g');
title('1000 epochs');
legend('target',train_algo1, train_algo2,'Location','north');
subplot(3,3,8);
postregm(cell2mat(a13),y);
subplot(3,3,9);
postregm(cell2mat(a23),y);

