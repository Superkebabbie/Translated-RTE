function [vec1, vec2] = tfIdf(text, hypothesis, senIdx, wordCounts)
    %text/hypothesis are sentences in the corpus, senIdx is index of text in wordCounts, 
    %wordCounts the map holding wordCounts in the entire corpus.
    
words1 = regexp(text, '[A-z]*', 'match');
words2 = regexp(hypothesis, '[A-z]*', 'match');
uniqueWords = unique([words1, words2]);

vec1 = zeros(1,length(uniqueWords));
vec2 = zeros(1,length(uniqueWords));

for idx = 1:length(uniqueWords)
   w = uniqueWords{idx};
   cnts = wordCounts(w);
   tf1 = cnts(senIdx);
   tf2 = cnts(senIdx+800);
   idf = log(length(cnts)/length(find(cnts>0)));
   vec1(idx) = tf1*idf;
   vec2(idx) = tf2*idf;
end