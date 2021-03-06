clear
clc
close all

%% load data and have a look at the first image
load data/threes -ascii;

colormap('gray');
imagesc(reshape(threes(1,:),16,16),[0,1]);

%% Plot the eigenvalues where D is the diagonal matrix of eigenvalues
% produces a diagonal matrix D of eigenvalues and 
% a full matrix V whose columns are the corresponding eigenvectors  
% so that A*V = V*D
C = cov(threes);
[V,D] = eig(C);

eigenvalues = flipud(diag(D));
plot(eigenvalues)
xlabel('q');
ylabel('Eigenvalue');
xlim([0 255]);
sizex = 10;
sizey = 8;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1_pca/figure1', 'png');


eig_cumsum = cumsum(eigenvalues) / sum(eigenvalues);
plot(1 - eig_cumsum);
xlabel('q');
ylabel('Quality loss');
xlim([0 255]);
ylim([0 1]);
 
sizex = 10;
sizey = 8;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1_pca/figure2', 'png');


%% compress data to 1,2,3,4 PC and visualize reconstruction of the images

% standardize first
avg = mean(threes);
sd = std(threes);
threes_stand = (threes - avg)./sd;
[coeff,score,latent,tsquared,explained] = pca(threes_stand);

% visualize variance explained in function of number of components
plot(explained)
xlim([1 size(explained,1)])
set(gca, 'YScale', 'log')
ylabel("Variance Exlained (log scale)")
xlabel("Number of Principal Components");

% reconstruct digits using only the 1,2,3,4,first components, and all (256)
% compenents
image_id = 6;
q = [1, 2, 3, 4, 256];
colormap('gray');
for i = 1:size(q,2)
    subplot(1,size(q,2)+1,i);
	threes_hat = (score(:,1:q(i)) * coeff(:,1:q(i))') .* sd + avg;
    imagesc(reshape(threes_hat(image_id,:),16,16),[0,1]);
    title(['q = ', num2str(q(i))])
    set(gca, 'visible', 'off')
    set(findall(gca, 'type', 'text'), 'visible', 'on')
end
% add original plot
subplot(1,size(q,2)+1,size(q,2)+1);
colormap('gray');
imagesc(reshape(threes(image_id,:),16,16),[0,1])
title("original");
set(gca, 'visible', 'off')
set(findall(gca, 'type', 'text'), 'visible', 'on')

sizex = 16;
sizey = 5;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1_pca/figure3.png');

%% 
% Use the Matlab function cumsum to create a vector whose i-th element is the sum of all but the i largest eigenvalues for
% i = 1 : 256. Compare the first 50 elements of this vector to the vector of reconstruction errors calculated previously. What
% do you notice? 

q = [1:50];
rmse_q = [1:size(q,2)];
for i=q
    threes_hat = (score(:,1:i) * coeff(:,1:i)') .* sd + avg;
    rmse_q(i) = mean(mean((threes-threes_hat).^2));
end

out = [1:256];
for i=out
    out(i) = sum(eigenvalues(i+1:end));
end

figure;
yyaxis left
plot(rmse_q)
ylabel("MSE")
hold on
yyaxis right
plot(out(1:50))
ylabel("Sum of all but the ith largest eigenvalues")
xlabel("Number of Principal Components (PC) / Eigenvalues");

sizex = 10;
sizey = 8;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1_pca/figure4.png');





