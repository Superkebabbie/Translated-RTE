function map = countMap(corpus)
%data=cellarray

map = containers.Map();
for document = 1:size(corpus,1)
   wordCount = wordCounts(regexp(corpus{document}, '[A-z]*', 'match'));
   for wordIdx = 1:size(wordCount,1)
       word = wordCount{wordIdx,1};
       if map.isKey(word)
          cnts = map(word);
          cnts(document) = wordCount{wordIdx,2};
          map(word) = cnts;
       else
          map(word) = [zeros(1,document-1),wordCount{wordIdx,2}];%Init new key
       end
   end
end

%fill all arrays to width
keys = map.keys;
width = size(corpus,1);
for idx = 1:length(keys)
    k = keys{idx};
    map(k) = [map(k), zeros(1,width-length(map(k)))];
end