# Translated-RTE

In this repository you can find all the code that I made for my bachelor's project on translated RTE, in which I recreated the ECNU system for Recognizing Textual Entailment (RTE) for English and made a version for Dutch to compare the system. For more information on this research, please see my thesis: (link will be added later when the library of the Rijksuniversiteit Groningen has approved its publication).

Please note that the code released here was never developed for public release, so there will be flaws and things may be confusing. There is a lack of proper commenting, however I will try to explain the process and how every part works as much as possible here. If you would like to use this code but have questions, feel free to contact me at [j.doornkamp@student.rug.nl]. 

Here's an index of all the files in this repository and a short description:
 - contractions_list.csv: simple csv-structured list of the contraction used by the English preprocessing script. The first column features the contraction, the second column the words the map to. The preprocessing script simply replaced any instance in the first column by the corresponding entry in the second column.
 - preprocessing_eng.py: the script that performs all steps of preprocessing for the English data set. Runs on python 3, and requires the nltk module (http://www.nltk.org/) to be installed. Also requires contractions_list.csv to be in the same folder.
 - preprocessing_dut.py: as preprocessing_eng.py, but for Dutch. As Dutch does not have contractions, it does not need a list of contractions. However, it does require OpenDutchWordnet, which can be cloned from https://github.com/MartenPostma/OpenDutchWordnet.
 - SVMclassification.m: the main MATLAB script that extracts features, trains an SVM and predicts data on the training set. All MATLAB scripts were run in MATLAB R2016a. It requires the data sets to be in MATLAB's current working directory.
 - makeData.m: MATLAB function that loads all data and converts into a table that extractFeatures.m can use. Note that the ORMF representations of sentences used were calculated using an external script, these are also loaded in by makeData.m. Thus the function requires those representations to be in a subfolder in the working directory named WTMF. This will be discussed in more detail below.
 - extractFeatures.m: the MATLAB script that computes all the features, following the guidelines of the ECNU system. So far features can be extracted independent of language. However, if you are going to add features that use resources like corpora or WordNet, you will have to distinguish between the language you are analysing!
 - tfIdf.m/wordCounts.m/countMap.m: A group of functions used to compute the tf*idf representations of sentences.
 - rowfun.m: to compute features for all sentence pairs in the data set, extractFeatures.m uses the MATLAB function `cellfun` a lot. However, we couldn't get a similar method to work for the table that held the ORMF representations of the sentences to work, so rowfun.m was created as a simple helper function to do extactly what cellfun does for those tables.

Sadly the data set used can't be published right now as I do not have the rights. You may use the code below for other projects but the filenames from the data set are often hardcoded into the scripts so you will adapt those yourself. If you would like to continue my research you can contact me and I will check with the owner of the data set whether it can be shared.

Below I will go over all the parts of developing the systems and which files, resources and other materials are needed.


### Preprocessing

The preprocessing phase consists of three phases: contraction removal, stemming (lemmatisation) and synonym replacement. As Dutch does not have contractions, contraction removal is not a phase for the Dutch system. Preprocessing is done by two scripts - preprocessing_eng.py and preprocessing_dut.py for English and Dutch data, resp. - and requires for contractions_list.csv to be in the same folder. Both English and Dutch scripts also require the nltk module (http://www.nltk.org/) to be installed and the Dutch script requires OpenDutchWordnet (https://github.com/MartenPostma/OpenDutchWordnet) to be cloned to the same folder.

Most of the code for this project uses filenames hardcoded into the scripts when loading in from external files such as the data set or contractions_list.csv. The filenames can often be found at the top of the code and can be customized there. For example, both the English and Dutch preprocessing scripts feature a global variable `filename` at the top of the code, which determines which file is being processed. Similarly the output file is also hardcoded; in this case the processed file is always printed to a file named output.csv.

The English version of the script does contraction removal and stemming at the same time, followed by synonym replaced. It does this for each sentence pair (so all three steps for each sentence pair before moving to the next pair, rather than doing contraction removal and stemming first for all sentence pairs and then going over them again).

Contraction removal is done by using the contractions in contractions_list.csv as a simple look-up table: if the word is in the first column of the table, replace it with the corresponding entry in the second column. Lemmatisation is then done using SnowballStemmer from the nltk module. Synonym normalization is done by looking at each word in the first sentence (the text) and generating its synset using WordNet. After that it is checked whether any of the words in the second sentence (the hypothesis) occur in this synset, and if so, replace the word in the text with the synonym from the hypothesis.

For the Dutch script the order of synonym normalisation and stemming has been inverted. This is because while WordNet can find synonyms using stemmed words, Open Dutch Wordnet can not. The approach for both steps stayed the same.


### RTE System

The ECNU system was recreated using MATLAB. All the *.m files in this repository were used in MATLAB R2016a. The SVM-classification was done using [`fitcsvm`](http://nl.mathworks.com/help/stats/fitcsvm.html), a MATLAB built-in function since R2014a, so the code will likely be backwards compatible with those versions, but this has not been tested!

SVMclassification.m is the main script of the RTE system. As before the name of the files it loads are defined in the script itself, though this time you need only define the language you would like to test - the script will generate the corresponding file names itself.

The script uses the function `makeData` from makeData.m to load in the data set to a table that is used by `extractFeatures`. Most of this is just the loading in of a csv file, but the ORMF representation of sentences had to be generated using code by the developers of the method: Weiwei Guo, Wei Liu and Mona Diab. You can read more about their method in [their paper](http://www.aclweb.org/anthology/C/C14/C14-1047.pdf).

The code was downloaded from [http://www.cs.columbia.edu/~weiwei/code.html]. It runs in Perl and uses MATLAB, the download includes a readme that exlains how it is run. After running this code the representations it generated were saved in CSV-files which makeData.m loads in seperately.

A similar method was applied to POS-tags. The ECNU system uses POS-tags in the second half of the length features. We used external programs to generate POS-tagged versions of the sentences, and loaded those in seperately in makeData.m. For the English data we used [Stanford POS tagger](http://nlp.stanford.edu/software/tagger.shtml), for the Dutch data we used [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/).

After `makeData` has combined all these data, it is passed to `extractFeatures`. This is the real powerful function which turns all the data into the features defined by the ECNU system. The names of the features correspond with those used in my thesis, where you can find more explanation on them, and often comments will also indicate which computation is which feature. The code uses the MATLAB function [`cellfun`](http://nl.mathworks.com/help/matlab/ref/cellfun.html) a lot to remove loops and fit most computations on one line.

For the second half of the Surface Text Similarity features (ST), the tf\*idf representations of the sentences is used. To compute these, the functions `countMap`, `tfIdf` and `wordCounts` are used. `countMap` constructs a map of how much each word occurs in the data set, using `wordCounts` to count how much each word occurs in each sentence. `tfIdf` uses the _countMap_ to compute the tf*idf representations.

`extractFeatures` is used for the training set of the set language first, then the SVM is trained, it is then used again on the test set, and those features are used to predict the entailment relation of the test set. SVMclassification.m also prints the accuracy of the predictions, and produces the predicitions as a single-column CSV-file headed by 3 numbers: the number of hits (predictions the same as human-annotated value), the total number of predictions (total data set size) and the accuracy as a percentage.
