#author: Joost Doornkamp
import csv
import codecs
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
from nltk.tokenize import word_tokenize
from nltk.stem.snowball import SnowballStemmer
from OpenDutchWordnet.wn_grid_parser import *

DEBUG = True #Using a windows terminal? Run "CHCP 65001" before this script to enable Unicode Character being printed to the terminal.

filename = 'RTE3_dev_Dutch_sentences.csv'

reader = csv.reader(codecs.open(filename, "r", "utf-8"),delimiter='\t')
writer = csv.writer(codecs.open('output.csv','w', "utf-8"),delimiter='\t')
stemmer = SnowballStemmer("dutch")

path = "OpenDutchWordnet/resources/odwn/odwn_orbn_gwg-LMF_1.3.xml.gz"
odwn = Wn_grid_parser(path_wn_grid_lmf=path)

#NB: No contractions
#NB2: order of lemmatization/synonym replacement is inverted

syn_cache = dict()#acceleration of synonym searching

for line in reader:
    #--- synonyms replacement ---#
    text = word_tokenize(line[0])
    hyp = word_tokenize(line[1])
    new_text = []
    for word in text:
        #--- Construct list of synonyms ---#
        if word in syn_cache:
            syns = syn_cache[word]
        else:
            syn_ids = set()
            for lem in odwn.lemma_get_generator(word):
                syn_id = lem.get_synset_id()
                if syn_id != None: syn_ids.add(syn_id)
            synles = [odwn.les_all_les_of_one_synset(syn_id) for syn_id in syn_ids]
            syns = [le.get_lemma() for le in synles for le in le]
            syn_cache[word] = syns
        #--- Look for synonyms in hypothesis ---#
        success = False
        for h_word in hyp:
            if h_word in syns and word != h_word:
                if DEBUG: print('Found synonym: ' + word + ' => ' + h_word)
                new_text.append(h_word)#insert the synonym
                success = True
                break
        if not success:
            new_text.append(word)
    #new_text is now normalized tokenized string
    #--- Lemmatization ---#
    lemmatized = []
    for word in new_text:
        lem = stemmer.stem(word)
        lemmatized.append(lem)
        if lem != word and DEBUG:
            print('Lemmatized: ' + word + ' => ' + lem)
    new_text = lemmatized #replace with lemmatized line
    lemmatized = []
    for word in hyp:
        lem = stemmer.stem(word)
        lemmatized.append(lem)
        if lem != word and DEBUG:
            print('Lemmatized: ' + word + ' => ' + lem)
    new_hyp = lemmatized 
    
    writer.writerow([' '.join(new_text),' '.join(new_hyp)])