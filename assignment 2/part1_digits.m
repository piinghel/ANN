clear
clc
close all
rng default
%%
% ---------------------------------------------------------------
% 2.1 Influence of spurious attractors
% ---------------------------------------------------------------


% ---------------------------------------------------------------
% Find sprious attractors: A) Strategic Search
% ---------------------------------------------------------------

load data/digits.mat

% convert 0 to -1
X = 2*X-1;

% get digits
index_dig = 1:20:181;
num_dig = size(index_dig, 2);
T = X(index_dig, :)';
num_iter = 1000;

d1 = T(:, 8+1);
d2 = T(:, 9+1);
avg = (d1 + d2) / 2;
inverse = -d1;
null = zeros(size(d1));
unit = ones(size(d1));
random = randn(size(d1));
target = random;

subplot(221);
imshow(reshape(d1,15,16)');
subplot(222);
imshow(reshape(d2,15,16)');
subplot(223);
imshow(reshape(target,15,16)');

net = newhop(T);
[Yn,~,~] = sim(net,{1 num_iter},{},target);

subplot(224);
spurs_strategic = Yn{1,end}';
imshow(reshape(spurs_strategic,15,16)')
detect_num(T, spurs_strategic')


% Find sprious attractors: B) Brute Force
% ---------------------------------------------------------------

index_dig = 1:20:181;
num_dig = size(index_dig, 2);
T = X(index_dig, :)';
num_iter = 1000;

net = newhop(T);
targets = {};
spurs = {};

for i=1:1000
    target = randn(size(T(:, 1)));
    [Yn,~,~] = sim(net,{1 num_iter},{},target);
    digit = Yn{1,end}';
    num = detect_num(T, digit');
    if num < 0
        disp('Spurious!');
        targets{end+1} = target;
        spurs{end+1} = digit';
    end
end

%filter out duplicate rows
m = cell2mat(spurs)';
tol = 0.0001;
[~, ii] = sortrows(m);
ii_unique = ii(logical([1; any(diff(m(ii,:))>tol,2)]));
spurs_bf = m(sort(ii_unique),:)';

n = size(spurs_bf, 2);
for col=1:n
    subplot(1, n, col);
	imshow(reshape(spurs_bf(:,col),15,16)');
end

% add spurious labels of strategic and brufe force
figure;
subplot(1, 4, 1);
imshow(reshape(spurs_strategic,15,16)');
for col=1:3
    subplot(1, n+1, col+1);
	imshow(reshape(spurs_bf(:,col),15,16)');
end
saveas(gcf, 'output/part1/digits/fig1.png');

sizex = 30;
sizey = 20;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1/digits/figure1.png');


%%
% ---------------------------------------------------------------
% 2.2 Confusion Matrix
% ---------------------------------------------------------------


repeat = 1000;
nums = zeros(repeat, 10);
noise_level = 4;
time_steps = 200;
for i=1:repeat
   nums(i,:) = hopdigit_own(noise_level, time_steps);
end

pred = reshape(nums,size(nums,1)*size(nums,2),1);
true = repelem(0:9,repeat)';
figure;
confusionchart(pred,true,'RowSummary','row-normalized','ColumnSummary','column-normalized');
sizex = 22;
sizey = 15;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1/digits/figure2.png');



%%
% ---------------------------------------------------------------
% 2.3 Simulation: study effect of noise and step size
% ---------------------------------------------------------------
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

%subplot(2, 1, 1);
figure;
surf(sigmas, iterations, total_correct');
%colorbar;
xlabel('\sigma');
ylabel('Iterations');
zlabel('Success count');
set(gca,'YScale','log');
sizex = 22;
sizey = 15;
set(gcf, 'PaperPosition', [0 0 sizex sizey]);
set(gcf, 'PaperSize', [sizex sizey]);
saveas(gcf, 'output/part1/digits/figure3.png');
%subplot(2, 1, 2);
%surf(sigmas, iterations, total_failed');
%colorbar;
%xlabel('\sigma');
%ylabel('Iterations');
%zlabel('Failure count');
%set(gca,'YScale','log');






