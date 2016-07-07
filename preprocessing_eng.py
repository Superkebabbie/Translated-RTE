#author: Joost Doornkamp
import csv
import codecs
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
from nltk.tokenize import word_tokenize
from nltk.stem.snowball import SnowballStemmer

DEBUG = True #Using a windows terminal? Run "CHCP 65001" before this script to enable Unicode Character being printed to the terminal.

filename = 'RTE3_test_English_sentences.csv'

reader = csv.reader(codecs.open(filename, "r", "utf-8"),delimiter='\t')
writer = csv.writer(codecs.open('output.csv','w', "utf-8"),delimiter='\t')
stemmer = SnowballStemmer("english")#change to "dutch" for Dutch version!

dictReader = csv.reader(codecs.open('contractions_list.csv', 'r', "mbcs"), delimiter='\t')
replacements = {}
for pair in dictReader:
    replacements[pair[0]] = pair[1]
    
for line in reader:
    #--- Contraction & Lemmatization ---#
    lemmapair = []
    for sentence in line:
        lemmatized = []
        words = word_tokenize(sentence)
        for word in words:
            if word in replacements:#found contraction, replace before lemmatizing
                replacement = str.split(replacements[word])#contractions become multiple words, resplit
                if DEBUG: print('Found contraction: ' + word + ' => ' + replacements[word])
                for subword in replacement:
                    lem = stemmer.stem(word)(subword)
                    lemmatized.append(lem)
                    if lem != word and DEBUG:
                        print('Lemmatized: ' + word + ' => ' + lem)
            else:#just lemmatize
                lem = stemmer.stem(word)
                lemmatized.append(lem)
                if lem != word and DEBUG:
                    print('Lemmatized: ' + word + ' => ' + lem)
        lemmapair.append(lemmatized)
    #--- synonyms replacement ---#
    finalpair = [[],' '.join(lemmapair[1])]#hypothesis is now finished  
    for word in lemmapair[0]:
        #--- Construct list of synonyms ---#
        syns = []
        for synset in wordnet.synsets(word):
            for lemma in synset.lemmas():
                syns.append(lemma.name())
        #print('Word: ' + word + ' => ' + ', '.join(syns))
        #--- Look for synonyms in hypothesis ---#
        success = False
        for h_word in lemmapair[1]:
            if h_word in syns and word != h_word:
                if DEBUG: print('Found synonym: ' + word + ' => ' + h_word)
                finalpair[0].append(h_word)#insert the synonym
                success = True
                break
        if not success:
            finalpair[0].append(word)
    finalpair[0] = ' '.join(finalpair[0])
    
    writer.writerow(finalpair)