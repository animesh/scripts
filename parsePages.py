#python parsePages.py C:\Users\animeshs\OneDrive\Desktop\pages <link to website> <what to search for in link-dev>
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("C:\\Users\\animeshs\\OneDrive\\Desktop\\pages\\")
#trainList=list(pathFiles.rglob("Page.260*.html"))
trainList=list(pathFiles.rglob("*.html"))
print(trainList,len(trainList))
import pandas as pd
#data=pd.read_html(trainList[0])#No tables found
from bs4 import BeautifulSoup as bs
#from re import compile, findall, IGNORECASE
#row_data_cell_re = compile(r'<td [\w="]+>([\w\s\.@:()\'-0-9]+)<\/td>')
quotes = {}
#html_parser = bs(open(trainList[260]), "html.parser")
#html_parser = bs(open('C:/Users/animeshs/OneDrive/Desktop/pages/Page.260.html'), "html.parser")
prefix=sys.argv[2]
suffix=sys.argv[3]
cnt=0
for fName in trainList:
    print(fName)
    html_parser = bs(open(fName,encoding="utf8"), "html.parser")
    links = html_parser.findAll('a',href=True)
    all_divs = []
    for ul in links:
        all_divs.extend(ul.findAll('div'))
    #print(all_divs[-12:])
    all_links = []
    for ul in links:
        if ul['href'].startswith(suffix):
            #print(ul['href'])
            all_links.append(prefix+ul['href'])
    #print(all_links)
    cntQ=0
    for text in all_divs[-len(all_links):]:
        #print(cntQ,text.get_text())
        cnt=cnt+1
        quotes[all_links[cntQ]+"#"+str(cntQ)+"#"+str(cnt)]=text.get_text()
        cntQ=cntQ+1
    print(len(all_links),cntQ,cnt)
print(len(quotes),cnt)
pd.DataFrame.from_dict(data=quotes, orient='index').to_csv(pathFiles/'quotes.csv', header=False)
