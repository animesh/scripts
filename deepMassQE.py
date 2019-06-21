#git clone https://github.com/animesh/deepmass
#cd deepmass/prism/
#DATA_DIR="./data"
#cat $DATA_DIR/input_table.csv
#ModifiedSequence,Charge,Fragmentation,MassAnalyzer
#AKM(ox)LIVR,3,HCD,ITMS
#ILFWYK,2,CID,FTMS

#python preprocess.py   --input_data="${DATA_DIR}/input_table.csv"   --output_data_dir="${DATA_DIR}"   --sequence_col="ModifiedSequence"   --charge_col="Charge"   --fragmentation_col="Fragmentation"   --analyzer_col="MassAnalyzer"
#gcloud ai-platform predict     --model deepmass_prism     --project deepmass-204419     --format json     --json-instances "${DATA_DIR}/input.json" > "${DATA_DIR}/prediction.results"
#python postprocess.py     --metadata_file="${DATA_DIR}/metadata.csv"     --input_data_pattern="${DATA_DIR}/prediction.results*"     --output_data_dir="${DATA_DIR}"     --batch_prediction=False
#https://www.tensorflow.org/tutorials/eager/custom_training_walkthrough
import tensorflow as tf
tf.enable_eager_execution()

print("TensorFlow version: {}".format(tf.__version__))
print("Eager execution: {}".format(tf.executing_eagerly()))

from tensorflow import app
from __future__ import absolute_import, division, print_function
import os
import matplotlib.pyplot as plt

train_dataset_url = "https://storage.googleapis.com/download.tensorflow.org/data/iris_training.csv"
train_dataset_fp = tf.keras.utils.get_file(fname=os.path.basename(train_dataset_url), origin=train_dataset_url)
print("Local copy of the dataset file: {}".format(train_dataset_fp))
!head -n5 {train_dataset_fp}
#column_names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species']

feature_names = column_names[:-1]
label_name = column_names[-1]

print("Label: {}".format(label_name))

batch_size = 32
