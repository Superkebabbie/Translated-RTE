function [wordCounts] = wordCounts(words)
%extracts word-count pairs for each word in a sentence
%words=cell-array

[word,~,wordIdx] = unique(words);
count = hist(wordIdx,1:length(word));

wordCounts = [word', num2cell(count')];