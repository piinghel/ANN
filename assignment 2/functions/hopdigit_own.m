function nums = hopdigit_own(noiselevel,num_iter)


load digits; clear size
[N, dim]=size(X);
maxx=max(max(X));

%Values must be +1 or -1
X(X==0)=-1;

index_dig = [1,21,41,61,81,101,121,141,161,181];
num_dig = size(index_dig, 2);
T = X(index_dig, :)';
net = newhop(T);

%Check if digits are attractors
[Y,~,~] = sim(net,num_dig,[],T);
Y = Y';

% Add noise to the digit maps
noise = noiselevel*maxx; % sd for Gaussian noise

Xn = X; 
for i=1:N
  Xn(i,:) = X(i,:) + noise*randn(1, dim);
end

Xn = Xn';
Tn = {Xn(:,index_dig)};
[Yn,~,~] = sim(net,{num_dig num_iter},{},Tn);
Yn = Yn{1,end}';
nums = zeros(1, num_dig);

for i = 1:num_dig
    digit = Yn(i,:);
    nums(i) = detect_num(T, digit');
end

