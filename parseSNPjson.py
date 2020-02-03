import requests
#response_html = requests.get("https://www.ncbi.nlm.nih.gov/snp/rs9387478")
print(response_html.text)
#response = requests.get("https://api.ncbi.nlm.nih.gov/variation/v0/beta/refsnp/9387478")
response = requests.get("https://api.ncbi.nlm.nih.gov/variation/v0/beta/refsnp/17879961") #CHEK2 missense
#https://www.ncbi.nlm.nih.gov/snp/rs1051730 CHRNA3 : Synonymous Variant
#https://www.ncbi.nlm.nih.gov/snp/rs11571833 BRCA2 : Stop Gained
#https://www.ncbi.nlm.nih.gov/snp/rs401681 CLPTM1L intron
#https://www.ncbi.nlm.nih.gov/snp/rs753955 LOC105370113%20:%20Intron%20Variant

import json
todos = json.loads(response.text)
todos['assembly_annotation']
import pathlib
pathlib.Path.cwd()
file = pathlib.Path("L:/promec/Animesh/HUNT/snpRS.txt")
print(file.read_text().split(' '))
