import os
import csv
import string
import codecs


def read_files(fdata,fkeywords,fwhiteListCodes,fwhiteListApps):
    data, keywords= [],[]
    with codecs.open(fdata,"r","latin-1") as f:
        data = [i.rsplit("\n")[0] for i in f]
        data = [i.rsplit("\t") for i in data if len(i.rsplit("\t")) > 3]
        data = [[i[0].lower(),i[1].lower(), i[2],i[3]]for i in data]
    '''with codecs.open(fdata) as csvfile:
        csvdata = csv.reader(csvfile,delimiter='\t')
            #for i in csvdata:
                #data = [unicode(s, "utf-8") for s in i]
        data = [[i[0].lower(),i[1].lower(), i[2], i[3] ] for i in list(csvdata)]'''
    with codecs.open(fkeywords) as csvfile:
        csvdata = csv.reader(csvfile,quotechar='\n')
        keywords = [ i[0].lower() for i in list(csvdata)]
    with codecs.open(fwhiteListCodes) as csvfile:
        csvdata = csv.reader(csvfile,quotechar='\n')
        whiteListCodes = [ i[0].lower() for i in list(csvdata)]
    with codecs.open(fwhiteListApps) as csvfile:
        csvdata = csv.reader(csvfile,quotechar='\n')
        whiteListApps = [ i[0].lower() for i in list(csvdata)]
    return (data,keywords,whiteListCodes,whiteListApps)
        

def filter_keywords(reviews, keywords):
    potential = []
    for i in reviews:
        Promo = False
        for k in keywords:
            if k in i[0] or k in i[1]:
                Promo = True
        if Promo:
            potential.append(i)
                 
    return potential