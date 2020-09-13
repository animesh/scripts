#https://www.kaggle.com/artgor/openvaccine-eda-feature-engineering-and-modelling
from pathlib import Path
pathFiles = Path('C:/Users/animeshs/stanford-covid-vaccine')
testFile=pathFiles/'test.json'
trainFile=pathFiles/'train.json'
imgList=list(pathFiles.rglob("npy"))

import pandas as pd
#train
dfTrain=pd.read_json(trainFile,lines=True)
train_data = []
dfTrain.columns.get_loc("mol_id")
dfTrain.loc[dfTrain['id'] == "mol_id"]
for mol_id in dfTrain['id'].unique():
    sample_data = dfTrain.loc[dfTrain['id'] == mol_id]
    for i in range(68):
        sample_tuple = (sample_data['id'].values[0], sample_data['sequence'].values[0][i],
                        sample_data['structure'].values[0][i], sample_data['predicted_loop_type'].values[0][i],
                        sample_data['reactivity'].values[0][i], sample_data['reactivity_error'].values[0][i],
                        sample_data['deg_Mg_pH10'].values[0][i], sample_data['deg_error_Mg_pH10'].values[0][i],
                        sample_data['deg_pH10'].values[0][i], sample_data['deg_error_pH10'].values[0][i],
                        sample_data['deg_Mg_50C'].values[0][i], sample_data['deg_error_Mg_50C'].values[0][i],
                        sample_data['deg_50C'].values[0][i], sample_data['deg_error_50C'].values[0][i])
        train_data.append(sample_tuple)
trainCSV=pathFiles/'train_data.csv'
train_data = pd.DataFrame(train_data, columns=['id', 'sequence', 'structure', 'predicted_loop_type', 'reactivity', 'reactivity_error', 'deg_Mg_pH10', 'deg_error_Mg_pH10','deg_pH10', 'deg_error_pH10', 'deg_Mg_50C', 'deg_error_Mg_50C', 'deg_50C', 'deg_error_50C'])
train_data.head()
train_data.to_csv(trainCSV, index = None)
#test
dfTest=pd.read_json(testFile,lines=True)
test_data = []
dfTest.loc[dfTest['id'] == "mol_id"]
for mol_id in dfTest['id'].unique():
    sample_data = dfTest.loc[dfTest['id'] == mol_id]
    for i in range(68):
        sample_tuple = (sample_data['id'].values[0], sample_data['sequence'].values[0][i],
                        sample_data['structure'].values[0][i], sample_data['predicted_loop_type'].values[0][i],
                        sample_data['reactivity'].values[0][i], sample_data['reactivity_error'].values[0][i],
                        sample_data['deg_Mg_pH10'].values[0][i], sample_data['deg_error_Mg_pH10'].values[0][i],
                        sample_data['deg_pH10'].values[0][i], sample_data['deg_error_pH10'].values[0][i],
                        sample_data['deg_Mg_50C'].values[0][i], sample_data['deg_error_Mg_50C'].values[0][i],
                        sample_data['deg_50C'].values[0][i], sample_data['deg_error_50C'].values[0][i])
        test_data.append(sample_tuple)
testCSV=pathFiles/'test_data.csv'
test_data = pd.DataFrame(test_data, columns=['id', 'sequence', 'structure', 'predicted_loop_type', 'reactivity', 'reactivity_error', 'deg_Mg_pH10', 'deg_error_Mg_pH10','deg_pH10', 'deg_error_pH10', 'deg_Mg_50C', 'deg_error_Mg_50C', 'deg_50C', 'deg_error_50C'])
test_data.head()
test_data.to_csv(testCSV, index = None)
