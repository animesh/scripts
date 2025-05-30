#python diffExprRank.py "L:\promec\TIMSTOF\LARS\2025\250428_Kamilla\new lysis\intensityreport.oxM.acetN.report.unique_genes_matrix.tsv_comb.sum.xlsx.met.acet.dataSelLog2Ratio.tsv" <key> 
#https://string-db.org/cgi/help?subpage=api%23valuesranks-enrichment-api
#https://version-12-0.string-db.org/api/json/get_api_key 
import requests ## python -m pip install requests
import json
import sys
string_api_url = "https://version-12-0.string-db.org/api"
output_format = "json"
method = "valuesranks_enrichment_submit"
request_url = "/".join([string_api_url, output_format, method])
input_file_path = sys.argv[1]
#input_file_path = "L:\\promec\\TIMSTOF\\LARS\\2025\\250428_Kamilla\\new lysis\\intensityreport.oxM.acetN.report.unique_genes_matrix.tsv_comb.sum.xlsx.met.acet.dataSelLog2Ratio.tsv"
identifiers = open(input_file_path).read()
params = {
    "species": 9606, 
    "caller_identity": "www.awesome_app.org",
    "identifiers": identifiers,
    "api_key": sys.argv[2],
    "ge_fdr": 0.05,
    "ge_enrichment_rank_direction": -1
}
response = requests.post(request_url, data=params)
data = json.loads(response.text)[0]
if 'status' in data and data['status'] == 'error':
    print("Status:", data['status'])
    print("Message:", data['message'])
else:
    job_id = data["job_id"]
    print("https://version-12-0.string-db.org/api/json/valuesranks_enrichment_status?api_key="+sys.argv[2]+"&job_id="+job_id)
