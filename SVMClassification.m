clear all;
language = 'Dutch'%'English'|'Dutch'
mode = 'len+st+ss'
trainDataName = strcat('RTE3_dev_', language);
testDataName = strcat('RTE3_test_', language);


%% -------------- TRAIN --------------------

data = makeData(trainDataName);
features = extractFeatures(data); 

trained = fitcsvm(features,data.entailment);

%% -------------- TEST ---------------------

data = makeData(testDataName);
features = extractFeatures(data);

Classified = predict(trained,features);

matches = 0;
for idx = 1:length(Classified)
    matches = matches + strcmp(Classified(idx),data.entailment(idx));
end

acc = matches/length(Classified)*100;
fprintf('Matched %d/%d entailment relations!\nAccuracy = %.2f%%\n',matches,length(Classified),acc);

%% ----------- WRITE RESULTS --------------
filename = strcat('RTE3_', mode, '_', language, '.txt');

file = fopen(filename,'w','n','UTF-8');
fprintf(file,'%d\t%d\t%.2f\n',matches,length(Classified),acc);%add performance info at top
for idx = 1:length(Classified)
    fprintf(file,'%s\n',Classified{idx});%add list of classifications
end

fclose(file);