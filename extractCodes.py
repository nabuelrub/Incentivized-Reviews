import re
from langdetect import detect,detect_langs
import enchant
d= enchant.Dict("en_US")



def AlphaNumeric(review,whiteList):
    Allwords = review.split(' ')
    regex = re.compile('\d')
    for word in Allwords:
        if (len(word)<4 or word in whiteList):
            continue
        match = re.findall(regex, word)
        if match:
            literals = re.sub(regex, "", word)
            literals2 = re.sub(regex, " ", word)
            #print literals2,len(literals2)
            literals2 =(literals2.strip()).rsplit(" ")
            meaningful = False
            literals2 = filter(lambda x : x <> '',literals2)
            for i in literals2:
                if len(i) > 1 and d.check(i):
                        meaningful = True
            if meaningful:
                continue
            #print literals2,len(literals2)           
            #if all( d.check(s) for s in literals2):
                #continue
            if len(literals)<1:
                continue
            if not(d.check(literals)) and not( any(s in literals.lower()  for s in whiteList)):      
                return word
    return False



def Alphabetic(w):
    
    patterns = []                  
    my_regex1 = r'\(\s*[a-zA-Z]{5,13}\s*\)'
    my_regex2 = r'\{\s*[a-zA-Z]{5,13}\s*\}'
    my_regex3 = r'-\s*[a-zA-Z]{5,13}\s*-'
    my_regex4 = r'\[\s*[a-zA-Z]{5,13}\s*\]'
    my_regex5 = r':\s*[a-zA-Z]{5,13}\s*'
    my_regex6 = r'"\s*[a-zA-Z]{5,13}\s*"'
    my_regex7 = r"'\s*[a-zA-Z]{5,13}\s*'"

    pattern1 = re.findall( my_regex1, w)
    pattern2 = re.findall( my_regex2, w)
    pattern3 = re.findall( my_regex3, w)
    pattern4 = re.findall( my_regex4, w)
    pattern5 = re.findall( my_regex5, w)
    pattern6 = re.findall( my_regex6, w)
    pattern7 = re.findall( my_regex7, w)
   
    patterns.extend(pattern1)
    patterns.extend(pattern2)
    patterns.extend(pattern3)
    patterns.extend(pattern4)
    patterns.extend(pattern5)
    patterns.extend(pattern6)
    patterns.extend(pattern7)
    
    for i in patterns:
        i = re.sub('[^a-zA-Z]', '', i)

        if len(i) > 4 and not(d.check(i)):
            return i
    return False

def ExtractCodes(reviews,whiteList):
    promoRev = []
    #iterate over review and look for codes
    for review in reviews:
        title = review[0]
        body = review[1]
        title = re.sub('[^a-zA-Z0-9\n\.]', ' ', title)
        body = re.sub('[^a-zA-Z0-9\n\.]', ' ', body)
        body = body.replace("."," ")
        title = title.replace("."," ")
        #flag variable
        code = False
        #skip
        if (title.find("error") != -1 or (body.lower()).find("error") != -1) :
            continue
        #skip
        if len(str(title+body) )< 4:
            continue
        #consider english words only
        if detect(title + body) != 'en':
            continue
        #look for Numeric codes
        regex = re.compile('\d{5,13}')
        match = re.findall(regex, body)
        if match and match[0].find("000") == -1:
            code = match[0]
        else:
            match = re.findall(regex, title)
            if match and match[0].find("000") == -1:
                code = match[0]
            else:
                ans = AlphaNumeric(body,whiteList)
                if ans:
                    code = ans
                else:
                    ans = AlphaNumeric(title,whiteList)
                    if ans:
                        code = ans
                    else:
                        ans = Alphabetic(review[0]+" "+review[1])
                        if ans:
                            code = ans
        if code: 
            promoRev.append([review[0],review[1],review[2],review[3],code])
    return promoRev