function out = rowfun(func, mat1, mat2)
%no variable inputs, too hard. it does what is needed
out=zeros(size(mat1,1),1);
for idx=1:size(mat1,1)
    out(idx) = func(mat1(idx,:),mat2(idx,:));
end