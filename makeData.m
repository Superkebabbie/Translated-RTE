function data = makeData(filename)

data = readtable(strcat(filename,'.csv'),'Delimiter','\t');
%format('long')%uncomment if you want to see full doubles instead of rounded things (in display only)

pos = readtable(strcat(filename,'_possed.csv'),'Delimiter','\t','ReadVariableNames',false);
pos.Properties.VariableNames = {'pos_t','pos_h'};

wtmf= dlmread(strcat('WTMF/WTMF_', filename,'.ls'));
wtmf = wtmf(:,1:100);%removes missing values (because a 101th NaN column is added)
wtmf_t = zeros(size(wtmf,1)/2,size(wtmf,2));
wtmf_h = zeros(size(wtmf,1)/2,size(wtmf,2));
for idx = 1:(size(wtmf,1)/2)
    wtmf_t(idx,:) = wtmf((2*idx)-1,:);
    wtmf_h(idx,:) = wtmf(2*idx,:);
end
wtmf = table(wtmf_t,wtmf_h);
wtmf.Properties.VariableNames = {'wtmf_t','wtmf_h'};

data = [data,pos,wtmf];
clearvars -except data %keep it clean!