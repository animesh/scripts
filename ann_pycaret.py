#!mamba create -n pycaret -c rapidsai-nightly -c nvidia -c conda-forge cuml=22.08 python=3.8 cudatoolkit=11.5
#!mamba activate pycaret
#!pip install --pre pycaret
#!mamba activate pycaret
from pycaret.datasets import get_data
data = get_data('juice')
from pycaret.classification import *
s = setup(data, target = 'Purchase')
best = compare_models()
plot_model(best)
evaluate_model(best)
from pycaret.classification import ClassificationExperiment
exp1 = ClassificationExperiment()
exp1.setup(data, target = 'Purchase')
dir(exp1)
exp1.compare_models()
