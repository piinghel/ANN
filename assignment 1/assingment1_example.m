clear all;
close all;
clc;

% Project 1.1: non-linear regression
studentNumber=0341925;


nDig = dec2base(studentNumber,10) - '0';
nDig = sort(nDig,'descend');
while length(nDig)<5
    nDig = [nDig 0];
end
%trim to 5 digits, add zeros of necessary.
nDig = nDig(1,1:5);

data = load('Data_Problem1_regression.mat');

Tnew = (nDig(1)*data.T1 + nDig(2)*data.T2 + nDig(3)*data.T3 + nDig(4)*data.T4 + nDig(5)*data.T5)/sum(nDig);
X1 = data.X1;
X2=data.X2;
X = [X1,X2];
X=X';
Tnew=Tnew';
T_norm = Tnew;

% Splitting
ind = randperm(size(Tnew,2),3000);
trainInd=ind(1:1000);
valInd = ind(1001:2000);
testInd=ind(2001:3000);

xtrain = X(:,trainInd);
xval= X(:,valInd);
xtest = X(:,testInd);
ttrain = (T_norm(trainInd));
tval= (T_norm(valInd));
ttest = (T_norm(testInd));

% Normalization 
temp=mapminmax(ttrain);
[xq,yq] = meshgrid(0:.1:1, 0:.1:1);
vq = griddata(xtrain(1,:),xtrain(2,:),ttrain,xq,yq);
figure
mesh(xq,yq,vq);
hold on
plot3(xtrain(1,:),xtrain(2,:),ttrain,'.');
title('Training Data');
zlabel('Tnew')
hold off;

[xq,yq] = meshgrid(0:.1:1, 0:.1:1);
vq = griddata(xtest(1,:),xtest(2,:),ttest,xq,yq);
figure
mesh(xq,yq,vq);
hold on
plot3(xtest(1,:),xtest(2,:),ttest,'.');
title('test data');

% create the network
% trainfn = {'trainbr','traingd','traincgf'}
% NN=[2 5 10 20 50];
trainfn={'trainbr'};
NN=[10];

for i=1:size(NN,2)
    %NN=15;
    for j=1:size(trainfn,2)
        %create NN
        net=feedforwardnet(NN(i),trainfn{j});
        
        net.divideFcn='divideind';
        net.divideParam.trainInd=trainInd;
        net.divideParam.valInd =valInd;
        net.divideParam.testInd =testInd;
        
        net.layers{2}.transferFcn='purelin';
        net.trainParam.showWindow=1;
        net.trainParam.epochs=10000;
        net.trainParam.max_fail = 100;
        net.trainParam.goal=0;
        
        
        net=configure(net,X,Tnew);
        net=init(net);
        
        tic,
        [net,tr]=train(net,X,Tnew);
        time(i,j)=toc;
        %         figure;
        %         plotperform(tr);
        
        ytrain=net(xtrain);
        yval=net(xval);
        %mse_val(n,i) = mse(net,tval,yval);
        
        perf_train(i,j) = tr.best_perf;
        perf_val(i,j) = tr.best_vperf;
        perf_test(i,j) = tr.best_tperf;
        epoch(i,j)=tr.best_epoch;
        
        ytest=net(xtest);
        mse_test(i,j) = mse(net,ttest,ytest);
        
        plotperform(tr);
        figure;
        plotregression(ttest,ytest,'Test Data',tval,yval,'Validation Data',...
            ttrain,ytrain,'Training Data');
        
        
    end
end

[xq,yq] = meshgrid(0:.1:1, 0:.1:1);
vq = griddata(xtest(1,:),xtest(2,:),ytest,xq,yq);
figure
mesh(xq,yq,vq);
hold on
plot3(xtest(1,:),xtest(2,:),ytest,'.');
title('Surface of the Test Set');


figure;
hold on;
for j=1:size(trainfn,2)
    scatter(j,time(j),'LineWidth',2);
end

legend('traingd','trainscg','traingdx','trainlm','trainbr');
title('Total training time for 5000 epochs');
%xlabel('Number of hidden layer neurons');
ylabel('Time (s)');
set(gca,'xtick',[])
hold off;

figure;
hold on;
for j=1:size(trainfn,2)
    scatter(j,rmse_val(j),'LineWidth',2);
end

legend('traingd','trainscg','traingdx','trainlm','trainbr');
title('Validation performance');
xlabel('Number of hidden layer neurons');
ylabel('MSE');
set(gca,'xtick',[]);
ax = gca;
ax.YTick = 0:0.01:max(rmse_val);
hold off;


figure;
hold on;
for j=1:size(trainfn,2)
    scatter(j,rmse_test(j),'LineWidth',2);
end
legend('traingd','trainscg','traingdx','trainlm','trainbr');
title('Testing performance');
xlabel('Number of hidden layer neurons');
ylabel('MSE');
set(gca,'xtick',[]);
ax = gca;
ax.YTick = 0:0.01:max(rmse_val);
hold off;

