# %% pin-ball-loss
#https://github.com/erykml/medium_articles/blob/master/Statistics/quantile_loss.ipynb
import numpy as np
import matplotlib.pyplot as plt

# Define the pinball loss function
def pinball_loss(y_true, y_pred, quantile):
    return np.where(y_true >= y_pred, quantile * (y_true - y_pred), (quantile - 1) * (y_true - y_pred))

# Generate a range of prediction errors
errors = np.linspace(-10, 10, 400)  
y_true = 0  

# Quantiles
quantiles = [0.1, 0.5, 0.9]
line_styles = ['-', '--', '-.']  

# Plotting
plt.figure(figsize=(10, 6))
for q, ls in zip(quantiles, line_styles):
    losses = pinball_loss(y_true, errors, q)
    plt.plot(errors, losses, linestyle=ls, label=f'Quantile {q*100:.0f}')
    
plt.axhline(0, color='gray', linestyle='--', linewidth=0.5)
plt.axvline(0, color='gray', linestyle='--', linewidth=0.5)
plt.xlabel('Prediction Error (y_true - y_pred)')
plt.ylabel('Pinball Loss')
plt.title('Pinball Loss for Different Quantiles')
plt.legend()
plt.grid(True)
plt.show()
# Generate a range of prediction errors
errors = np.linspace(90, 110, 400)  
y_true = 100  

# Quantiles
QUANTILE = 0.9

plt.figure(figsize=(10, 6))
losses = pinball_loss(y_true, errors, QUANTILE)
plt.plot(errors, losses, label=f'Quantile {QUANTILE*100:.0f}')
    
plt.xlabel('Prediction Error (y_true - y_pred)')
plt.ylabel('Pinball Loss')
plt.title(f'Pinball Loss for $\\alpha$ = {QUANTILE}')
plt.legend()
plt.grid(True)
plt.show()

# %% optimization
#https://blog.dailydoseofds.com/p/introduction-to-quantile-regression?utm_source=post-email-title&publication_id=1119889&post_id=148343716&utm_campaign=email-post-title&isFreemail=true&r=a55q5&triedRedirect=true&utm_medium=email
def find_loss(initial_weights, w):
# current prediction
prediction = initial_weights[0]*X + initial_weights[1]
# error
error = Y - prediction
# reweigh error term
weighted_error = np.where (error > 0,
wwnp. abs (error), # if true
(1-w) * np. abs (error)) # if true
# total loss
return weighted_error.sum()
from scipy.optimize import minimize
initial_weights = np. array ([0,1])
def get_quantile_model (w):
model_weights = minimize(find_loss, initial_weights, args=(w)).x
return model_weights


# %% hyperopt
#https://github.com/nextflow-io/hyperopt/blob/master/modules/fetch_dataset/resources/usr/bin/fetch-dataset.py
import argparse
import json
from sklearn.datasets import fetch_openml


def is_categorical(y):
    return y.dtype.kind in 'OSUV'


def get_categories(df):
    result = {}
    for c in df.columns:
        if is_categorical(df[c]):
            values = df[c].unique().tolist()

            # fix bug with numerical categories
            if sum(v.isdigit() for v in values) == len(values):
                values = [int(v) for v in values]

            result[c] = values

    return result


if __name__ == '__main__':
    # parse command-line arguments
    parser = argparse.ArgumentParser(description='Download an OpenML dataset')
    parser.add_argument('--name', help='dataset name', required=True)
    parser.add_argument('--data', help='data file', default='data.txt')
    parser.add_argument('--meta', help='metadata file', default='meta.json')

    args = parser.parse_args()

    # download dataset from openml
    dataset = fetch_openml(args.name, as_frame=True)

    # save data
    dataset.frame.to_csv(args.data, sep='\t')

    # save metadata
    meta = {
        'name': args.name,
        'feature_names': dataset.feature_names,
        'target_names': dataset.target_names,
        'categories': get_categories(dataset.frame) 
    }

    with open(args.meta, 'w') as f:
        json.dump(meta, f)

# %% mlops
#https://github.com/animesh/mlops-project
1. Clone the Repository
Clone the project repository from GitHub:

git clone https://github.com/prsdm/ml-project.git
cd ml-project
2. Set Up the Environment
Ensure you have Python 3.8+ installed. Create a virtual environment and install the necessary dependencies:

python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
Alternatively, you can use the Makefile command:

make setup
3. Data Preparation
Pull the data from DVC. If this command doesn't work, the train and test data are already present in the data folder:

dvc pull
4. Train the Model
To train the model, run the following command:

python main.py 
Or use the Makefile command:

make run
This script will load the data, preprocess it, train the model, and save the trained model to the models/ directory.

5. FastAPI
Start the FastAPI application by running:

uvicorn app:app --reload
6. Docker
To build the Docker image and run the container:

docker build -t my_fastapi .
docker run -p 80:80 my_fastapi
Once your Docker image is built, you can push it to Docker Hub, making it accessible for deployment on any cloud platform.

7. Monitor the Model
Integrate Evidently AI to monitor the model for data drift and performance degradation:

run monitor.ipynb file


# %% timeseries
#https://pub.towardsai.net/optimizing-supply-chain-with-time-series-forecasting-a-customer-centric-approach-390541ff83eb


import pandas as pd
import numpy as np
from lifetimes import BetaGeoFitter, GammaGammaFitter
from lifetimes.utils import summary_data_from_transaction_data
from scipy import stats
from statsmodels.tsa.seasonal import seasonal_decompose
from sklearn.metrics import mean_absolute_error, mean_squared_error
import warnings

warnings.filterwarnings('ignore')

# Assuming 'tran_df_bs' is your original DataFrame
df = tran_df_bs.copy()

# Convert 'trans_date' to datetime
df['trans_date'] = pd.to_datetime(df['trans_date'])

# Handle missing values and data cleaning
df.dropna(subset=['Customer ID', 'Quantity'], inplace=True)
df = df[df['Quantity'] > 0]  # Remove negative quantities

# Remove outliers in 'Quantity' using IQR method
Q1 = df['Quantity'].quantile(0.25)
Q3 = df['Quantity'].quantile(0.75)
IQR = Q3 - Q1
df = df[(df['Quantity'] >= Q1 - 1.5 * IQR) & (df['Quantity'] <= Q3 + 1.5 * IQR)]

# Split the data into training and validation sets
cutoff_date = pd.to_datetime('2011-11-30')
train_df = df[df['trans_date'] < cutoff_date]
valid_df = df[(df['trans_date'] >= cutoff_date) & (df['trans_date'] < cutoff_date + pd.Timedelta(days=10))]

# Update valid_df to include only customers present in train_df
train_customers = train_df['Customer ID'].unique()
valid_df = valid_df[valid_df['Customer ID'].isin(train_customers)]
# Prepare data using method: summary_data_from_transaction_data
summary = summary_data_from_transaction_data(
    train_df,
    'Customer ID',
    'trans_date',
    monetary_value_col='Quantity',
    observation_period_end=train_df['trans_date'].max()
)

# Ensure monetary values are positive
summary = summary[summary['monetary_value'] > 0]

# Fit the BG/NBD model
bgf = BetaGeoFitter(penalizer_coef=0.05)
bgf.fit(summary['frequency'], summary['recency'], summary['T'])

# Predict the number of transactions for the next 10 days
t = 10
summary['predicted_purchases'] = bgf.conditional_expected_number_of_purchases_up_to_time(
    t, summary['frequency'], summary['recency'], summary['T']
)
summary['predicted_purchases'] = summary['predicted_purchases'].clip(lower=0)

# Fit the Gamma-Gamma model for monetary value
ggf = GammaGammaFitter(penalizer_coef=0.02)
ggf.fit(returning_customers_summary['frequency'], returning_customers_summary['monetary_value'])
summary['expected_avg_sales'] = ggf.conditional_expected_average_profit(
    summary['frequency'],
    summary['monetary_value']
)
summary['expected_avg_sales'] = summary['expected_avg_sales'].clip(lower=0)
# Calculate expected sales for each customer
summary['expected_sales'] = summary['predicted_purchases'] * summary['expected_avg_sales']
summary['expected_sales'] = summary['expected_sales'].clip(lower=0)

# Merge predictions with customer-product data
customer_product = train_df.groupby(['Customer ID', 'Description'])['Quantity'].sum().reset_index()
customer_product = customer_product.merge(
    summary[['expected_sales', 'frequency', 'recency', 'monetary_value']],
    left_on='Customer ID', right_index=True, how='left'
)

# Calculate the proportion of each product purchased by each customer
total_quantity_per_customer = customer_product.groupby('Customer ID')['Quantity'].transform('sum')
customer_product['product_proportion'] = customer_product['Quantity'] / total_quantity_per_customer
customer_product['product_proportion'] = customer_product['product_proportion'].clip(lower=0)
# Aggregate data to daily sales per product
daily_sales = train_df.groupby(['trans_date', 'Description'])['Quantity'].sum().reset_index()

# Pivot data to have products as columns
daily_sales_pivot = daily_sales.pivot(index='trans_date', columns='Description', values='Quantity').fillna(0)

# Decompose each product's time series
seasonal_indices = {}
for product in daily_sales_pivot.columns:
    product_series = daily_sales_pivot[product]
    has_zeros = (product_series == 0).any()
    model_type = 'additive' if has_zeros else 'multiplicative'
    if len(product_series.dropna()) >= 90:
        try:
            decomposition = seasonal_decompose(product_series, model=model_type, period=30)
            seasonal = decomposition.seasonal
            forecast_dates = pd.date_range(start=cutoff_date, periods=t)
            forecast_seasonal = seasonal[seasonal.index.isin(forecast_dates)]
            seasonal_index = forecast_seasonal.mean() if not forecast_seasonal.empty else 0
            seasonal_indices[product] = {'index': seasonal_index, 'model': model_type}
        except Exception as e:
            seasonal_indices[product] = {'index': 0 if model_type == 'additive' else 1, 'model': model_type}
# Apply seasonal adjustment
def adjust_sales(row):
    product = row['Description']
    expected_sales = row['expected_product_sales']
    seasonal_info = seasonal_indices.get(product, {'index': 0, 'model': 'additive'})
    seasonal_index = seasonal_info['index']
    model_type = seasonal_info['model']
    return max(expected_sales + seasonal_index if model_type == 'additive' else expected_sales * seasonal_index, 0)

product_sales_forecast['adjusted_expected_sales'] = product_sales_forecast.apply(adjust_sales, axis=1)
# Validate the forecast
actual_sales = valid_df.groupby('Description')['Quantity'].sum().reset_index()
validation_df = final_forecast.merge(actual_sales, on='Description', how='left')
validation_df['actual_sales'].fillna(0, inplace=True)

# Calculate APE
validation_df['APE'] = np.where(
    validation_df['actual_sales'] == 0,
    np.nan,
    np.abs((validation_df['actual_sales'] - validation_df['adjusted_expected_sales']) / validation_df['actual_sales'])
)

# Calculate MAE and RMSE
mae = mean_absolute_error(validation_df['actual_sales'], validation_df['adjusted_expected_sales'])
rmse = np.sqrt(mean_squared_error(validation_df['actual_sales'], validation_df['adjusted_expected_sales']))

print(f"Validation MAE: {mae:.2f}")
print(f"Validation RMSE: {rmse:.2f}")
# Filter out low sales values
threshold = 5
validation_df_filtered = validation_df[validation_df['actual_sales'] >= threshold]

# Calculate MAPE and median APE
mape = validation_df_filtered['APE'].mean(skipna=True) * 100
median_ape = validation_df_filtered['APE'].median(skipna=True) * 100

print(f"Filtered Validation MAPE: {mape:.2f}%")
print(f"Filtered Median APE: {median_ape:.2f}%")

#prophet
model = Prophet(
    yearly_seasonality=True,
    weekly_seasonality=True,
    daily_seasonality=False,
    seasonality_mode='multiplicative'
)


model.add_seasonality(name='monthly', period=30.5, fourier_order=5)

model.fit(product_train)

future_dates = model.make_future_dataframe(periods=30, freq='D')
forecast = model.predict(future_dates)
forecast_next_30 = forecast[['ds', 'yhat']].tail(30)
validation = product_valid.merge(forecast_next_30, on='ds', how='left')

validation['APE'] = np.where(
    validation['y'] == 0,
    np.nan,
    np.abs((validation['y'] - validation['yhat']) / validation['y'])
)
product_forecasts = forecast_results.groupby('Description')['yhat'].sum().reset_index()
#https://github.com/animesh/tm_lifetime/blob/main/code/repurchase_prophet_tm.py

# %% matrix-inverse
#https://pub.towardsai.net/data-structures-in-machine-learning-a-comprehensive-guide-to-efficiency-and-scalability-f7429919c9c5
import numpy as np

# Example dataset
X = np.array([[1, 1], [1, 2], [2, 2], [2, 3]])  # Feature matrix
y = np.dot(X, np.array([1, 2])) + 3  # Target vector

# Add a column of ones to X to account for the intercept term
X = np.hstack([np.ones((X.shape[0], 1)), X])

# Calculate beta using the normal equation
beta = np.linalg.inv(X.T @ X) @ X.T @ y

print("Estimated coefficients:", beta)
Estimated coefficients: [3. 1. 2.]
Hosted on Jovian
View File

# %% a*
import heapq

# Example graph (as an adjacency list)
graph = {
    'A': [('B', 1), ('C', 4)],
    'B': [('A', 1), ('C', 2), ('D', 5)],
    'C': [('A', 4), ('B', 2), ('D', 1)],
    'D': [('B', 5), ('C', 1)]
}

# A* search function
def a_star(graph, start, goal, h):
    # Priority queue, initialized with the start node
    pq = [(0 + h(start), 0, start, [])]  # (f = g + h, g, node, path)
    heapq.heapify(pq)
    
    while pq:
        (f, g, current, path) = heapq.heappop(pq)
        
        # Path to the current node
        path = path + [current]
        
        if current == goal:
            return path, f  # Return the found path and its total cost
        
        for (neighbor, cost) in graph[current]:
            heapq.heappush(pq, (g + cost + h(neighbor), g + cost, neighbor, path))
    
    return None  # If no path is found

# Heuristic function (for simplicity, using zero heuristic as an example)
def h(node):
    return 0

# Find path from A to D
path, cost = a_star(graph, 'A', 'D', h)
print("Path:", path, "Cost:", cost)
Path: ['A', 'B', 'C', 'D'] Cost: 4
Hosted on Jovian
View File

# %% k-NN 
import numpy as np

def initialize_centroids(X, k):
    centroids = []
    centroids.append(X[np.random.randint(X.shape[0])])
    
    for _ in range(1, k):
        distances = np.array([min([np.linalg.norm(x - c) for c in centroids]) for x in X])
        heap = [(dist, i) for i, dist in enumerate(distances)]
        heapq.heapify(heap)
        
        # Weighted random selection of the next centroid
        total_dist = sum(distances)
        r = np.random.uniform(0, total_dist)
        cumulative_dist = 0
        
        for dist, i in heap:
            cumulative_dist += dist
            if cumulative_dist >= r:
                centroids.append(X[i])
                break
    
    return np.array(centroids)

# Example dataset
X = np.array([[1, 2], [1, 4], [3, 2], [5, 6], [7, 8], [9, 10]])
centroids = initialize_centroids(X, 2)
print("Initial centroids:\n", centroids)
Initial centroids:
 [[ 9 10]
 [ 5  6]]
Hosted on Jovian
View File

# %% p-NN
import numpy as np
from sklearn.neighbors import NearestNeighbors
from sklearn.random_projection import SparseRandomProjection

# Example dataset: 2D points
points = np.random.rand(1000, 2)

# Using random projections to approximate nearest neighbors
lsh = SparseRandomProjection(n_components=2)
projected_points = lsh.fit_transform(points)

# Using NearestNeighbors for finding approximate neighbors
nbrs = NearestNeighbors(n_neighbors=3, algorithm='ball_tree').fit(projected_points)
distances, indices = nbrs.kneighbors(projected_points)

# Example: Finding nearest neighbors of a point
point_index = 0
print(f"Nearest neighbors of point {point_index}: {indices[point_index]}")
Nearest neighbors of point 0: [  0 129 312]
Hosted on Jovian
View File

# %% DT
from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier
from sklearn import tree
import matplotlib.pyplot as plt

# Load example dataset
iris = load_iris()
X, y = iris.data, iris.target

# Train a decision tree classifier
clf = DecisionTreeClassifier(criterion='gini', max_depth=3)
clf.fit(X, y)

# Visualize the decision tree
plt.figure(figsize=(12,8))
tree.plot_tree(clf, filled=True, feature_names=iris.feature_names, class_names=iris.target_names)
plt.show()
Notebook Image
Hosted on Jovian
View File

# %% KDT
from sklearn.neighbors import KDTree
import numpy as np

# Create a dataset of 2D points
points = np.array([
    [2, 3],
    [5, 4],
    [9, 6],
    [4, 7],
    [8, 1],
    [7, 2]
])

# Build a kd-tree
kd_tree = KDTree(points, leaf_size=2)

# Query the kd-tree for the nearest neighbor of a given point
query_point = np.array([[9, 2]])
dist, ind = kd_tree.query(query_point, k=1)

print(f"Nearest neighbor of {query_point} is {points[ind]} with distance {dist}")
Nearest neighbor of [[9 2]] is [[[8 1]]] with distance [[1.41421356]]
Hosted on Jovian
View File

# %% graph
import networkx as nx
import matplotlib.pyplot as plt
from networkx.algorithms.community import greedy_modularity_communities

# Create an example social network graph
G = nx.karate_club_graph()

# Detect communities using the Girvan-Newman method
communities = greedy_modularity_communities(G)

# Plot the graph with community coloring
pos = nx.spring_layout(G)
plt.figure(figsize=(10, 7))

# Color nodes by community
for i, community in enumerate(communities):
    nx.draw_networkx_nodes(G, pos, nodelist=list(community), node_color=f'C{i}', label=f'Community {i+1}')

nx.draw_networkx_edges(G, pos)
nx.draw_networkx_labels(G, pos)
plt.legend()
plt.show()
Notebook Image
Hosted on Jovian
View File
# Depth-First Search (DFS) using recursion
def dfs(graph, node, visited):
    if node not in visited:
        print(node, end=" ")
        visited.add(node)
        for neighbor in graph[node]:
            dfs(graph, neighbor, visited)

# Breadth-First Search (BFS) using a queue
from collections import deque

def bfs(graph, start):
    visited = set()
    queue = deque([start])
    
    while queue:
        node = queue.popleft()
        if node not in visited:
            print(node, end=" ")
            visited.add(node)
            queue.extend(graph[node])

# Example graph
graph = {
    'A': ['B', 'C'],
    'B': ['D', 'E'],
    'C': ['F'],
    'D': [],
    'E': ['F'],
    'F': []
}

print("DFS traversal:")
dfs(graph, 'A', set())

print("\nBFS traversal:")
bfs(graph, 'A')
DFS traversal:
A B D E F C 
BFS traversal:
A B C D E F 
Hosted on Jovian
View File
Example: Implementing DFS and BFS.
2. Memory Management for Large 
import sys
import numpy as np
from scipy.sparse import csr_matrix

# Example graph represented as an adjacency matrix (dense)
adj_matrix = np.array([
    [0, 1, 1, 0],
    [1, 0, 1, 1],
    [1, 1, 0, 1],
    [0, 1, 1, 0]
])

# Convert dense matrix to sparse representation
sparse_matrix = csr_matrix(adj_matrix)
print(f"\nDense matrix representation:\n{adj_matrix}\nSize: {sys.getsizeof(adj_matrix)}")
print(f"\nSparse matrix representation:\n{sparse_matrix}\nSize: {sys.getsizeof(sparse_matrix)}")

Dense matrix representation:
[[0 1 1 0]
 [1 0 1 1]
 [1 1 0 1]
 [0 1 1 0]]
Size: 256

Sparse matrix representation:
  (0, 1)	1
  (0, 2)	1
  (1, 0)	1
  (1, 2)	1
  (1, 3)	1
  (2, 0)	1
  (2, 1)	1
  (2, 3)	1
  (3, 1)	1
  (3, 2)	1
Size: 56
Hosted on Jovian
View File

# %% distfit1hotcode
#https://towardsdatascience.com/all-you-need-is-statistics-to-analyze-tabular-datasets-3a1717f92749
from distfit import distfit
import numpy as np

# Variable X
X = np.random.normal(163, 10, 10000)

# Fit distribution for most known distributions.
dfit = distfit(distr='popular', bound='both', alpha=0.05)
results = dfit.fit_transform(X)

# Get threshold for the confidence intervals
th_low = results['model']['CII_min_alpha']
th_high = results['model']['CII_max_alpha']

# Apply the function to variable X
df = pd.DataFrame(X, columns=['Value'])
df['Category'] = df['Value'].apply(discretize_X, args=(th_low, th_high))

# One-hot encoding
one_hot_encoded_df = pd.get_dummies(df, columns=['Category'])

# Function to categorize based on confidence interval
def discretize_X(X, th_low, th_high):
    if X < th_low:
        return 'Low'
    elif X > th_high:
        return 'High'
    else:
        return 'Medium'
# Load datazets library
import datazets as dz
# Get the data science salary dataset
df = dz.get('ds_salaries.zip')

# The features are as following
df.columns

# 'work_year'          > The year the salary was paid.
# 'experience_level'   > The experience level in the job during the year.
# 'employment_type'    > Type of employment: Part-time, full time, contract or freelance.
# 'job_title'          > Name of the role.
# 'salary'             > Total gross salary amount paid.
# 'salary_currency'    > Currency of the salary paid (ISO 4217 code).
# 'salary_in_usd'      > Converted salary in USD.
# 'employee_residence' > Primary country of residence.
# 'remote_ratio'       > Remote work: less than 20%, partially, more than 80%
# 'company_location'   > Country of the employer's main office.
# 'company_size'       > Average number of people that worked for the company during the year.

# Make the catagorical variables better to understand.
df['experience_level'] = df['experience_level'].replace({'EN':'Entry-level', 'MI':'Junior Mid-level', 'SE':'Intermediate Senior-level', 'EX':'Expert Executive-level / Director'}, regex=True)
df['employment_type'] = df['employment_type'].replace({'PT':'Part-time', 'FT':'Full-time', 'CT':'Contract', 'FL':'Freelance'}, regex=True)
df['company_size'] = df['company_size'].replace({'S':'Small (less than 50)', 'M':'Medium (50 to 250)', 'L':'Large (>250)'}, regex=True)
df['remote_ratio'] = df['remote_ratio'].replace({0:'No remote', 50:'Partially remote', 100:'>80% remote'}, regex=True)
df['work_year'] = df['work_year'].astype(str)

df.shape
# (4134, 8)
# Import scipy library
from scipy.stats import hypergeom

# Collect the counts
N = df.shape[0] # Total number of samples
K = sum(df['company_location']=='US') # Number of successes in the population
n = sum(df['salary_currency']=='USD')
x = sum((df['company_location']=='US') & (df['salary_currency']=='USD'))

# Compute association using the hypergeometric test
P = hypergeom.sf(x-1, N, n, K)

print(P)
0.0
# Import libraries
from hnet import hnet
import datazets as dz

# Get the data science salary dataset
df = dz.get('ds_salaries.zip')

# Initialize
hn = hnet(alpha=0.05,
          y_min=10,
          multtest='holm',
          dtypes=['cat', 'cat', 'cat', 'cat', 'num', 'cat', 'num', 'cat', 'cat', 'cat', 'cat'])

# Perform the analysis
results = hn.association_learning(df, verbose=4)

# [df2onehot] >Set dtypes in dataframe..
# [df2onehot] >Total onehot features: 84
# [hnet] >Association learning across [84] categories.
# 100%   > 84/84 [00:14<00:00,  5.73it/s]
# [hnet] >Multiple test correction using holm
# [hnet] >Dropping salary
# [hnet] >Dropping salary_in_usd
# -----------------------------------------------------
# [hnet] >Total number of associatons computed: [23256]
# -----------------------------------------------------
# [hnet] >Computing category association using fishers method..
# 100%   > 11/11 [00:00<00:00, 175.45it/s][hnet] >Fin.

# Make static plot
hn.plot(summarize=False, figsize=(50, 40))

# Make interactive network plot
hn.d3graph(summarize=False)

# Create interactive heatmap
hn.d3heatmap(summarize=False, fontsize=8)
# Import libraries
from df2onehot import df2onehot
from pca import pca

# Load dataset
df = dz.get('ds_salaries.zip')

# Store salary in separate target variable.
y = df['salary_in_usd']

# Remove redundant variables
df.drop(labels=['salary_currency', 'salary', 'salary_in_usd'], inplace=True, axis=1)

# Make the catagorical variables better to understand.
df['experience_level'] = df['experience_level'].replace({'EN':'Entry-level', 'MI':'Junior Mid-level', 'SE':'Intermediate Senior-level', 'EX':'Expert Executive-level / Director'}, regex=True)
df['employment_type'] = df['employment_type'].replace({'PT':'Part-time', 'FT':'Full-time', 'CT':'Contract', 'FL':'Freelance'}, regex=True)
df['company_size'] = df['company_size'].replace({'S':'Small (less than 50)', 'M':'Medium (50 to 250)', 'L':'Large (>250)'}, regex=True)
df['remote_ratio'] = df['remote_ratio'].replace({0:'No remote', 50:'Partially remote', 100:'>80% remote'}, regex=True)
df['work_year'] = df['work_year'].astype(str)


# One hot encoding and removing any multicollinearity to prevent the dummy trap.
dfhot = df2onehot(df,
                  remove_multicollinearity=True,
                  y_min=5,
                  verbose=4)['onehot']

# Initialize
model = pca(normalize=False)
# Fit model using PCA
model.fit_transform(dfhot)

# Make biplot
model.biplot(labels=df['job_title'],
             s=y/500,
             marker=df['experience_level'],
             n_feat=10,
             density=True,
             fontsize=0,
             jitter=0.05,
             alpha=0.8,
             color_arrow='#000000',
             arrowdict={'color_text': '#000000', 'fontsize': 32},
             figsize=(40, 30),
             verbose=4,
             )

# %% regresionBias
#https://towardsdatascience.com/how-biased-is-your-regression-model-4ef6c1495b77
import math
import pandas as pd
import numpy as np
from patsy import dmatrices
import statsmodels.api as sm
import scipy.stats
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from matplotlib.ticker import StrMethodFormatter
import seaborn as sns


############################################
####### Load the M & M weights data ########
############################################
df_mm = pd.read_csv(filepath_or_buffer='m_and_m_sample_weights.csv', header=0)

df_mm['Mean_Sample_Weight'] = df_mm['Weight_In_GMS']/15 

plt.figure(figsize=(8, 6))

############################################
######### Plot the 60 sample means #########
############################################
sns.scatterplot(x=['Mean Sample Weight']*60, y=df_mm['Mean_Sample_Weight'], color='cornflowerblue', label='Mean Sample Weight')

# Plot the mean of the 'population' of 453 M&Ms
sns.scatterplot(x=['Mean Sample Weight'], y=2.29792, color='orange', label=f'Population mean', s=100)

plt.title('Mean Weights of 60 Random Samples')
plt.xlabel('Samples')
plt.ylabel('Weight in Grams')
plt.legend()
plt.grid(True)

plt.show()

############################################
#### Load the Taipei house prices data #####
############################################
df_hp = pd.read_csv(filepath_or_buffer='taipei_real_estate_prices.csv', header=0)

##########################################################
# Plot House price versus number of convenenience stores #
##########################################################
plt.figure(figsize=(10, 6))
sns.scatterplot(x='number_of_convenience_stores', y='house_price_of_unit_area', data=df_hp, color='cornflowerblue')

plt.xlabel('Number of Nearby Convenience Stores')
plt.ylabel('House Price per Unit Area')
plt.title('House Price per Unit Area vs. Number of Nearby Convenience Stores')
plt.legend()

# Show the plot
plt.show()

############################################
########## Fit the linear model  ###########
############################################
reg_expr = 'house_price_of_unit_area ~ number_of_convenience_stores'
y, X = dmatrices(reg_expr, data=df_hp, return_type='dataframe')
olsr_model_results = sm.OLS(y, X).fit()
olsr_model_results.params

############################################
########## Plot the fitted model ###########
############################################
plt.figure(figsize=(10, 6))
sns.scatterplot(x='number_of_convenience_stores', y='house_price_of_unit_area', data=df_hp, color='cornflowerblue')

# Get the predicted y values
predicted_y = olsr_model_results.predict(X)

sns.lineplot(x=np.array(X['number_of_convenience_stores']), y=np.array(predicted_y), color='orange', marker='o', label='OLS Predicted')

plt.xlabel('Number of Nearby Convenience Stores')
plt.ylabel('House Price per Unit Area')
plt.title('House Price per Unit Area vs. Number of Nearby Convenience Stores')
plt.legend()

plt.show()

################################################
# Plot 50 fitted models on bootstrapped samples 
################################################

num_c_stores_unique = df_hp['number_of_convenience_stores'].unique()
num_c_stores_unique.sort()

columns = [f'num_c_stores_{int(val)}' for val in num_c_stores_unique]
predicted_means_df = pd.DataFrame(columns=columns)
predicted_means_df['beta_0'] = np.nan
predicted_means_df['beta_1'] = np.nan

plt.figure(figsize=(10, 6))
sns.scatterplot(x='number_of_convenience_stores', y='house_price_of_unit_area', data=df_hp, color='cornflowerblue')

# Run the simulation 50 times
for i in range(50):
    # Pull out a random sample of 50 rows
    sample_df = df_hp.sample(n=50, random_state=i)

    y, X = dmatrices('house_price_of_unit_area ~ number_of_convenience_stores', data=sample_df, return_type='dataframe')

    model = sm.OLS(y, X).fit()

    predicted_y = model.predict(X)

    means = []
    for val in num_c_stores_unique:
        mean_val = predicted_y[sample_df['number_of_convenience_stores'] == val].mean()
        means.append(mean_val)
    
    predicted_means_df.loc[i, columns] = means

    predicted_means_df.loc[i, 'beta_0'] = model.params['Intercept']
    predicted_means_df.loc[i, 'beta_1'] = model.params['number_of_convenience_stores']

    x_vals = np.array([df_hp['number_of_convenience_stores'].min(), df_hp['number_of_convenience_stores'].max()])
    y_vals = model.params['Intercept'] + model.params['number_of_convenience_stores'] * x_vals
    sns.lineplot(x=x_vals, y=y_vals, color='orange', linestyle='--', alpha=0.3)

plt.title('OLS Regression Lines Fitted on 50 Random Samples with the Full Dataset in the Background')
plt.xlabel('Number of Nearby Convenience Stores')
plt.ylabel('House Price per Unit Area')
plt.show()


#######################################################
# Plot beta_0 and beta_1 from the bootstrapped models #
#######################################################

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

ax1.set_title("Estimated β_0 and population β_0", fontsize=14)
ax1.set_ylabel("β_0", color='black', fontsize=14)

ax1.scatter(x=['beta_0']*50, y=predicted_means_df['beta_0'], marker='o', label="Sample β_0", color='cornflowerblue')
ax1.scatter(x=['beta_0'], y=olsr_model_results.params['Intercept'], marker='o', s=100, label="Population β_0", color='orange')
ax1.tick_params(axis='both', which='major', labelsize=14)

ax2.set_title("Estimated β_1 and population β_1", fontsize=14)
ax2.scatter(x=['beta_1']*50, y=predicted_means_df['beta_1'], marker='o', label="β_1", color='cornflowerblue')
ax2.scatter(x=['beta_1'], y=olsr_model_results.params['number_of_convenience_stores'], marker='o', s=100, label="Population β_1", color='orange')
ax2.set_ylabel("β_1", color='black', fontsize=14)

ax2.tick_params(axis='both', which='major', labelsize=14)

plt.show()

###################################################################################
# Fit a linear model on a sample that leaves out the top 5% most expensive houses #
###################################################################################

#The original model
reg_expr = 'house_price_of_unit_area ~ number_of_convenience_stores'

y, X = dmatrices(reg_expr, data=df_hp, return_type='dataframe')

olsr_model_results = sm.OLS(y, X).fit()

print(olsr_model_results.params)

#Biased sample
df_hp_95p = df_hp[df_hp['house_price_of_unit_area'] < 59.525]

#The biased model
reg_expr = 'house_price_of_unit_area ~ number_of_convenience_stores'

y_95p, X_95p = dmatrices(reg_expr, data=df_hp_95p, return_type='dataframe')

olsr_model_results_95p = sm.OLS(y_95p, X_95p).fit()

print(olsr_model_results_95p.params)

################################################
#  Display the original and the biased models  #
################################################
# Create a scatter plot
plt.figure(figsize=(10, 6))
sns.scatterplot(x='number_of_convenience_stores', y='house_price_of_unit_area', data=df_hp, color='cornflowerblue')

predicted_y = olsr_model_results.predict(X)

sns.lineplot(x=np.array(X['number_of_convenience_stores']), y=np.array(predicted_y), color='orange', marker='o', label='OLS Predicted')

predicted_y_95p = olsr_model_results_95p.predict(X)

sns.lineplot(x=np.array(X['number_of_convenience_stores']), y=np.array(predicted_y_95p), color='red', marker='o', label='OLS Predicted (Biased Coeffs)')

plt.xlabel('Number of Nearby Convenience Stores')
plt.ylabel('House Price per Unit Area')
plt.title('House Price per Unit Area vs. Number of Nearby Convenience Stores')
plt.legend()

# Show the plot
plt.show()


################################################
# Plot House Price versus distance to MRT stop #
################################################

plt.figure(figsize=(10, 6))

sns.scatterplot(x='distance_to_the_nearest_mrt_station', y='house_price_of_unit_area', data=df_hp, color='cornflowerblue')

plt.title('House Price per Unit Area vs Distance to Nearest MRT Station')
plt.xlabel('Distance to the Nearest MRT Station')
plt.ylabel('House Price per Unit Area')
plt.grid(True)

# Show plot
plt.show()

####################################################
####### Fit a log-linear model on this data ########
####################################################

# Compute the log of house_price_of_unit_area
df_hp['log_house_price_of_unit_area'] = np.log(df_hp['house_price_of_unit_area'])

reg_expr = 'log_house_price_of_unit_area ~ distance_to_the_nearest_mrt_station'

y, X = dmatrices(reg_expr, data=df_hp, return_type='dataframe')

log_linear_olsr_model_results = sm.OLS(y, X).fit()

log_linear_olsr_model_results.params

################################################
########## Plot the log-linear model ###########
################################################

plt.figure(figsize=(10, 6))

sns.scatterplot(x='distance_to_the_nearest_mrt_station', y='log_house_price_of_unit_area', data=df_hp, color='cornflowerblue')

predicted_y = log_linear_olsr_model_results.predict(X)

sns.lineplot(x=np.array(X['distance_to_the_nearest_mrt_station']), y=np.array(predicted_y), color='orange', marker='o', label='OLS Predicted')

plt.title('Natural Log of House Price per Unit Area vs Distance to Nearest MRT Station')
plt.xlabel('Distance to the Nearest MRT Station')
plt.ylabel('Natural Log of House Price per Unit Area')
plt.grid(True)

plt.show()


################################################
# Fit linear models on 50 bootstrapped samples #
################################################
estimated_params_log_linear_ols_mrt_model_df = pd.DataFrame(columns=['gamma_0', 'gamma_1'])

regression_expr = 'house_price_of_unit_area ~ distance_to_the_nearest_mrt_station'

for i in range(50):
    sample_df = df_hp.sample(n=50, random_state=np.random.randint(0, 10000))

    y, X = dmatrices(regression_expr, data=sample_df, return_type='dataframe')

    sample_model_results = sm.OLS(y, X).fit()

    gamma_0 = sample_model_results.params['Intercept']
    gamma_1 = sample_model_results.params['distance_to_the_nearest_mrt_station']
    
    estimated_params_log_linear_ols_mrt_model_df.at[i, 'gamma_0'] = gamma_0
    estimated_params_log_linear_ols_mrt_model_df.at[i, 'gamma_1'] = gamma_1


############################################################################
# Plot the Beta_0 and Beta_1 params from the 50 bootstrapped linear models #
############ and the 'population' mean from the log-linear model ###########
############################################################################

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

ax1.set_title("Estimated γ_0 from the linear model and\nthe population e^γ_0 from the log-linear model", fontsize='14')
ax1.set_ylabel("γ_0", color='black', fontsize=14)
ax1.tick_params(axis='both', which='major', labelsize=14)

ax1.scatter(x=['gamma_0']*50, y=estimated_params_log_linear_ols_mrt_model_df['gamma_0'], marker='o', label="Sample γ_0", color='cornflowerblue')
ax1.scatter(x=['gamma_0'], y=np.exp(log_linear_olsr_model_results.params['Intercept']), marker='o', s=100, label="Population γ_0", color='orange')

ax2.set_title("Estimated γ_1 from the linear model and\nthe population γ_1 from the log-linear model", fontsize='14')
ax2.set_ylabel("γ_1", color='black', fontsize=14)
ax2.tick_params(axis='both', which='major', labelsize=14)

ax2.scatter(x=['gamma_1']*50, y=estimated_params_log_linear_ols_mrt_model_df['gamma_1'], marker='o', label="γ_1", color='cornflowerblue')
ax2.scatter(x=['gamma_1'], y=log_linear_olsr_model_results.params['distance_to_the_nearest_mrt_station'], marker='o', s=100, label="Population γ_1", color='orange')

plt.show()
#data M&M https://gist.githubusercontent.com/sachinsdate/a6554f4736299e9ddaf35d795b8b874e/raw/ad736257c3eaa9727f01f9870dbaaa43add3e5e6/m_and_m_sample_weights.csv
#data house https://gist.githubusercontent.com/sachinsdate/a6554f4736299e9ddaf35d795b8b874e/raw/ad736257c3eaa9727f01f9870dbaaa43add3e5e6/taipei_real_estate_prices.csv
#https://gist.githubusercontent.com/sachinsdate/19965de966bb064bae8c7d4c7988a593/raw/72e4ae1cfdb3f0402d66634ceb1567241bb1abb3/taipei_real_estate_prices.csv

# %% removeDuplicate
#https://blog.devops.dev/unlocking-model-performance-essential-feature-selection-techniques-for-data-scientists-26b4c84a6144
import pandas as pd
df = pd.DataFrame({
    "Gender": ["M", "F", "M", "F", "M", "M", "F", "F", "M", "F"],
    "Experience": [2, 3, 5, 6, 7, 8, 9, 5, 4, 3],
    "gender": ["M", "F", "M", "F", "M", "M", "F", "F", "M", "F"],  # Duplicate of "Gender"
    "exp": [2, 3, 5, 6, 7, 8, 9, 5, 4, 3],  # Duplicate of "Experience"
    "Salary": [25000, 30000, 40000, 45000, 50000, 65000, 80000, 40000, 35000, 30000]
})
print("Original DataFrame:")
print(df)
print("*"*60)

# Identify duplicate columns
duplicate_columns = df.columns[df.T.duplicated()]
print(duplicate_columns)
print("*"*60)

# Drop the duplicate columns
columns=df.T[df.T.duplicated()].T
df.drop(columns,axis=1,inplace=True)

# Display the DataFrame after removing duplicate columns
print("\nDataFrame after removing duplicate columns:")
print(df)

# %% remLowVar
from sklearn.datasets import load_breast_cancer
from sklearn.feature_selection import VarianceThreshold
import pandas as pd

# Load the Breast Cancer dataset
X, y = load_breast_cancer(return_X_y=True, as_frame=True)

# Display the shape of the original feature set
print("Original Shape: ", X.shape)
print("*" * 60)

# Initialize VarianceThreshold with a threshold of 0.03
# This will filter out features with variance below 0.03
vth = VarianceThreshold(threshold=0.03)

# Fit the VarianceThreshold and transform the data
# This removes features with low variance
X_filtered = vth.fit_transform(X)

# Display the shape of the filtered feature set
print("Filtered Shape: ", X_filtered.shape)

# Display feature names after filtering
# Note: VarianceThreshold does not have get_feature_names_out() method
# The following line may not work and could be omitted or replaced with manual feature names
print(vth.get_feature_names_out())
print("*" * 60)

# Create a DataFrame with the filtered features
# Feature names might not be available, so using generic names instead
X_filtered_df = pd.DataFrame(X_filtered, columns=vth.get_feature_names_out())

# Display the filtered DataFrame
print(X_filtered_df)

# %% chi2
import pandas as pd
from scipy.stats import chi2_contingency

# Sample dataset
data = {
    'Gender': ['Male', 'Female', 'Female', 'Male', 'Female', 'Male', 'Male', 'Female', 'Female', 'Male'],
    'Marital_Status': ['Married', 'Single', 'Married', 'Single', 'Married', 'Single', 'Married', 'Single', 'Single', 'Married'],
    'Purchased': ['No', 'Yes', 'Yes', 'No', 'Yes', 'No', 'Yes', 'No', 'Yes', 'No']
}

df = pd.DataFrame(data)
print("Sample Data:")
print(df)

# Create crosstab between Gender and Purchased
crosstab = pd.crosstab(df['Gender'], df['Purchased'])
print("\nCrosstab (Contingency Table):")
print(crosstab)

# Perform Chi-Square test
chi2, p, dof, expected = chi2_contingency(crosstab)

print("\nChi-Square Test Results:")
print(f"Chi-Square Statistic: {chi2}")
print(f"P-value: {p}")
print(f"Degrees of Freedom: {dof}")
print("Expected Frequencies:")
print(expected)

# Interpretation
if p < 0.05:
    print("\nConclusion: There is a significant relationship between Gender and Purchased.")
else:
    print("\nConclusion: There is no significant relationship between Gender and Purchased.")

# %% ANOVA
import pandas as pd
from scipy.stats import f_oneway

# Sample dataset
data = {
    'Education_Level': ['High School', 'Bachelor', 'Master', 'High School', 'Bachelor', 'Master', 'Bachelor', 'Master', 'High School'],
    'Income': [40000, 55000, 70000, 42000, 58000, 72000, 60000, 75000, 41000]
}

df = pd.DataFrame(data)
print("Sample Data:")
print(df)

# Group the data by 'Education_Level'
groups = df.groupby('Education_Level')['Income'].apply(list)

# Perform ANOVA
f_statistic, p_value = f_oneway(*groups)

print("\nANOVA Test Results:")
print(f"F-Statistic: {f_statistic}")
print(f"P-value: {p_value}")

# Interpretation
if p_value < 0.05:
    print("\nConclusion: There is a significant difference in Income between different Education Levels.")
else:
    print("\nConclusion: There is no significant difference in Income between different Education Levels.")
Output :

# %% corrHeatMap
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Sample data
data = {'Hours_Studied': [1, 2, 3, 4, 5],
        'Exam_Score': [50, 55, 60, 70, 75]}
df = pd.DataFrame(data)
fig, axes = plt.subplots(1, 2, figsize=(12,5))
plt.subplots_adjust(hspace=0.3, wspace=0.3)

# Pearson Correlation
correlation = df.corr(method="pearson")
sns.heatmap(correlation,annot=True,ax=axes[0])
sns.lineplot(x=df["Hours_Studied"],y=df["Exam_Score"],ax=axes[1])
O

# %% MI

import pandas as pd
from sklearn.feature_selection import mutual_info_classif
from sklearn.preprocessing import OneHotEncoder

# Sample dataset
data = {
    'Gender': ['Male', 'Female', 'Female', 'Male', 'Female', 'Male', 'Male', 'Female', 'Female', 'Male'],
    'Education_Level': ['High School', 'Bachelor', 'Master', 'PhD', 'High School', 'Bachelor', 'Master', 'PhD', 'Bachelor', 'Master'],
    'Income': ['Low', 'Medium', 'High', 'High', 'Low', 'Medium', 'High', 'High', 'Medium', 'High'],
    'Target': [0, 1, 1, 0, 0, 1, 1, 1, 1, 0]
}

df = pd.DataFrame(data)
print("Sample Data:")
print(df)

# OneHotEncode categorical features
encoder = OneHotEncoder(sparse_output=False)
encoded_features = encoder.fit_transform(df[['Gender', 'Education_Level', 'Income']])

# Convert the encoded features into a DataFrame
encoded_df = pd.DataFrame(encoded_features, columns=encoder.get_feature_names_out())

# Calculate mutual information
mi_scores = mutual_info_classif(encoded_df, df['Target'], discrete_features=True)

# Create a DataFrame to display the MI scores
mi_df = pd.DataFrame({'Feature': encoded_df.columns, 'Mutual Information': mi_scores})
mi_df = mi_df.sort_values(by='Mutual Information', ascending=False)
print("\nMutual Information Scores:")
sns.barplot(x=mi_df["Feature"],y=mi_df["Mutual Information"],hue=mi_df["Feature"])
plt.xticks(rotation=90)
print(mi_df)
Output :
  
# %% select

f_classif: ANOVA F-value between label/feature for classification tasks.
chi2: Chi-square test for independence.
mutual_info_classif: Mutual information for classification.
2. Select the Best Features: Based on the scoring function, it ranks all features and selects the top k features.
import pandas as pd
import numpy as np
from sklearn.datasets import load_iris
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# 1. Load Data
data = load_iris()
X = data.data
y = data.target

# Convert to DataFrame for better visualization
df = pd.DataFrame(X, columns=data.feature_names)
df['target'] = y


# 2. SelectKBest
# We use the ANOVA F-value as the scoring function for classification tasks.
selector = SelectKBest(score_func=f_classif, k=3)  # Select the top 3features
X_new = selector.fit_transform(X, y)

# Display the scores and selected features
scores = selector.scores_
selected_features = np.array(data.feature_names)[selector.get_support()]
print("\nFeature Scores:\n", scores)
print("\nSelected Features:\n", selected_features)

# 3. Train-Test Split
X_train, X_test, y_train, y_test = train_test_split(X_new, y, test_size=0.2, random_state=42)

# 4. Train a Model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# 5. Evaluate the Model
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print("\nModel Accuracy with Selected Features:", accuracy)

# %% sbest

import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from mlxtend.feature_selection import ExhaustiveFeatureSelector
from sklearn.metrics import accuracy_score

# Load the iris dataset
data = load_iris()
X = pd.DataFrame(data.data, columns=data.feature_names)
y = pd.Series(data.target)

# Split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Initialize the model
model = LogisticRegression(max_iter=200)

# Initialize the Exhaustive Feature Selector
efs = ExhaustiveFeatureSelector(
    estimator=model,
    min_features=1,
    max_features=3,
    scoring='accuracy',
    cv=5,
    n_jobs=-1
)

# Perform the feature selection
efs = efs.fit(X_train, y_train)

# Get the best feature subset and its score
best_features = efs.best_feature_names_
best_score = efs.best_score_

print("Best Feature Subset:", best_features)
print("Best Accuracy Score:", best_score)

# %% fwd

import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.feature_selection import SequentialFeatureSelector
from sklearn.metrics import mean_squared_error

# Sample data
data = pd.DataFrame({
    'X1': [1, 2, 3, 4, 5],
    'X2': [2, 3, 4, 5, 6],
    'X3': [5, 6, 7, 8, 9],
    'Y': [1, 2, 1, 2, 1]
})

# Splitting the data
X = data[['X1', 'X2', 'X3']]
y = data['Y']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

# Forward Selection
forward_selector = SequentialFeatureSelector(
    estimator=LinearRegression(),
    n_features_to_select='auto',  # Can specify number of features or use 'auto'
    direction='forward',
    scoring='neg_mean_squared_error',
    cv=4  # Cross-validation
)

# Fit the model
forward_selector.fit(X_train, y_train)
print("Forward Selection - Selected features:", X_train.columns[forward_selector.get_support()].tolist())

# Backward Elimination
backward_selector = SequentialFeatureSelector(
    estimator=LinearRegression(),
    n_features_to_select='auto',  # Can specify number of features or use 'auto'
    direction='backward',
    scoring='neg_mean_squared_error',
    cv=4  # Cross-validation
)

# Fit the model
backward_selector.fit(X_train, y_train)
print("Backward Elimination - Selected features:", X_train.columns[backward_selector.get_support()].tolist())

# %% RFE
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris
import pandas as pd

# Load data
X, y = load_iris(return_X_y=True)

# Apply Random Forest
rf = RandomForestClassifier()
rf.fit(X, y)

# Get feature importances
feature_importances = rf.feature_importances_
feature_names = load_iris().feature_names
importance_df = pd.DataFrame({'Feature': feature_names, 'Importance': feature_importances})
print(importance_df.sort_values(by='Importance', ascending=False))

# %% utlier
import numpy as np
import pandas as pd
from scipy import stats
from sklearn.datasets import load_iris
import matplotlib.pyplot as plt

# Load the iris dataset
iris = load_iris()
data = pd.DataFrame(iris.data, columns=iris.feature_names)
# Calculate Z-scores
z_scores = np.abs(stats.zscore(data))
threshold = 3
outliers = np.where(z_scores > threshold)

# Remove outliers
data_zs = data[(z_scores < threshold).all(axis=1)]

print("Data shape before outlier removal:", data.shape)
print("Data shape after outlier removal (Z-Score):", data_zs.shape)
# Visualization
plt.figure(figsize=(12, 6))
plt.scatter(data.iloc[:, 0], data.iloc[:, 1], color='blue', label='Original Data')
plt.scatter(data_zs.iloc[:, 0], data_zs.iloc[:, 1], color='red', label='Data without Outliers (Z-Score)')
plt.xlabel(iris.feature_names[0])
plt.ylabel(iris.feature_names[1])
plt.title('Z-Score Method for Outlier Detection')
plt.legend()
plt.show()
# Calculate Q1 (25th percentile) and Q3 (75th percentile)
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

# Identify outliers
outliers = ((data < (Q1 - 1.5 * IQR)) | (data > (Q3 + 1.5 * IQR))).any(axis=1)

# Remove outliers
data_iqr = data[~outliers]

print("Data shape before outlier removal:", data.shape)
print("Data shape after outlier removal (IQR):", data_iqr.shape)


# Visualization
plt.figure(figsize=(12, 6))
plt.scatter(data.iloc[:, 0], data.iloc[:, 1], color='blue', label='Original Data')
plt.scatter(data_iqr.iloc[:, 0], data_iqr.iloc[:, 1], color='red', label='Data without Outliers (IQR)')
plt.xlabel(iris.feature_names[0])
plt.ylabel(iris.feature_names[1])
plt.title('IQR Method for Outlier Detection')
plt.legend()
plt.show()
from sklearn.ensemble import IsolationForest

# Initialize the model
iso_forest = IsolationForest(contamination=0.1)

# Fit the model
outliers = iso_forest.fit_predict(data)

# Remove outliers
data_if = data[outliers == 1]

print("Data shape before outlier removal:", data.shape)
print("Data shape after outlier removal (Isolation Forest):", data_if.shape)

# Visualization
plt.figure(figsize=(12, 6))
plt.scatter(data.iloc[:, 0], data.iloc[:, 1], color='blue', label='Original Data')
plt.scatter(data_if.iloc[:, 0], data_if.iloc[:, 1], color='red', label='Data without Outliers (Isolation Forest)')
plt.xlabel(iris.feature_names[0])
plt.ylabel(iris.feature_names[1])
plt.title('Isolation Forest for Outlier Detection')
plt.legend()
plt.show()
from sklearn.cluster import DBSCAN

# Initialize the model
dbscan = DBSCAN(eps=0.5, min_samples=5)

# Fit the model
clusters = dbscan.fit_predict(data)

# Identify outliers (points labeled as -1 are outliers)
outliers = clusters == -1

# Remove outliers
data_dbscan = data[~outliers]

print("Data shape before outlier removal:", data.shape)
print("Data shape after outlier removal (DBSCAN):", data_dbscan.shape)


# Visualization
plt.figure(figsize=(12, 6))
plt.scatter(data.iloc[:, 0], data.iloc[:, 1], color='blue', label='Original Data')
plt.scatter(data_dbscan.iloc[:, 0], data_dbscan.iloc[:, 1], color='red', label='Data without Outliers (DBSCAN)')
plt.xlabel(iris.feature_names[0])
plt.ylabel(iris.feature_names[1])
plt.title('DBSCAN for Outlier Detection')
plt.legend()
plt.show()

# %% timeSeriesOutliers
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Generate a date range (e.g., daily data for one year)
date_range = pd.date_range(start='2023-01-01', periods=365, freq='D')

# Generate synthetic data (e.g., daily temperatures with some noise)
np.random.seed(42)  # For reproducibility
data = 20 + 10 * np.sin(2 * np.pi * date_range.dayofyear / 365) + np.random.normal(0, 2, len(date_range))
# Create a DataFrame
df = pd.DataFrame({'Date': date_range, 'Value': data})
df.set_index('Date', inplace=True)  # Set the date range as the index
# Plot the time series
plt.figure(figsize=(15, 5))
plt.plot(df.index, df['Value'], label='Synthetic Time Series')
plt.title('Synthetic Time Series Data')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
# Ensure data is a NumPy array
data = np.array(data)
# Add outliers
outlier_indices = np.random.choice(len(data), size=5, replace=False)  # Randomly select 5 indices

# Modify the NumPy array directly
data_with_outliers = data.copy()  # Create a copy of data to avoid modifying in place

# Add outliers by adding large anomalies to the selected indices
data_with_outliers[outlier_indices] = data_with_outliers[outlier_indices] + np.random.normal(15, 5, size=outlier_indices.shape[0])

# Create DataFrame
df = pd.DataFrame({'Date': date_range, 'Value': data_with_outliers})
df.set_index('Date', inplace=True)

# Visualize the original time series
plt.figure(figsize=(15,5))
plt.plot(df.index, df['Value'], label='Time Series Data')
plt.title('Synthetic Time Series Data with Outliers')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
# Calculate rolling statistics
window_size = 15
rolling_mean = df['Value'].rolling(window=window_size).mean()
rolling_std = df['Value'].rolling(window=window_size).std()

# Define threshold (e.g., 3 standard deviations)
threshold = 3

# Identify outliers
outliers = df[np.abs(df['Value'] - rolling_mean) > threshold * rolling_std]

# Visualize the results
plt.figure(figsize=(15,5))
plt.plot(df.index, df['Value'], label='Original Data')
plt.plot(df.index, rolling_mean, color='orange', label='Rolling Mean')
plt.scatter(outliers.index, outliers['Value'], color='red', label='Detected Outliers')
plt.title('Outlier Detection using Rolling Statistics')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
from statsmodels.tsa.seasonal import seasonal_decompose

# Apply seasonal decomposition
decomposition = seasonal_decompose(df['Value'], model='additive', period=30)

# Plot decomposed components
fig = decomposition.plot()
fig.set_size_inches(15, 8)
plt.show()

# Extract residuals and identify outliers using Z-score
residual = decomposition.resid.dropna()
z_scores = np.abs((residual - residual.mean()) / residual.std())
outliers_decomp = residual[z_scores > 3]

# Visualize the results
plt.figure(figsize=(15,5))
plt.plot(df.index, df['Value'], label='Original Data')
plt.scatter(outliers_decomp.index, df.loc[outliers_decomp.index]['Value'], color='red', label='Detected Outliers')
plt.title('Outlier Detection using Seasonal Decomposition')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
from prophet import Prophet

# Prepare the data for Prophet
df_prophet = df.reset_index().rename(columns={'Date': 'ds', 'Value': 'y'})

# Fit the Prophet model
model = Prophet()
model.fit(df_prophet)

# Create a dataframe with future dates for prediction (not necessary here)
future = model.make_future_dataframe(periods=0)
forecast = model.predict(future)

# Calculate residuals
df_prophet['yhat'] = forecast['yhat']
df_prophet['residual'] = df_prophet['y'] - df_prophet['yhat']

# Identify anomalies (3 standard deviations away from the mean)
std_residual = np.std(df_prophet['residual'])
threshold = 3 * std_residual
df_prophet['anomaly'] = df_prophet['residual'].apply(lambda x: 1 if np.abs(x) > threshold else 0)

# Extract anomalies
anomalies_prophet = df_prophet[df_prophet['anomaly'] == 1]

# Visualize the results
plt.figure(figsize=(15,5))
plt.plot(df_prophet['ds'], df_prophet['y'], label='Actual')
plt.plot(df_prophet['ds'], df_prophet['yhat'], label='Predicted')
plt.scatter(anomalies_prophet['ds'], anomalies_prophet['y'], color='red', label='Anomalies')
plt.title('Anomaly Detection using Prophet')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import IsolationForest


# Reshape the data to 2D array (required by IsolationForest)
X = df['Value'].values.reshape(-1, 1)

# Apply Isolation Forest
iso_forest = IsolationForest(contamination=0.01, random_state=42)
df['Anomaly'] = iso_forest.fit_predict(X)

# Anomalies are labeled as -1, normal points as 1
outliers = df[df['Anomaly'] == -1]
normal_data = df[df['Anomaly'] == 1]

# Remove the outliers
df_cleaned = df[df['Anomaly'] == 1]

# Plot the original time series with detected outliers
plt.figure(figsize=(15, 5))
plt.plot(df.index, df['Value'], label='Original Data with Outliers')
plt.scatter(outliers.index, outliers['Value'], color='red', label='Detected Outliers')
plt.title('Outlier Detection with Isolation Forest')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()

# Plot the cleaned time series after removing outliers
plt.figure(figsize=(15, 5))
plt.plot(df_cleaned.index, df_cleaned['Value'], label='Cleaned Data (Outliers Removed)')
plt.title('Time Series Data after Outlier Removal using Isolation Forest')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.arima.model import ARIMA
from scipy import stats

# Fit an ARIMA model
model = ARIMA(df['Value'], order=(5, 1, 0))  # Here (5, 1, 0) are the ARIMA parameters, adjust as needed
model_fit = model.fit()

# Get the residuals from the model
df['Residuals'] = model_fit.resid

# Plot residuals
plt.figure(figsize=(15, 5))
plt.plot(df.index, df['Residuals'], label='Residuals')
plt.axhline(y=0, color='red', linestyle='--')
plt.title('Residuals from ARIMA Model')
plt.xlabel('Date')
plt.ylabel('Residuals')
plt.legend()
plt.show()

# Detect outliers using Z-score
z_scores = np.abs(stats.zscore(df['Residuals']))
df['Outlier'] = z_scores > 3  # Mark as outlier if Z-score is greater than 3

# Remove the outliers
df_cleaned = df[df['Outlier'] == False]

# Plot the original time series with detected outliers
plt.figure(figsize=(15, 5))
plt.plot(df.index, df['Value'], label='Original Data with Outliers')
plt.scatter(df[df['Outlier']].index, df[df['Outlier']]['Value'], color='red', label='Detected Outliers')
plt.title('Outlier Detection with ARIMA Residual Analysis')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()

# Plot the cleaned time series after removing outliers
plt.figure(figsize=(15, 5))
plt.plot(df_cleaned.index, df_cleaned['Value'], label='Cleaned Data (Outliers Removed)')
plt.title('Time Series Data after Outlier Removal using ARIMA Residuals')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend()
plt.show()

# %% PCA
#https://towardsdatascience.com/principal-component-analysis-hands-on-tutorial-3a451ff3d5db
#pip install numpy pandas scikit-learn scikit-image matplotlib gensim -q
# import libraries
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
%matplotlib inline
# load the dataset
iris = load_iris()
X = iris.data
y = iris.target

# standardize the data
scaler = StandardScaler()
X_std = scaler.fit_transform(X)

# apply pca
pca = PCA(n_components=2)
principal_components = pca.fit_transform(X_std)
# dataframe of principal components
principal_df = pd.DataFrame(data=principal_components, columns=['PC1', 'PC2'])
final_df = pd.concat([principal_df, pd.DataFrame(y, columns=['target'])], axis=1)

# visualization
plt.figure(figsize=(8,6))
targets = [0, 1, 2]
colors = ['r', 'g', 'b']
for target, color in zip(targets, colors):
    indices = final_df['target'] == target
    plt.scatter(final_df.loc[indices, 'PC1'],
                final_df.loc[indices, 'PC2'],
                c=color,
                s=50)
plt.legend(iris.target_names)
plt.xlabel('Principal Component 1')
plt.ylabel('Principal Component 2')
plt.title('PCA of Iris Dataset')
plt.show()
# load the dataset
iris = load_iris()
X = iris.data

# standardize the data
scaler = StandardScaler()
X_std = scaler.fit_transform(X)

# apply pca (keep all 4 features to see the original variance)
pca = PCA(n_components=4)
pca.fit(X_std)

# calculate explained variance ratio for each principal component
explained_variance = pca.explained_variance_ratio_

# calculate cumulative explained variance
cumulative_variance = np.cumsum(explained_variance)

# visualize
plt.figure(figsize=(6,4))
plt.plot(range(1, len(cumulative_variance)+1), cumulative_variance, marker='o', linestyle='--', color='b')
plt.title('Cumulative Explained Variance')
plt.xlabel('Number of Principal Components')
plt.ylabel('Cumulative Explained Variance')
plt.grid()
plt.show()

#text
# import libraries
import gensim.downloader as api
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
%matplotlib inline

# load pre-trained word embedding
model = api.load('glove-wiki-gigaword-50')  # 50-dimensional embeddings
model['medium']
# select 10 random words
words = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'brown', 'black', 'white']
word_vectors = [model[word] for word in words]

# apply pca
pca = PCA(n_components=2)
components = pca.fit_transform(word_vectors)

# visualize 2-dimensional embeddings
plt.figure(figsize=(8,6))
for i, word in enumerate(words):
    plt.scatter(components[i,0], components[i,1])
    plt.annotate(word, (components[i,0], components[i,1]))
plt.title('PCA of Word Embeddings')
plt.xlabel('Principal Component 1')
plt.ylabel('Principal Component 2')
plt.show()
# reduce to 10 dimensions
pca_10d = PCA(n_components=10)
word_vectors_10d = pca_10d.fit_transform(word_vectors)

# explained variance ratio
explained_variance_ratio_10d = pca_10d.explained_variance_ratio_

# cumulative variance
cumulative_variance_10d = np.cumsum(explained_variance_ratio_10d)

# plot
plt.figure(figsize=(8, 6))
plt.plot(range(1, 11), cumulative_variance_10d, marker='o', linestyle='--', color='b')
plt.title('Cumulative Explained Variance for 10 Principal Components')
plt.xlabel('Number of Principal Components')
plt.ylabel('Cumulative Explained Variance')
plt.xticks(range(1, 11))
plt.grid()
plt.show()

#image
# import libraries
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from skimage import io, color

# load the image
image = io.imread('icecream.jpg')

# convert to gray scale
gray_image = color.rgb2gray(image)

# get the original size and shape of the image before any further changes
original_size = gray_image.size
original_shape = gray_image.shape
print(f"Original Image Size (number of pixels): {original_size}")
print(f"Original Image Shape: {original_shape}")

# standardize and flatten the image, since pca requires a matrix (each row is a pixel and each column is a feature after flatenning)
h, w = gray_image.shape
flat_image = gray_image - np.mean(gray_image, axis=0)

# pca down to 50 dimensions
pca = PCA(n_components=50)
image_pca = pca.fit_transform(flat_image)

# get the size and shape of the dimensionality-reduced/transformed image
reduced_size = image_pca.size + pca.components_.size
reduced_shape = image_pca.shape
print(f"Reduced Image Size (number of pixels, after PCA): {reduced_size}")
print(f"Reduced Image Shape (after PCA): {reduced_shape}")
# reconstruct the transformed image so that we can view it later
reconstructed_image = pca.inverse_transform(image_pca)

# plot images side by side
plt.figure(figsize=(12, 6))

# original image
plt.subplot(1, 2, 1)
plt.imshow(gray_image, cmap='gray')
plt.title("Original Image")
plt.axis('off')

# transformed image
plt.subplot(1, 2, 2)
plt.imshow(reconstructed_image, cmap='gray')
plt.title("Reconstructed Image (PCA)")
plt.axis('off')
plt.show()
# explained information/variance
explained_variance = pca.explained_variance_ratio_
cumulative_variance = np.cumsum(explained_variance)

# plot
plt.figure(figsize=(8, 6))
plt.plot(range(1, len(cumulative_variance) + 1), cumulative_variance, marker='o', linestyle='--', color='b')
plt.title('Cumulative Explained Variance for PCA Components')
plt.xlabel('Number of Principal Components')
plt.ylabel('Cumulative Explained Variance')
plt.grid()
plt.show()

# %% optimize-classificaton
#https://towardsdatascience.com/calibrating-classification-probabilities-the-right-way-da935caee18d
from sklearn.datasets import make_classification
2	from sklearn.model_selection import train_test_split
3	from sklearn.naive_bayes import GaussianNB
4	from venn_abers import VennAbersCalibrator
5	
6	X, y = make_classification(n_samples=1000, n_classes=2, n_informative=10, test_size=0.2)
7	X_train, X_test, y_train, y_test = train_test_split(X, y)
8	
9	# Define Venn-ABERS predictor
10	va = VennAbersCalibrator(estimator=GaussianNB(), inductive=True, cal_size=0.2, random_state=42)
11	
12	# Fit on the training set
13	va.fit(X_train, y_train)
14	
15	# Generate probabilities and class predictions on the test set
16	p_prime = va.predict_proba(X_test)
17	y_pred = va.predict(X_test)
# Create calibration set
2	X_train, X_cal, y_train, y_cal = train_test_split(X_train, y_train, test_size=0.2)
3	
4	# Fit classifier on training set
5	clf = GaussianNB()
6	clf.fit(X_train, y_train)
7	
8	# Define Venn-ABERS predictor
9	VAC = VennAbersCalibrator()
10	
11	# Generate uncalibrated probabilities on the calibration and test set
12	p_cal = clf.predict_proba(X_cal)
13	p_test = clf.predict_proba(X_test)
14	
15	# Calibrate probabilities on the calibration set and generate calibrated probabilities on the test set
16	p_prime, p0_p1 = VAC.predict_proba(p_cal=p_cal, y_cal=y_cal, p_test=p_test, p0_p1_output=True)

# %% PCApretty
X = data.drop("quality", axis=1)
y = data["quality"]

X_scaled = StandardScaler().fit_transform(X)

pca = PCA().fit(X_scaled)
pca_res = pca.transform(X_scaled)

pca_res_df = pd.DataFrame(pca_res, columns=[f"PC{i}" for i in range(1, pca_res.shape[1] + 1)])
pca_res_df.head()
#https://archive.ph/o/EeKE8/https://fonts.google.com/specimen/Roboto+Condensed
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager

import matplotlib_inline
matplotlib_inline.backend_inline.set_matplotlib_formats("svg")

font_dir = ["Roboto_Condensed"]
for font in font_manager.findSystemFonts(font_dir):
    font_manager.fontManager.addfont(font)

plt.rcParams["figure.figsize"] = 10, 6
plt.rcParams["axes.spines.top"] = False
plt.rcParams["axes.spines.right"] = False
plt.rcParams["font.size"] = 14
plt.rcParams["figure.titlesize"] = "xx-large"
plt.rcParams["xtick.labelsize"] = "medium"
plt.rcParams["ytick.labelsize"] = "medium"
plt.rcParams["axes.axisbelow"] = True
plt.rcParams["font.family"] = "Roboto Condensed"
plot_y = [val * 100 for val in pca.explained_variance_ratio_]
plot_x = range(1, len(plot_y) + 1)

bars = plt.bar(plot_x, plot_y, align="center", color="#1C3041", edgecolor="#000000", linewidth=1.2)
for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, yval + 0.001, f"{yval:.1f}%", ha="center", va="bottom")

plt.xlabel("Principal Component")
plt.ylabel("Percentage of Explained Variance")
plt.title("Variance Explained per Principal Component", loc="left", fontdict={"weight": "bold"}, y=1.06)
plt.grid(axis="y")
plt.xticks(plot_x)

plt.show()
exp_var = [val * 100 for val in pca.explained_variance_ratio_]
plot_y = [sum(exp_var[:i+1]) for i in range(len(exp_var))]
plot_x = range(1, len(plot_y) + 1)

plt.plot(plot_x, plot_y, marker="o", color="#9B1D20")
for x, y in zip(plot_x, plot_y):
    plt.text(x, y + 1.5, f"{y:.1f}%", ha="center", va="bottom")

plt.xlabel("Principal Component")
plt.ylabel("Cumulative Percentage of Explained Variance")
plt.title("Cumulative Variance Explained per Principal Component", loc="left", fontdict={"weight": "bold"}, y=1.06)

plt.yticks(range(0, 101, 5))
plt.grid(axis="y")
plt.xticks(plot_x)

plt.show()
total_explained_variance = sum(pca.explained_variance_ratio_[:2]) * 100
colors = ["#1C3041", "#9B1D20", "#0B6E4F", "#895884", "#F07605", "#F5E400"]

pca_2d_df = pd.DataFrame(pca_res[:, :2], columns=["PC1", "PC2"])
pca_2d_df["y"] = data["quality"]

fig, ax = plt.subplots()
for i, target in enumerate(sorted(pca_2d_df["y"].unique())):
    subset = pca_2d_df[pca_2d_df["y"] == target]
    ax.scatter(x=subset["PC1"], y=subset["PC2"], s=70, alpha=0.7, c=colors[i], edgecolors="#000000", label=target)

plt.xlabel("Principal Component 1")
plt.ylabel("Principal Component 2")
plt.title(f"Wine Quality Dataset PCA ({total_explained_variance:.2f}% Explained Variance)", loc="left", fontdict={"weight": "bold"}, y=1.06)

ax.legend(title="Wine quality")
plt.show()
total_explained_variance = sum(pca.explained_variance_ratio_[:3]) * 100
colors = ["#1C3041", "#9B1D20", "#0B6E4F", "#895884", "#F07605", "#F5E400"]

pca_3d_df = pd.DataFrame(pca_res[:, :3], columns=["PC1", "PC2", "PC3"])
pca_3d_df["y"] = data["quality"]

fig = plt.figure(figsize=(10, 10))
ax = fig.add_subplot(projection="3d")

for i, target in enumerate(sorted(pca_3d_df["y"].unique())):
    subset = pca_3d_df[pca_3d_df["y"] == target]
    ax.scatter(xs=subset["PC1"], ys=subset["PC2"], zs=subset["PC3"], s=70, alpha=0.7, c=colors[i], edgecolors="#000000", label=target)

ax.set_xlabel("Principal Component 1")
ax.set_ylabel("Principal Component 2")
ax.set_zlabel("Principal Component 3")
ax.set_title(f"Wine Quality Dataset PCA ({total_explained_variance:.2f}% Explained Variance)", loc="left", fontdict={"weight": "bold"})

ax.legend(title="Wine quality", loc="lower left")
plt.show()
ax.view_init(elev=<value>, azim=<value>)
#biplot
labels = X.columns
n = len(labels)
coeff = np.transpose(pca.components_)
pc1 = pca.components_[:, 0]
pc2 = pca.components_[:, 1]

plt.figure(figsize=(8, 8))

for i in range(n):
    plt.arrow(x=0, y=0, dx=coeff[i, 0], dy=coeff[i, 1], color="#000000", width=0.003, head_width=0.03)
    plt.text(x=coeff[i, 0] * 1.15, y=coeff[i, 1] * 1.15, s=labels[i], size=13, color="#000000", ha="center", va="center")

plt.axis("square")
plt.title(f"Wine Quality Dataset PCA Biplot", loc="left", fontdict={"weight": "bold"}, y=1.06)
plt.xlabel("Principal Component 1")
plt.ylabel("Principal Component 2")

plt.xlim(-1, 1)
plt.ylim(-1, 1)
plt.xticks(np.arange(-1, 1.1, 0.2))
plt.yticks(np.arange(-1, 1.1, 0.2))

plt.axhline(y=0, color="black", linestyle="--")
plt.axvline(x=0, color="black", linestyle="--")
circle = plt.Circle((0, 0), 0.99, color="gray", fill=False)
plt.gca().add_artist(circle)

plt.grid()
plt.show()
loadings = pd.DataFrame(
    data=pca.components_.T * np.sqrt(pca.explained_variance_), 
    columns=[f"PC{i}" for i in range(1, len(X.columns) + 1)],
    index=X.columns
)

fig, axs = plt.subplots(2, 2, figsize=(14, 10), sharex=True, sharey=True)
colors = ["#1C3041", "#9B1D20", "#0B6E4F", "#895884"]

for i, ax in enumerate(axs.flatten()):
    explained_variance = pca.explained_variance_ratio_[i] * 100
    pc = f"PC{i+1}"
    bars = ax.bar(loadings.index, loadings[pc], color=colors[i], edgecolor="#000000", linewidth=1.2)
    ax.set_title(f"{pc} Loading Scores ({explained_variance:.2f}% Explained Variance)", loc="left", fontdict={"weight": "bold"}, y=1.06)
    ax.set_xlabel("Feature")
    ax.set_ylabel("Loading Score")
    ax.grid(axis="y")
    ax.tick_params(axis="x", rotation=90)
    ax.set_ylim(-1, 1)
    
    for bar in bars:
        yval = bar.get_height()
        offset = yval + 0.02 if yval > 0 else yval - 0.15
        ax.text(bar.get_x() + bar.get_width() / 2, offset, f"{yval:.2f}", ha="center", va="bottom")

plt.tight_layout()
plt.show()

# %% power-transform 
#https://pub.towardsai.net/mathematical-transformations-in-feature-engineering-log-reciprocal-and-power-transforms-5d7a3b7146ac
from sklearn.preprocessing import PowerTransformer
# Apply Power Transform (Box-Cox)
pt = PowerTransformer(method='box-cox', standardize=False)
df['Power_Transform'] = pt.fit_transform(df[['Skewed_Value']])
# QQPlot after Power Transformation
sm.qqplot(df['Power_Transform'], line='45')
plt.title('QQPlot After Power Transformation')
plt.show()
# distplot after Power Transformation
sns.distplot(df['Power_Transform'], kde=True)
plt.title('Distribution After Power Transformation')
plt.show()

# %% boost 
#https://medium.com/internet-of-technology/gps-vs-linear-regression-vs-xgboost-886fac83d5a3
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Load data.
data = pd.read_csv("stats/response_stats.csv")

# Separate features and target.
X = data[["Likes", "Comments", "Read Time"]]
y = data["Earnings"]
X["Title"] = data["Title"]

# (Optional) I will be working with earnings, earnings cannot be negative,
# therefore I have converted the y-values to logarithmic scale.
y += 1
y = np.log(y)

# Split data into training and test sets.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.10, random_state=42)

# (Optional) Save titles.
test_titles = X_test["Title"]
X_train = X_train.drop(columns="Title")
X_test = X_test.drop(columns="Title")

from xgboost import XGBRegressor

# Initialize and train the XGBoost model.
model = XGBRegressor(objective='reg:squarederror', n_estimators=100)
model.fit(X_train, y_train)

# Predict on the test set.
y_pred = model.predict(X_test)
y_pred = np.exp(y_pred) - 1

# Evaluate the model
mse = mean_squared_error(np.exp(y_test) - 1, y_pred)
r2 = r2_score(np.exp(y_test) - 1, y_pred)  # (Optional) Omit if you don't use logarithmic scaling.

print(f"MSE: {mse:.2f}")
print(f"R2 Score: {r2:.2f}")

# (Optional) Print the title, actual earnings, and predicted earnings.
for title, actual, predicted in zip(test_titles, np.exp(y_test) - 1, y_pred):
    print(f"Title: {title}, Actual Earnings: ${actual:.2f}, Predicted Earnings: ${predicted:.2f}")


# %% LM
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score

# Scale features.
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Initialize and train the linear regression model.
model = LinearRegression()
model.fit(X_train_scaled, y_train)

# Predict on the test set.
y_pred = model.predict(X_test_scaled)
y_pred = np.exp(y_pred) - 1  # (Optional) Omit if you don't use logarithmic scaling.

# Evaluate the model.
mse = mean_squared_error(np.exp(y_test) - 1, y_pred)
r2 = r2_score(np.exp(y_test) - 1, y_pred)

print(f"MSE: {mse:.2f}")
print(f"R2 Score: {r2:.2f}")

# (Optional) Print the title, actual earnings, and predicted earnings.
for title, actual, predicted in zip(test_titles, np.exp(y_test) - 1, y_pred):
    print(f"Title: {title}, Actual Earnings: ${actual:.2f}, Predicted Earnings: ${predicted:.2f}")

# %% GP
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import ConstantKernel as C, WhiteKernel
from sklearn.gaussian_process.kernels import RationalQuadratic

# Load data.
data = pd.read_csv("stats/response_stats.csv")

# Separate features and target.
X = data[["Likes", "Comments", "Read Time"]]
y = data["Earnings"]
X["Title"] = data["Title"]

# Split data into training and test sets.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.10, random_state=42)

# (Optional) Save titles from the test set.
test_titles = X_test["Title"]
X_train = X_train.drop(columns="Title")
X_test = X_test.drop(columns="Title")

# Scale features.
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# (Optional) Convert targets to logarithmic scale.
y_train_log = np.log(y_train + 1)
y_test_log = np.log(y_test + 1)

# Define the kernel and train the Gaussian Process.
# The hyperparameters are tuned and kernel is chosen for this problem.
kernel = C(1.0, (1e-2, 1e2)) * RationalQuadratic(length_scale=39.28455176212197, alpha=8.362426847738403) + WhiteKernel(noise_level=0.33739616048352883)
gp = GaussianProcessRegressor(kernel=kernel, n_restarts_optimizer=15, normalize_y=True)
gp.fit(X_train_scaled, y_train_log)

# Predict on the test set.
y_pred, std = gp.predict(X_test_scaled, return_std=True)
y_pred = np.exp(y_pred) - 1  # (Optional) Omit if you don't use logarithmic scaling.

# Evaluation
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"MSE: {mse:.3f}")
print(f"R2 Score: {r2:.3f}")

# (Optional) Print the title, actual earnings, predicted earnings, and standard deviation, and confidence intervals
for i in range(len(X_test)):
    title = test_titles.iloc[i]
    lower_bound = y_pred[i] - 1.96 * std[i]
    upper_bound = y_pred[i] + 1.96 * std[i]
    lower_bound = max(0, lower_bound)
    upper_bound = max(0, upper_bound)
    print(f"Title: {title}, Predicted: {y_pred[i]:.3f}, Actual: {y_test.iloc[i]:.3f}, STD: {std[i]:.3f}, 95% CI: [{lower_bound:.3f}, {upper_bound:.3f}]")

# %% auto
#check https://github.com/sinaptik-ai/pandas-ai
#https://towardsdatascience.com/automl-with-autogluon-transform-your-ml-workflow-with-just-four-lines-of-code-1d4b593be129
from autogluon.tabular
import TabularDataset,
 TabularPredictor
train_data =
 TabularDataset('train.csv')
predictor =
 TabularPredictor(label='Target').fit(train_data,
 presets='best_quality')
predictions
 = predictor.predict(train_data)
#https://auto.gluon.ai/stable/install.html
#https://youtu.be/fdfGb2jq-_c?t=1991
#from auto_mm_bench import *
from auto_mm_bench import *
from autogluon.tabular import TabularDataset, TabularPredictor
predictor = TabularPredictor(label='Class').fit(train_data,presets='best_quality',time_limit=60)
predictions = predictor.predict(test_data)
# %% RF
#https://towardsdatascience.com/data-scientists-cant-excel-in-python-without-mastering-these-functions-517dae1f0c37
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import requests
from io import StringIO
def load_wine_data(url):
    """Download and load wine data from a given URL."""
    response = requests.get(url)
    data = StringIO(response.text)
    df = pd.read_csv(data, sep=';')
    return df

def calculate_stats(df, columns):
    """Calculate basic statistics for specified columns."""
    stats = {}
    for col in columns:
        stats[col] = {
            'mean': np.mean(df[col]),
            'median': np.median(df[col]),
            'std': np.std(df[col])
        }
    return stats

def engineer_features(df):
    """Create new features from existing ones."""
    df['total_acidity'] = df['fixed acidity'] + df['volatile acidity']
    df['sugar_to_acid_ratio'] = df['residual sugar'] / df['total_acidity']
    return df
def apply_transformations(df, transformations):
    for column, transform_func in transformations.items():
        df[column] = df[column].apply(transform_func)
    return df
def main():
    # Load data
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"
    df = load_wine_data(url)

    # Data cleaning (using built-in function)
    df = df.dropna()

    # Feature engineering
    df = engineer_features(df)

    # Apply transformations using lambda functions
    transformations = {
        'alcohol': lambda x: x / 100,  # Convert to decimal
        'pH': lambda x: 10**(-x)  # Convert pH to hydrogen ion concentration
    }
    df = apply_transformations(df, transformations)

    # Calculate statistics for numeric columns
    numeric_columns = df.select_dtypes(include=[np.number]).columns
    stats = calculate_stats(df, numeric_columns)
    print("Basic statistics:")
    print(pd.DataFrame(stats))

    # Prepare features and target
    X = df.drop('quality', axis=1)
    y = df['quality']

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # Train model
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train_scaled, y_train)

    # Make predictions
    y_pred = model.predict(X_test_scaled)

    # Calculate metrics
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    print(f"\nMean Squared Error: {mse:.4f}")
    print(f"R-squared Score: {r2:.4f}")

    # Print feature importances (using lambda function)
    feature_importances = sorted(
        zip(model.feature_importances_, X.columns),
        key=lambda x: x[0],
        reverse=True
    )
    print("\nTop 5 Feature Importances:")
    for importance, feature in feature_importances[:5]:
        print(f"{feature}: {importance:.4f}")

# Call the main workflow
if __name__ == "__main__":
    main()
# %% setup
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
conda install -c conda-forge mamba pycaret xgboost catboost
mamba install -c rapidsai -c nvidia -c conda-forge cuml
python -m pip install dvc scikit-learn scikit-image pandas numpy
ln -s /mnt/f/GD/OneDrive/Dokumenter/GitHub/scripts .
tail -f scripts/logs.log
rsync -Parv ash022@login1.nird-lmd.sigma2.no:PD/Animesh/Aida/ML/ .
# %% mm
import pandas as pd
data=pd.read_csv("dataTmmS42T.csv")
data.describe()
data.info()
data.cor()
# %% lazy
#https://medium.com/omics-diary/how-to-use-the-lazy-predict-library-to-select-the-best-machine-learning-model-65378bf4568e
#pip install lazypredict
conda install -c conda-forge xgboost
conda install -c conda-forge lightgbm
%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import plotly.express as px
from IPython.display import display
from pandas.plotting import scatter_matrix
attributes = ["LAMP1", "TFRC", "UNG", "MYC"]
scatter_matrix(df[attributes], figsize = (10,8))
df_cat_to_array = pd.get_dummies(df)
df_cat_to_array = df_cat_to_array.drop("species_id", axis=1)
df_cat_to_array
import lazypredict
from sklearn.model_selection import train_test_split
from lazypredict.Supervised import LazyRegressor
X = df_cat_to_array .drop(["sepal_width"], axis=1)
Y = df_cat_to_array ["sepal_width"]
X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size = 0.2, random_state = 64)
reg = LazyRegressor(verbose=0, ignore_warnings=False, custom_metric=None)
models,pred = reg.fit(X_train, X_test, y_train, y_test)
models
from lazypredict.Supervised import LazyClassifier
from sklearn.model_selection import train_test_split
X =  df_cat_to_array.drop(["species_setosa", "species_versicolor", "species_virginica"], axis=1)
Y = df_cat_to_array["species_versicolor"]
X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state =55)
clf = LazyClassifier(verbose=0, ignore_warnings=True, custom_metric=None)
models,predictions = clf.fit(X_train, X_test, y_train, y_test)
models

dGroup="Class"
print("Grouping by: ", dGroup)
print(data.groupby(dGroup).count())#mapping = {'MGUS':1,'MM':2,'Ml':3}
#mapping = {'MGUS':'G','MM':'M','Ml':'M'}
mapping = {'MGUS':'G','MM':'M','Ml':'L'}
#mapping = {'MGUS':'0000FF','MM':'FF0000','Ml':'00FF00'}
data=data.replace({dGroup: mapping})
#data=data[data["Group"] != -1]
print(data.groupby(dGroup).count())
train_labels = data[dGroup]
train_data = data.drop(columns=dGroup)
print ("Data for Modeling :" + str(train_data.shape))
# %% DVC
python -m pip install dvc scikit-learn scikit-image pandas numpy
ln -s /mnt/f/OneDrive\ -\ NTNU/Data data
mv proteinGroups.txt data/.
git clone https://github.com/animesh/DVC
git checkout -b "first_experiment"
dvc init
dvc config core.analytics false
mkdir DVCrem
dvc remote add -d remote_storage ~/ntnu1d/DVCrem
less .dvc/config 
dvc add data/raw/train
# %% aim
from aimstack.base import Run
aim_run = Run(repo='./.aim')

from aimstack.base import Run, Metric
# Create a run
run = Run()
run['hparams'] = {
    'lr': 0.001,
    'batch_size': 32
}
# Create a metric
metric = Metric(run, name='loss', context={'epoch': 1})
for i in range(1000):
      metric.track(i, epoch=1)
# %% weka
#sudo apt-get update  --fix-missing
#sudo apt-get install weka libsvm-java
#export CLASSPATH=/usr/share/java/weka.jar 
#wget  "https://prdownloads.sourceforge.net/weka/weka-3-9-6.zip"
#unzip weka-3-9-6.zip
#pip install weka
#export CLASSPATH=$PWD/weka-3-9-6/weka.jar 
java weka.core.converters.CSVLoader /home/ash022/1d/Aida/ML/dataTmmS42T.csv > /home/ash022/1d/Aida/ML/dataTmmS42T.arff
java weka.classifiers.meta.ClassificationViaRegression -x 46 -t /home/ash022/1d/Aida/ML/dataTmmS42T.arff  | less
java weka.clusterers.SimpleKMeans  -A "weka.core.EuclideanDistance -R first-last"  -t /home/ash022/1d/Aida/ML/dataTmmS42T.arff  
java weka.clusterers.EM -t /home/ash022/1d/Aida/ML/dataTmmS42T.arff  
from weka.classifiers import Classifier
c = Classifier(name='weka.classifiers.meta.ClassificationViaRegression', ckargs={'-x':10})
c.train('/home/ash022/1d/Aida/ML/dataTmmS42T.arff')
predictions = c.predict('query.arff')
Alternatively, you can instantiate the classifier by calling its name directly:
weka.core,converters.csvloader 
from weka.core.converters import CSVLoader

weka.classifiers.meta.ClassificationViaRegression -W weka.classifiers.trees.M5P -- -M 4.0 -num-decimal-places 4
from weka.classifiers import IBk
c = IBk(K=1)
c.train('training.arff')
predictions = c.predict('query.arff')
The instance contains Weka's serialized model, so the classifier can be easily pickled and unpickled like any normal Python instance:

c.save('myclassifier.pkl')
c = Classifier.load('myclassifier.pkl')
predictions = c.predict('query.arff')
# %% RF
#https://www.blog.dailydoseofds.com/p/your-random-forest-is-underperforming
from sklearn.ensemble import RandomForestClassifier
model=RandomForestClassifier(n_estimators=100)
model.fit(train_data,train_labels)
model.score(train_data,train_labels)
model.estimators_
#Compute accuracy
model_accs = I] # list to store accuracies
for idx, tree in enumerate (model.estimators_):
score = tree.score(X_test, y-test) # find accuracy
model_accs. append ([idx, scorel]) # store accuracy
model_accs = np.array (model_accs)
model_accs
sorted_indices = np.argsort(model_accs[:, 1])[::-1]
model_ids = model_accs[sorted_indices][:,0].astype(int)
#array([65, 97, 18, 24, 38, 11,...
# create numpy array, rearrange the models and convert back to list
model.estimators_ = np.array(model.estimators_)[model_ids].tolist()
#array([[ 0.   ,  0.815], # [tree id, test accuracy]
#cum acc
import сору
result = []] # array to store cumulative score
total_models = len(model. estimators_)
for k in range(2, total_models) :
# create a copy of current model
    small_model = copy .deepcopy (model)
# set its trees to first 'k' trees of original model
    small_model.estimators_ = model.estimators_[: k]
# compute the score
    score = small_model. score (X_test, _test)
    result. append ([i, score])
>>> model. score (X_test, y_test)
#
0.845
»>> small_model.score (X_test, y_test)
# 0.875
Run-time
›››
%timeit model.predict (X_test)
# Run-time: 4.69 ms
›>> %timeit small_model.predict (X_test)
# Run-time: 720 uS
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
    km = KMeans(n_clusters=i, init='k-means++', n_init=10, max_iter=100, random_state=42)
    q, mod = divmod(i, 2)
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
