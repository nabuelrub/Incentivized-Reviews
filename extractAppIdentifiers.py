

#!/usr/bin/env python
# -- coding: utf-8 --
import sys,os
import codecs
import unicodedata
from langdetect import detect
import re
import spacy, spacy.en
import csv
from nltk.corpus import words
import nltk 
import enchant 
import numpy as np

d = enchant.Dict("en_US")

def GenerateAppIdentifiers(Revs):
	App = []
	arr = []
	AllApps = []
    
	'''SpecificApps = []
	for i in Revs:
	    SpecificApps.append(i[3])
	SpecificApps = list(set(SpecificApps))
	#print "length",len(SpecificApps),SpecificApps[0]'''
	f =  codecs.open("Identifiers.csv", "r",encoding = "latin-1") 
	AllApps = [line.rsplit("\n")[0] for line in f]
	f.close()
	for i in AllApps:
		j = i.rsplit("\t")
		if len(j) > 1 : #and j[1] in SpecificApps:
			arr.append([j[1],j[0]])
	#print len(arr)

	for lines in arr:
		line = lines[1]
		ID = lines[0]

		if (len(line) < 5):
			continue
		try:
			if detect(line) == 'en':
				p =0
		except:
			continue

		name = line
		if len(name) > 5 and name.lower() not in words.words():
			App.append([name,ID])
		spaces  =name.rsplit(" ")
		if len(spaces[0]) > 5 and spaces[0].lower() not in words.words():
			App.append([spaces[0],ID])
		if len(spaces) > 1:
			if len(spaces[0]+spaces[1] ) > 5 and (spaces[0]+spaces[1]).lower() not in words.words():
				App.append([spaces[0]+" "+ spaces[1],ID])
				App.append([spaces[0]+ spaces[1],ID])
		if len(spaces) > 2:
			if len(spaces[0]+spaces[1]+spaces[2]) > 5 and (spaces[0]+spaces[1]+spaces[2]).lower() not in words.words():
				App.append([spaces[0]+" "+ spaces[1]+" "+ spaces[2],ID])
				App.append([spaces[0]+ spaces[1]+ spaces[2],ID])

		s = name.rsplit(":")
		if len(s) > 1 and len(s[0]) > 4 and s[0].lower() not in words.words():
			App.append([s[0],ID])
		s = name.rsplit("-")
		if len(s) > 1  and len(s[0]) > 4 and s[0].lower() not in words.words():
			App.append([s[0],ID])
		s = name.rsplit("_")
		if len(s) > 1  and len(s[0]) > 4 and s[0].lower() not in words.words():
			App.append([s[0],ID])	
		s = name.rsplit("(")
		if len(s) > 1  and len(s[0]) > 4 and s[0].lower() not in words.words() :
			App.append([s[0],ID])	
		s = name.rsplit("\\")
		if len(s) > 1  and len(s[0]) > 4 and s[0].lower() not in words.words():
			App.append([s[0],ID])		

		name =  re.sub("[:(\)-]"," ",name)
		name = " ".join(name.split())
		if len(name) > 5 and name.lower() not in words.words():
			App.append([name,ID])


	App = filter(lambda a: a[0] != "NULL", App)
	App = filter(lambda a: a[0] != " ", App)
	App = filter(lambda a: a[0] != '', App)
	App = filter(lambda a: not(d.check(a[0])) , App)



	b_set = set(tuple(x) for x in App)
	App = [ list(x) for x in b_set ]
	print len(App)
	f = codecs.open("GeneratedIdentifiers.txt","w",encoding="utf-8")
	for i in App:
		f.write(i[0]+"\t"+i[1]+"\n")
	f.close()
	return App



def findpattern(Apps, Revs):

	App = []
	for i in Revs:
	    App.append(i[3])
	App = list(set(App))
	#print "Len App",len(App)
	dic = {}
	for i, j in enumerate(App):
	    dic[j] = i
	NumApp = len(App)
	for i in range(0,len(Revs)):
	    for j in range(0, len(Revs[i])):
	        if Revs[i][j] == "NULL":
	            Revs[i][j] = ""

	# <codecell>

	result1 =codecs.open("dis1.txt","w","utf-8")
	pairs1 = np.zeros((NumApp,NumApp),dtype = np.int)
	resultApp =codecs.open("output.txt","w","utf-8")
	####################################################
	nlp = spacy.en.English()
	count = 0
	'''with codecs.open("sample.csv","r","latin-1") as f:
		arr = [i.rsplit("\n")[0] for i in f]
		arr = [i.rsplit("\t") for i in arr]'''
	c=0
	for rev in Revs:
		#print count
		count = count+1
		title = rev[0]
		body = rev[1]
		r = title+ u","+body
		#r = title + u" , " +body
		AppID = rev[3]
		words = []
		#print r,type(r)
		doc = nlp(r)
		for chunk in doc.noun_chunks:
		    #print "NNP" , chunk.orth_
		    words.append(chunk.orth_)
		for token in doc:
		    if token.tag_ == "NN" or token.tag_ == "NNS" or token.tag_ == "NNP" or token.tag_ == "NNPS":
		        #print "NN",token
		        words.append(token.orth_)

		for i , j in enumerate(words):
			j = j.lower()
			if j.endswith(' app'):
				words.append(j[:-4])
			if j.endswith(' game'):
				words.append(j[:-5])
			if j.startswith('the '):
				words.append(j[4:])	
				
		found1 = False
		found2 = False
		Ans = "NULL"
        
		for i in  words:

			for j in Apps:
				#if j[1] != AppID:
				#dist = distance(j[0],i.lower())
				if AppID.find(i) != -1:
					continue
				try:
					if j[0] == i.lower()   and not found1:
						result1.write(i+"\t"+title+"\t"+body+"\t"+j[1]+"\t"+AppID+"\n")
						# writing as [Source][Target] == from source to target
						pairs1[dic[j[1]],dic[AppID]]  = pairs1[dic[j[1]],dic[AppID]]+1
						found1 = True
						Ans = j[1]
						#print "Found",j[1],j[0],i
						c=c+1

				except Exception as e:
					#print "\error","  ",str(e)
					#print AppID,"    ",j[1]
					p =0
				if found1:
					break
			if found1 :
				break
		resultApp.write(rev[0]+"\t"+rev[1]+"\t"+rev[2]+"\t"+rev[3]+"\t"+rev[4]+"\t"+Ans+"\n")
	print 'total found',c
	resultApp.close()



def ExtractAppsNames(Rev,whiteListApps):

	App = GenerateAppIdentifiers(Rev)
	f = codecs.open("GeneratedIdentifiers.txt", "r",encoding = "utf-8")
	App = [line.rsplit("\n")[0] for line in f]
	f.close()
	print len(App)
	App = filter(lambda a: (a.rsplit("\t")[0]).lower() not in whiteListApps, App)
	AppsTmp = []
	for i in App:
		name = i.rsplit("\t")
		if not d.check(name[0].lower()):
			AppsTmp.append([name[0].lower(),name[1]])
	App = AppsTmp
	print len(App)
	print App[0]
	AppsTmp=[]
	for i in App:
		name = i[0]
		count = 0
		for j in App:
			if j[0] ==  name:
				count = count+1
		if count == 1:
			AppsTmp.append(i)
	App = AppsTmp
	print len(App)
	findpattern(App, Rev)

