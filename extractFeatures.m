function [features] = extractFeatures(data)

%% ------------- LEN -------------------

uniqueWordsA = cellfun(@unique, regexp(data.t, '[A-z]*', 'match'), 'UniformOutput', false); %A%
uniqueWordsB = cellfun(@unique, regexp(data.h, '[A-z]*', 'match'), 'UniformOutput', false); %B%
% regexp finds words, unique makes set, length makes the number. cellfun is just a one-line for loop

numUniqueWordsA = cellfun(@length, uniqueWordsA); %|A|%
numUniqueWordsB = cellfun(@length, uniqueWordsB); %|B|%

sizeDiffA = cellfun(@length, cellfun(@setdiff, uniqueWordsA, uniqueWordsB, 'UniformOutput', false));%|A-B|%
sizeDiffB = cellfun(@length, cellfun(@setdiff, uniqueWordsB, uniqueWordsA, 'UniformOutput', false));%|B-A|%

sizeIntersect = cellfun(@length, cellfun(@intersect, uniqueWordsA, uniqueWordsB, 'UniformOutput', false));%|A?B|%
sizeUnion = cellfun(@length, cellfun(@union, uniqueWordsA, uniqueWordsB, 'UniformOutput', false));%|AUB|%

normDiffA =  arrayfun(@(x,y) ((x-y)/y), numUniqueWordsA, numUniqueWordsB);%(|A|-|B|)/|B|%
normDiffB =  arrayfun(@(x,y) ((x-y)/y), numUniqueWordsB, numUniqueWordsA);%(|B|-|A|)/|A|%

%construct pos
nounsA = cellfun(@unique,regexp(data.pos_t,'[A-z]+_NN[A-z]*','match'),'UniformOutput', false);
nounsB = cellfun(@unique,regexp(data.pos_h,'[A-z]+_NN[A-z]','match') ,'UniformOutput', false);
verbsA = cellfun(@unique,regexp(data.pos_t,'[A-z]+_VB[A-z]?','match'),'UniformOutput', false);
verbsB = cellfun(@unique,regexp(data.pos_h,'[A-z]+_VB[A-z]?','match'),'UniformOutput', false);
adjsA  = cellfun(@unique,regexp(data.pos_t,'[A-z]+_JJ[A-z]?','match'),'UniformOutput', false);
adjsB  = cellfun(@unique,regexp(data.pos_h,'[A-z]+_JJ[A-z]?','match'),'UniformOutput', false);
advsA  = cellfun(@unique,regexp(data.pos_t,'[A-z]+_[RB[A-z]|WRB]?','match'),'UniformOutput', false);
advsB  = cellfun(@unique,regexp(data.pos_h,'[A-z]+_[RB[A-z]|WRB]?','match'),'UniformOutput', false);

sizeDiffNounA = cellfun(@length, cellfun(@setdiff, nounsA, nounsB,'UniformOutput', false));%|A-B|noun%
sizeDiffNounB = cellfun(@length, cellfun(@setdiff, nounsB, nounsA,'UniformOutput', false));%|B-A|noun%
sizeDiffVerbA = cellfun(@length, cellfun(@setdiff, verbsA, verbsB,'UniformOutput', false));%|A-B|verb%
sizeDiffVerbB = cellfun(@length, cellfun(@setdiff, verbsB, verbsA,'UniformOutput', false));%|B-A|verb%
sizeDiffAdjA  = cellfun(@length, cellfun(@setdiff, adjsA,  adjsB, 'UniformOutput', false));%|A-B|adj%
sizeDiffAdjB  = cellfun(@length, cellfun(@setdiff, adjsB,  adjsA, 'UniformOutput', false));%|B-A|adj%
sizeDiffAdvA  = cellfun(@length, cellfun(@setdiff, advsA,  advsB, 'UniformOutput', false));%|A-B|adv%
sizeDiffAdvB  = cellfun(@length, cellfun(@setdiff, advsB,  advsA, 'UniformOutput', false));%|B-A|adv%

%% ------------- ST ---------------------

jaccard = arrayfun(@(x,y) (x/y), sizeIntersect, sizeUnion);%|A?B|/|AUB|%
dice = arrayfun(@(x,y,z) (2*x/(y+z)), sizeIntersect, numUniqueWordsA, numUniqueWordsB);%2*|A?B|/(|A|+|B|)%
overlapA = arrayfun(@(x,y) (x/y),sizeIntersect, numUniqueWordsA);%|A?B|/|A|%
overlapB = arrayfun(@(x,y) (x/y),sizeIntersect, numUniqueWordsB);%|A?B|/|B|%

%tfidf construction
wordCounts = countMap([data.t;data.h]);%keys are words, values are arrays of count of that word for each sentence.
                                       %texts take indices 1-800, hypothesis 801-1600. Pairs are just i and i+800!
tfIdf_t = cell(length(data.t),1);
tfIdf_h = cell(length(data.h),1);
for idx = 1:length(data.t)
    [tfIdf_t{idx}, tfIdf_h{idx}] = tfIdf(data.t{idx}, data.h{idx}, idx, wordCounts);%tfIdf are cell arrays of array representations!
end

cosine_sim = cellfun(@(x,y) ((dot(x,y))/(length(x)*length(y))), tfIdf_t, tfIdf_h);
manhattan_sim = cellfun(@(x,y) (sum(abs(x-y))), tfIdf_t, tfIdf_h);%vector subtraction is automatically stepwise
euclidian_sim = cellfun(@(x,y) (sqrt(sum((x-y).^2))), tfIdf_t, tfIdf_h);
pearson_cor = cellfun(@(x,y) (corr(x',y', 'type', 'Pearson')), tfIdf_t, tfIdf_h);
spearman_cor = cellfun(@(x,y) (corr(x',y', 'type', 'Spearman')), tfIdf_t, tfIdf_h);
kendall_cor = cellfun(@(x,y) (corr(x',y', 'type', 'Kendall')), tfIdf_t, tfIdf_h);

%% ------------- SS -------------------

wtmf_cosine_sim = rowfun(@(x,y) ((dot(x,y))/(length(x)*length(y))), data.wtmf_t, data.wtmf_h);
wtmf_manhattan_sim = rowfun(@(x,y) (sum(abs(x-y))), data.wtmf_t, data.wtmf_h);%vector subtraction is automatically stepwise
wtmf_euclidian_sim = rowfun(@(x,y) (sqrt(sum((x-y).^2))), data.wtmf_t, data.wtmf_h);
wtmf_pearson_cor = rowfun(@(x,y) (corr(x',y', 'type', 'Pearson')), data.wtmf_t, data.wtmf_h);
wtmf_spearman_cor = rowfun(@(x,y) (corr(x',y', 'type', 'Spearman')), data.wtmf_t, data.wtmf_h);
wtmf_kendall_cor = rowfun(@(x,y) (corr(x',y', 'type', 'Kendall')), data.wtmf_t, data.wtmf_h);


%% ------------- finalize -------------

features = table(numUniqueWordsA,numUniqueWordsB,sizeDiffA,sizeDiffB,sizeUnion,sizeIntersect,normDiffA,normDiffB,...
    sizeDiffNounA, sizeDiffNounB, sizeDiffVerbA, sizeDiffVerbB, sizeDiffAdjA, sizeDiffAdjB, sizeDiffAdvA, sizeDiffAdvB,...
    jaccard,dice,overlapA,overlapB,cosine_sim, manhattan_sim, euclidian_sim, pearson_cor, spearman_cor, kendall_cor,...
    wtmf_cosine_sim, wtmf_manhattan_sim, wtmf_euclidian_sim, wtmf_pearson_cor, wtmf_spearman_cor, wtmf_kendall_cor);
    
features.Properties.VariableNames = {...
    'numUniqueWordsA','numUniqueWordsB','sizeDiffA','sizeDiffB','sizeUnion','sizeIntersect','normDiffA','normDiffB',...
    'sizeDiffNounA', 'sizeDiffNounB', 'sizeDiffVerbA', 'sizeDiffVerbB', 'sizeDiffAdjA', 'sizeDiffAdjB', 'sizeDiffAdvA', 'sizeDiffAdvB',...
    'jaccard','dice','overlapA','overlapB','cosine','manhattan','euclidian','pearson','spearman','kendall',...
    'wtmf_cosine','wtmf_manhattan','wtmf_euclidian','wtmf_pearson','wtmf_spearman','wtmf_kendall',...
     };
