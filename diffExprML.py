# %% setup
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
conda install -c conda-forge mamba pycaret xgboost catboost
mamba install -c rapidsai -c nvidia -c conda-forge cuml
ln -s /mnt/f/GD/OneDrive/Dokumenter/GitHub/scripts .
tail -f scripts/logs.log
# %% mm
import pandas as pd
data=pd.read_csv("/home/ash022/1d/Aida/ML/dataTmmS42T.csv")
dGroup="Class"
print(data.groupby(dGroup).count())
#mapping = {'MGUS':1,'MM':2,'Ml':3}
#mapping = {'MGUS':'G','MM':'M','Ml':'M'}
mapping = {'MGUS':'G','MM':'M','Ml':'L'}
#mapping = {'MGUS':'0000FF','MM':'FF0000','Ml':'00FF00'}
data=data.replace({dGroup: mapping})
#data=data[data["Group"] != -1]
print(data.groupby(dGroup).count())
train_labels = data[dGroup]
train_data = data.drop(columns=dGroup)
print ("Data for Modeling :" + str(train_data.shape))
# %% kNN
#https://towardsdatascience.com/elbow-method-is-not-sufficient-to-find-best-k-in-k-means-clustering-fc820da0631d
!pip install yellowbrick  

from sklearn import datasets
from sklearn.cluster import KMeans
from yellowbrick.cluster import KElbowVisualizer

# Load the IRIS dataset
iris = datasets.load_iris()
X = iris.data
y = iris.target

# Instantiate the clustering model and visualizer
km = KMeans(random_state=42)
visualizer = KElbowVisualizer(km, k=(2,10))
 
visualizer.fit(X)        # Fit the data to the visualizer
visualizer.show()        # Finalize and render the figure
from sklearn import datasets
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
from yellowbrick.cluster import SilhouetteVisualizer

# Load the IRIS dataset
iris = datasets.load_iris()
X = iris.data
y = iris.target
  
fig, ax = plt.subplots(3, 2, figsize=(15,8))
for i in [2, 3, 4, 5]:
    '''
    Create KMeans instances for different number of clusters
    '''
    km = KMeans(n_clusters=i, init='k-means++', n_init=10, max_iter=100, random_state=42)
    q, mod = divmod(i, 2)
    '''
    Create SilhouetteVisualizer instance with KMeans instance
    Fit the visualizer
    '''
    visualizer = SilhouetteVisualizer(km, colors='yellowbrick', ax=ax[q-1][mod])
    visualizer.fit(X) 
# %% hypothesize
#https://alcampopiano.github.io/hypothesize/function_guide/#pb2gen
#!pip install hypothesize
from hypothesize.utilities import create_example_data, trim_mean
from hypothesize.compare_groups_with_single_factor import pb2gen
df=create_example_data(2)
pb2gen(df.cell_1, df.cell_2, trim_mean, .2, alpha=.05, nboot=1000, seed=42)
# %% drift
#https://towardsdatascience.com/mlops-understanding-data-drift-69f9bf8a2e46
import numpy as np
def detect_drift(X_train, X_test):
    # Compute summary statistics for each feature in the training and test data
    train_mean = np.mean(X_train, axis=0)
    train_median = np.median(X_train, axis=0)
    train_variance = np.var(X_train, axis=0)
    train_missing = np.count_nonzero(np.isnan(X_train), axis=0)
    train_max = np.max(X_train, axis=0)
    train_min = np.min(X_train, axis=0)
    
    test_mean = np.mean(X_test, axis=0)
    test_median = np.median(X_test, axis=0)
    test_variance = np.var(X_test, axis=0)
    test_missing = np.count_nonzero(np.isnan(X_test), axis=0)
    test_max = np.max(X_test, axis=0)
    test_min = np.min(X_test, axis=0)
    
    # Compare the summary statistics between the training and test data
    if np.abs(train_mean - test_mean).sum() > 0.1:
        return True
    elif np.abs(train_median - test_median).sum() > 0.1:
        return True
    elif np.abs(train_variance - test_variance).sum() > 0.1:
        return True
    elif np.abs(train_missing - test_missing).sum() > 10:
        return True
    elif np.abs(train_max - test_max).sum() > 10:
        return True
    elif np.abs(train_min - test_min).sum() > 10:
        return True
    else:
        return False
import numpy as np
from scipy.stats import entropy

def jensen_shannon_divergence(p, q):
    # Compute the Jensen-Shannon divergence between two probability distributions
    m = (p + q) / 2
    return (entropy(p, m) + entropy(q, m)) / 2

def detect_drift(X_train, X_test):
    # Compute the Jensen-Shannon divergence between the feature distributions in the training and test data
    js_divergence = jensen_shannon_divergence(X_train, X_test)
    
    # Return True if the divergence is above a certain threshold
    if js_divergence > 0.2:
        return True
    else:
        return False
import numpy as np
from scipy.stats import ks_2samp
import matplotlib.pyplot as plt

def detect_drift(X_train, X_test):
    # Compute the p-value of the two-sample KS test between the feature distributions in the training and test data
    p_value = ks_2samp(X_train, X_test)
    
    # Return True if the p-value is below a certain threshold
    if p_value < 0.05:
        return True
    else:
        return False
    
# Plot the feature distributions in the training and test data
plt.hist(X_train, bins=20, alpha=0.5, label='Training data')
plt.hist(X_test, bins=20, alpha=0.5, label='Test data')
plt.legend(loc='upper right')
plt.show()
import numpy as np
from scipy.stats import wasserstein_distance

def detect_drift(X_train, X_test):
    # Compute the Wasserstein distance between the feature distributions in the training and test data
    wd = wasserstein_distance(X_train, X_test)
    
    # Return True if the distance is above a certain threshold
    if wd > 0.1:
        return True
    else:
        return False
import numpy as np
from scipy.stats import entropy

def kullback_leibler_divergence(p, q):
    # Compute the Kullback-Leibler divergence between two probability distributions
    return entropy(p, q)

def detect_drift(X_train, X_test):
    # Compute the Kullback-Leibler divergence between the feature distributions in the training and test data
    kl_divergence = kullback_leibler_divergence(X_train, X_test)
    
    # Return True if the divergence is above a certain threshold
    if kl_divergence > 0.1:
        return True
    else:
        return False
import numpy as np

def detect_drift(X_train, X_test):
    # Compute the mode, number of unique values, and number of missing values in the training and test data
    train_mode = X_train.mode()
    test_mode = X_test.mode()
    train_unique = X_train.nunique()
    test_unique = X_test.nunique()
    train_missing = X_train.isnull().sum()
    test_missing = X_test.isnull().sum()
    
    # Check if the mode or number of unique values has changed significantly between the training and test data
    if (train_mode != test_mode).any() or (train_unique != test_unique).any():
        return True
    # Check if the number of missing values has increased significantly between the training and test data
    elif (test_missing - train_missing) > 0.1 * X_train.size:
        return True
    else:
        return False
import numpy as np
from scipy.stats import chi2_contingency

def detect_drift(X_train, X_test):
    # Compute the Chi Squared statistic and p-value of the test using the training and test data
    _, p_value, _, _ = chi2_contingency(np.array([X_train, X_test]))
    
    # Return True if the p-value is below a certain threshold
    if p_value < 0.05:
        return True
    else:
        return False
import numpy as np
from scipy.stats import chi2_contingency

def detect_drift(X_train, X_test):
    # Compute the Chi Squared statistic and p-value of the test using the training and test data
    p_value = chi2_contingency(np.array([X_train, X_test]))
    
    # Return True if the p-value is below a certain threshold
    if p_value < 0.05:
        return True
    else:
        return False
import numpy as np
from scipy.stats import fisher_exact

def detect_drift(X_train, X_test):
    # Compute the p-value of the Fisher Exact Test using the training and test data
    p_value = fisher_exact(np.array([X_train, X_test]))
    
    # Return True if the p-value is below a certain threshold
    if p_value < 0.05:
        return True
    else:
        return False
import numpy as np
from scipy.stats import chi2_contingency, fisher_exact, wasserstein_distance
from scipy.spatial.distance import jensenshannon

class MonitorDrift:
    def __init__(self, data):
        self.data = data
        
    def feature_drift_fisher(self, feature):
        # Compute the p-value of the Fisher Exact Test for the specified feature
        _, p_value = fisher_exact(np.array([self.data[feature], self.data[feature]]))
        return p_value
    
    def feature_drift_chi2(self, feature):
        # Compute the Chi Squared statistic and p-value of the two-way Chi Squared test for the specified feature
        _, p_value, _, _ = chi2_contingency(np.array([self.data[feature], self.data[feature]]))
        return p_value
    
    def feature_drift_chi2_one_way(self, feature):
        # Compute the Chi Squared statistic and p-value of the one-way Chi Squared test for the specified feature
        _, p_value, _, _ = chi2_contingency(np.array([self.data[feature], self.data[feature]]), lambda_="log-likelihood")
        return p_value
    
    def feature_drift_jensen_shannon(self, feature):
        # Compute the Jensen Shannon distance between the training and test data for the specified feature
        distance = jensenshannon(self.data[feature], self.data[feature])
        return distance
    
    def feature_drift_wasserstein(self, feature):
        # Compute the Wasserstein distance between the training and test data for the specified feature
        distance = wasserstein_distance(self.data[feature], self.data[feature])
        return distance
# %% label-drift
from pagehinkley import PageHinkley

class MonitorLabelDrift:
    def __init__(self, threshold=0.1):
        # Initialize the Page-Hinkley test with the specified threshold
        self.test = PageHinkley(threshold=threshold)
        
    def update(self, label):
        # Update the test with the new label
        self.test.update(label)
        
    def detected_drift(self):
        # Return True if the test has detected a change, False otherwise
        return self.test.detected_change()
# Create a monitor for label drift                     
monitor = MonitorLabelDrift()

# Update the monitor with a series of labels
labels = [1, 1, 1, 0, 1, 1, 0, 0, 0, 1]
for label in labels:
    monitor.update(label)
    
    # Check if label drift has been detected
    if monitor.detected_drift():
        print("Label drift detected!")
        break
# %% pred-drift
from pagehinkley import PageHinkley

class MonitorOutputDrift:
    def __init__(self, threshold=0.1):
        # Initialize the Page-Hinkley test with the specified threshold
        self.test = PageHinkley(threshold=threshold)
        
    def update(self, y_true, y_pred):
        # Calculate the accuracy of the model's predictions
        accuracy = accuracy_score(y_true, y_pred)
        
        # Update the test with the accuracy
        self.test.update(accuracy)
        
    def detected_drift(self):
        # Return True if the test has detected a change, False otherwise
        return self.test.detected_change()


      
# Create a monitor for output drift
monitor = MonitorOutputDrift()

# Loop through a series of predictions and update the monitor
for i in range(100):
    # Generate some fake predictions
    y_true = np.random.randint(0, 2, size=100)
    y_pred = np.random.randint(0, 2, size=100)
    
    # Update the monitor
    monitor.update(y_true, y_pred)
    
    # Check if output drift has been detected
    if monitor.detected_drift():
        print("Output drift detected!")
        break
# %% printarr
#https://gist.github.com/nmwsharp/54d04af87872a4988809f128e1a1d233
def printarr(*arrs, float_width=6):
    """
    Print a pretty table giving name, shape, dtype, type, and content information for input tensors or scalars.
    Call like: printarr(my_arr, some_other_arr, maybe_a_scalar). Accepts a variable number of arguments.
    Inputs can be:
        - Numpy tensor arrays
        - Pytorch tensor arrays
        - Jax tensor arrays
        - Python ints / floats
        - None
    It may also work with other array-like types, but they have not been tested.
    Use the `float_width` option specify the precision to which floating point types are printed.
    Author: Nicholas Sharp (nmwsharp.com)
    Canonical source: https://gist.github.com/nmwsharp/54d04af87872a4988809f128e1a1d233
    License: This snippet may be used under an MIT license, and it is also released into the public domain. 
             Please retain this docstring as a reference.
    """
    
    frame = inspect.currentframe().f_back
    default_name = "[temporary]"

    ## helpers to gather data about each array
    def name_from_outer_scope(a):
        if a is None:
            return '[None]'
        name = default_name
        for k, v in frame.f_locals.items():
            if v is a:
                name = k
                break
        return name
    def dtype_str(a):
        if a is None:
            return 'None'
        if isinstance(a, int):
            return 'int'
        if isinstance(a, float):
            return 'float'
        return str(a.dtype)
    def shape_str(a):
        if a is None:
            return 'N/A'
        if isinstance(a, int):
            return 'scalar'
        if isinstance(a, float):
            return 'scalar'
        return str(list(a.shape))
    def type_str(a):
        return str(type(a))[8:-2] # TODO this is is weird... what's the better way?
    def device_str(a):
        if hasattr(a, 'device'):
            device_str = str(a.device)
            if len(device_str) < 10:
                # heuristic: jax returns some goofy long string we don't want, ignore it
                return device_str
        return ""
    def format_float(x):
        return f"{x:{float_width}g}"
    def minmaxmean_str(a):
        if a is None:
            return ('N/A', 'N/A', 'N/A')
        if isinstance(a, int) or isinstance(a, float): 
            return (format_float(a), format_float(a), format_float(a))

        # compute min/max/mean. if anything goes wrong, just print 'N/A'
        min_str = "N/A"
        try: min_str = format_float(a.min())
        except: pass
        max_str = "N/A"
        try: max_str = format_float(a.max())
        except: pass
        mean_str = "N/A"
        try: mean_str = format_float(a.mean())
        except: pass

        return (min_str, max_str, mean_str)

    try:

        props = ['name', 'dtype', 'shape', 'type', 'device', 'min', 'max', 'mean']

        # precompute all of the properties for each input
        str_props = []
        for a in arrs:
            minmaxmean = minmaxmean_str(a)
            str_props.append({
                'name' : name_from_outer_scope(a),
                'dtype' : dtype_str(a),
                'shape' : shape_str(a),
                'type' : type_str(a),
                'device' : device_str(a),
                'min' : minmaxmean[0],
                'max' : minmaxmean[1],
                'mean' : minmaxmean[2],
            })

        # for each property, compute its length
        maxlen = {}
        for p in props: maxlen[p] = 0
        for sp in str_props:
            for p in props:
                maxlen[p] = max(maxlen[p], len(sp[p]))

        # if any property got all empty strings, don't bother printing it, remove if from the list
        props = [p for p in props if maxlen[p] > 0]

        # print a header
        header_str = ""
        for p in props:
            prefix =  "" if p == 'name' else " | "
            fmt_key = ">" if p == 'name' else "<"
            header_str += f"{prefix}{p:{fmt_key}{maxlen[p]}}"
        print(header_str)
        print("-"*len(header_str))
            
        # now print the acual arrays
        for strp in str_props:
            for p in props:
                prefix =  "" if p == 'name' else " | "
                fmt_key = ">" if p == 'name' else "<"
                print(f"{prefix}{strp[p]:{fmt_key}{maxlen[p]}}", end='')
            print("")

    finally:
        del frame
# %% printarr-test
#https://gist.github.com/nmwsharp/54d04af87872a4988809f128e1a1d233
import inspect
if __name__ == "__main__":

    ## test it!

    # plain python vlaues
    noneval = None
    intval1 = 7
    intval2 = -3
    floatval0 = 42.0
    floatval1 = 5.5 * 1e-12
    floatval2 = 7.7232412351231231234 * 1e44

    # numpy values
    import numpy as np
    npval1 = np.arange(100)
    npval2 = np.arange(10000)
    npval3 = np.arange(10000).astype(np.uint64)
    npval4 = np.arange(10000).astype(np.float32).reshape(100,10,10)
    npval5 = np.arange(10000)[-1]

    # torch values 
    torchval1 = None
    torchval2 = None
    torchval3 = None
    torchval4 = None
    try:
        import torch
        torchval1 = torch.randn((1000,12,3))
        torchval2 = torch.randn((1000,12,3))#.cuda()
        torchval3 = torch.arange(1000)
        torchval4 = torch.arange(1000)[0]
    except ModuleNotFoundError:
        pass
    
    # jax values 
    jaxval1 = None
    jaxval2 = None
    jaxval3 = None
    jaxval4 = None
    try:
        import jax
        import jax.numpy as jnp
        jaxval1 = jnp.linspace(0,1,10000)
        jaxval2 = jnp.linspace(0,1,10000).reshape(100,10,10)
        jaxval3 = jnp.arange(1000)
        jaxval4 = jnp.arange(1000)[0]
    except ModuleNotFoundError:
        pass
        
        
    printarr(noneval, 
             intval1, intval2, \
             floatval0, floatval1, floatval2, \
             npval1, npval2, npval3, npval4, npval4[0,:,2:], npval5, \
             torchval1, torchval2, torchval3, torchval4, \
             jaxval1, jaxval2, jaxval3, jaxval4, \
    )
# %% concept-drift
from sklearn.ensemble import RandomForestClassifier
import numpy as np

# Split your data into a training set and a test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train a random forest classifier on the training set
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Initialize a list to store the model's accuracy over time
accuracies = []

# Monitor model performance over time by regularly evaluating the model on the test set
while True:
    # Evaluate the model on the test set
    y_pred = model.predict(X_test)
    accuracy = calculate_accuracy(y_test, y_pred)

    # Add the accuracy to the list
    accuracies.append(accuracy)

    # If the mean accuracy over the past N evaluation intervals falls below a certain threshold,
    # it could be an indication of concept drift
    if len(accuracies) > N:
        mean_accuracy = np.mean(accuracies[-N:])
        if mean_accuracy < THRESHOLD:
            # Retrain the model on fresh data and continue monitoring
            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
            model.fit(X_train, y_train)
            accuracies = []
    else:
        # If the model has not been evaluated N times yet, continue monitoring
        sleep(MONITORING_INTERVAL)

# %% multi-quantile-regression
#https://towardsdatascience.com/a-new-way-to-predict-probability-distributions-e7258349f464
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from catboost import CatBoostRegressor
sns.set()
n = 1000
x_train = np.random.rand(n)
x_test = np.random.rand(n)
noise_train = np.random.normal(0, 0.3, n)
noise_test = np.random.normal(0, 0.3, n)
a, b = 2, 3
y_train = a * x_train + b + noise_train
y_test = a * x_test + b + noise_test
# Store quantiles 0.01 through 0.99 in a list
quantiles = [q/100 for q in range(1, 100)]

# Format the quantiles as a string for Catboost
quantile_str = str(quantiles).replace('[','').replace(']','')

# Fit the multi quantile model
model = CatBoostRegressor(iterations=100,
                          loss_function=f'MultiQuantile:alpha={quantile_str}')

model.fit(x_train.reshape(-1,1), y_train)

# Make predictions on the test set
preds = model.predict(x_test.reshape(-1, 1))
preds = pd.DataFrame(preds, columns=[f'pred_{q}' for q in quantiles])
fig, ax = plt.subplots(figsize=(10, 6))
ax.scatter(x_test, y_test)

for col in ['pred_0.05', 'pred_0.5', 'pred_0.95']:
    ax.scatter(x_test.reshape(-1,1), preds[col], alpha=0.50, label=col)

ax.legend()
coverage_90 = np.mean((y_test <= preds['pred_0.95']) & (y_test >= preds['pred_0.05']))*100
print(coverage_90) 
# Give the model a new input of x = 0.4
x = np.array([0.4])

# We expect the mean of this array to be about 2*0.4 + 3 = 3.8
# We expect the standard deviation of this array to be about 0.30
y_pred = model.predict(x.reshape(-1, 1))

mu = np.mean(y_pred)
sigma = np.std(y_pred)
print(mu) # Output: 3.836147287742427
print(sigma) # Output: 0.3283984093786787
# Plot the predicted distribution
fig, ax = plt.subplots(figsize=(10, 6))
_ = ax.hist(y_pred.reshape(-1,1), density=True)
ax.set_xlabel('$y$')
ax.set_title(f'Predicted Distribution $P(y|x=4)$, $\mu$ = {round(mu, 3)}, $\sigma$ = {round(sigma, 3)}')

# Output: 91.4
# %% Non-Linear Regression with Variable Noise
# https://catboost.ai/en/docs/concepts/loss-functions-regression#MultiQuantile
bounds = [(-10, -8), (-5, -4), (-4, -3), (-3, -1), (-1, 1), (1, 3), (3, 4), (4, 5), (8, 10)]
scales = [18, 15, 8, 11, 1, 2, 9, 16, 19]

x_train = np.array([])
x_test = np.array([])
y_train = np.array([])
y_test = np.array([])

for b, scale in zip(bounds, scales):

    # Randomly select the number of samples in each region 
    n = np.random.randint(low=100, high = 200)

    # Generate values of the domain between b[0] and b[1]
    x_curr = np.linspace(b[0], b[1], n)

    # For even scales, noise comes from an exponential distribution
    if scale % 2 == 0:

        noise_train = np.random.exponential(scale=scale, size=n)
        noise_test = np.random.exponential(scale=scale, size=n)

    # For odd scales, noise comes from a normal distribution
    else:

        noise_train = np.random.normal(scale=scale, size=n)
        noise_test = np.random.normal(scale=scale, size=n)

    # Create training and testing sets
    y_curr_train = x_curr**2  + noise_train
    y_curr_test = x_curr**2  + noise_test

    x_train = np.concatenate([x_train, x_curr])
    x_test = np.concatenate([x_test, x_curr])
    y_train = np.concatenate([y_train, y_curr_train])
    y_test = np.concatenate([y_test, y_curr_test])
model = CatBoostRegressor(iterations=300,
                          loss_function=f'MultiQuantile:alpha={quantile_str}')

model.fit(x_train.reshape(-1,1), y_train)

preds = model.predict(x_test.reshape(-1, 1))
preds = pd.DataFrame(preds, columns=[f'pred_{q}' for q in quantiles])

fig, ax = plt.subplots(figsize=(10, 6))
ax.scatter(x_test, y_test)

for col in ['pred_0.05', 'pred_0.5', 'pred_0.95']:

    quantile = int(float(col.split('_')[-1])*100)
    label_name = f'Predicted Quantile {quantile}'
    ax.scatter(x_test.reshape(-1,1), preds[col], alpha=0.50, label=label_name)

ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Testing Data for Example 2 with Predicted Quantiles')
ax.legend()
coverage_90 = np.mean((y_test <= preds['pred_0.95']) & (y_test >= preds['pred_0.05']))*100
print(coverage_90) 
# Output: 90.506

# %% autoML
#https://towardsdatascience.com/auto-sklearn-scikit-learn-on-steroids-42abd4680e94
import autosklearn
print(autosklearn.__version__)
import sklearn.metrics
from sklearn.model_selection import train_test_split, StratifiedKFold
from autosklearn.classification import AutoSklearnClassifier
from autosklearn.metrics import (accuracy,
                                 f1,
                                 roc_auc,
                                 precision,
                                 average_precision,
                                 recall,
                                 log_loss)
skf = StratifiedKFold(n_splits=5)
clf = AutoSklearnClassifier(time_left_for_this_task=600,
                            max_models_on_disc=5,
                            memory_limit=10240,
                            #resampling_strategy=skf,
                            ensemble_size=3,
                            metric=average_precision,
                            scoring_functions=[roc_auc, average_precision, accuracy, f1, precision, recall, log_loss])
clf.fit(X=train_data, y=train_labels)
df_cv_results = pd.DataFrame(clf.cv_results_).sort_values(by = 'mean_test_score', ascending = False)
df_cv_results
clf.leaderboard(detailed=True, ensemble_only=False)
clf.get_models_with_weights()
clf.sprint_statistics()
clf.refit(X = X_train, y = y_train)
dump(clf, 'model.joblib')
clf = load('model.joblib')
y_probas = clf.predict_proba(X_test)
pos_label = 'yes'
y_proba = y_probas[:, clf.classes_.tolist().index(pos_label)]

# %% h2O
# https://towardsdatascience.com/automated-machine-learning-with-h2o-258a2f3a203f
import h2o
from h2o.automl import H2OAutoML
h2o.init()
#train_data.describe()#chunk_summary=True)
aml = H2OAutoML(max_models =25,balance_classes=False,seed =42)
aml.train(training_frame = h2o.import_file(path="/home/ash022/1d/Aida/ML/dataTmmS42T.csv"), y = 'Class')
# %% cHeck2O
lb = aml.leaderboard
lb.head(rows=lb.nrows)
best_model = aml.leader
print(best_model)
# %% varImp
# https://docs.h2o.ai/h2o/latest-stable/h2o-docs/variable-importance.html
#metalearner = h2o.get_model(best_model['name']))
#metalearner.varimp()
#lb[0,0]
model = h2o.get_model(lb[7, 0])
model.model_performance(h2o.import_file(path="/home/ash022/1d/Aida/ML/dataTmmS42T.csv"))
print(model.varimp(use_pandas=True))
model.varimp_plot(num_of_features = 25)
#best_model.model_performance(test)
#explain_model = aml.explain(frame=test, figsize=(8, 6))
#model_path = h2o.save_model(model=best_model, path='/kaggle/working/model', force=True)
#print(model_path)
#loaded_model = h2o.load_model(path='/kaggle/working/model/StackedEnsemble_AllModels_AutoML_20210803_232409')
# loaded_model.predict(test)
# %% TFDF
# https://github.com/tensorflow/decision-forests
import tensorflow_decision_forests as tfdf 
import pandas as pd
train_df = pd.read_csv("/home/ash022/1d/Aida/ML/dataTmmS42T.csv")
test_df = train_df
train_ds = tfdf.keras.pd_dataframe_to_tf_dataset(train_df, label="Class")
test_ds = tfdf.keras.pd_dataframe_to_tf_dataset(test_df, label="Class")
model = tfdf.keras.RandomForestModel()
model.fit(train_ds)
model.summary()
model.evaluate(test_ds)
print(model.summary())
model.save("tf-df.model")
# %% inspect
# https://www.tensorflow.org/decision_forests/tutorials/automatic_tuning_colab
tuner = tfdf.tuner.RandomSearch(num_trials=50)
tuner.choice("min_examples", [2, 5, 7, 10])
tuner.choice("categorical_algorithm", ["CART", "RANDOM"])
local_search_space = tuner.choice("growing_strategy", ["LOCAL"])
local_search_space.choice("max_depth", [3, 4, 5, 6, 8])
global_search_space = tuner.choice("growing_strategy", ["BEST_FIRST_GLOBAL"], merge=True)
global_search_space.choice("max_num_nodes", [16, 32, 64, 128, 256])
tuner.choice("use_hessian_gain", [True, False])
tuner.choice("shrinkage", [0.02, 0.05, 0.10, 0.15])
tuner.choice("num_candidate_attributes_ratio", [0.2, 0.5, 0.9, 1.0])
tuner.choice("split_axis", ["AXIS_ALIGNED"])
oblique_space = tuner.choice("split_axis", ["SPARSE_OBLIQUE"], merge=True)
oblique_space.choice("sparse_oblique_normalization",["NONE", "STANDARD_DEVIATION", "MIN_MAX"])
oblique_space.choice("sparse_oblique_weights", ["BINARY", "CONTINUOUS"])
oblique_space.choice("sparse_oblique_num_projections_exponent", [1.0, 1.5])
tuned_model = tfdf.keras.GradientBoostedTreesModel(tuner=tuner)
tuned_model.fit(train_ds, verbose=2)
# %% test
tuned_model.compile(["accuracy"])
tuned_test_accuracy = tuned_model.evaluate(test_ds, return_dict=True, verbose=0)["accuracy"]
print( f"Test accuracy with the TF-DF hyper-parameter tuner: {tuned_test_accuracy:.4f}")
tuning_logs = tuned_model.make_inspector().tuning_logs()
tuning_logs.head()
tuning_logs[tuning_logs.best].iloc[0]
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 5))
plt.plot(tuning_logs["score"], label="current trial")
plt.plot(tuning_logs["score"].cummax(), label="best trial")
plt.xlabel("Tuning step")
plt.ylabel("Tuning score")
plt.legend()
plt.show()
# %% plot3d
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.cm import viridis
fig = plt.figure(figsize=(12, 9))
ax = Axes3D(fig)
y = data.iloc[:,1]
x = data.iloc[:,0]
z = data.iloc[:,2]
c = data[dGroup]
ax.scatter(x,y,z, c=viridis(c))#, cmap='coolwarm')
plt.title('First 3 Principal Components')
ax.set_ylabel('PC2')
ax.set_xlabel('PC1')
ax.set_zlabel('PC3')
plt.legend()
# %% CatBoostClassifier
import numpy as np
from catboost import CatBoostClassifier, Pool
train_labels = data[dGroup]
train_data = data.drop(columns=dGroup)
#train_data = np.random.randint(0,100, size=(100, 10))
#train_labels = np.random.randint(0,2,size=(100))
test_data = catboost_pool = Pool(train_data, train_labels)
model = CatBoostClassifier(random_state=42,task_type="GPU")#,iterations=100,depth=3,learning_rate=0.1,loss_function='Logloss',verbose=False)
# train the model
model.fit(train_data, train_labels)
print(model)
# make the prediction using the resulting model
preds_class = model.predict(test_data)
preds_proba = model.predict_proba(test_data)
print("class = ", preds_class)
print("proba = ", preds_proba)
# %% cnfusion matrix
import seaborn as sns
from sklearn.metrics import confusion_matrix
sns.set(rc={'figure.figsize':(8,6)})
cm = confusion_matrix(train_labels, preds_class)
sns.heatmap(cm,annot=True)
print(cm)
# %% feature importance
#sns.barplot(feature_importance)
import matplotlib.pyplot as plt
feature_importance = model.feature_importances_
plt.hist(np.log2(feature_importance+1), bins=30)
plt.hist(np.log2(feature_importance+1)>1, bins=30)
sorted_idx = np.argsort(feature_importance)
fig = plt.figure(figsize=(12, 6))
plt.barh(range(len(sorted_idx<10)), feature_importance[sorted_idx<10], align='center')
#plt.yticks(range(len(sorted_idx)), np.array(train_data.columns)[sorted_idx])
plt.title('Feature Importance')
# %% permutation importance
from sklearn.inspection import permutation_importance
perm_importance = permutation_importance(model, train_data, train_labels, n_repeats=10, random_state=1066)
sorted_idx = perm_importance.importances_mean.argsort()
fig = plt.figure(figsize=(12, 6))
plt.barh(range(len(sorted_idx)), perm_importance.importances_mean[sorted_idx], align='center')
plt.yticks(range(len(sorted_idx)), np.array(X_test.columns)[sorted_idx])
plt.title('Permutation Importance')
# %% SHAP
explainer = shap.Explainer(model)
shap_values = explainer(X_test)
shap_importance = shap_values.abs.mean(0).values
sorted_idx = shap_importance.argsort()
fig = plt.figure(figsize=(12, 6))
plt.barh(range(len(sorted_idx)), shap_importance[sorted_idx], align='center')
plt.yticks(range(len(sorted_idx)), np.array(X_test.columns)[sorted_idx])
plt.title('SHAP Importance')


shap.plots.bar(shap_values, max_display=X_test.shape[0])

# %% cross validation
cv(pool=None,params=None,dtrain=None,iterations=None,num_boost_round=None,fold_count=3,nfold=None,inverted=False,partition_random_seed=0,seed=None,shuffle=True,logging_level=None,stratified=None,as_pandas=True,metric_period=None,verbose=None,verbose_eval=None,plot=False,early_stopping_rounds=None,folds=None,type='Classical',return_models=False)

# %% autoML
#https://pycaret.gitbook.io/docs/get-started/quickstart#classification
#https://twitter.com/machsci/status/1585848304872849408?t=EcW5sr4Z0__C3n01nzM3Pg&s=03
from pycaret.classification import *
dPycaret = setup(data = data, target = dGroup)#, session_id=42,use_gpu=True)
best=compare_models()
evaluate_model(best)
plot_model(best, plot = 'auc')#plot = 'confusion_matrix')
predict_model(best)
# %% predML
#et=create_model('catboost')
#predictions = predict_model(tuned_et, data=data)
predictions = predict_model(best, data=data)#, raw_score=True)
predictions.head()
# %% saveML
save_model(best, 'mm_best_pipeline')
loaded_model = load_model('mm_best_pipeline')
print(loaded_model)

# %% testML
#http://www.pycaret.org/tutorials/html/MCLF101.html
import pandas as pd
pathDir="C:/Users/animeshs/OneDrive - NTNU/Aida/"
fileName="Supplementary Table 2 for working purpose.xlsxgeneG3.csv"
dataset=pd.read_csvc
data=dataset.sample(frac=0.8)
data_unseen=dataset.drop(data.index)
data.reset_index(drop=True, inplace=True)
data_unseen.reset_index(drop=True, inplace=True)
data.to_csv(pathDir+"mm.train.csv")
data_unseen.to_csv(pathDir+"mm.test.csv")
data=pd.read_csv("mm.train.csv",index_col=False)
data.drop('Unnamed: 0',axis=1,inplace=True)
data_unseen=pd.read_csv("mm.test.csv")
data_unseen.drop('Unnamed: 0',axis=1,inplace=True)
print ("Data for Modeling :" + str(data.shape))
print("unseen Data For Predictions:"+str(data_unseen.shape))
data_unseen['Group']
#Data for Modeling :(37, 3956)
#unseen Data For Predictions:(9, 3956)
from pycaret.classification import *
exp_mclf101 = setup(data = data, target = 'Group', session_id=42,use_gpu=True)
compare_models()
#MAE lasso +/-6.6676USD
et=create_model('dt')
tuned_et = tune_model (et, n_iter = 1000)
#6.6635
unseen_predictions = predict_model (tuned_et, data=data_unseen)
# %% autoML
#https://medium.com/aimstack/an-end-to-end-example-of-aim-logger-used-with-xgboost-library-3d461f535617
from __future__ import division
import numpy as np
import xgboost as xgb
from aim.xgboost import AimCallback
# label need to be 0 to num_class -1
data = np.loadtxt('./dermatology.data', delimiter=',',
        converters={33: lambda x:int(x == '?'), 34: lambda x:int(x) - 1})
sz = data.shape
train = data[:int(sz[0] * 0.7), :]
test = data[int(sz[0] * 0.7):, :]
train_X = train[:, :33]
train_Y = train[:, 34]
test_X = test[:, :33]
test_Y = test[:, 34]
print(len(train_X))
xg_train = xgb.DMatrix(train_X, label=train_Y)
xg_test = xgb.DMatrix(test_X, label=test_Y)
# setup parameters for xgboost
param = {}
# use softmax multi-class classification
param['objective'] = 'multi:softmax'
# scale weight of positive examples
param['eta'] = 0.1
param['max_depth'] = 6
param['nthread'] = 4
param['num_class'] = 6
watchlist = [(xg_train, 'train'), (xg_test, 'test')]
num_round = 50
bst = xgb.train(param, xg_train, num_round, watchlist)
# get prediction
pred = bst.predict(xg_test)
error_rate = np.sum(pred != test_Y) / test_Y.shape[0]
print('Test error using softmax = {}'.format(error_rate))
# do the same thing again, but output probabilities
param['objective'] = 'multi:softprob'
bst = xgb.train(param, xg_train, num_round, watchlist, 
                callbacks=[AimCallback(repo='.', experiment='xgboost_test')])
# Note: this convention has been changed since xgboost-unity
# get prediction, this is in 1D array, need reshape to (ndata, nclass)
pred_prob = bst.predict(xg_test).reshape(test_Y.shape[0], 6)
pred_label = np.argmax(pred_prob, axis=1)
error_rate = np.sum(pred_label != test_Y) / test_Y.shape[0]
print('Test error using softprob = {}'.format(error_rate))
#https://medium.com/aimstack/aim-basics-using-context-and-subplots-to-compare-validation-and-test-metrics-f1a4d7e6b9ca
import aim
# train loop
for epoch in range(num_epochs):
  for i, (images, labels) in enumerate(train_loader):
    if i % 30 == 0:
      aim.track(loss.item(), name='loss', epoch=epoch, subset='train')
      aim.track(acc.item(), name='accuracy', epoch=epoch, subset='train')
    
  # calculate validation metrics at the end of each epoch
  # ...
  aim.track(loss.item(), name='loss', epoch=epoch, subset='val')
  aim.track(acc.item(), name='acc', epoch=epoch, subset='val')
  # ...
  
  # calculate test metrics 
  # ...
  aim.track(loss.item(), name='loss', subset='test')
  aim.track(acc.item(), name='loss', subset='test')
#https://towardsdatascience.com/introduction-to-hydra-cc-a-powerful-framework-to-configure-your-data-science-projects-ed65713a53c6
#import hydra
#from hydra import utils 
import pandas as pd 
#@hydra.main(config_path="conf", config_name='preprocessing.yaml')
#pd.read_csv(utils.get_original_cwd() + "/" + config.dataset.data, encoding=config.dataset.encoding)
#python file.py model=logisticregression
df=pd.read_csv("data/data.csv")
from sklearn.preprocessing import StandardScaler
X,y=df.iloc[:,:-1],df['Group']
scalar = StandardScaler().fit(X)
scalar.feature_names_in_
#from sklearnex import patch_sklearn
#patch_sklearn()
#sklearnex.unpatch_sklearn()
# You need to re-import scikit-learn algorithms after the unpatch:
from sklearn.cluster import KMeans
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
print(f"kmeans.labels_ = {kmeans.labels_}")
#df.corr('spearman')
df=dataset
print(df.groupby(["Group"])['NDUFB7.6'].transform(lambda x: x.fillna(x.mean())))
dfNAR=df.groupby(["Group"]).transform(lambda x: x.fillna(x.median()))
print(min(dfNAR.min()))
dfNARM=dfNAR.fillna(int(min(dfNAR.min())-1))
print(min(dfNARM.min()))
dfNARM.T.to_csv(pathDir+fileName+"imp.T.csv")
dfNARM["Group"]=df["Group"]
dfNARM.to_csv(pathDir+fileName+"imp.csv",index=False)
X,y=dfNARM.iloc[:,:-1],dfNARM['Group']
scalar = StandardScaler().fit(X)
scalar.feature_names_in_
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
print(f"kmeans.labels_ = {kmeans.labels_}")
#https://scikit-learn.org/stable/auto_examples/release_highlights/plot_release_highlights_1_0_0.html
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
X=dfNARM
preprocessor = ColumnTransformer(
    [
        ("numerical", StandardScaler(), ["age"]),
        ("categorical", OneHotEncoder(), ["Group"]),
    ],
    verbose_feature_names_out=False,
).fit(X)
preprocessor.get_feature_names_out()
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
pipe = make_pipeline(preprocessor, LogisticRegression())
pipe.fit(X, y)
pipe[:-1].get_feature_names_out()
#https://scikit-learn.org/stable/auto_examples/miscellaneous/plot_anomaly_comparison.html#sphx-glr-auto-examples-miscellaneous-plot-anomaly-comparison-py
from sklearn.ensemble import HistGradientBoostingClassifier
anomaly_algorithms = [
    ("Robust covariance", EllipticEnvelope(contamination=outliers_fraction)),
    ("One-Class SVM", svm.OneClassSVM(nu=outliers_fraction, kernel="rbf", gamma=0.1)),
    (
        "One-Class SVM (SGD)",
        make_pipeline(
            Nystroem(gamma=0.1, random_state=42, n_components=150),
            SGDOneClassSVM(
                nu=outliers_fraction,
                shuffle=True,
                fit_intercept=True,
                random_state=42,
                tol=1e-6,
            ),
        ),
    ),
    (
        "Isolation Forest",
        IsolationForest(contamination=outliers_fraction, random_state=42),
    ),
    (
        "Local Outlier Factor",
        LocalOutlierFactor(n_neighbors=35, contamination=outliers_fraction),
    ),
]
        if name == "Local Outlier Factor":
            y_pred = algorithm.fit_predict(X)
        else:
            y_pred = algorithm.fit(X).predict(X)

        # plot the levels lines and the points
        if name != "Local Outlier Factor":  # LOF does not implement predict
            Z = algorithm.predict(np.c_[xx.ravel(), yy.ravel()])
            Z = Z.reshape(xx.shape)
            plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors="black")


import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas! Tested with Python 3.7.9 \n\nUSAGE: python resultsGroupby.py <path to file of interest like \"L:\promec\mqpar.xml.1623227664.results\combined\txt\proteinGroupsCombine.py> <column of interest like \"Score\"\n\n")
#python resultsGroupby.py "L:\promec\USERS\Synnøve\20210709_Synnove_6samples\HF\combined\txt\msmsScans.txt" "Raw file"
inpF = sys.argv[1]
columnID = sys.argv[2]
#inpF = "L:\\promec\\USERS\\Synnøve\\20210709_Synnove_6samples\\HF\\combined\\txt\\msmsScans.txt"
#columnID = "Raw file"
import pandas as pd
df = pd.read_table(inpF)
df.describe()
print(df.columns)
print(df.head())
#print(df.info())
dfC=df.groupby(columnID).count()
print(dfC)
outFc=inpF+columnID+"count.csv"
dfC.to_csv(outFc)#.with_suffix('.combo.csv'))
print(outFc)
outFc=inpF+columnID+"count.png"
dfC.iloc[:,1].plot(kind="barh").figure.savefig(outFc,dpi=100,bbox_inches = "tight")
#plt.close()
print(outFc)
dfS=df.groupby(columnID).sum()
# %%
