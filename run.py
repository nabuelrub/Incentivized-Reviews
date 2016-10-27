#-*- coding: utf-8 -*-


import csv
import codecs
from preprocessing import *
from extractCodes import *
from extractAppIdentifiers import *
import os,sys
import numpy as np
from nltk.corpus import words
import re
import nltk


def main():
    data,keywords,whiteListCodes,whiteListApps = read_files('sample.csv','Keywords.csv','whiteListCodes.csv','whiteListApps.csv')
    print len(data),len(keywords),len(whiteListCodes),len(whiteListApps)
    data = filter_keywords(data, keywords)
    print "Number of Potential Promotional Reviews: ",len(data)
    #print keywords
    promoRev = ExtractCodes(data,whiteListCodes)
    f = codecs.open("extractcodes.txt",'w',encoding="utf-8")
    for i in promoRev:
        f.write(i[4]+"\t"+i[0]+"\t"+i[1]+"\t"+i[2]+"\t"+i[3]+"\n")
    f.close()
    print len(promoRev), promoRev[0]
    promoRev = ExtractAppsNames(promoRev,whiteListApps)
    
__author__ = "Noor Abuelrub"
__email__ = "nabuelrub@unm.edu"
__copyright__ = ""
__license__ = ""

if __name__ == '__main__':
    main()
        