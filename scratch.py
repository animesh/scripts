#https://medium.com/@thakermadhav/build-your-own-rag-with-mistral-7b-and-langchain-97d0c92fa146
from langchain.text_splitter import CharacterTextSplitter
from langchain.document_loaders import AsyncChromiumLoader
from langchain.document_transformers import Html2TextTransformer
from langchain.vectorstores import FAISS
import nest_asyncio

nest_asyncio.apply()

articles = ["https://www.fantasypros.com/2023/11/rival-fantasy-nfl-week-10/",
            "https://www.fantasypros.com/2023/11/5-stats-to-know-before-setting-your-fantasy-lineup-week-10/",
            "https://www.fantasypros.com/2023/11/nfl-week-10-sleeper-picks-player-predictions-2023/",
            "https://www.fantasypros.com/2023/11/nfl-dfs-week-10-stacking-advice-picks-2023-fantasy-football/",
            "https://www.fantasypros.com/2023/11/players-to-buy-low-sell-high-trade-advice-2023-fantasy-football/"]

# Scrapes the blogs above
loader = AsyncChromiumLoader(articles)
docs = loader.load()

# Converts HTML to plain text 
html2text = Html2TextTransformer()
docs_transformed = html2text.transform_documents(docs)

# Chunk text
text_splitter = CharacterTextSplitter(chunk_size=100, 
                                      chunk_overlap=0)
chunked_documents = text_splitter.split_documents(docs_transformed)

# Load chunked documents into the FAISS index
db = FAISS.from_documents(chunked_documents, 
                          HuggingFaceEmbeddings(model_name='sentence-transformers/all-mpnet-base-v2'))


# Connect query to FAISS index using a retriever
retriever = db.as_retriever(
    search_type="similarity",
    search_kwargs={'k': 4}
)
from langchain.llms import HuggingFacePipeline
from langchain.prompts import PromptTemplate
from langchain.embeddings.huggingface import HuggingFaceEmbeddings

text_generation_pipeline = transformers.pipeline(
    model=model,
    tokenizer=tokenizer,
    task="text-generation",
    temperature=0.2,
    repetition_penalty=1.1,
    return_full_text=True,
    max_new_tokens=300,
)

prompt_template = """
### [INST] 
Instruction: Answer the question based on your 
fantasy football knowledge. Here is context to help:

{context}

### QUESTION:
{question} 

[/INST]
 """

mistral_llm = HuggingFacePipeline(pipeline=text_generation_pipeline)

# Create prompt from prompt template 
prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=prompt_template,
)

# Create llm chain 
llm_chain = LLMChain(llm=mistral_llm, prompt=prompt)
llm_chain.invoke({"context":"", 
                  "question": "Should I pick up Alvin Kamara for my fantasy team?"})

"Whether or not you should pick up Alvin Kamara for your fantasy team 
depends on a few factors, such as the specific league rules and roster 
requirements, the current performance of Kamara and other players in your 
league, and your overall strategy for building your team.
query = "Should I pick up Alvin Kamara for my fantasy team?" 

retriever = db.as_retriever()

rag_chain = ( 
 {"context": retriever, "question": RunnablePassthrough()}
    | llm_chain
)

rag_chain.invoke(query)
#https://github.com/madhavthaker1/llm/blob/main/rag/e2e_rag.ipynb
!pip install -q -U torch datasets transformers tensorflow langchain playwright html2text sentence_transformers faiss-cpu
!pip install -q accelerate==0.21.0 peft==0.4.0 bitsandbytes==0.40.2 trl==0.4.7

import os
import torch
from transformers import (
  AutoTokenizer, 
  AutoModelForCausalLM, 
  BitsAndBytesConfig
  pipeline
)

from transformers import BitsAndBytesConfig

from langchain.text_splitter import CharacterTextSplitter
from langchain.document_transformers import Html2TextTransformer
from langchain.document_loaders import AsyncChromiumLoader

from langchain.embeddings.huggingface import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS

from langchain.prompts import PromptTemplate
from langchain.schema.runnable import RunnablePassthrough
from langchain.llms import HuggingFacePipeline
from langchain.chains import LLMChain

import nest_asyncio
#################################################################
# Tokenizer
#################################################################

model_name='mistralai/Mistral-7B-Instruct-v0.1'

model_config = transformers.AutoConfig.from_pretrained(
    model_name,
)

tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
tokenizer.pad_token = tokenizer.eos_token
tokenizer.padding_side = "right"

#################################################################
# bitsandbytes parameters
#################################################################

# Activate 4-bit precision base model loading
use_4bit = True

# Compute dtype for 4-bit base models
bnb_4bit_compute_dtype = "float16"

# Quantization type (fp4 or nf4)
bnb_4bit_quant_type = "nf4"

# Activate nested quantization for 4-bit base models (double quantization)
use_nested_quant = False

#################################################################
# Set up quantization config
#################################################################
compute_dtype = getattr(torch, bnb_4bit_compute_dtype)

bnb_config = BitsAndBytesConfig(
    load_in_4bit=use_4bit,
    bnb_4bit_quant_type=bnb_4bit_quant_type,
    bnb_4bit_compute_dtype=compute_dtype,
    bnb_4bit_use_double_quant=use_nested_quant,
)

# Check GPU compatibility with bfloat16
if compute_dtype == torch.float16 and use_4bit:
    major, _ = torch.cuda.get_device_capability()
    if major >= 8:
        print("=" * 80)
        print("Your GPU supports bfloat16: accelerate training with bf16=True")
        print("=" * 80)

#################################################################
# Load pre-trained config
#################################################################
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    quantization_config=bnb_config,
)


def print_number_of_trainable_model_parameters(model):
    trainable_model_params = 0
    all_model_params = 0
    for _, param in model.named_parameters():
        all_model_params += param.numel()
        if param.requires_grad:
            trainable_model_params += param.numel()
    return f"trainable model parameters: {trainable_model_params}\nall model parameters: {all_model_params}\npercentage of trainable model parameters: {100 * trainable_model_params / all_model_params:.2f}%"

print(print_number_of_trainable_model_parameters(model))

text_generation_pipeline = pipeline(
    model=model,
    tokenizer=tokenizer,
    task="text-generation",
    temperature=0.2,
    repetition_penalty=1.1,
    return_full_text=True,
    max_new_tokens=1000,
)

mistral_llm = HuggingFacePipeline(pipeline=text_generation_pipeline)

!playwright install 
!playwright install-deps 

import nest_asyncio
nest_asyncio.apply()

# Articles to index
articles = ["https://www.fantasypros.com/2023/11/rival-fantasy-nfl-week-10/",
            "https://www.fantasypros.com/2023/11/5-stats-to-know-before-setting-your-fantasy-lineup-week-10/",
            "https://www.fantasypros.com/2023/11/nfl-week-10-sleeper-picks-player-predictions-2023/",
            "https://www.fantasypros.com/2023/11/nfl-dfs-week-10-stacking-advice-picks-2023-fantasy-football/",
            "https://www.fantasypros.com/2023/11/players-to-buy-low-sell-high-trade-advice-2023-fantasy-football/"]

# Scrapes the blogs above
loader = AsyncChromiumLoader(articles)
docs = loader.load()

# Converts HTML to plain text 
html2text = Html2TextTransformer()
docs_transformed = html2text.transform_documents(docs)

# Chunk text
text_splitter = CharacterTextSplitter(chunk_size=100, 
                                      chunk_overlap=0)
chunked_documents = text_splitter.split_documents(docs_transformed)

# Load chunked documents into the FAISS index
db = FAISS.from_documents(chunked_documents, 
                          HuggingFaceEmbeddings(model_name='sentence-transformers/all-mpnet-base-v2'))

retriever = db.as_retriever()

# Create prompt template
prompt_template = """
### [INST] Instruction: Answer the question based on your fantasy football knowledge. Here is context to help:

{context}

### QUESTION:
{question} [/INST]
 """

# Create prompt from prompt template 
prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=prompt_template,
)

# Create llm chain 
llm_chain = LLMChain(llm=mistral_llm, prompt=prompt)

rag_chain = ( 
 {"context": retriever, "question": RunnablePassthrough()}
    | llm_chain
)

rag_chain.invoke("Should I start Gibbs next week for fantasy?")

#https://towardsdatascience.com/comparing-outlier-detection-methods-956f4b097061
import matplotlib.pyplot as plt
import seaborn as sns

g = sns.JointGrid(data=df, x="OBP", y="SLG", height=5)
g = g.plot_joint(func=sns.scatterplot, data=df, hue="League",
                 palette={"AL":"blue","NL":"maroon","NL/AL":"green"},
                 alpha=0.6
                )
g.fig.suptitle("On-base percentage vs. Slugging\n2023 season, min "
               f"{MIN_PLATE_APPEARANCES} plate appearances"
              )
g.figure.subplots_adjust(top=0.9)
sns.kdeplot(x=df["OBP"], color="orange", ax=g.ax_marg_x, alpha=0.5)
sns.kdeplot(y=df["SLG"], color="orange", ax=g.ax_marg_y, alpha=0.5)
sns.kdeplot(data=df, x="OBP", y="SLG",
            ax=g.ax_joint, color="orange", alpha=0.5
           )
df_extremes = df[ df["OBP"].isin([df["OBP"].min(),df["OBP"].max()]) 
                 | df["OPS"].isin([df["OPS"].min(),df["OPS"].max()])
                ]

for _,row in df_extremes.iterrows():
    g.ax_joint.annotate(row["Name"], (row["OBP"], row["SLG"]),size=6,
                      xycoords='data', xytext=(-3, 0),
                        textcoords='offset points', ha="right",
                      alpha=0.7)
plt.show()
import numpy as np

X = df[["OBP","SLG"]].to_numpy()

GRID_RESOLUTION = 200

disp_x_range, disp_y_range = ( (.6*X[:,i].min(), 1.2*X[:,i].max()) 
                               for i in [0,1]
                             )
xx, yy = np.meshgrid(np.linspace(*disp_x_range, GRID_RESOLUTION), 
                     np.linspace(*disp_y_range, GRID_RESOLUTION)
                    )
grid_shape = xx.shape
grid_unstacked = np.c_[xx.ravel(), yy.ravel()]
from sklearn.covariance import EllipticEnvelope

ell = EllipticEnvelope(random_state=17).fit(X)
df["outlier_score_ell"] = ell.decision_function(X)
Z_ell = ell.decision_function(grid_unstacked).reshape(grid_shape)
K = int(np.sqrt(X.shape[0]))

print(f"Using K={K} nearest neighbors.")

from scipy.spatial.distance import pdist, squareform

# If we didn't have the elliptical envelope already,
# we could calculate robust covariance:
#   from sklearn.covariance import MinCovDet
#   robust_cov = MinCovDet().fit(X).covariance_
# But we can just re-use it from elliptical envelope:
robust_cov = ell.covariance_

print(f"Robust covariance matrix:\n{np.round(robust_cov,5)}\n")

inv_robust_cov = np.linalg.inv(robust_cov)

D_mahal = squareform(pdist(X, 'mahalanobis', VI=inv_robust_cov))

print(f"Mahalanobis distance matrix of size {D_mahal.shape}, "
      f"e.g.:\n{np.round(D_mahal[:5,:5],3)}...\n...\n")

from scipy.spatial.distance import pdist, squareform

# If we didn't have the elliptical envelope already,
# we could calculate robust covariance:
#   from sklearn.covariance import MinCovDet
#   robust_cov = MinCovDet().fit(X).covariance_
# But we can just re-use it from elliptical envelope:
robust_cov = ell.covariance_

print(f"Robust covariance matrix:\n{np.round(robust_cov,5)}\n")

inv_robust_cov = np.linalg.inv(robust_cov)

D_mahal = squareform(pdist(X, 'mahalanobis', VI=inv_robust_cov))

print(f"Mahalanobis distance matrix of size {D_mahal.shape}, "
      f"e.g.:\n{np.round(D_mahal[:5,:5],3)}...\n...\n")

from scipy.spatial.distance import cdist

D_mahal_grid = cdist(XA=grid_unstacked, XB=X, 
                     metric='mahalanobis', VI=inv_robust_cov
                    )
Z_lof = lof.decision_function(D_mahal_grid).reshape(grid_shape)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import RobustScaler
from sklearn.kernel_approximation import Nystroem
from sklearn.linear_model import SGDOneClassSVM

suv = make_pipeline(
            RobustScaler(),
            Nystroem(random_state=17),
            SGDOneClassSVM(random_state=17)
).fit(X)

df["outlier_score_svm"] = suv.decision_function(X)

Z_svm = suv.decision_function(grid_unstacked).reshape(grid_shape)

from adjustText import adjust_text
from sklearn.preprocessing import QuantileTransformer

N_QUANTILES = 8 # This many color breaks per chart
N_CALLOUTS=15  # Label this many top outliers per chart

fig, axs = plt.subplots(2, 2, figsize=(12, 12), sharex=True, sharey=True)

fig.suptitle("Comparison of Outlier Identification Algorithms",size=20)
fig.supxlabel("On-Base Percentage (OBP)")
fig.supylabel("Slugging (SLG)")

ax_ell = axs[0,0]
ax_lof = axs[0,1]
ax_svm = axs[1,0]
ax_iso = axs[1,1]

model_abbrs = ["ell","iso","lof","svm"]

qt = QuantileTransformer(n_quantiles=N_QUANTILES)

for ax, nm, abbr, zz in zip( [ax_ell,ax_iso,ax_lof,ax_svm], 
                            ["Elliptic Envelope","Isolation Forest",
                             "Local Outlier Factor","One-class SVM"], 
                            model_abbrs,
                            [Z_ell,Z_iso,Z_lof,Z_svm]
                           ):
    ax.title.set_text(nm)
    outlier_score_var_nm = f"outlier_score_{abbr}"
    
    qt.fit(np.sort(zz.reshape(-1,1)))
    zz_qtl = qt.transform(zz.reshape(-1,1)).reshape(zz.shape)

    cs = ax.contourf(xx, yy, zz_qtl, cmap=plt.cm.OrRd.reversed(), 
                     levels=np.linspace(0,1,N_QUANTILES)
                    )
    ax.scatter(X[:, 0], X[:, 1], s=20, c="b", edgecolor="k", alpha=0.5)
    
    df_callouts = df.sort_values(outlier_score_var_nm).head(N_CALLOUTS)
    texts = [ ax.text(row["OBP"], row["SLG"], row["Name"], c="b",
                      size=9, alpha=1.0) 
             for _,row in df_callouts.iterrows()
            ]
    adjust_text(texts, 
                df_callouts["OBP"].values, df_callouts["SLG"].values, 
                arrowprops=dict(arrowstyle='->', color="b", alpha=0.6), 
                ax=ax
               )

plt.tight_layout(pad=2)
plt.show()

for var in ["OBP","SLG"]:
    df[f"Pctl_{var}"] = 100*(df[var].rank()/df[var].size).round(3)

model_score_vars = [f"outlier_score_{nm}" for nm in model_abbrs]  
model_rank_vars = [f"Rank_{nm.upper()}" for nm in model_abbrs]


df[model_rank_vars] = df[model_score_vars].rank(axis=0).astype(int)
    
# Averaging the ranks is arbitrary; we just need a countdown order
df["Rank_avg"] = df[model_rank_vars].mean(axis=1)

print("Counting down to the greatest outlier...\n")
print(
    df.sort_values("Rank_avg",ascending=False
                  ).tail(N_CALLOUTS)[["Name","AB","PA","H","2B","3B",
                                      "HR","BB","HBP","SO","OBP",
                                      "Pctl_OBP","SLG","Pctl_SLG"
                                     ] + 
                             [f"Rank_{nm.upper()}" for nm in model_abbrs]
                            ].to_string(index=False)
)


#https://youtu.be/E72DWgKP_1Y?t=1023
Farmer's Problem
from pulp
import *
# problem formulation
model = LpProblem(sense=LpMaximize)
X_P = LpVariable(name="potatoes", lowBound=0)
x_c = LpVariable(name="carrots",
, lowBound=0)
model += x_p
<= 3000
# potatoes
model +=
x_C <= 4000
# carrots
model += x_p + x_c <= 5000
# fertilizer
model *= X_p * 1.2 + x_C * 1.7
# solve (without being verbose)
status = model.solve(PULP
_CBC_CMD(msg=False))
print ("potatoes:", x_p. value())
print("carrots:", x_c.value())
print("profit:", model.objective.value())
from
pulp
import *
variables: 1 ≥ b ≥0
#
data
n
8
weights
[4, 2, 8, 3, 7, 5, 9, 6]
prices = [19,
17, 30, 13, 25, 29, 23, 10J
carry_weight = 17
subject to
weights • b ≤ carry-weight
objective function
max prices • b
# problem formulation
model = LpProblem(sense=LpMaximize)
variables • [LpVariable(name-f"x_{i}", cat-LpBinary) for i in range(n)]
model += lpDot(weights, variables) <= carry_weight
model += lpDot(prices, variables)
# solve (without being verbose)
status = model. solve( PULP
_CBC_CMD(msg=False))
print("price:"
, model.objective.value())
print("take:" *[variablesfil value() for i in range(n)])
#!pip install --upgrade pip
#!pip install spyder
#C:\Users\sharm\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts\spyder.exe
#cd f:\GD\OneDrive\Dokumenter\GitHub\scripts
import sys
sys.executable
sys.setrecursionlimit(1000)
# %% GP https://medium.com/@okanyenigun/step-by-step-guide-to-bayesian-optimization-a-python-based-approach-3558985c6818
import numpy as np
import matplotlib.pyplot as plt
np.random.seed(42)
def black_box_function(x):
    y = np.sin(x) + np.cos(2*x)
    return y
# range of x values
x_range = np.linspace(-2*np.pi, 2*np.pi, 100)
# output for each x value
black_box_output = black_box_function(x_range)
# plot
plt.plot(x_range, black_box_output)
plt.xlabel('x')
plt.ylabel('y')
plt.title('Black Box Function Output')
plt.show()
# random x values for sampling
num_samples = 10
sample_x = np.random.choice(x_range, size=num_samples)

# output for each sampled x value
sample_y = black_box_function(sample_x)

# plot
plt.plot(x_range, black_box_function(x_range), label='Black Box Function')
plt.scatter(sample_x, sample_y, color='red', label='Samples')
plt.xlabel('x')
plt.ylabel('Black Box Output')
plt.title('Sampled Points')
plt.legend()
plt.show()
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF

# Gaussian process regressor with an RBF kernel
kernel = RBF(length_scale=1.0)
gp_model = GaussianProcessRegressor(kernel=kernel)

# Fit the Gaussian process model to the sampled points
gp_model.fit(sample_x.reshape(-1, 1), sample_y)

# Generate predictions using the Gaussian process model
y_pred, y_std = gp_model.predict(x_range.reshape(-1, 1), return_std=True)

# Plot 
plt.figure(figsize=(10, 6))
plt.plot(x_range, black_box_function(x_range), label='Black Box Function')
plt.scatter(sample_x, sample_y, color='red', label='Samples')
plt.plot(x_range, y_pred, color='blue', label='Gaussian Process')
plt.fill_between(x_range, y_pred - 2*y_std, y_pred + 2*y_std, color='blue', alpha=0.2)
plt.xlabel('x')
plt.ylabel('Black Box Output')
plt.title('Black Box Function with Gaussian Process Surrogate Model')
plt.legend()
plt.show()
from scipy.stats import norm

def expected_improvement(x, gp_model, best_y):
    y_pred, y_std = gp_model.predict(x.reshape(-1, 1), return_std=True)
    z = (y_pred - best_y) / y_std
    ei = (y_pred - best_y) * norm.cdf(z) + y_std * norm.pdf(z)
    return ei

# Determine the point with the highest observed function value
best_idx = np.argmax(sample_y)
best_x = sample_x[best_idx]
best_y = sample_y[best_idx]

ei = expected_improvement(x_range, gp_model, best_y)

# Plot the expected improvement
plt.figure(figsize=(10, 6))
plt.plot(x_range, ei, color='green', label='Expected Improvement')
plt.xlabel('x')
plt.ylabel('Expected Improvement')
plt.title('Expected Improvement')
plt.legend()
plt.show()
def upper_confidence_bound(x, gp_model, beta):
    y_pred, y_std = gp_model.predict(x.reshape(-1, 1), return_std=True)
    ucb = y_pred + beta * y_std
    return ucb

beta = 2.0

# UCB
ucb = upper_confidence_bound(x_range, gp_model, beta)

plt.figure(figsize=(10, 6))
plt.plot(x_range, ucb, color='green', label='UCB')
plt.xlabel('x')
plt.ylabel('UCB')
plt.title('UCB')
plt.legend()
plt.show()
def probability_of_improvement(x, gp_model, best_y):
    y_pred, y_std = gp_model.predict(x.reshape(-1, 1), return_std=True)
    z = (y_pred - best_y) / y_std
    pi = norm.cdf(z)
    return pi

# Probability of Improvement
pi = probability_of_improvement(x_range, gp_model, best_y)


plt.figure(figsize=(10, 6))
plt.plot(x_range, pi, color='green', label='PI')
plt.xlabel('x')
plt.ylabel('PI')
plt.title('PI')
plt.legend()
plt.show()
num_iterations = 5

plt.figure(figsize=(10, 6))

for i in range(num_iterations):
    # Fit the Gaussian process model to the sampled points
    gp_model.fit(sample_x.reshape(-1, 1), sample_y)

    # Determine the point with the highest observed function value
    best_idx = np.argmax(sample_y)
    best_x = sample_x[best_idx]
    best_y = sample_y[best_idx]

    # Set the value of beta for the UCB acquisition function
    beta = 2.0

    # Generate the Upper Confidence Bound (UCB) using the Gaussian process model
    ucb = upper_confidence_bound(x_range, gp_model, beta)

    # Plot the black box function, surrogate function, previous points, and new points
    plt.plot(x_range, black_box_function(x_range), color='black', label='Black Box Function')
    plt.plot(x_range, ucb, color='red', linestyle='dashed', label='Surrogate Function')
    plt.scatter(sample_x, sample_y, color='blue', label='Previous Points')
    if i < num_iterations - 1:
        new_x = x_range[np.argmax(ucb)]  # Select the next point based on UCB
        new_y = black_box_function(new_x)
        sample_x = np.append(sample_x, new_x)
        sample_y = np.append(sample_y, new_y)
        plt.scatter(new_x, new_y, color='green', label='New Points')

    plt.xlabel('x')
    plt.ylabel('y')
    plt.title(f"Iteration #{i+1}")
    plt.legend()
    plt.show()
# %% chi^2 http://allendowney.blogspot.com/2011/05/there-is-only-one-test.html https://towardsdatascience.com/data-scientists-need-to-know-just-one-statistical-test-3115b2ff26fd 
Value=[1,2,3,4,5,6]
Frequency=[8,9,19,6,8,10]
import matplotlib.pyplot as plt
plt.style.use('dark_background')
matplotlib.use("module://matplotlib.backends.html5_canvas_backend")plt.plot(Value, Frequency)#python via wasm?
plt.plot(Frequency,Value)
plt.hist(Value)
def ChiSquared(expected, observed):
    total = 0.0
    for x, exp in expected.Items():
        obs = observed.Freq(x)
        total += (obs - exp)**2 / exp
    return total
def SimulateRolls(sides, num_rolls):
    """Generates a Hist of simulated die rolls. Args:sides: number of sides on the die num_rolls: number of times to rolls Returns: Hist object"""
    hist = Pmf.Hist()
    for i in range(num_rolls):
        roll = random.randint(1, sides)
        hist.Incr(roll)
    return hist
count = 0.
num_trials = 1000
num_rolls = 60
threshold = ChiSquared(expected, observed)
for _ in range(num_trials):
    simulated = SimulateRolls(sides, num_rolls)
    chi2 = ChiSquared(expected, simulated)
    if chi2 >= threshold:
        count += 1
pvalue = count / num_trials
print('p-value', pvalue)
# %% CI https://sebastianraschka.com/blog/2022/confidence-intervals-for-ml.html
observed_outcome = np.array([1,1,1,1,1,2,2,2,3,3])
def draw_random_outcome(): return np.random.choice([1,2,3,4,5,6], size=10)
def unexp_score(outcome):
  outcome_distribution = np.array([np.mean(outcome == face) for face in [1,2,3,4,5,6]])
  return np.mean(np.abs(outcome_distribution - 1/6))
# %% 345 https://en.wikipedia.org/wiki/Category:Statistical_tests
n_iter = 10000
random_unexp_scores = np.empty(n_iter)
for i in range(n_iter):
  random_unexp_scores[i] = unexp_score(draw_random_outcome())
observed_unexp_score = unexp_score(observed_outcome)
pvalue = np.sum(random_unexp_scores >= observed_unexp_score) / n_iter
print(pvalue)
# %% scrabble
observed_outcome = 'FEAR'
def draw_random_outcome():
  size=np.random.randint(low=1, high=27)
  return ''.join(np.random.choice(list(string.ascii_uppercase), size=size, replace=False))
from english_words import english_words_set
english_words_set = [w.upper() for w in english_words_set]
def unexp_score(outcome):
  is_in_dictionary = outcome in english_words_set
  return (1 if is_in_dictionary else -1) * len(outcome)
# %% rating
product_a = np.repeat([1,2,3,4,5], 20)
product_b = np.array([1]*27+[2]*25+[3]*19+[4]*16+[5]*13)
observed_outcome = np.mean(product_a) - np.mean(product_b)
def draw_random_outcome():
  pr_a, pr_b = np.random.permutation(np.hstack([product_a, product_b])).reshape(2,-1)
  return np.mean(pr_a) - np.mean(pr_b)
def unexp_score(outcome): return np.abs(outcome)
# %% AUC
y_test = np.random.choice([0,1], size=100, p=[.9,.1])
proba_test = np.random.uniform(low=0, high=1, size=100)
observed_outcome = .7
def draw_random_outcome(): return roc_auc_score(y_test, np.random.permutation(proba_test))
def unexp_score(outcome): return np.abs(outcome - .5)
# %% CIc
import numpy as np
clf.fit(X_train, y_train)
acc_test = clf.score(X_test, y_test)
ci_length = z_value * np.sqrt((acc_test * (1 - acc_test)) / y_test.shape[0])
ci_lower = acc_test - ci_length
ci_upper = acc_test + ci_length
print(ci_lower, ci_upper)
#Bootstrapping and Uncertainties of “Model Evaluation, Model Selection, and Algorithm Selection in Machine Learning
import numpy as np
rng = np.random.RandomState(seed=12345)
idx = np.arange(y_train.shape[0])
bootstrap_train_accuracies = []
bootstrap_rounds = 200
for i in range(bootstrap_rounds):
    train_idx = rng.choice(idx, size=idx.shape[0], replace=True)
    valid_idx = np.setdiff1d(idx, train_idx, assume_unique=False)
    boot_train_X, boot_train_y = X_train[train_idx], y_train[train_idx]
    boot_valid_X, boot_valid_y = X_train[valid_idx], y_train[valid_idx]
    clf.fit(boot_train_X, boot_train_y)
    acc = clf.score(boot_valid_X, boot_valid_y)
    bootstrap_train_accuracies.append(acc)
bootstrap_train_mean = np.mean(bootstrap_train_accuracies)
confidence = 0.95  # Change to your desired confidence level
t_value = scipy.stats.t.ppf((1 + confidence) / 2.0, df=bootstrap_rounds - 1)
print(t_value)
se = 0.0
for acc in bootstrap_train_accuracies:
    se += (acc - bootstrap_train_mean) ** 2
se = np.sqrt((1.0 / (bootstrap_rounds - 1)) * se)
ci_length = t_value * se
ci_lower = bootstrap_train_mean - ci_length
ci_upper = bootstrap_train_mean + ci_length
print(ci_lower, ci_upper)
ci_lower = np.percentile(bootstrap_train_accuracies, 2.5)
ci_upper = np.percentile(bootstrap_train_accuracies, 97.5)
print(ci_lower, ci_upper)
rng = np.random.RandomState(seed=12345)
idx = np.arange(y_train.shape[0])
bootstrap_train_accuracies = []
bootstrap_rounds = 200
weight = 0.632
for i in range(bootstrap_rounds):
    train_idx = rng.choice(idx, size=idx.shape[0], replace=True)
    valid_idx = np.setdiff1d(idx, train_idx, assume_unique=False)
    boot_train_X, boot_train_y = X_train[train_idx], y_train[train_idx]
    boot_valid_X, boot_valid_y = X_train[valid_idx], y_train[valid_idx]
    clf.fit(boot_train_X, boot_train_y)
    valid_acc = clf.score(boot_valid_X, boot_valid_y)
    # predict training accuracy on the whole training set
    # as ib the original .632 boostrap paper
    # in Eq (6.12) in
    #    "Estimating the Error Rate of a Prediction Rule: Improvement
    #     on Cross-Validation"
    #     by B. Efron, 1983, https://doi.org/10.2307/2288636
    train_acc = clf.score(X_train, y_train)
    acc = weight * train_acc + (1.0 - weight) * valid_acc
    bootstrap_train_accuracies.append(acc)
bootstrap_train_mean = np.mean(bootstrap_train_accuracies)
bootstrap_train_mean
# %% GP https://www.tidyverse.org/blog/2022/06/announce-vetiver/
from vetiver.data import mtcars
from sklearn import tree
car_mod = tree.DecisionTreeRegressor().fit(mtcars, mtcars["mpg"])
from vetiver import VetiverModel
v = VetiverModel(car_mod, model_name = "cars_mpg", 
                 save_ptype = True, ptype_data = mtcars)
v.description
#https://vetiver.rstudio.com/get-started/deploy.html
#> "Scikit-learn <class 'sklearn.tree._classes.DecisionTreeRegressor'> model"
# %% GP https://towardsdatascience.com/quick-start-to-gaussian-process-regression-36d838810319
import sklearn.gaussian_process as gp
#In GPR, we first assume a Gaussian process prior, which can be specified using a mean function, m(x), and covariance function, k(x, x’):
# X_tr <-- training observations [# points, # features]
# y_tr <-- training labels [# points]
# X_te <-- test observations [# points, # features]
# y_te <-- test labels [# points]
kernel = gp.kernels.ConstantKernel(1.0, (1e-1, 1e3)) * gp.kernels.RBF(10.0, (1e-3, 1e3))
model = gp.GaussianProcessRegressor(kernel=kernel, n_restarts_optimizer=10, alpha=0.1, normalize_y=True)
model.fit(X_tr, y_tr)
params = model.kernel_.get_params()
y_pred, std = model.predict(X_te, return_std=True)
MSE = ((y_pred-y_te)**2).mean()
# %% holo
#https://nbviewer.org/github/wino6687/medium_hvPlot_Intro/blob/master/hvPlot_Intro_Plots.ipynb
import hvplot.streamz
from streamz.dataframe import Random
stream_df = Random(freq='10ms')
stream_df.hvplot(backlog=80, height=300, width=400) +\
stream_df.hvplot.hexbin(x='x', y='z', backlog=1600, height=300, width=400)
#network
import networkx as nx
import hvplot.networkx as hvnx
characters = ["R2-D2","CHEWBACCA","C-3PO","LUKE","DARTH VADER",...]
edges = [("CHEWBACCA", "R2-D2"),("C-3PO", "R2-D2"),("BERU", "R2-D2"),...]
G = nx.Graph()
G.add_nodes_from(characters)
G.add_edges_from(edges)
hvnx.draw_circular(G, labels="index")
# %% sp
#https://medium.com/@koki_noda/how-to-find-the-most-attractive-stocks-in-this-bear-market-data-analysis-with-python-dd5fbc41d604
import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
import datetime as dt
from concurrent import futures
import numpy as np
from scipy.stats import gaussian_kde
import pandas_datareader.data as web
data_dir = "./data/most_attractive_stocks"
os.makedirs(data_dir, exist_ok=True)
tables = pd.read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies')
sp500_df = tables[0]
second_table = tables[1]
print(sp500_df.shape)
# rename symbol to escape symbol error
sp500_df["Symbol"] = sp500_df["Symbol"].map(lambda x: x.replace(".", "-"))  
sp500_df.to_csv("./data/SP500_20220615.csv", index=False)
sp500_df = pd.read_csv("./data/SP500_20220615.csv")
print(sp500_df.shape)
sp500_tickers = list(sp500_df["Symbol"])
sp500_df.head()
def download_stock(stock):
    try:
        print(stock)
        stock_df = web.DataReader(stock, 'yahoo', start_time, end_time)
        stock_df['Name'] = stock
        output_name = f"{data_dir}/{stock}.csv"
        stock_df.to_csv(output_name)
    except BaseException:
        bad_names.append(stock)
        print('bad: %s' % (stock))
""" set the download window """
start_time = dt.datetime(1900, 1, 1)
end_time = dt.datetime(2022, 6, 15)
bad_names = []  # to keep track of failed queries
#set the maximum thread number
max_workers = 20
now = dt.datetime.now()
path_failed_queries = f'{data_dir}/failed_queries.txt'
if os.path.exists(path_failed_queries):
    with open(path_failed_queries) as f:
        failed_queries = f.read().split("\n")[:-1]
        sp500_tickers_ = failed_queries
else:
    sp500_tickers_ = sp500_tickers
print("number of stocks to download:", len(sp500_tickers_))
# in case a smaller number of stocks than threads was passed in
workers = min(max_workers, len(sp500_tickers_))
with futures.ThreadPoolExecutor(workers) as executor:
    res = executor.map(download_stock, sp500_tickers_)
""" Save failed queries to a text file to retry """
if len(bad_names) > 0:
    with open(path_failed_queries, 'w') as outfile:
        for name in bad_names:
            outfile.write(name + '\n')
finish_time = dt.datetime.now()
duration = finish_time - now
minutes, seconds = divmod(duration.seconds, 60)
print(f'The threaded script took {minutes} minutes and {seconds} seconds to run.')
print(f"{len(bad_names)} stocks failed: ", bad_names)
historical_stock_data_files = glob.glob(f"{data_dir}/*.csv")
highest_day_list = []
for files in historical_stock_data_files:
    price = pd.read_csv(files, index_col="Date", parse_dates=True)
    ticker = os.path.splitext(os.path.basename(files))[0]
    price_close = price[["Close"]]
    highest_day = price_close.idxmax()[0]
    highest_price = price_close.max()[0]
    highest_day_list.append(
        pd.DataFrame({"highest_day": [highest_day], "ticker": [ticker], "highest_price": highest_price}))
df = pd.concat(highest_day_list).reset_index(drop=True)
print(df.shape)
df.head()
# additional info
df["highest_month"] = df["highest_day"].dt.to_period("M")
df = pd.merge(df, sp500_df[["Symbol", "GICS Sector", "GICS Sub-Industry"]], left_on='ticker', right_on='Symbol')
df.sort_values("highest_day", ascending=False).head()
industry_value_counts = df[df["highest_day"] >= "2022-06-01"]["GICS Sub-Industry"].value_counts()
fig, ax = plt.subplots(figsize=(20, 8))
ax.bar(industry_value_counts.index, industry_value_counts.values)
ax.set_xticklabels(industry_value_counts.index, rotation=90)
ax.set_xlabel("industry")
ax.set_ylabel("number of stocks")
plt.show()
industry_value_counts[industry_value_counts.index.str.contains("Oil & Gas")]
highest_day_count = df.groupby("highest_month").count()
highest_day_count["ticker"].plot()
plt.title("Number of stocks that reached new highs")
plt.ylabel("number of stocks")
plt.show()
highest_day_count["ticker"].plot(marker=".")
plt.grid(axis='y')
plt.title("Number of stocks that reached new highs")
plt.xlim("2021-01-01", "2022-06-30")
plt.ylabel("number of stocks")
plt.show()
tikcer_list = ["GOOG", "AAPL", "FB", "AMZN", "MSFT", "TSLA", "NVDA"]
df[df["ticker"].isin(tikcer_list)]
industry_value_counts = df[df["highest_day"] <= "2021-12-31"]["GICS Sub-Industry"].value_counts()
fig, ax = plt.subplots(figsize=(20, 8))
ax.bar(industry_value_counts.index, industry_value_counts.values)
ax.set_xticklabels(industry_value_counts.index, rotation=90)
ax.set_xlabel("industry")
ax.set_ylabel("number of stocks")
plt.show()
df["in_2022"] = df["highest_day"].map(lambda x: False if x.year < 2022 else True)
value_counts_before_2022 = df[df["in_2022"] == False]["GICS Sub-Industry"].value_counts()
value_counts_2022 = df[df["in_2022"] == True]["GICS Sub-Industry"].value_counts()
value_counts_before_2022.name = "~2021"
value_counts_2022.name = "2022"
comparison_df = pd.concat([value_counts_2022, value_counts_before_2022], axis=1)
comparison_df = comparison_df.fillna(0)
comparison_df.head()
fig, ax = plt.subplots(figsize=(20, 8))
comparison_df.plot(kind='bar', stacked=True, ax=ax)
ax.set_xlabel("industry")
ax.set_ylabel("number of stocks")
plt.show()
#avoid industry groups that have a high percentage of stocks (in orange) that do not have the ability to make new highs.
    
# %% evaluate
#https://huggingface.co/docs/evaluate/installation pip install evaluate
import evaluate
print(evaluate.load('accuracy').compute(references=[1], predictions=[1]))
#{'accuracy': 1.0}
# %% evaluate
#https://github.com/souravbhadra/century_corn_yield 
#https://sbhadra019.medium.com/interactive-webmap-using-python-8b11ba2f5f0f
gpd_data = gpd.read_file("location_of_the_shapefile")
# Read the slope data
slope_data = pd.read_csv("location_of_the_slope_data")
# Create a custom scale for the legend
# Here we are using the quantile classification to make 
# a custom scale
custom_scale = (slope_data['Slope'].quantile((0, 0.2, 0.4, 0.6, 0.8, 1))).tolist()
# Initialize the map and store it in a m object
m = folium.Map(location=[42, -88], zoom_start=5)
# This is the folium object
ch = folium.Choropleth(
            geo_data=shape_geo, # geopandas object
            data=slope_data, # pandas dataframe
            columns=['Id', 'Slope'], # specify the columns to use, we only need these two
            key_on='feature.properties.Id', # Specify the Id column, which is unique
            bins=custom_scale, # Defining the scale
            fill_color='YlOrRd', # Defining the color scale
            nan_fill_color="White", # If there is nan data, make it white
            fill_opacity=0.7, # Some transparency in the fill color
            line_opacity=0.2, # Same same
            legend_name='Trend', # legend name
            highlight=True, # highlighting shape when hovering
            line_color='black').add_to(m) # Add this object to the defined map
m
# We will need some extra functions
import base64
from folium import IFrame

# Run a for loop for every row in the dataframe
for i in range(gpd_data.shape[0]):
    # Create a png file pathname to get the png files
    png_name = gpd_data.loc[i, 'COUNTY_NM']+'_'+gpd_data.loc[i, 'STATE_NM']
    png = os.path.join(r"location", png_name+'.png')
    
    # Encode the png image and encode it
    encoded = base64.b64encode(open(png, 'rb').read())
    html = '<img src="data:image/png;base64,{}">'.format
    width, height = 4, 2 # Smaller width and height of each figure
    resolution = 72 # Little lower resolution
    # Create the frame, note that we are adding some values (20 and 30).
    # This will help use to avoid scrolling in the popped up figures
    iframe = IFrame(html(encoded.decode('UTF-8')), width=(width*resolution)+20, height=(height*resolution)+30) 
    popup = folium.Popup(iframe, max_width=2650) # This is the popup object
    
    # The style function is important. This is a lambda function with style propoerties.
    # It says the clickable polygon should not have any fill or line colors
    style_function = lambda x: {'fillColor': '#ffffff', 
                                'color':'#000000', 
                                'fillOpacity': 0.1, 
                                'weight': 0.1}
    # Create a geojson object of each polygon. Note that, this is practically invisible.
    b = folium.GeoJson(gpd_data.iloc[i, -1], style_function=style_function)
    
    b.add_child(popup) # Add the popup to it
    ch.add_child(b) # Add the geojson into the map
# Adding map title
text = 'A 100-year Spatiotemporal Trend of Yield in the Corn Belt of U.S.'
title_html = '''
             <h3 align="left" style="font-size:22px"><b>{}</b></h3>
             '''.format(text)

m.get_root().html.add_child(folium.Element(title_html))

# Save the html file
m.save(r"location_to_html_file/map.html")
#https://souravbhadra.github.io/images/map.html
# %% sound
#https://python-sounddevice.readthedocs.io/en/0.4.1/examples.html
"""Play a sine signal."""
import argparse
import sys
import numpy as np
import sounddevice as sd
def int_or_str(text):
    """Helper function for argument parsing."""
    try:
        return int(text)
    except ValueError:
        return text
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    '-l', '--list-devices', action='store_true',
    help='show list of audio devices and exit')
args, remaining = parser.parse_known_args()
if args.list_devices:
    print(sd.query_devices())
    parser.exit(0)
parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    parents=[parser])
parser.add_argument(
    'frequency', nargs='?', metavar='FREQUENCY', type=float, default=500,
    help='frequency in Hz (default: %(default)s)')
parser.add_argument(
    '-d', '--device', type=int_or_str,
    help='output device (numeric ID or substring)')
parser.add_argument(
    '-a', '--amplitude', type=float, default=0.2,
    help='amplitude (default: %(default)s)')
args = parser.parse_args(remaining)

start_idx = 0

try:
    samplerate = sd.query_devices(args.device, 'output')['default_samplerate']

    def callback(outdata, frames, time, status):
        if status:
            print(status, file=sys.stderr)
        global start_idx
        t = (start_idx + np.arange(frames)) / samplerate
        t = t.reshape(-1, 1)
        outdata[:] = args.amplitude * np.sin(2 * np.pi * args.frequency * t)
        start_idx += frames

    with sd.OutputStream(device=args.device, channels=1, callback=callback,
                         samplerate=samplerate):
        print('#' * 80)
        print('press Return to quit')
        print('#' * 80)
        input()
except KeyboardInterrupt:
    parser.exit('')
except Exception as e:
    parser.exit(type(e).__name__ + ': ' + str(e))
# %% viz
#https://diagrams.mingrammer.com/docs/getting-started/installation
#!pip install diagrams # diagram.py
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
with Diagram("Web Service", show=False): ELB("lb") >> EC2("web") >> RDS("userdb")
# %% viz
#https://github.com/holoviz/lumen
pip install lumen
lumen serve dashboard.yaml --show
# %% ga
#https://itnext.io/goodbye-google-analytics-why-and-how-you-should-leave-the-platform-a1b60b878a79#91df-ad7c6c7143de
#!pip install ga-extractor
ga-extractor setup \
  --sa-key-path="analytics-api-24102021-4edf0b7270c0.json" \
  --table-id="123456789" \
  --metrics="ga:sessions" \
  --dimensions="ga:browser" \
  --start-date="2021-01-01" \
  --end-date="2022-04-21"
ga-extractor extract --report="my-awesome-report.json"
cat /home/user/.config/ga-extractor/my-awesome-report.json | jq .
ga-extractor migrate --format=CSV
head /home/user/.config/ga-extractor/02c2db1a-1ff0-47af-bad3-9c8bc51c1d13_extract.csv
# path,browser,os,device,screen,language,country,referral_path,count,date
# /,Chrome,Android,mobile,1370x1370,zh-cn,China,(direct),1,2022-03-18
# /,Chrome,Android,mobile,340x620,en-gb,United Kingdom,t.co/,1,2022-03-18
ga-extractor migrate --format=UMAMI
# Report written to /home/user/.config/ga-extractor/cee9e1d0-3b87-4052-a295-1b7224c5ba78_extract.sql
# %% clust
#https://github.com/animesh/classix/tree/master
pip install classixclustering
pip show classixclustering #WARNING: Ignoring invalid distribution -ip (c:\users\animeshs\appdata\local\packages\pythonsoftwarefoundation.python.3.9_qbz5n2kfra8p0\localcache\local-packages\python39\site-packages) Name: ClassixClustering Version: 0.5.8
from classix import CLASSIX
X=data[["x","y"]]
clx = CLASSIX(radius=0.3, verbose=1)
clx.fit(X)
import matplotlib.pyplot as plt
plt.figure(figsize=(10,10))
plt.rcParams['axes.facecolor'] = 'white'
clx.labels_
plt.scatter(X["x"], X["y"], c=clx.labels_)
clx.explain(plot=True)
clx.explain(0, plot=True)
clx.explain(0, 100, plot=True)
#from sklearn import datasets
#X, _ = make_blobs(n_samples=5, centers=2, n_features=2, cluster_std=1.5, random_state=1)
#X = pd.DataFrame(X, index=['Anna', 'Bert', 'Carl', 'Tom', 'Bob'])
#clx.explain(index1='Tom', index2='Bert', plot=True, sp_fontsize=12)
# %% codon
#https://github.com/koaning/drawdata
from drawdata import draw_scatter
draw_scatter()
data=pd.read_clipboard(sep=",")
data.head()
#https://calmcode.io/labs/drawdata.html
import pandas as pd
data=pd.read_csv("data4class.csv")
data.plot()
import seaborn as sns
sns.pairplot(data,hue="z")
# %% codon
#translate a DNA sequence to protein
import sys
codon_table = {
    'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
    'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
    'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
    'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
    'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
    'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
    'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
    'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
    'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
    'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
    'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
    'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
    'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
    'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
    'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_',
    'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W',
}
# %%
msg = "Hello World"
print(msg)

# %%
msg = "Hello again"
print(msg)
# %%

#https://blog.devgenius.io/predicting-tesla-stocks-tsla-using-python-pycaret-45af9ed47de9
import pandas as pd
import pandas_datareader as pdr
ts = pdr. av. time_series .AVTimeSeriesReader ("IBM", api_key="44T41340509IQGHL")
df=ts.read()
df.index = pd.to_datetime (df.index, format='%Y-%m-%d')
df.to_csv("output.csv")
dataset=pd.read_csv("output.csv")
data=dataset.sample(frac=0.9)
data_unseen=dataset.drop(data.index)
data.reset_index(drop=True, inplace=True)
data_unseen.reset_index(drop=True, inplace=True)
print ("Data for Modeling :" + str(data.shape))
print("unseen Data For Predictions:"+str(data_unseen.shape))
#Data for Modeling: (2640, 6)
#Unseen Data For Predictions : (293, 6)
from pycaret.regression import *
exp_reg102 = setup(data=data,target='close',session_id=123,use_gpu=True)
compare_models()
#MAE lasso +/-6.6676USD
et=create_model('en')
tuned_et = tune_model (et, n_iter = 1000)
#6.6635
unseen_predictions = predict_model (tuned_et, data=data_unseen)

#https://www.autodesk.com/research/publications/same-stats-different-graphs

#https://stackoverflow.com/a/39881366
def getMatrixMinor(m,i,j): return [row[:j] + row[j+1:] for row in (m[:i]+m[i+1:])]
def getMatrixDeternminant(m):
    #base case for 2x2 matrix
    if len(m) == 2:
        return m[0][0]*m[1][1]-m[0][1]*m[1][0]
    determinant = 0
    for c in range(len(m)):
        determinant += ((-1)**c)*m[0][c]*getMatrixDeternminant(getMatrixMinor(m,0,c))
    return determinant
def getMatrixInverse(m):
    determinant = getMatrixDeternminant(m)
    #special case for 2x2 matrix:
    if len(m) == 2:
        return [[m[1][1]/determinant, -1*m[0][1]/determinant],
                [-1*m[1][0]/determinant, m[0][0]/determinant]]
    #find matrix of cofactors
    cofactors = []
    for r in range(len(m)):
        cofactorRow = []
        for c in range(len(m)):
            minor = getMatrixMinor(m,r,c)
            cofactorRow.append(((-1)**(r+c)) * getMatrixDeternminant(minor))
        cofactors.append(cofactorRow)
    cofactors = transposeMatrix(cofactors)
    for r in range(len(cofactors)):
        for c in range(len(cofactors)):
            cofactors[r][c] = cofactors[r][c]/determinant
    return cofactors
getMatrixInverse([[1,0],[0,1]])#getMatrixInverse([[0,1],[1,0]])
#https://medium.com/gooddata-developers/how-to-automate-your-statistical-data-analysis-852f1a463b95
content_service = sdk.catalog_workspace_content
catalog = content_service.get_full_catalog(workspace_id)
attributes = []
for dataset in catalog.datasets:
    attributes.extend(dataset.attributes)
metrics = catalog.metrics
facts = []
for dataset in catalog.datasets:
    facts.extend(dataset.facts)
numbers: list[Numeric] = []
numbers.extend(metrics)
numbers.extend(facts)
combinations = set()
pairs = itertools.combinations(numbers, 2)
for pair in pairs:
    valid_objects = content_service.compute_valid_objects(workspace_id, list(pair))
    for a in valid_objects.get("attribute", []):
        attribute = catalog.find_label_attribute(f"label/{a}")
        if attribute:
            combinations.add(Triplet([attribute] + list(pair)))
pandas = GoodPandas(os.getenv('HOST'), os.getenv('TOKEN'))
df_factory = pandas.data_frames(workspace_id)
combinations = load_combinations()
columns = list(combinations)[0].as_computable_dictionary
data_frame = df_factory.not_indexed(columns)
#pip install pycircstat
#https://github.com/circstat/pycircstat
#https://medium.com/analytics-vidhya/the-simplest-way-to-create-complex-visualizations-in-python-isnt-with-matplotlib-a5802f2dba92
data.diff().plot.box(vert=False,
                     color={'medians':'lightblue',
                            'boxes':'blue',
                            'caps':'darkblue'});
#https://twitter.com/PhilippBayer/status/1493762737281052677?t=9NRye90Vs1olvEkX3U4mCQ&s=03
#unset PYTHONPATH
#https://machinelearningmastery.com/statistical-hypothesis-tests-in-python-cheat-sheet/
1. Normality Tests
Shapiro-Wilk Test
Observations in each sample are independent and identically distributed (iid).
from scipy.stats import shapiro
data = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
stat, p = shapiro(data)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05: print('Probably Gaussian')
# Example of the D'Agostino's K^2 Normality Test
from scipy.stats import normaltest
stat, p = normaltest(data)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:print('Probably Gaussian')
# Example of the Anderson-Darling Normality Test
from scipy.stats import anderson
result = anderson(data)
print('stat=%.3f' % (result.statistic))
for i in range(len(result.critical_values)):
	sl, cv = result.significance_level[i], result.critical_values[i]
	if result.statistic < cv:
		print('Probably Gaussian at the %.1f%% level' % (sl))
2. Correlation Tests
Observations in each sample have the same variance.
from scipy.stats import pearsonr
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [0.353, 3.517, 0.125, -7.545, -0.555, -1.536, 3.350, -1.578, -3.537, -1.579]
stat, p = pearsonr(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05: print('Probably independent')
Spearman’s Rank Correlation
Observations in each sample can be ranked.
from scipy.stats import spearmanr
stat, p = spearmanr(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05: print('Probably independent')
Kendall’s Rank Correlation
from scipy.stats import kendalltau
stat, p = kendalltau(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05: print('Probably independent')
Chi-Squared Test
Observations used in the calculation of the contingency table are independent.
25 or more examples in each cell of the contingency table.
from scipy.stats import chi2_contingency
table = [[10, 20, 30],[6,  9,  17]]
stat, p, dof, expected = chi2_contingency(table)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05: print('Probably independent')

A Gentle Introduction to the Chi-Squared Test for Machine Learning
scipy.stats.chi2_contingency
Chi-Squared test on Wikipedia
3. Stationary Tests
This section lists statistical tests that you can use to check if a time series is stationary or not.

Augmented Dickey-Fuller Unit Root Test
Tests whether a time series has a unit root, e.g. has a trend or more generally is autoregressive.

Assumptions

Observations in are temporally ordered.
Interpretation

H0: a unit root is present (series is non-stationary).
H1: a unit root is not present (series is stationary).
Python Code

# Example of the Augmented Dickey-Fuller unit root test
from statsmodels.tsa.stattools import adfuller
data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
stat, p, lags, obs, crit, t = adfuller(data)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably not Stationary')
else:
	print('Probably Stationary')
More Information

How to Check if Time Series Data is Stationary with Python
statsmodels.tsa.stattools.adfuller API.
Augmented Dickey–Fuller test, Wikipedia.
Kwiatkowski-Phillips-Schmidt-Shin
Tests whether a time series is trend stationary or not.

Assumptions

Observations in are temporally ordered.
Interpretation

H0: the time series is trend-stationary.
H1: the time series is not trend-stationary.
Python Code

# Example of the Kwiatkowski-Phillips-Schmidt-Shin test
from statsmodels.tsa.stattools import kpss
data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
stat, p, lags, crit = kpss(data)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably Stationary')
else:
	print('Probably not Stationary')
More Information

statsmodels.tsa.stattools.kpss API.
KPSS test, Wikipedia.
4. Parametric Statistical Hypothesis Tests
This section lists statistical tests that you can use to compare data samples.

Student’s t-test
Tests whether the means of two independent samples are significantly different.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample are normally distributed.
Observations in each sample have the same variance.
Interpretation

H0: the means of the samples are equal.
H1: the means of the samples are unequal.
Python Code

# Example of the Student's t-test
from scipy.stats import ttest_ind
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
stat, p = ttest_ind(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Parametric Statistical Hypothesis Tests in Python
scipy.stats.ttest_ind
Student’s t-test on Wikipedia
Paired Student’s t-test
Tests whether the means of two paired samples are significantly different.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample are normally distributed.
Observations in each sample have the same variance.
Observations across each sample are paired.
Interpretation

H0: the means of the samples are equal.
H1: the means of the samples are unequal.
Python Code

# Example of the Paired Student's t-test
from scipy.stats import ttest_rel
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
stat, p = ttest_rel(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Parametric Statistical Hypothesis Tests in Python
scipy.stats.ttest_rel
Student’s t-test on Wikipedia
Analysis of Variance Test (ANOVA)
Tests whether the means of two or more independent samples are significantly different.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample are normally distributed.
Observations in each sample have the same variance.
Interpretation

H0: the means of the samples are equal.
H1: one or more of the means of the samples are unequal.
Python Code

# Example of the Analysis of Variance Test
from scipy.stats import f_oneway
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
data3 = [-0.208, 0.696, 0.928, -1.148, -0.213, 0.229, 0.137, 0.269, -0.870, -1.204]
stat, p = f_oneway(data1, data2, data3)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Parametric Statistical Hypothesis Tests in Python
scipy.stats.f_oneway
Analysis of variance on Wikipedia
Repeated Measures ANOVA Test
Tests whether the means of two or more paired samples are significantly different.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample are normally distributed.
Observations in each sample have the same variance.
Observations across each sample are paired.
Interpretation

H0: the means of the samples are equal.
H1: one or more of the means of the samples are unequal.
Python Code

Currently not supported in Python.

More Information

How to Calculate Parametric Statistical Hypothesis Tests in Python
Analysis of variance on Wikipedia
5. Nonparametric Statistical Hypothesis Tests
Mann-Whitney U Test
Tests whether the distributions of two independent samples are equal or not.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample can be ranked.
Interpretation

H0: the distributions of both samples are equal.
H1: the distributions of both samples are not equal.
Python Code

# Example of the Mann-Whitney U Test
from scipy.stats import mannwhitneyu
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
stat, p = mannwhitneyu(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Nonparametric Statistical Hypothesis Tests in Python
scipy.stats.mannwhitneyu
Mann-Whitney U test on Wikipedia
Wilcoxon Signed-Rank Test
Tests whether the distributions of two paired samples are equal or not.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample can be ranked.
Observations across each sample are paired.
Interpretation

H0: the distributions of both samples are equal.
H1: the distributions of both samples are not equal.
Python Code

# Example of the Wilcoxon Signed-Rank Test
from scipy.stats import wilcoxon
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
stat, p = wilcoxon(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Nonparametric Statistical Hypothesis Tests in Python
scipy.stats.wilcoxon
Wilcoxon signed-rank test on Wikipedia
Kruskal-Wallis H Test
Tests whether the distributions of two or more independent samples are equal or not.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample can be ranked.
Interpretation

H0: the distributions of all samples are equal.
H1: the distributions of one or more samples are not equal.
Python Code

# Example of the Kruskal-Wallis H Test
from scipy.stats import kruskal
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
stat, p = kruskal(data1, data2)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Nonparametric Statistical Hypothesis Tests in Python
scipy.stats.kruskal
Kruskal-Wallis one-way analysis of variance on Wikipedia
Friedman Test
Tests whether the distributions of two or more paired samples are equal or not.

Assumptions

Observations in each sample are independent and identically distributed (iid).
Observations in each sample can be ranked.
Observations across each sample are paired.
Interpretation

H0: the distributions of all samples are equal.
H1: the distributions of one or more samples are not equal.
Python Code

# Example of the Friedman Test
from scipy.stats import friedmanchisquare
data1 = [0.873, 2.817, 0.121, -0.945, -0.055, -1.436, 0.360, -1.478, -1.637, -1.869]
data2 = [1.142, -0.432, -0.938, -0.729, -0.846, -0.157, 0.500, 1.183, -1.075, -0.169]
data3 = [-0.208, 0.696, 0.928, -1.148, -0.213, 0.229, 0.137, 0.269, -0.870, -1.204]
stat, p = friedmanchisquare(data1, data2, data3)
print('stat=%.3f, p=%.3f' % (stat, p))
if p > 0.05:
	print('Probably the same distribution')
else:
	print('Probably different distributions')
More Information

How to Calculate Nonparametric Statistical Hypothesis Tests in Python
scipy.stats.friedmanchisquare
Friedman test on Wikipedia
Further Reading
This section provides more resources on the topic if you are looking to go deeper.

A Gentle Introduction to Normality Tests in Python
How to Use Correlation to Understand the Relationship Between Variables
How to Use Parametric Statistical Significance Tests in Python
A Gentle Introduction to Statistical Hypothesis Tests
Summary
In this tutorial, you discovered the key statistical hypothesis tests that you may need to use in a machine learning project.

Specifically, you learned:

The types of tests to use in different circumstances, such as normality checking, relationships between variables, and differences between samples.
The key assumptions for each test and how to interpret the test result.
How to implement the test using the Python API.
Do you have any questions?
Ask your questions in the comments below and I will do my best to answer.

Did I miss an important statistical test or key assumption for one of the listed tests?
Let me know in the comments below.

Get a Handle on Statistics for Machine Learning!
Statistical Methods for Machine Learning
Develop a working understanding of statistics
...by writing lines of code in python

Discover how in my new Ebook:
Statistical Methods for Machine Learning

It provides self-study tutorials on topics like:
Hypothesis Tests, Correlation, Nonparametric Stats, Resampling, and much more...

Discover how to Transform Data into Knowledge
Skip the Academics. Just Results.

SEE WHAT'S INSIDE
Tweet Tweet  Share
More On This Topic
A Gentle Introduction to Statistical Hypothesis Testing
A Gentle Introduction to Statistical Hypothesis Testing
What is a Hypothesis in Machine Learning?
What is a Hypothesis in Machine Learning?
Statistical Significance Tests for Comparing Machine Learning Algorithms
Statistical Significance Tests for Comparing Machine…
A Gentle Introduction to Statistical Power and Power Analysis in Python
A Gentle Introduction to Statistical Power and Power…
Statistics for Machine Learning (7-Day Mini-Course)
Statistics for Machine Learning (7-Day Mini-Course)
Hypothesis Test for Comparing Machine Learning Algorithms
Hypothesis Test for Comparing Machine Learning Algorithms

About Jason Brownlee
Jason Brownlee, PhD is a machine learning specialist who teaches developers how to get results with modern machine learning methods via hands-on tutorials.
View all posts by Jason Brownlee →
 How to Reduce Variance in a Final Machine Learning ModelA Gentle Introduction to SARIMA for Time Series Forecasting in Python 
82 Responses to 17 Statistical Hypothesis Tests in Python (Cheat Sheet)

Jonathan dunne August 17, 2018 at 7:17 am #
hi, the list looks good. a few omissions. fishers exact test and Bernards test (potentially more power than a fishers exact test)

one note on the anderson darling test. the use of p values to determine GoF has been discouraged in some fields .

REPLY

Jason Brownlee August 17, 2018 at 7:43 am #
Excellent note, thanks Jonathan.

Indeed, I think it was a journal of psychology that has adopted “estimation statistics” instead of hypothesis tests in reporting results.

REPLY

Hitesh August 17, 2018 at 3:19 pm #
Very Very Good and Useful Article

REPLY

Jason Brownlee August 18, 2018 at 5:32 am #
Thanks, I’m happy to hear that.

REPLY

Barrie August 17, 2018 at 9:38 pm #
Hi, thanks for this nice overview.

Some of these tests, like friedmanchisquare, expect that the quantity of events is the group to remain the same over time. But in practice this is not allways the case.

Lets say there are 4 observations on a group of 100 people, but the size of the response from this group changes over time with n1=100, n2=95, n3=98, n4=60 respondants.
n4 is smaller because some external factor like bad weather.
What would be your advice on how to tackle this different ‘respondants’ sizes over time?

REPLY

Jason Brownlee August 18, 2018 at 5:36 am #
Good question.

Perhaps check the literature for corrections to the degrees of freedom for this situation?

REPLY

Fredrik August 21, 2018 at 5:44 am #
Shouldn’t it say that Pearson correlation measures the linear relationship between variables? I would say that monotonic suggests, a not necessarily linear, “increasing” or “decreasing” relationship.

REPLY

Jason Brownlee August 21, 2018 at 6:23 am #
Right, Pearson is a linear relationship, nonparametric methods like Spearmans are monotonic relationships.

Thanks, fixed.

REPLY

Fredrik August 23, 2018 at 8:59 pm #
No problem. Thank you for a great blog! It has introduced me to so many interesting and useful topics.

REPLY

Jason Brownlee August 24, 2018 at 6:07 am #
Happy to hear that!

REPLY

Anthony The Koala August 22, 2018 at 2:47 am #
Two points/questions on testing for normality of data:
(1) In the Shapiro/Wilk, D’Agostino and Anderson/Darling tests, do you use all three to be sure that your data is likely to be normally distributed? Or put it another way, what if only one or two of the three test indicate that the data may be gaussian?

(2) What about using graphical means such as a histogram of the data – is it symmetrical? What about normal plots https://www.itl.nist.gov/div898/handbook/eda/section3/normprpl.htm if the line is straight, then with the statistical tests described in (1), you can assess that the data may well come from a gaussian distribution.

Thank you,
Anthony of Sydney

REPLY

Jason Brownlee August 22, 2018 at 6:15 am #
More on what normality tests to use here (graphical and otherwise):
https://machinelearningmastery.com/a-gentle-introduction-to-normality-tests-in-python/

REPLY

SEYE April 25, 2020 at 8:42 pm #
This is quite helpful, thanks Jason.

REPLY

Jason Brownlee April 26, 2020 at 6:10 am #
You’re welcome.

REPLY

Tej Yadav August 26, 2018 at 4:07 pm #
Wow.. this is what I was looking for. Ready made thing for ready reference.

Thanks for sharing Jason.

REPLY

Jason Brownlee August 27, 2018 at 6:10 am #
I’m happy it helps!

REPLY

Nithin November 7, 2018 at 11:23 pm #
Thanks a lot, Jason! You’re the best. I’ve been scouring the internet for a piece on practical implementation of Inferential statistics in Machine Learning for some time now!
Lots of articles with the same theory stuff going over and over again but none like this.

REPLY

Jason Brownlee November 8, 2018 at 6:08 am #
Thanks, I’m glad it helped.

REPLY

Nithin November 8, 2018 at 11:12 pm #
Hi Jason, Statsmodels is another module that has got lots to offer but very little info on how to go about it on the web. The documentation is not as comprehensive either compared to scipy. Have you written anything on Statsmodels ? A similar article would be of great help.

REPLY

Jason Brownlee November 9, 2018 at 5:22 am #
Yes, I have many tutorials showing how to use statsmodels for time series:
https://machinelearningmastery.com/start-here/#timeseries

and statsmodels for general statistics:
https://machinelearningmastery.com/start-here/#statistical_methods

REPLY

Thomas March 29, 2019 at 10:02 pm #
Hey Jason, thank you for your awesome blog. Gave me some good introductions into unfamiliar topics!

If your seeking for completeness on easy appliable hypothesis tests like those, I suggest to add the Kolmogorov-Smirnov test which is not that different from the Shapiro-Wilk.

– https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.ks_2samp.html
– https://www.researchgate.net/post/Whats_the_difference_between_Kolmogorov-Smirnov_test_and_Shapiro-Wilk_test

REPLY

Jason Brownlee March 30, 2019 at 6:27 am #
Thanks for the suggestion Thomas.

REPLY

Paresh April 16, 2019 at 5:17 pm #
Which methods fits for classification or regression data sets? Which statistical tests are good for Semi-supervised/ un-supervised data sets?

REPLY

Jason Brownlee April 17, 2019 at 6:55 am #
This post will help:
https://machinelearningmastery.com/statistical-significance-tests-for-comparing-machine-learning-algorithms/

REPLY

Luc May 1, 2019 at 10:01 pm #
Hello,
Thank you very much for your blog !

I’m wondering how to check that “observations in each sample have the same variance” … Is there a test to check that ?

REPLY

Jason Brownlee May 2, 2019 at 8:03 am #
Great question.

You can calculate the mean and standard deviation for each interval.

You can also plot the series and visually look for increasing variance.

REPLY

João Antônio Martins June 2, 2019 at 4:39 am #
Is there a test similar to the friedman test? which has the same characteristics “whether the distributions of two or more paired samples are equal or not”.

REPLY

Jason Brownlee June 2, 2019 at 6:45 am #
Yes, the paired student’s t-test.

REPLY

MIAO June 27, 2019 at 3:37 pm #
HI, Jason, Thank you for your nice blog. I have one question. I have two samples with different size (one is 102, the other is 2482), as well as the variances are different, which statistical hypothesis method is appropriate? Thank you.

REPLY

Jason Brownlee June 28, 2019 at 5:57 am #
That is a very big difference.

The test depends on the nature of the question you’re trying to answer.

REPLY

Adrian Olszewski February 27, 2020 at 11:32 pm #
Practically ALL assumptions and ALL interpretations are wrong in this cheatsheet. I cannot recommend this, as if a student repeats that on a stat exam or on an interview led by a statistician, one’s likely to fail it. I am messaged regularly by young aspiring data scientists who experienced problems after repeating texts from the internet, that’s why I ask you to not exposing learners to such situations.

1. Assumptions of the paired t-test are totally wrong, or copy-pasted. The interpretation is wrong too.
2. Anova is not a test, but OK, let’s pretend I didn’t see it. The interpretation isn’t correct. If you follow that, you may be really surprised doing the post-hoc
3. interpretation of the RM-ANOVA is wrong
4. Mann-Whitney is described imprecisely.
5. Paired Wilcoxon has wrong interpretation.
6. Normality tests – all is wrong. What “each sample” – in normality test? and it doesn’t tell if it’s Gaussian! It says of the data is approximated by the normal distribution acceptably well at this sample size. In a minute I can give you examples drawn from log-normal or Weibull reported as “Gaussian” .

It’s worth noting there are over 270 tests, 50 in constant, everyday use, varying across industries and areas of specialization. Type “100 statistical tests PDF” into Google or find the handbook of parametric and non-parametric methods by Sheskin (also available in PDF), to get some rough idea about them. The more you know, the less you are limited. Each of those tests has its weaknesses and strengthens you should know before the use. Always pay attention to the null hypothesis and the assumptions. Jason Brownlee

REPLY

Jason Brownlee February 28, 2020 at 6:09 am #
Thanks for your feedback Adrian.

REPLY

Mr.T March 1, 2020 at 9:08 am #
You sir, are patronizing.

I am an early stage learner of all of this, and Jason’s posts have been incredibly helpful in helping me construct a semantic tree of all the knowledge pieces. Without a lot of his posts, my knowledge pieces would be scattered.
I am not certain about the accuracy as you have pointed out, but your lack of constructiveness in your comment is concerning. You do not provide what you believe is the correct interpretation.

I truly hate to see a comment like this. Keep up the good work Jason!

REPLY

Jason Brownlee March 2, 2020 at 6:10 am #
Thanks for your support!

REPLY

Andrew M October 26, 2021 at 7:51 pm #
Adrian, having stumbled on this blog, I have to say this is an extremely unhelpful comment. Jason has put together a simple, concise and helpful well structured guide to stats for those not expert in the field. All you have done is spout a load of negativity. Some manners, gratitude and constructive comment would be more useful. People like you are the reason why so many are put off statistics. Thank you Jason, please carry on with your helpful content

REPLY

MIAO June 28, 2019 at 5:50 pm #
Thank you. Jason. The problem I process is that: I have results of two groups, 102 features for patient group and 2482 features for healthy group, and I would like to take a significant test for the features of two groups to test if the feature is appropriate for differentiate the two groups. I am not sure which method is right for this case. Could you give me some suggestions? Thank you.

REPLY

Jason Brownlee June 29, 2019 at 6:37 am #
Sounds like you want a classification (discrimination) model, not a statistical test?

REPLY

MIAO July 1, 2019 at 10:52 am #
Yeah, I think you are right. I will use SVM to classify the features. Thank you.

REPLY

Veetee August 6, 2019 at 1:04 am #
Hi Jason, thanks for the very useful post. Is there a variant of Friedman’s test for only two sets of measurements? I have an experiment in which two conditions were tested on the same people. I expect a semi-constant change between the two conditions, such that the ranks within blocks are expected to stay very similar.

REPLY

Jason Brownlee August 6, 2019 at 6:40 am #
Yes: Wilcoxon Signed-Rank Test

REPLY

wishy September 6, 2019 at 10:09 pm #
Dear Sir,

I have one question if we take subset of the huge data,and according to the Central limit theorem the ‘samples averages follow normal distribution’.So in that case is it should we consider Nonparametric Statistical Hypothesis Tests or parametric Statistical Hypothesis Tests

REPLY

Jason Brownlee September 7, 2019 at 5:29 am #
I don’t follow your question sorry, please you can restate it?

Generally nonparametric stats use ranking instead of gaussians.

REPLY

gopal jamnal September 28, 2019 at 10:43 pm #
What is A-B testing, and how it can be useful in machine learning. Is it different then hypotheisis testing?

REPLY

Jason Brownlee September 29, 2019 at 6:12 am #
More on a/b testing:
https://en.wikipedia.org/wiki/A/B_testing

It is not related to machine learning.

Instead, in machine learning, we will evaluate the performance of different machine learning algorithms, and compare the samples of performance estimates to see if the difference in performance between algorithms is significant or not.

Does that help?

More here:
https://machinelearningmastery.com/statistical-significance-tests-for-comparing-machine-learning-algorithms/

REPLY

Peiran November 14, 2019 at 8:57 am #
You can’t imagine how happy I am to find a cheat sheet like this! Thank you for the links too.

REPLY

Jason Brownlee November 14, 2019 at 1:43 pm #
Thanks, I’m happy it helps!

REPLY

Chris Winsor December 3, 2019 at 2:23 pm #
Hi Jason –

Thank you for helping to bring the theory of statistics to everyday application !

I’m wishing you had included an example of a t-test for equivalence. This is slightly different from the standard t-test and there are many applications – for example – demonstrating version 2.0 of the ml algorithm matches version 1.0. That is actually super important for customers that don’t want to re-validate their instruments, or manufacturers that would need to answer why/if those versions perform the same as one-another.

I observe a library at
http://www.statsmodels.org/0.9.0/generated/statsmodels.stats.weightstats.ttost_paired.html#statsmodels.stats.weightstats.ttost_paired
but it doesn’t explain how to establish reasonable low and high limits.

Anyway thank you for the examples !

REPLY

Jason Brownlee December 4, 2019 at 5:28 am #
Great suggestion, thanks Chris!

REPLY

makis January 29, 2020 at 4:58 am #
Hi Jason,

Great article.

If I want to compare the Gender across 2 groups, is chi-square test a good choice?
I want to test for signiicant differences similarly to a t-test for a numerical variable.

REPLY

Jason Brownlee January 29, 2020 at 6:48 am #
It depends on the data, perhaps explore whether it is appropriate with a prototype?

REPLY

jessie June 29, 2020 at 7:10 pm #
Hi Jason,
I wanna use Nonparametric Statistical Hypothesis Tests to analysis ordinal data(good, fair, bed) or categorical data, would i encode them to numerical data and follow the above steps? Would u give some suggestion?
Thanks.

REPLY

Jason Brownlee June 30, 2020 at 6:21 am #
Good question. No, I don’t think that would be correct.

Perhaps seek out a test specific for this type of data?

REPLY

Jonathan August 23, 2020 at 8:43 am #
Repeated measures ANOVA can be performed in Python using the Pingouin library https://pingouin-stats.org/generated/pingouin.rm_anova.html

REPLY

Jason Brownlee August 23, 2020 at 1:16 pm #
Thanks for sharing.

REPLY

Kenny August 31, 2020 at 7:17 pm #
Hi Jason,
Thanks for the very informative Article. It looks great to see all Hypothesis tests in one article.
1) Would you be able to help saying when to use Parametric Statistical Hypothesis Tests and when to use Non-Parametric Statistical Hypothesis Tests,please?
Knowing what to use in given situations could be a lot helpful.
2) For doing A/B Testing with varying distributions in the 2 experiments under conditions of multiple features involved, would you recommend Parametric Statistical Hypothesis Tests or Non-Parametric Statistical Hypothesis Tests?
( I have tried Parametric Statistical Hypothesis Tests but it was getting hard to meet the statistical significance, as there are multiple features involved)

REPLY

Jason Brownlee September 1, 2020 at 6:28 am #
Use a parametric test when your data is Gaussian and well behaved, use a non-parametric test otherwise.

I don’t know about significance test for A/B testing off hand sorry. The sample distribution is discrete I would expect. Perhaps a chi squared test would be appropriate? I’m shooting from the hip.

REPLY

MARCILIO DE OLIVEIRA MEIRA September 4, 2020 at 1:08 pm #
Hi Jason, make any sense using an statistical hypothesis tests for image classification, with machine learning? What method is more suitable for a problem of image classification to determine if a image belong to a class A or class B?

REPLY

Jason Brownlee September 4, 2020 at 1:38 pm #
Not in this case, a machine learning model would perform this prediction for you.

REPLY

Kenny September 21, 2020 at 4:59 pm #
Hi Jason,
Thanks for the article .Its quite informative.

Say if the data for some reasons has a non-monotonic relationship between the variables, would Hypothesis testing be of much help?
Doesn’t it make sense to first check the prior belief by actually verifying if the relationship is monotonous or not, before doing any specific Hypothesis tests to get further statistical insights?

REPLY

Jason Brownlee September 22, 2020 at 6:43 am #
It depends on the question you want to answer.

REPLY

Hugo November 11, 2020 at 2:58 am #
Hi Jason,

Congratulations on the work you are doing with such subjects. It really helps me every time I need to get quick and pŕecise content in this field.

I do have a question, though. About the stats.f_oneway module (ANOVA), I’m trying to run it with samples that have different sizes, and that is returning an error “ValueError: arrays must all be same length”.

I tried to find the solution for this in the community, but I failed in finding it. Could you please help me out with this? Should I input np.nan values to “fill” the empty spaces in the samples so they all match the same length?

Thanks in advance!

Best regards from Brazil.

REPLY

Jason Brownlee November 11, 2020 at 6:52 am #
Thanks!

Perhaps a different test is more appropriate?
Perhaps you can duplicate some samples (might make the result less valid)?
Perhaps you can find an alternate implementation?
Perhaps you can develop your own implementation from a textbook?

I hope that gives you some ideas.

REPLY

Bahram Khazra March 7, 2021 at 6:25 pm #
Hi Jason,
Can we use cross-entropy for hypothesis testing?
Is there any relation between cross-entropy and p-value?

REPLY

Jason Brownlee March 8, 2021 at 4:44 am #
You can run hypothesis testing on cross-entropy values.

No direct connection between cross entropy and statistical hypothesis testing as far as I can think of off the cuff.

REPLY

JG April 16, 2021 at 6:17 pm #
Hi Jason,

Thank you very much for this statistical test summary. Where, e.g. we can check features distribution and inter-correlations. Also we appreciate your code oriented explanation as a way to teach and play with these statistical concepts.

I share the following comments, experimenting with your small pieces of codes.

1º) if we set the same two data arrays (but not if we change the order) on the table of chi-squared test function, you get a surprising answer (they are independents!). I guess something wrong on chi2-contingency() module library

2º) if we set the same two data arrays on the Paired Student’s t-test arguments, we got the same bad results (they are different distribution)!. Same comment on possible fail library implementation.

3º) if we set the same two data arrays on Wilcoxon Signed-Rank Test, we got an err message indicating they can not work if both array are exactly the same.

4º) regarding Friedman test. two comments. It is only work with 3 or more data arrays (two are not enough as you write-down). And if you set the same 3 arrays you got the same surprising results that they are different distributions.

you can check out these experiments in less than 1 minute.

regards,
JG

REPLY

Jason Brownlee April 17, 2021 at 6:09 am #
Great experiments, I should have done them myself!

The functions should include such cases in their unit tests…

REPLY

JG April 17, 2021 at 8:01 pm #
Thank you Jason !

Perfect is the enemy of good!, said Voltaire

so I like your inspirational and the great values of your codes-posts, quickly ready for use …I am not interesting on perfection…because meanwhile you can loose attention to other emerging options that are replacing the value of your search ! 🙂

REPLY

Jason Brownlee April 18, 2021 at 5:53 am #
Thanks!

REPLY

PSE July 15, 2021 at 3:50 am #
Thank you, Jason! Great read and so helpful. Sharing with my machine learning enthusiastic contacts as well on LinkedIn.

REPLY

Jason Brownlee July 15, 2021 at 5:33 am #
You’re welcome!

REPLY

Shanna August 14, 2021 at 4:31 am #
Thanks for the great work!

REPLY

Adrian Tam August 14, 2021 at 11:37 am #
Glad you like it!

REPLY

TR RAO September 13, 2021 at 11:58 pm #
You are doing great. We are learning ML happily. Great efforts by you. Thanks

TR RAO

REPLY

Adrian Tam September 14, 2021 at 1:36 pm #
You’re welcomed.

REPLY

sanju September 21, 2021 at 3:57 pm #
Hi, great post. If you could update the post with an application example of all the test, it would be just awesome. BTW thanks for all the awesome posts.

REPLY

Adrian Tam September 23, 2021 at 3:04 am #
Thanks for the suggestion. We will consider that.

REPLY

suanzy November 5, 2021 at 6:04 pm #
Hey, please check the Kwiatkowski-Phillips-Schmidt-Shin part in this article. Ho & H1 seems to be another way round…

REPLY

Adrian Tam November 7, 2021 at 8:08 am #
You’re right! It is corrected.

REPLY

Hari N November 12, 2021 at 5:17 pm #
Excellent. It would be greatly appreciated if you can make a tutorial on Bayesian Analysis.

REPLY

Adrian Tam November 14, 2021 at 2:20 pm #
Any particular example you want to learn on?

REPLY

Prem February 8, 2022 at 9:57 am #
Hi Jason, than you for the wonderful comprehensive post. Just to add, there is a test available in statsmodels for repeated ANOVA test. Worth exploring.

from statsmodels.stats.anova import AnovaRM

REPLY

James Carmichael February 8, 2022 at 12:27 pm #
Thank you for the feedback Prem!

REPLY
Leave a Reply

Name (required)

Email (will not be published) (required)


Welcome!
I'm Jason Brownlee PhD
and I help developers get results with machine learning.
Read more

Never miss a tutorial:

LinkedIn     Twitter     Facebook     Email Newsletter     RSS Feed
Picked for you:

Statistics for Machine Learning (7-Day Mini-Course)
Statistics for Machine Learning (7-Day Mini-Course)
A Gentle Introduction to k-fold Cross-Validation
A Gentle Introduction to k-fold Cross-Validation
How to Calculate Bootstrap Confidence Intervals For Machine Learning Results in Python
How to Calculate Bootstrap Confidence Intervals For Machine Learning Results in Python
Statistical Significance Tests for Comparing Machine Learning Algorithms
Statistical Significance Tests for Comparing Machine Learning Algorithms
A Gentle Introduction to Normality Tests in Python
A Gentle Introduction to Normality Tests in Python
Loving the Tutorials?
The Statistics for Machine Learning EBook is
where you'll find the Really Good stuff.

>> SEE WHAT'S INSIDE
© 2021 Machine Learning Mastery. All Rights Reserved.
LinkedIn | Twitter | Facebook | Newsletter | RSS

Privacy | Disclaimer | Terms | Contact | Sitemap | Search

#https://medium.com/@florian.rieger/if-you-haven-t-heard-of-descriptors-you-don-t-know-python-1ea4fd1614c2
class IsBetween:
    def __init__(self,
                 min_value, 
                 max_value, 
                 below_exception=ValueError(),                        
                 above_exception=ValueError()):
        self.min_value = min_value
        self.max_value = max_value

        self.below_exception = below_exception
        self.above_exception = above_exception

    def __set_name__(self, owner, name):
        self.private_name = '_' + name
        self.public_name = name

    def __set__(self, obj, value):
        if value < self.min_value:
            raise self.below_exception

        if value > self.max_value:
            raise self.above_exception

        setattr(obj, self.private_name, value)

    def __get__(self, obj, objtype=None):
        return getattr(obj, self.private_name)
class Car:

    fuel_amount = IsBetween(0, 60, ValueError(), ValueError())

    def __init__(self):
        self.fuel_amount = 0
#https://github.com/datapane/gallery/tree/master/stock-reporting
#Create Plotly functions for our visualizations, Create the report in Python using Datapane’s library, Write a .yml file for GitHub actions, Share the report online or embed it on blogs
trace0 = go.Scatter(x=nflx.Date, y=nflx.Close, name='nflx')
fig0 = go.Figure([trace0])
fig0.update_layout(
    title={
        'text': "Disease Stock Price",
        'x':0.5,
        'xanchor': 'center'})
trace0 = go.Scatter(x=nflx.Date, y=nflx.Close, name='NFLX')
trace1 = go.Scatter(x=nflx.Date, y=nflx['10-day MA'], name='10-day MA')
trace2 = go.Scatter(x=nflx.Date, y=nflx['20-day MA'], name='20-day MA')
fig1 = go.Figure([trace0, trace1, trace2])
fig1.update_layout(
    title={
        'text': "Disease Stock Price",
        'x':0.5,
        'xanchor': 'center'})
dp.Report(
        dp.Blocks(
            dp.Plot(fig0),
            dp.Plot(fig1),
            dp.Plot(fig2),
            dp.Plot(fig3),
            dp.Plot(fig4),
            dp.Plot(fig5),
            dp.Plot(fig6),
            dp.Plot(fig7),
            columns=2,
            rows=4
        ), dp.Plot(fig8)
    ).publish(name='stock_report', open=True)
#Write a .yml file for GitHub actions, Added requirements (pandas-reader), Scheduled cron jobs (every day at 6 am), Added script and token
#pip install darts
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from darts import TimeSeries
from darts.datasets import AirPassengersDataset
series = AirPassengersDataset().load()
series.plot()
series1, series2 = series.split_before(0.75)
series1.plot()
series2.plot()
from darts.utils.missing_values import fill_missing_values
values = np.arange(50, step=0.5)
values[10:30] = np.nan
values[60:95] = np.nan
series_ = TimeSeries.from_values(values)
(series_ - 10).plot(label="with missing values (shifted below)")
fill_missing_values(series_).plot(label="without missing values")
#https://medium.com/@rajpurohitvijesh/fast-data-visualization-using-utilmy-afb4e02da75e
!pip install utilmy
from utilmy.viz import vizhtml as vi
import pandas as pd
url = 'https://raw.githubusercontent.com/AlexAdvent/high_charts/main/data/stock_data.csv'
df = pd.read_csv(url)
df.head()
### title: will set the page title to it
doc = vi.htmlDoc(title='Stock Market Analysis' )
doc.h2('Stock Market Analysis')
doc.h4('plot Data in table format')
doc.table(df,  table_id="test", custom_css_class='intro',use_datatable=True)
doc.hr()
doc.h4('Stock tseries graph')

doc.plot_tseries(
    df,coldate    = 'Date', 
    date_format   = '%m/%d/%Y', 
    coly1         = ['Open', 'High', 'Low', 'Close'], 
    coly2         = ['Turnover (Lacs)'],title = "Stock",
)
doc.save('stock market analysis.html')
df = pd.DataFrame({ 
     'from':['A', 'B', 'C','A'], 
     'to':['D', 'A', 'E','C'], 
     'weight':[1, 2, 1,5]})
doc = vi.htmlDoc(title='Plot Graph',css_name = "A4_size")
doc.h4('Graph Data plot')
doc.table(df, use_datatable=True, table_id="test", 
    custom_css_class='intro')
doc.pd_plot_network(df, cola='from', colb='to', 
    coledge='col_edge',colweight="weight")
doc = vi.htmlDoc(title="A histogram")
doc.plot_histogram(df, col="Close",mode='highcharts')
doc = vi.htmlDoc(title="A histogram")
doc.plot_histogram(df, col="Close",mode='highcharts')
doc = vi.htmlDoc(title="A histogram")
doc.plot_histogram(df,col='Close',title="Price", mode='matplot')
#https://medium.com/similarweb-engineering/visualize-a-message-using-python-faafd93bbcb
scat = ax.scatter(datasource_a['x'], datasource_a['y'], s = 50, alpha = 0.3, zorder=10) # Data source A scatter
y_delta = datasource_b['y'] - datasource_a['y'] # distance to animate
def animate(i):
    perc_of_change = ((i+1)*1./NUM_OF_FRAMES)
    scat.set_offsets(np.array([datasource_a['x'], datasource_a['y'] + perc_of_change * (y_delta)]).T)
    if i*1./NUM_OF_FRAMES <= 0.3: # fade out text of Data source A
        ax.texts[0].update({'alpha': 1- i*1./NUM_OF_FRAMES/0.3})
    else:
        ax.texts[0].update({'alpha': i*1./NUM_OF_FRAMES}) # fade in text of Data source B
        ax.texts[0].set_text('Data source B')
anim = animation.FuncAnimation(fig, animate, interval = 70, frames = NUM_OF_FRAMES, repeat = False)
HTML(anim.to_html5_video())
#https://sivachandan1996.medium.com/text-matching-for-data-manipulation-in-pandas-using-fuzzywuzzy-1a24f00e010
#!pip install fuzzywuzzy
from fuzzywuzzy import process
for state in Indian_Crime_Data['State']:
    match = process.extract(state,Indian_Population['State'],limit = 1)
    #print(type(match),match)
    Indian_Crime_Data['State'] = Indian_Crime_Data['State'].str.replace(state,match[0][0])
#what process.extract() does. It takes three arguments. A string that we compare with an array of strings An array of strings a limit = n(integer) argument to specify how many matches should we return as a list After passing these arguments and executing process.extract(), it returns a list containing tuples, which has a match along with its score. These tuples are sorted in descending order with respect to their score. Check the example below to see how the process.extract() works Since we passed the argument limit = 1 only one tuple will be present in the list. The Final Data Frame: After we are done with this text/String matching using Fuzzywuzzy. We can now easily merge the data on the ‘State’ column.
# Merging the Data Frames on State column
Indian_crime = Indian_Crime_Data.merge(Indian_Population,on = 'State')
#https://towardsdatascience.com/hiplot-interactive-visualization-tool-by-facebook-f83aea1b639a
#!pip install -U hiplot
import hiplot as hip
import pandas as pd
from sklearn.datasets import load_iris
iris = load_iris(as_frame=True)['frame']
iris.head()
hip.Experiment.from_dataframe(iris).display()
df.progress_apply(lambda x: pass)
verstack
#https://datas-science.medium.com/a-swiss-knife-python-package-for-fast-data-science-4bc3295d830a
from utilmy import np_list_intersection
np_list_intersection([1, 2, 3, 4], [3, 4, 5, 6])
#https://medium.com/analytics-vidhya/calendar-heatmaps-a-perfect-way-to-display-your-time-series-quantitative-data-ad36bf81a3ed
!pip install calplot july
#read the data
import pandas as pd
df = pd.read_csv('C:/Users/~sales_data_sample.csv')
df['ORDERDATE'] = pd.to_datetime(df['ORDERDATE'])
#Set orderdate as index
df.set_index('ORDERDATE', inplace = True)
import calplot
pl1 = calplot.calplot(data = df['SALES'],how = 'sum', cmap = 'Reds', figsize = (16, 8), suptitle = "Total Sales by Month and Year")
#https://chromedriver.chromium.org/downloads/#group the orders by date and count the number of orders per day
counts = df.groupby('ORDERDATE')['ORDERNUMBER'].agg( 'count').reset_index()
counts['ORDERDATE'] = pd.to_datetime(counts['ORDERDATE'])
counts
#create the plot
calplot.calplot(counts['ORDERNUMBER'], cmap = 'GnBu', textformat  ={:.0f}', figsize = (16, 8), suptitle = "Total Orders by Month and Year")version-selection
!pip install ipywidgets
from ipywidgets import interact, interactive, fixed, interact_manual
import ipywidgets as widgets
products = set(list(df['PRODUCTLINE]))
def draw_calplot(prod):
   data_subset = df[df['PRODUCTLINE'] == prod]
   plt = calplot.calplot(data = data_subset['SALES'], how = 'sum',     cmaps = 'Reds', figsize = (16,8), suptitle = 'Total Sales for teh Product '+prod) 
x = interact(draw_calplot, prod = products) 
import july
from july.utils import date_range
dates = date_range("2004-01-01", "2004-12-31")
july.heatmap( dates, data =df1['SALES'], title='Total Sales', cmap="golden", month_grid=True, horizontal = True)
#https://medium.com/geekculture/displaying-altair-charts-in-power-bi-4673e0f80291
# The following code to create a dataframe and remove duplicated rows is always executed and acts as a preamble for your script:

# dataset = pandas.DataFrame(Emoji, Use Percent, Use Number)
# dataset = dataset.drop_duplicates()

# Paste or type your script code here:

# The following code to create a dataframe and remove duplicated rows is always executed and acts as a preamble for your script:


import altair as alt

plot = (
    alt.Chart(dataset)
    .mark_square(color="red", strokeWidth=3,)
    .encode(
        x=alt.X("Emoji:N", axis=alt.Axis(title=None, labelFontSize=30, labelAngle=0)),
        y=alt.Y(
            "Use Percent:Q",
            axis=alt.Axis(
                format=".0%",
                labelFontSize=12,
                labelFontWeight="bold",
                titleFontSize=20,
                titleFontWeight="bold",
            ),
        ),
        size=alt.Size(
            "Use Percent:Q",
            scale=alt.Scale(domain=[0, 0.3], range=[30, 500]),
            legend=None,
        ),
        color=alt.Color(
            "Use Percent:Q",
            scale=alt.Scale(range=["green", "yellow", "red"]),
            legend=alt.Legend(format=".1%"),
        ),
    )
    .properties(width=600, height=400)
)


text = plot.mark_text(
    align="left",
    baseline="middle",
    dx=10,  # Nudges text to right so it doesn't appear on top of the bar
    dy=-10,
).encode(
    # we'll use the percentage as the text
    text=alt.Text("Use Number:Q"),
    size=alt.SizeValue(20),
)

# (text+plot).show()

(text + plot).save("chart.png")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

img = mpimg.imread("chart.png")
imgplot = plt.imshow(img)
!pip install pymotif
To verify that the installation was successful, run this in a new cell:
from pymotif import Motif
motif = Motif()
motif.plot()
#https://medium.com/spatial-data-science/styling-pandas-dataframe-elegantly-with-tabulator-c66f33b1905f

#https://medium.com/@pranjallk1995/a-complete-introduction-to-plotly-from-beginner-to-advanced-34e506cc1f94
#‘pip install jupyterthemes’. Then do ‘jt -t onedork’
#https://towardsdatascience.com/interactive-data-visualization-in-python-with-pygal-4696fccc8c96
#visualizing daily correlation matrix
from google.colab import drive
drive.mount('/content/drive')
Then we will import the required libraries and set the default renderer as Google Colab as shown:
#importing libararies
import numpy as np
import pandas as pd
import datetime as dt
import plotly.io as pio
import plotly.graph_objs as go

from plotly import subplots
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
X_appartment = np.array(dataset_train["Squaremeter"]).reshape(-1, 1)
Y_appartment = np.array(dataset_train["Price"]).reshape(-1, 1)
regressor = LinearRegression()
regressor.fit(X_appartment, Y_appartment)
trace0 = go.Scatter(
    x = dataset_train["Squaremeter"], 
    y = dataset_train["Price"], 
    mode = "markers",
    name = "Price vs Squaremeter"
)
X = np.linspace(start = 5, stop = 120, num = 500).reshape(-1, 1)
trace1 = go.Scatter(
    x = X.reshape(len(X),),
    y = regressor.predict(X).reshape(len(X),),
    mode = "lines",
    name = "Trendline"
)
data = [trace0, trace1]
fig = go.Figure(data)
fig.update_layout(title = "Apartment Prices", 
                  xaxis_title = "Sq. meters", yaxis_title = "Price", 
                  template = "plotly_dark")
fig.show()
#setting the rederer as colab
pio.renderers.default = "colab"
date = "08"
month = "01"
corr_daily = dataset_train_day.corr()
corr_daily[np.isnan(corr_daily)] = 0
mask = np.triu(np.ones_like(corr_daily, dtype = bool))
annotations_daily = []
for n, row in enumerate(corr_daily):
    for m, col in enumerate(corr_daily):
        if n >= m or abs(corr_daily[row][col]) <= 0.35:
            annotations_daily.append(go.layout.Annotation(text = "", 
                                         xref = "x",
                                         yref = "y",
                                         x = row,
                                         y = col,
                                         showarrow = False))
        else:
            annotations_daily.append(go.layout.Annotation(
                         text = str(round(corr_daily[row][col], 2)),
                                         xref = "x",
                                         yref = "y",
                                         x = row,
                                         y = col,
                                         showarrow = False))
trace0 = go.Heatmap(
    z = corr_daily.mask(mask),
    x = corr_daily.index.values,
    y = corr_daily.columns.values,
    colorscale = "RdBu",
    ygap = 1, 
    xgap = 1,
    showscale = False,
    xaxis = "x",
    yaxis = "y"
)


#visualizing yearly correlation matrix
corr = dataset_train_group.corr()
mask = np.triu(np.ones_like(corr, dtype = bool))
annotations = []
for n, row in enumerate(corr):
    for m, col in enumerate(corr):
        if n >= m or abs(corr[row][col]) <= 0.35:
            annotations.append(go.layout.Annotation(text = "",
                                         xref = "x2",
                                         yref = "y2",
                                         x = row,
                                         y = col,
                                         showarrow = False))
        else:
            annotations.append(go.layout.Annotation(
                               text = str(round(corr[row][col], 2)),
                                         xref = "x2",
                                         yref = "y2",
                                         x = row,
                                         y = col,
                                         showarrow = False))
trace1 = go.Heatmap(
    z = corr.mask(mask),
    x = corr.index.values,
    y = corr.columns.values,
    colorscale = "RdBu",
    ygap = 1, 
    xgap = 1,
    xaxis = "x2",
    yaxis = "y2"
)


fig = subplots.make_subplots(rows = 2, cols = 1, 
                             shared_xaxes = True, 
                             vertical_spacing = 0.1,
                             subplot_titles = (
                             "Heatmap for " + date + "-" \
                             + str(dt.datetime.strptime(
                                   month, "%m").strftime("%b")),
                             "Yearly Heatmap"))
fig.add_trace(trace0, row = 1, col = 1)
fig.add_trace(trace1, row = 2, col = 1)
fig["layout"].update(title = "Correlation Matrices", 
                     template = "plotly_dark", 
                     annotations = [annotations[0]] + \  
                                   [annotations[1]] + \
                                    annotations + annotations_daily,
                     #seems to be a bug, had to add annotations[0] 
                     #and annotations[1] explicitly... 
                     #wasted more than 3hrs easily T_T
                     xaxis = {"visible": False}, 
                     xaxis2 = {"visible": False},
                     yaxis = {"visible": False}, 
                     yaxis2 = {"visible": False},
                     yaxis_autorange = "reversed", 
                     yaxis2_autorange = "reversed",
                     xaxis_showgrid = False, yaxis_showgrid = False,
                     xaxis2_showgrid = False, 
                     yaxis2_showgrid = False, height = 900)
fig.show()
from pygal.style import Style
custom_style = Style(
  background='transparent',
  plot_background='transparent',
  font_family = 'googlefont:Bad Script',
  colors=('#05668D', '#028090', '#00A896', '#02C39A', '#F0F3BD'))
import pygal
import pandas as pd
#Parse the dataframe
data = pd.read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv") 
#Get the mean number of cases per states
mean_per_state = data.groupby('state')['cases'].mean()
#The donut shape gauge chart
gauge = pygal.SolidGauge(inner_radius=0.70)
[gauge.add(x[0], [{"value" : x[1] * 100}] ) for x in mean_per_state.head().iteritems()]
display(HTML(base_html.format(rendered_chart=gauge.render(is_unicode=True))))
#The needle shape gquge chart
gauge = pygal.Gauge(human_readable=True)
[gauge.add(x[0], [{"value" : x[1] * 100}] ) for x in mean_per_state.head().iteritems()]
display(HTML(base_html.format(rendered_chart=gauge.render(is_unicode=True))))
#https://medium.com/casual-inference/the-most-time-efficient-ways-to-import-csv-data-in-python-cc159b44063d  of which was already covered above:
import pandas as pd
import time
import csv
import paratext
import dask.dataframe
input_file = "random.csv"
start_time = time.time()
data = csv.DictReader(open(input_file))
print("csv.DictReader took %s seconds" % (time.time() - start_time))
start_time = time.time()
data = pd.read_csv(input_file)
print("pd.read_csv took %s seconds" % (time.time() - start_time))
start_time = time.time()
data = pd.read_csv("random.csv", chunksize=100000)
print("pd.read_csv with chunksize took %s seconds" % (time.time() - start_time))
start_time = time.time()
data = dask.dataframe.read_csv(input_file)
print("dask.dataframe took %s seconds" % (time.time() - start_time))
#https://danilzherebtsov.medium.com/parallelise-like-a-boss-with-a-single-line-of-code-in-python-30af0d640511
# iterate over a pd.DataFrame and a list
iterable_list = list(range(0,10))
import pandas as pd
iterable_df = pd.DataFrame(
    {'col1':range(5,15), 
     'col2':range(10,20), 
     'col3':list('abcdefghij')})
def iterate_dataframe_and_iterable(iterable, df):
    result = df['col1'] * iterable / (df['col2']**2)
    return result    
from verstack import Multicore
worker = Multicore(multiple_iterables = True,workers = 2) # notice the workers parameter
result = worker.execute(iterate_dataframe_and_iterable, [iterable_list, iterable_df])
iterable = range(0,1000000)
def func(n):
    # Real hard work here
    return n**2

def execute_func_using_verstack():
    from verstack import Multicore
    import pickle
    worker = Multicore()
    result = worker.execute(func, iterable)
    pickle.dump(result, open('iteration_result.p', 'wb'))

if __name__ == '__main__':
    execute_func_using_verstack()

#NaNImputerwill deploy machine learning models based on XGBoost and predict missing values
#verstack.ThreshTuner — tune threshold for binary classification models automatically
#verstack.ThreshTuner — automatic threshold selection for improving loss function
#stratified_continuous_split — continuous data stratification (by far the most popular tool)
#timer
#https://medium.com/fandom-engineering/sroka-a-python-library-to-simplify-data-access-5a2fdc8542a0
# Athena API
from sroka.api.athena.athena_api import query_athena, done_athena
# GAM API
from sroka.api.google_ad_manager.gam_api import get_data_from_admanager
# data wrangling
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.dates as mdates
# GAM query
start_day = '01'
end_day = '31'
start_month = '03'
end_month = '03'
year = '2019'
query = """WHERE CUSTOM_TARGETING_VALUE_ID IN ([wiki_ids])"""
dimensions = ['DATE']
columns = ['TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS']
start_date = {'year': year,
              'month': start_month,
              'day': start_day}
stop_date = {'year': year,
             'month': end_month,
             'day': end_day}
print('starting...')
data_raw_gam = get_data_from_admanager(query, dimensions, columns, start_date, stop_date)
print('data gathered')
# create df copy
df_gam = data_raw_gam.copy()
# change column names
df_gam.rename(
    columns={
        'Dimension.DATE': 'Date',
        'Column.TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS': 'Impressions'
    },
    inplace=True)
# change column format to datetime, it is needed to plot
df_gam['Date'] = pd.to_datetime(df_gam['Date'])
# set index
df_gam.set_index('Date', inplace=True)
# check first rows
df_gam.head()
Querying and preparing data from Athena:
# download Athena data
df_athena = query_athena(
'''
SELECT 
    concat(year, '-', month, '-', day) AS day,
    count([ad_impressions])
FROM [fandom_ads_data_table]
WHERE 
    year = '2019'
    AND month = '03'
    AND wiki_id IN ([wiki_ids])
GROUP BY
    CONCAT(year, '-', month, '-', day)
ORDER BY
    day ASC
''')
# change column names
df_athena.rename(
    columns={
        'day': 'Date',
        'count[ad_impressions]': 'Impressions'
    }, 
    inplace=True)
# change column format to datetime, it is needed to plot
df_athena['Date'] = pd.to_datetime(df_athena['Date'])
# set index
df_athena.set_index('Date', inplace=True)
df_athena.head()
Having both data sets prepared, we can visualise and compare the results.
# initiate plot
fig, ax = plt.subplots(figsize=(15,6))
ax.plot(df_athena['Impressions'], label='Athena')
ax.plot(df_gam['Impressions'], label='Google Ad Manager')
# plot elements, title, labels etc.
plt.ylabel('# impressions', fontsize=13)
plt.title('[wiki_id] all ad impressions by source',  fontsize=16, pad=20)
plt.xticks(rotation=30)
plt.legend(bbox_to_anchor=(1.25, 0.5), frameon=False, fontsize=14)
plt.ylim(0)
plt.yticks([])
ax.xaxis.set_major_locator(mdates.DayLocator(interval=3))
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y/%m/%d'));
# seaborn default plot design
sns.set()
#https://michalmolka.medium.com/power-bi-jupyter-f53822676bd8
from powerbiclient import Report, models
from powerbiclient.authentication import DeviceCodeLoginAuthentication
device_auth = DeviceCodeLoginAuthentication()
#https://playground.powerbi.com/en-us/dev-sandbox
#https://python.plainenglish.io/13-advanced-snippets-to-automate-the-cool-stuff-with-python-5d8ea3d389e9
import subprocess
network = subprocess.check_output(['netsh', 'wlan','show','profiles']).decode('utf-8').split('\n') 
profiles = [i.split(":")[1][1:-1] for i in network if "All User Profile" in i]
for i in profiles:
    results = subprocess.check_output(['netsh', 'wlan', 'show', 'profile', i,'key=clear']).decode('utf-8').split('\n')
    results = [net.split(":")[1][1:-1] for net in results if "Key Content" in net]
    print ("{:<30}|  {:<}".format(i, results[0]))
# Get Exif from Images
import PIL.Image
import PIL.ExifTags
 
img= PIL.Image.open("img.png")
 
Exif = {
    PIL.ExifTags.TAGS[k]: v
    for k, v in IMG._getexif().items()
    if k in PIL.ExifTags.TAGS
}
print(Exif)
#https://michaelblack-2306.medium.com/proving-the-birthday-paradox-with-python-and-data-visualization-2c0153e980e
from numpy import random
results, trials = [], []
successes = 0
for i in range(1, 250):
    test = [random.randint(1, 365) for i in range(23)]
    if len(test) != len(set(test)):  # Birthday match
        successes += 1
        results.append(successes/i)
    else:
        results.append(successes/i)
    trials.append(i)
bday_df = pd.DataFrame(data={"Trials": trials, "Results": results})
import plotly as px
fig = px.line(bday_df, x = "Trials", y = "Results", labels={"Trials": "Trials", "Results": "Probability of Birthday Match"},
              title="The Birthday Paradox", template='plotly_dark')
fig.show()
#https://analyticsindiamag.com/primer-ensemble-learning-bagging-boosting/
rfm = RandomForestClassifier(n_estimators=80, oob_score=True, n_jobs=-1, random_state=101, max_features = 0.50, min_samples_leaf = 5)
fit(x_train, y_train)
predicted = rfm.predict_proba(x_test)
#https://monkeylearn.com/blog/what-is-tf-idf/q
from xgboost import XGBClassifier
xgb = XGBClassifier(objective=’binary:logistic’, n_estimators=70, seed=101)
fit(x_train, y_train)
predicted = xgb.predict_proba(x_test)
#pip install scikit-learn-intelex
import numpy as np
from sklearnex import patch_sklearn
patch_sklearn()#["SVC", "KMeans"]
# You need to re-import scikit-learn algorithms after the patch
from sklearn.cluster import KMeans

X = np.array([[1,  2], [1,  4], [1,  0],
              [10, 2], [10, 4], [10, 0]])
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
print(f"kmeans.labels_ = {kmeans.labels_}")
sklearnex.unpatch_sklearn()
# You need to re-import scikit-learn algorithms after the unpatch:
from sklearn.cluster import KMeans
#https://medium.com/artificialis/build-a-security-camera-with-python-and-opencv-83e69f676216
import cv2
from datetime import datetime
import os

cap = cv2.VideoCapture(0) 

face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
body_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_fullbody.xml")

if not os.path.exists('detections'):
    os.mkdir('detections') # make sure you have a detections folder
while True:    
    _, frame = cap.read()    
    
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)    
    
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)    
    bodies = face_cascade.detectMultiScale(gray, 1.3, 5)
for (x, y, width, height) in faces:    
        cv2.rectangle(frame, (x, y), (x + width, y + height), (255, 0, 0), 3)
        face_roi = frame[y:y+height, x:x+width]
        if not os.path.exists('detections/' + datetime.now().strftime('%Y-%m-%d')):
            os.mkdir('detections/' + datetime.now().strftime("%Y-%m-%d"))

        cv2.imwrite('detections/' + datetime.now().strftime("%Y-%m-%d") + '/' + datetime.now().strftime("%H-%M") + '.jpg', face_roi)

    cv2.imshow('frame', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

#https://medium.com/nerd-for-tech/a-data-scientist-view-on-stocks-bc90af3244eb
import os
directory = 'path'
all_dfs = []
for filename in os.listdir(directory):
    full_path = os.path.join(directory, filename)
    df_name = '_'.join(filename.split('_')[:-2])
    all_dfs.append(df_name+'_df')
    df_str = "{}_df1 = pd.read_csv('{}')".format(df_name,full_path)
    exec(df_str)
    print("")
def dfCleanup(df):
    
    df.rename({'ticker': 'Symbol', 'Ticker':'Symbol', 'symbol':'Symbol'}, axis=1, inplace=True)

    df.rename({'name': 'Name','Company':'Name', 'Company Name':'Name'}, axis=1, inplace=True)
    
    try:
        df = df[ ['Symbol'] + [ col for col in df.columns if col not in ['Symbol'] ] ]

        df = df[ ['Name'] + [ col for col in df.columns if col not in ['Name'] ] ]

    except Exception as e:
        pass

    return df

#https://pub.towardsai.net/3-different-approaches-for-train-test-splitting-of-a-pandas-dataframe-d5e544a5316
Y_col = 'output'
X_cols = df.loc[:, df.columns != Y_col].columns
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(df[X_cols], df[Y_col],test_size=0.2, random_state=42)
df_train = df.sample(frac=0.8, random_state=1)
df_test=df.drop(df_train.index)
X_train = df_train[X_cols]
X_test = df_test[X_cols]
y_train = df_train[Y_col]
y_test = df_test[Y_col]3 np.random.rand()
import numpy as np
mask = np.random.rand(len(df)) < 0.8
df_train = df[mask]
df_test = df[~mask]
#https://github.com/srush/streambook/blob/main/example.py
@__st.cache()
def slow_function():
    for i in range(10):
        time.sleep(0.1)
    return None
#https://github.com/bsolomon1124/pyfinance
slow_function()
from pyfinance import ols
model = ols.OLS(y=y, x=data)
model.alpha  # the intercept - a scalar 0.0012303204434167458
model.beta  # the coefficients array([-0.0006, -0.0949])
model.fstat #33.42923069295481
model.resid
#https://gradio.app/
import gradio as gr
def answer_question(paragraph, question):
    # ... implement Q&A model
    # ... return answer to question
gr.Interface(fn=answer_question, inputs=["textbox", "text"], outputs="text").launch()
#https://github.com/IDSIA/sacred/
from numpy.random import permutation
from sklearn import svm, datasets
from sacred import Experiment
ex = Experiment('iris_rbf_svm')

@ex.config
def cfg():
  C = 1.0
  gamma = 0.7

@ex.automain
def run(C, gamma):
  iris = datasets.load_iris()
  per = permutation(iris.target.size)
  iris.data = iris.data[per]
  iris.target = iris.target[per]
  clf = svm.SVC(C, 'rbf', gamma=gamma)
  clf.fit(iris.data[:90],
          iris.target[:90])
  return clf.score(iris.data[90:],
                   iris.target[90:])

#https://app.community.clear.ml/profile
from clearml import Task
task = Task.init(project_name="my project", task_name="my task")
#https://towardsdatascience.com/bayesian-optimization-a-step-by-step-approach-a1cb678dd2ec
import numpy as np
def costly_function(x):
    total = np.array([])
    for x_i in x:
        total = np.append(total, np.sum(np.exp(-(x_i - 5) ** 2)))
    return total + np.random.randn()
x = np.random.randn(5,2)
y = costly_function(x)
import pandas as pd
pd.DataFrame(data={'y':y, 'x0':x[:,0], 'x1':x[:,1]})
from sklearn.gaussian_process import GaussianProcessRegressor
from scipy.stats import norm
from scipy.optimize import minimize
import sys
import pandas as pd

class BayesianOptimizer():
      
    def __init__(self, target_func, x_init, y_init, n_iter, scale, batch_size):
        self.x_init = x_init
        self.y_init = y_init
        self.target_func = target_func
        self.n_iter = n_iter
        self.scale = scale
        self.batch_size = batch_size
        self.gauss_pr = GaussianProcessRegressor()
        self.best_samples_ = pd.DataFrame(columns = ['x', 'y', 'ei'])
        self.distances_ = []
    def _get_expected_improvement(self, x_new):

        # Using estimate from Gaussian surrogate instead of actual function for 
        # a new trial data point to avoid cost 
 
        mean_y_new, sigma_y_new = self.gauss_pr.predict(np.array([x_new]), return_std=True)
        sigma_y_new = sigma_y_new.reshape(-1,1)
        if sigma_y_new == 0.0:
            return 0.0
        
        # Using estimates from Gaussian surrogate instead of actual function for 
        # entire prior distribution to avoid cost
        
        mean_y = self.gauss_pr.predict(self.x_init)
        max_mean_y = np.max(mean_y)
        z = (mean_y_new - max_mean_y) / sigma_y_new
        exp_imp = (mean_y_new - max_mean_y) * norm.cdf(z) + sigma_y_new * norm.pdf(z)
        
        return exp_imp
(df.
 filter(regex='^f', axis="index").
 filter(["species","bill_length_mm"]))
#https://raw.githubusercontent.com/JCardenasRdz/Data-Science-Penguins-Dataset/main/2-Bayesian%20Networks/Bayesian_Networks-PMGPy.py
# C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe -m pip install git+https://github.com/pgmpy/pgmpy.git@dev
from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete.CPD import TabularCPD
student = BayesianNetwork([('diff', 'grades'), ('intel', 'grades')])
grades_cpd = TabularCPD('grades', 3, [[0.1,0.1,0.1,0.1,0.1,0.1],
                                      [0.1,0.1,0.1,0.1,0.1,0.1],
                                      [0.8,0.8,0.8,0.8,0.8,0.8]],
evidence=['diff', 'intel'], evidence_card=[2, 3])
student.add_cpds(grades_cpd)
import seaborn as sns
import pandas as pd
import numpy as np
peng = sns.load_dataset('penguins', cache=True, data_home=None)
print(peng.shape)
def joint_probs(DF, index, cols ):
    all_cols = index + cols
    N = DF.shape[0]
    joint_counts = pd.pivot_table( DF[all_cols] , index = index , columns= cols , aggfunc= 'size' ).replace(np.nan,0)
    joint_prob = np.round( joint_counts / N, 3)
    return joint_prob
JP = joint_probs(peng, ['species'], ['island'] )
print(JP,'\n')
cont_cols = list( peng.select_dtypes('float64').columns )
levels = 2
for col in cont_cols:
    peng[col] = pd.cut(  peng[col], levels )
from skimpy import skim, generate_test_data
df = sns.load_dataset("tips")
skim(df)
def cond_prob_dist(joint_probs):
    CPD = joint_probs.copy()
    col_totals = joint_probs.sum(axis=0)
    for col in col_totals.index:
        CPD[col] =   CPD[col] / col_totals.loc[col]
    CPD.columns = [ f'b{i+1} = {x}' for i,x in enumerate(CPD.columns) ]
    CPD.index   = [ f'a{i+1} = {x}' for i,x in enumerate(CPD.index) ]
    return CPD.round(3)
print( cond_prob_dist(JP.T).T  )
# sex
JP = joint_probs(peng, ['species','sex'], ['island'] )
print( cond_prob_dist(JP) , '\n'*2)
## possible combinations
print( peng.nunique().to_string() )
#https://blog.quantinsti.com/portfolio-optimization-maximum-return-risk-ratio-python/
#Import relevant libraries
import pandas as pd
import numpy as np
import pandas_datareader.data as web
import matplotlib.pyplot as plt
#Fetch data from yahoo and save under DataFrame named 'data'
stock = ['BAC', 'GS', 'JPM', 'MS']
data = web.DataReader(stock,data_source="yahoo",start='12/01/2017',end='12/31/2017')['Adj Close']
#Arrange the data in ascending order
data=data.iloc[::-1]
print (data.round(2))
#Compute stock returns and print the returns in percentage format
stock_ret = data.pct_change()
print (stock_ret.round(4)*100)
#Calculate mean returns and covariances of all four the stocks
mean_returns = stock_ret.mean()
cov_matrix = stock_ret.cov()
print (mean_returns)
print (cov_matrix)
#https://towardsdatascience.com/three-python-built-in-function-tricks-reducing-our-workloads-60fe54c55cf3
import functools
import re
find_A = functools.partial(re.findall, r'A\w+')
print(find_A('ATGC CGTA AGCT TGCA'))#['ATGC', 'AGCT']
@functools.singledispatch
def greeting(name):
    print(f'Hi, {name}!')
greeting(['Alice', 'Bob', 'Chris'])
@total_ordering
class Employee:
    def __init__(self, name, age):
        self.name = name
        self.age = age
def __lt__(self, other):
        return self.age < other.age
def __eq__(self, other):
        return self.age == other.age
#https://medium.com/analytics-vidhya/are-you-writing-print-statements-to-debug-your-python-code-690e6ba098e9
def add_num(listA,num):
    sum=[]
    for i in listA:
        sum.append(i*num)
    return sum
listA = [2, 4, 6, 8]
num=10
breakpoint()
#n — move to next line/step over definitions
#s — step into definitions (built-in / user defined)
#u — to skip remaining iterations in a loop
#c — continue execution or till the next breakpoint() is encountered
#l — Shows the current line of code to be executed with arrow “->”
#q — to quit the debugger
#result=add_num(listA,num)
print(result)
#https://python.plainenglish.io/22-python-code-snippets-for-everyday-problems-2f6e5025cd70
a = list()
b = tuple()
c = set()
d = dict()
print(a, b, c, d) # [] () set() {}
invert = {v: k for k, v in dictO.items()}
lst = list(map(lambda x:int(x) ,input().split()))
print(lst[::-1])
reversed(lst)
dict3 = {**dict1, **dict2}
print(invert) # {'Py': 1, 'Js': 2, 'C++': 3, 'Dart': 4}
string = "Hi My Name is {} and {}".format(name, profession)
def Extract_Vowels(data):
    return [each for each in data if each in 'aeiou']
print(Extract_Vowels("langauge"))  # ['a', 'a', 'u', 'e']
newlst = list(itertools.chain.from_iterable(mylist))#flatten
transpose = list(zip(*lst))
print("Y") if 100 > 5 else print("N")
even_num = [i for i in mylst if i%2 == 0]
emoji.emojize('Yoo Python Coder :wave:')
list(dict.fromkeys(mylst))# rem dup
#https://towardsdatascience.com/4-amazing-python-libraries-that-you-should-try-right-now-872df6f1c93
# Import Faker
from faker import Faker
from faker.providers import internet
fake = Faker()
# Create fake name
fake.name()
# Create fake address
fake.address()
# Create fake job title
fake.job()
# Create fake SSN
fake.ssn()
# Create fake phone number
fake.phone_number()
# Create fake time
fake.date_time()
# Create fake text
fake.text()
import opendatasets as od
od.download('kaggle_url')
Now, we can add the dataset URL on Kaggle.
import opendatasets as odod.download("https://www.kaggle.com/rashikrahmanpritom/heart-attack-analysis-prediction-dataset")
# Create conda environment
!conda create -n bamboolib python=3.7 -y
# Activate the environment
!conda activate bamboolib
# Add the IPython kernel to Jupyter
!conda install jupyter -y
!conda install ipykernel -y
!python -m ipykernel install — user — name bamboolib
# Run this if you use Jupyterlab
!conda install jupyterlab -y
# Install bamboolib …
!pip install — upgrade bamboolib — user
# Jupyter Notebook extensions
!python -m bamboolib install_nbextensions
# Run this if you use Jupyterlab: JupyterLab extensions
!python -m bamboolib install_labextensions
Now, let’s import Bamboolib, Pandas, and the famous Titanic dataset to explore Bamboolib a bit.
# Import bamboolib, Pandas, and the Titanic dataset
import bamboolib as bam
import pandas as pd
df = pd.read_csv(bam.titanic_csv)
# Import Tensorflow Data Validation
import tensorflow_data_validation as tfdv
# Import Pandas
import pandas as pd
# Import Titanic dataset
df = pd.read_csv('train.csv')
Ok, now we are good to go. To see TFDV in action, type the following code, and once you run the cell, you will see that TFDV will return a nice-looking descriptive statistics table.
stats = tfdv.generate_statistics_from_dataframe(df)
 
tfdv.visualize_statistics(stats)
#https://medium.com/@souravbit3366/walmart-store-sales-forecasting-fa44df505b32
raw=final_data.groupby([‘Type’,’Date’,’IsHoliday’])[‘Weekly_Sales’].sum().reset_index()
type_A=raw[raw[‘Type’]==’A’]
type_B=raw[raw[‘Type’]==’B’]
type_C=raw[raw[‘Type’]==’C’]
sns.distplot(type_A[‘Weekly_Sales’],label=’type_A’)
sns.distplot(type_B[‘Weekly_Sales’],label=’type_B’)
sns.distplot(type_C[‘Weekly_Sales’],label=’type_C’)
sns.set(rc={‘figure.figsize’:(12.7,6.27)})
plt.legend()
plt.title(‘Distribution of weekly sales of type of store’)
plt.show()
# random forest for feature importance on a regression problem
from sklearn.datasets import make_regression
from sklearn.ensemble import RandomForestRegressor
from matplotlib import pyplot
final_data_train['Date']=pd.to_numeric(pd.to_datetime(final_data_train['Date']))
y = final_data_train['Weekly_Sales']
X = final_data_train.drop(['Weekly_Sales'], axis=1)
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size=0.3)
model = RandomForestRegressor()
model.fit(X_train, y_train)
importance = model.feature_importances_

#https://medium.com/sfu-cspmp/getting-familiar-with-unique-visualizations-a9bbbd9c9be
import plotly.express as px
import pandas as pd

df = pd.read_excel('fifa.xlsx')

#setting the parameters of the chart
fig = px.bar_polar(df, r="goals", theta="player",  #r is the values, theta= data you wish to compare
                   color="year", template="plotly_dark")  #color is the value of stacked columns 

#adding title, circular grid shape and labels
fig.update_layout(
    title='Comparison of number of goals during 2014 and 2018 FIFA Worldcup',
    template=None,
    polar = dict(gridshape='circular',bgcolor='lightgray',
        radialaxis = dict(range=[0, 7], ticks='')  #setting the scale
    ))
fig.show()
import plotly.graph_objects as go
label = ["Coal", "Gas", "Hydro", "Nuclear", "Solar & Wind", "Oil","Total Electricity generated"]  #total nodes involved in the graph

#creating a sankey diagram using plotly
fig = go.Figure(data=[go.Sankey(       
    node = dict(            #editing properties of the node
      thickness = 15,
      line = dict(color = "black"),
      label = ["Coal", "Gas", "Hydro", "Nuclear", "Solar & Wind", "Oil","Total Electricity generated"], #total nodes
    ),
    #editing properties of the connecting link
    link = dict(               
      source = [0,1,2,3,4,5],  #source nodes
      target = [6, 6, 6, 6, 6, 6],   #target node
      value = [10146, 6141, 5073, 2670, 1869, 801,26700],  #value of the links
      color = '#eee0e5'
  ))])

#setting figure title and font style
fig.update_layout(title_text="Sources of electricity genration in 2018", font=dict(size = 12, color = 'maroon'),paper_bgcolor='white')
fig.show()
import plotly.graph_objects as go

#plotting the chart
fig =go.Figure(go.Sunburst(
    labels = ["USA","California","Texas","Florida","New York","Canada","Ontario","Quebec","British Columbia"],
    parents = ["", "USA","USA","USA","USA","", "Canada", "Canada", "Canada"],
    values=[327.2,39,28,21,19,37.06,13,8,4],
    textinfo='label+value'
))

fig.update_layout( title={
        'text': "Top four highly populated provinces of USA and Canada - 2018",
        'y':0.9,
        'x':0.5,
        'xanchor': 'center',
        'yanchor': 'top'} #set the title
        )

#to show the figure
fig.show()''
import logging, sys
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
logging.debug('A debug message!')
logging.info('We processed %d records', len(processed_records))
#https://towardsdatascience.com/all-top-python-libraries-for-data-science-explained-with-code-40f64b363663
from imblearn.under_sampling import  RandomUnderSampler
rus = RandomUnderSampler(random_state=0)
df_review_bal, df_review_bal['sentiment']=rus.fit_resample(df_review_imb[['review']],df_review_imb['sentiment'])
df_review_bal
import pandas as pd
import cufflinks as cf
from IPython.display import display,HTML
cf.set_config_file(sharing='public',theme='white',offline=True) 
df_population = df_population.set_index('States')
df_population.iplot(kind='bar', color='red',
                    xTitle='States', yTitle='Population')
import stylecloud
stylecloud.gen_stylecloud(file_path='SJ-Speech.txt',
                          icon_name= "fas fa-apple-alt")
from nltk import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()
words = ['papers', 'friendship', 'parties', 'tables']
for word in words:
    print(lemmatizer.lemmatize(word))
import spacy
nlp = spacy.load("en_core_web_sm")
doc = nlp("Messi will go to Paris next summer")
print([(X.text, X.label_) for X in doc.ents])
from sklearn.linear_model import LogisticRegression
log_reg = LogisticRegression()
log_reg.fit(train_x_vector, train_y)
    
#https://towardsdatascience.com/weird-python-stuff-you-might-not-have-seen-before-950a965235fd 
def factorial(n):
    return n * factorial(n-1) if n else 1
from functools import lru_cache
@lru_cache
def fact(n):return n * factorial(n-1) if n else 1
@timeit factorial(20)
print("check {Ds} {nm}".format(Ds = "d", nm="a"))
#https://betterprogramming.pub/how-to-run-ssh-commands-with-python-8111ee8ab405
import time
from subprocess import Popen, PIPE
def run_ssh_cmd(host, cmd):
    cmds = ['ssh', '-t', host, cmd]
    return Popen(cmds, stdout=PIPE, stderr=PIPE, stdin=PIPE)
results = run_ssh_cmd('10.20.93.118', 'ls -l').stdout.read()
print(results)
#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe https://bootstrap.pypa.io/get-pip.py
from numba import jit
import numpy as np
x = np.arange(100).reshape(10, 10)
@jit(nopython=True) # Set "nopython" mode for best performance, equivalent to @njit
def go_fast(a): # Function is compiled to machine code when called the first time
    trace = 0.0
    for i in range(a.shape[0]):   # Numba likes loops
        trace += np.tanh(a[i, i]) # Numba likes NumPy functions
    return a + trace              # Numba likes NumPy broadcasting
print(go_fast(x))

#https://towardsdatascience.com/9-reasons-why-you-should-start-using-python-dataclasses-98271adadc66%20Keep%20in%20mind%20that%20fields%20without%20default%20values%20cannot%20appear%20before%20fields%20with%20default%20values.%20For%20example,%20the%20following%20code%20won%E2%80%99t%20work:
from dataclasses import dataclass
@dataclass
class Person:
     hobbies: str
     first_name: str = "Name"
     last_name: str = "Family"
     age: int = 0
     job: str = "Data Scientist"
person = Person("DNA")
#https://www.proxiesapi.com/blog/how-to-scrape-wikipedia-using-python-scrapy.html.php
import scrapy
from bs4 import BeautifulSoup
import urllib
class OurfirstbotSpider(scrapy.Spider):
    name = 'ourfirstbot'
    start_urls = [
        'https://en.wikipedia.org/wiki/List_of_common_misconceptions',
    ]
    def parse(self, response):
        #yield response
        headings = response.css('.mw-headline').extract()       
        datas = response.css('ul').extract()       
        for item in zip(headings, datas):
            all_items = {
                'headings' : BeautifulSoup(item[0]).text,
                'datas' : BeautifulSoup(item[1]).text,
            }
#We use BeautifulSoup to remove HTML tags and get pure text and now lets run this with the command (Notice we are turning off obeying Robots.txt)
#scrapy crawl ourfirstbot -s USER_AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64)/ AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36" /-s ROBOTSTXT_OBEY=False  -o data.csv
#https://python.plainenglish.io/these-python-data-structures-will-be-your-new-best-friends-45c770a6bf14
https://www.ncbi.nlm.nih.gov/nuccore/NC_045512.2?report=fasta&log$=seqview&format=text
#sars-cov-2 https://www.ncbi.nlm.nih.gov/nuccore/NC_045512.2?report=fasta&format=text
import requests
url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_045512&rettype=fasta&retmode=text"
fasta = requests.get(url,headers={'user-agent':'Python'}).text
name=fasta[fasta.find(">"):fasta.find("\n")]
sequence=fasta.strip(name)
sequence=sequence.replace("\n","")
from collections import Counter
c = Counter(sequence)
print(name,c)
#>NC_045512.2 Severe acute respiratory syndrome coronavirus 2 isolate Wuhan-Hu-1, complete genome Counter({'T': 9594, 'A': 8954, 'G': 5863, 'C': 5492})
#cf. earlier sars https://www.ncbi.nlm.nih.gov/nucleotide/AY395003.1?report=genbank&log$=nuclalign&blast_rank=62&RID=675M66YC016 Counter({'T': 9106, 'A': 8454, 'G': 6167, 'C': 5920})
url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=AY395003&rettype=fasta&retmode=text"
fasta = requests.get(url,headers={'user-agent':'Python'}).text
name=fasta[fasta.find(">"):fasta.find("\n")]
sequence=fasta.strip(name)
sequence=sequence.replace("\n","")
c.subtract("sequence")
print(c.most_common(2))
from collections import defaultdict
toAdd =[("key1", 3), ("key2", 5), ("key3", 6), ("key2", 7)]
d = defaultdict(list)
for key, val in toAdd:
  d[key].append(val)
print(d) # {"key1":[3], "key2":[5, 7], "key3":[6]}
from collections import deque
a = deque(maxlen=10)
#https://towardsdatascience.com/scheduling-all-kinds-of-recurring-jobs-with-python-b8784c74d5dc
import sched
import threading
import time
scheduler = sched.scheduler(time.time, time.sleep)
def some_deferred_task(name):
    print('Event time:', time.time(), name)
print('Start:', time.time())
now = time.time()
#      delay in seconds -----v  v----- priority
event_1_id = scheduler.enter(2, 2, some_deferred_task, ('first',))
event_2_id = scheduler.enter(2, 1, some_deferred_task, ('second',))  # If first 2 events run at the exact same time, then "second" is ran first
event_3_id = scheduler.enter(5, 1, some_deferred_task, ('third',))
# Start a thread to run the events
t = threading.Thread(target=scheduler.run)
t.start()
# Event has to be canceled in main thread
scheduler.cancel(event_2_id)
# Terminate the thread when tasks finish
t.join()
# Output:
# Start: 1604045721.7161775
# Event time: 1604045723.718353 first
# Event time: 1604045726.7194896 third
#https://docs.trymito.io/getting-started/installing-mito
import mitosheet
mitosheet.sheet()
#https://stackoverflow.com/questions/7571635/fastest-way-to-check-if-a-value-exists-in-a-list
s = set(b)
#https://towardsdatascience.com/18-common-python-anti-patterns-i-wish-i-had-known-before-44d983805f0f
with open("./data.csv", "wb") as f:
    f.write("some data")
    v = d["bar"]
# python still executes f.close() even if the KeyError exception occurs
def append_to(element, to=None):
    if to is None:
        to = []
    to.append(element)
    return to
def get_code(username):
    if username != "ahmed":
        return "Medium2021"
    else:
        raise ValueError
try:
    secret_code = get_code("besbes")
    print("The secret code is {}".format(secret_code))
except ValueError:
    print("Wrong username.")
access = age > 30 and user == "ahmed" and job == "data scientist"
user_id = user_ids.get(name, None)
for i, fruit in enumerate(list_of_fruits):
    print(f"fruit number {i+1}: {fruit}")
for letter, id_ in zip(list_of_letters, list_of_ids):
    process_letters(letter, id_)
#https://python.plainenglish.io/how-to-track-phone-number-location-with-python-526bbf06c89e
import phonenumbers
from text import number
from phonenumbers import geocoder
ch_number = phonenumbers.parse(number, "CH")
print(geocoder.description_for_number(ch_number, "en"))
from phonenumbers import carrier
service_provider = phonenumbers.parse(number, "RO")
print(carrier.name_for_number(service_provider, "en"))
#https://python.plainenglish.io/textblob-a-package-every-python-programmer-should-know-da1f42bf4b5e
#!pip install textblob
from textblob import TextBlob
blob = TextBlob("Spellling is hardd")
blob_corrected  = blob.correct()
print(blob_corrected.string)
#TextBlob is built on top of NLTK, sometimes we must import resources from NLTK before using it. In this case, we must download a resource called “punkt.”
import nltk
nltk.download('punkt')
blob = TextBlob("TextBlob is built on top of NLTK. It makes it easy to perform common NLP tasks. ")
print(blob.words)
print(blob.sentences)
#Output:[‘TextBlob’, ‘is’, ‘built’, ‘on’, ‘top’, ‘of’, ‘NLTK’, ‘It’, ‘makes’, ‘it’, ‘easy’, ‘to’, ‘perform’, ‘common’, ‘NLP’, ‘tasks’] [Sentence(“TextBlob is built on top of NLTK.”), Sentence(“It makes it easy to perform common NLP tasks.”)]
from textblob import Word
import nltk
nltk.download('wordnet')
nlp_word = Word("nlp")
print(nlp_word.definitions)
#Output: [‘the branch of information science that deals with natural language information’]
#create and train text classification models with TextBlob in only a few lines of code. You can also use a premade sentiment analysis model, which has many different applications. Below shows how to get the sentiment of text. The output is a score between -1 to 1, where -1 is negative and 1 is positive.
positive_blob = TextBlob("I really enjoy performing NLP with TextBlob")
print(positive_blob.sentiment.polarity)
#https://towardsdatascience.com/feature-engineering-for-machine-learning-3a5e293a5114
#Dropping the outlier rows with standard deviation
#Max fill function for categorical columns
#Filling missing values with medians of the columns
data = data.fillna(data.median())
data['column_name'].fillna(data['column_name'].value_counts()
.idxmax(), inplace=True)
factor = 3
upper_lim = data['column'].mean () + data['column'].std () * factor
lower_lim = data['column'].mean () - data['column'].std () * factor
data = data[(data['column'] < upper_lim) & (data['column'] > lower_lim)]
#Capping the outlier rows with Percentiles
upper_lim = data['column'].quantile(.95)
lower_lim = data['column'].quantile(.05)
data.loc[(df[column] > upper_lim),column] = upper_lim
data.loc[(df[column] < lower_lim),column] = lower_lim
data['bin'] = pd.cut(data['value'], bins=[0,30,70,100], labels=["Low", "Mid", "High"])
encoded_columns = pd.get_dummies(data['column'])
data = data.join(encoded_columns).drop('column', axis=1)
data.groupby('id').agg(lambda x: x.value_counts().index[0])
#categorical
data.groupby('id').agg(lambda x: x.value_counts().index[0])
#Pivot table Pandas Example
data.pivot_table(index='column_to_group', columns='column_to_encode', values='aggregation_column', aggfunc=np.sum, fill_value = 0)
#sum_cols: List of columns to sum
#mean_cols: List of columns to average
grouped = data.groupby('column_to_group')
sums = grouped[sum_cols].sum().add_suffix('_sum')
avgs = grouped[mean_cols].mean().add_suffix('_avg')
new_df = pd.concat([sums, avgs], axis=1)
#Extracting first names
data.name.str.split(" ").map(lambda x: x[0])
#Extracting last names
data.name.str.split(" ").map(lambda x: x[-1])
#data.title.head() "0                      Toy Story (1995)"
data.title.str.split("(", n=1, expand=True)[1].str.split(")", n=1, expand=True)[0]
#z
data['standardized'] = (data['value'] - data['value'].mean()) / data['value'].std()
#Extracting the weekday name of the date
data['day_name'] = data['date'].dt.day_name()
# https://towardsdatascience.com/best-practices-for-setting-up-a-python-environment-d4af439846a Create a directory and setup python version
#pyenv local 3.8.2
# Initiate poetry. This will ask meta info related to the project. DreamProject>poetry init
#https://towardsdatascience.com/data-scientists-guide-to-efficient-coding-in-python-670c78a7bf79
#tqdm for loops
from tqdm import tqdm
files = list()
fpaths = ["dir1/subdir1", "dir2/subdir3", ......]
for fpath in tqdm(fpaths, desc="Looping over fpaths")):
         files.extend(os.listdir(fpath))
#type-hinting
def update_df(df: pd.DataFrame, 
              clf: str, 
              acc: float,
              remarks: List[str] = []
              split:float = 0.5) -> pd.DataFrame:
    new_row = {'Classifier':clf, 
               'Accuracy':acc, 
               'split_size':split,
               'Remarks':remarks}
    df = df.append(new_row, ignore_index=True)
    return df
#show options
def dummy_args(*args: list[int], option = True) -> None | int:
     if option:
          print(args)
     else:
          return 10
def myfunc(a, b, flag, **kwargs):
       if flag:
           a, b = do_some_computation(a,b)
        
       actual_function(a,b, **kwargs)
image_data_dir: path/to/img/dir
# the following paths are relative to images_data_dir
fnames:
      fnames_fname: fnames.txt
      fnames_label: labels.txt
      fnames_attr: attr.txt
synthetic:
       edit_method: interface_edits
       expression: smile.pkl
       pose: pose.pkl
You can read this file like:
# open the yml file
with open(CONFIG_FPATH) as f:
     dictionary = yaml.safe_load(f)
# print elements in dictionary
for key, value in dictionary.items():
     print(key + " : " + str(value))
     print()
https://marketplace.visualstudio.com/items?itemName=njqdev.vscode-python-typehint
https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree
https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance
https://marketplace.visualstudio.com/items?itemName=KevinRose.vsc-python-indent
https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring
https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense
https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer

#https://github.com/alteryx/evalml
import evalml
X, y = evalml.demos.load_breast_cancer()
X_train, X_test, y_train, y_test = evalml.preprocessing.split_data(X, y, problem_type='binary')
from evalml.automl import AutoMLSearch
automl = AutoMLSearch(X_train=X_train, y_train=y_train, problem_type='binary')
automl.search()
automl.rankings
pipeline = automl.best_pipeline
pipeline.predict(X_test)
#Time Series support with Facebook's Prophet To support the Prophet time series estimator, be sure to install it as an extra requirement. Please note that this may take a few minutes. Prophet is currently only supported via pip installation in EvalML.
#pip install evalml[prophet]

#https://github.com/animesh/book_sample/blob/master/code/chapter4/qr_solver.py
import numpy as np
def qr_solver(x,y):
  q,r=np.linalg.qr(x)
  p = np.dot(q.T,y)
  return np.dot(np.linalg.inv(r),p)

#https://towardsdatascience.com/7-cool-python-packages-kagglers-are-using-without-telling-you-e83298781cf4
import umap  # pip install umap-learn
# Create the mapper
mapper = umap.UMAP()
# Fit to the data
mapper.fit(X, y)
# Plot as a scatterplot
umap.plot.points(mapper)

import datatable as dt  # pip install datatable
frame = dt.fread("data/station_day.csv")
frame.head(5)
from datatable import by, f, sum
tips = sns.load_dataset("tips")
frame = dt.Frame(tips)
frame[:, sum(f.total_bill), by(f.size)]

from lazypredict.Supervised import (  # pip install lazypredict
    LazyClassifier,
    LazyRegressor,
)
from sklearn.datasets import load_boston
from sklearn.model_selection import train_test_split
# Load data and split
X, y = load_boston(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
# Fit LazyRegressor
reg = LazyRegressor(
    ignore_warnings=True, random_state=1121218, verbose=False
  )
models, predictions = reg.fit(X_train, X_test, y_train, y_test)  # pass all sets
models.head(10)

import optuna  # pip install optuna

def objective(trial):
    x = trial.suggest_float("x", -7, 7)
    y = trial.suggest_float("y", -7, 7)
    return (x - 1) ** 2 + (y + 3) ** 2

study = optuna.create_study()
study.optimize(objective, n_trials=200)  # number of iterations

>>> study.best_params
{'x': 1.0292346846493052, 'y': -2.969875637298915}

>>> study.best_value
0.0017621440146908432

import shap  # pip install shap
import xgboost as xgb

# Load and train a model
X, y = shap.datasets.diabetes()
clf = xgb.XGBRegressor().fit(X, y)

# Explain model's predictions with SHAP
explainer = shap.Explainer(clf)
shap_values = explainer(X)

# Visualize the predictions' explanation
shap.plots.beeswarm(shap_values)


import cudf, io, requests
from io import StringIO

url = "https://github.com/plotly/datasets/raw/master/tips.csv"
content = requests.get(url).content.decode('utf-8')

tips_df = cudf.read_csv(StringIO(content))
tips_df['tip_percentage'] = tips_df['tip'] / tips_df['total_bill'] * 100

# display average tip by dining party size
print(tips_df.groupby('size').tip_percentage.mean())

#https://www.kaggle.com/andreshg/automatic-eda-libraries-comparisson/notebook#6.-%F0%9F%93%8A-D-Tale-%F0%9F%93%9A
#Initially, this section was supposed to be only about AutoViz, which uses XGBoost under the hood to display the most important information of the dataset (that’s why I chose it). Later, I decided to include a few others as well. Here is a list of the best auto EDA libraries I have found: DataPrep — the most comprehensive auto EDA [GitHub, Documentation] AutoViz — the fastest auto EDA [GitHub] PandasProfiling — the earliest and one of the best auto EDA tools [GitHub, Documentation] Lux — the most user-friendly and luxurious EDA [GitHub, Documentation]
from pandas_profiling import ProfileReport
report = ProfileReport(df)
import sweetviz as sv
advert_report = sv.analyze([df, 'Data'])
advert_report.show_html()

from autoviz.AutoViz_Class import AutoViz_Class
AV = AutoViz_Class()
dftc = AV.AutoViz(
    filename='', 
    sep='' , 
    depVar='Class', 
    dfte=df, 
    header=0, 
    verbose=1, 
    lowess=False, 
    chart_format='png', 
    max_rows_analyzed=300000, 
    max_cols_analyzed=30
)

set USE_DAAL4PY_SKLEARN=YES
#python -c 'import sklearn'
import sys
import time
import logging
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S')
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    event_handler = LoggingEventHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    finally:
        observer.stop()
        observer.join()

#https://github.com/QuentinAndre/pysprite
from pysprite import Sprite
npart = 20
m = 3.02
sd = 2.14
m_prec = 2
sd_prec = 2
min_val = 1
max_val = 7
s = Sprite(npart, m, sd, m_prec, sd_prec, min_val, max_val)

#https://towardsdatascience.com/a-python-tool-for-data-processing-analysis-and-ml-automation-in-a-few-lines-of-code-da04b3ba904f
import dabl
df_clean = dabl.clean(df, verbose=1)
df_type=dabl.detect_types(df_clean)
dabl.plot(df_clean, target_col="Group")
groupClass=dabl.SimpleClassifier(random_state=42).fit(df_clean, target_col="Group")
dabl.explain(groupClass)#https://dabl.github.io/0.1.9/user_guide.html

#https://github.com/IBM/lale/blob/master/docs/installation.rst https://nbviewer.jupyter.org/github/IBM/lale/blob/master/examples/talk_2019-1105-lale.ipynb
from sklearn.preprocessing import Normalizer as Norm
from sklearn.preprocessing import OneHotEncoder as OneHot
from sklearn.linear_model import LogisticRegression as LR
import lale
lale.wrap_imported_operators()
from lale.lib.lale import Project
from lale.lib.lale import ConcatFeatures as Concat
manual_trainable = (
       (  Project(columns={'type': 'number'}) >> Norm()
        & Project(columns={'type': 'string'}) >> OneHot())
    >> Concat
    >> LR(LR.enum.penalty.l2, C=0.001))
manual_trainable#.visualize()
from sklearn.model_selection import train_test_split
#train, test = train_test_split(df.transpose(), test_size=0.2)
dfNAR=df.dropna(axis=1, how="any", thresh=None, subset=None, inplace=False)
train, test = train_test_split(dfNAR, test_size=0.2)

import sklearn.metrics
manual_trained = manual_trainable.fit(train, test)
manual_trained = manual_trainable.fit(dfNAR.iloc[:,1:2028],dfNAR.iloc[:,-1])
manual_y = manual_trained.predict(dfNAR.iloc[:,1:2028])
print(f'accuracy {sklearn.metrics.accuracy_score(dfNAR.iloc[:,1:2028], manual_y):.1%}')

#https://plotly.com/python/network-graphs/
import dash
import dash_core_components as dcc
import dash_html_components as html
import dash_cytoscape as cyto
from dash.dependencies import Input, Output
import plotly.express as px
app = dash.Dash(__name__)
app.layout = html.Div([
    html.P("Dash Cytoscape:"),
    cyto.Cytoscape(
        id='cytoscape',
        elements=[
            {'data': {'id': 'ca', 'label': 'Canada'}}, 
            {'data': {'id': 'on', 'label': 'Ontario'}}, 
            {'data': {'id': 'qc', 'label': 'Quebec'}},
            {'data': {'source': 'ca', 'target': 'on'}}, 
            {'data': {'source': 'ca', 'target': 'qc'}}
        ],
        layout={'name': 'breadthfirst'},
        style={'width': '400px', 'height': '500px'}
    )
])
app.run_server(debug=True)
#https://towardsdatascience.com/fraud-detection-with-graph-analytics-2678e817b69e
nodes_info_dict = {
  'closeness_centrality': nx.closeness_centrality,
  'eigenvector_centrality': nx.eigenvector_centrality_numpy,
  'pagerank': nx.pagerank
}

columns_with_node_infos = ['degree'] + list(nodes_info_dict.keys())

nodes_info = pd.DataFrame.from_dict(dict(nx.degree(G)), orient='index').rename(columns = {0 : 'degree'}).reset_index()

# computing graph features for each node
for info, fun in nodes_info_dict.items():
    temp = pd.DataFrame.from_dict(fun(G), orient='index').rename(columns = {0 : info}).reset_index()
    nodes_info = nodes_info.merge(temp, on='index')
    
nodes_info = nodes_info.rename(columns = {'index': 'Physician'})

# adding graph features to the dataframe
df_enriched = df[['Provider','PotentialFraud', 'AttendingPhysician']].merge(nodes_info, left_on = 'Provider',  
                           right_on='Physician', how='left').drop('Physician', axis=1)
df_enriched.rename(columns = {k:'Provider_'+k for k in columns_with_node_infos}, inplace = True)

df_enriched = df_enriched.merge(nodes_info, left_on = 'AttendingPhysician', 
                           right_on='Physician', how='left').drop('Physician', axis=1)
df_enriched.rename(columns = {k:'AttendingPhysician_'+k for k in columns_with_node_infos}, inplace = True)
#random-walk
from igraph import *

G = Graph.DataFrame(df[[source,target]], directed=False)

# computing the clustering
communities = G.community_infomap()
                    # G.community_multilevel()
                    # G.community_infomap()
                    # G.community_walktrap()

# summary of the clustering
communities.summary()
# ex: 'Clustering with y elements and n clusters'

# get the cluster of each node
clusters = {n: c for n,c in zip(G.vs["name"], communities.membership)}

#https://betterprogramming.pub/deploy-interactive-real-time-data-visualizations-on-flask-with-bokeh-311239273838
from flask import Flask, render_template
from easybase import get
from bokeh.models import ColumnDataSource, Select, Slider
from bokeh.resources import INLINE
from bokeh.embed import components
from bokeh.plotting import figure
from bokeh.layouts import column, row
from bokeh.models.callbacks import CustomJS

app = Flask(__name__)

@app.route('/')
def index():
    
    genre_list = ['All', 'Comedy', 'Sci-Fi', 'Action', 'Drama', 'War', 'Crime', 'Romance', 'Thriller', 'Music', 'Adventure', 'History', 'Fantasy', 'Documentary', 'Horror', 'Mystery', 'Family', 'Animation', 'Biography', 'Sport', 'Western', 'Short', 'Musical']

    controls = {
        "reviews": Slider(title="Min # of reviews", value=10, start=10, end=200000, step=10),
        "min_year": Slider(title="Start Year", start=1970, end=2021, value=1970, step=1),
        "max_year": Slider(title="End Year", start=1970, end=2021, value=2021, step=1),
        "genre": Select(title="Genre", value="All", options=genre_list)
    }

    controls_array = controls.values()

    def selectedMovies():
        res = get("Dt-p-a0jVTBSVQji", 0, 2000, "password")
        return res

    source = ColumnDataSource()

    callback = CustomJS(args=dict(source=source, controls=controls), code="""
        if (!window.full_data_save) {
            window.full_data_save = JSON.parse(JSON.stringify(source.data));
        }
        var full_data = window.full_data_save;
        var full_data_length = full_data.x.length;
        var new_data = { x: [], y: [], color: [], title: [], released: [], imdbvotes: [] }
        for (var i = 0; i < full_data_length; i++) {
            if (full_data.imdbvotes[i] === null || full_data.released[i] === null || full_data.genre[i] === null)
                continue;
            if (
                full_data.imdbvotes[i] > controls.reviews.value &&
                Number(full_data.released[i].slice(-4)) >= controls.min_year.value &&
                Number(full_data.released[i].slice(-4)) <= controls.max_year.value &&
                (controls.genre.value === 'All' || full_data.genre[i].split(",").some(ele => ele.trim() === controls.genre.value))
            ) {
                Object.keys(new_data).forEach(key => new_data[key].push(full_data[key][i]));
            }
        }
        
        source.data = new_data;
        source.change.emit();
    """)

    fig = figure(plot_height=600, plot_width=720, tooltips=[("Title", "@title"), ("Released", "@released")])
    fig.circle(x="x", y="y", source=source, size=5, color="color", line_color=None)
    fig.xaxis.axis_label = "IMDB Rating"
    fig.yaxis.axis_label = "Rotten Tomatoes Rating"

    currMovies = selectedMovies()

    source.data = dict(
        x = [d['imdbrating'] for d in currMovies],
        y = [d['numericrating'] for d in currMovies],
        color = ["#FF9900" for d in currMovies],
        title = [d['title'] for d in currMovies],
        released = [d['released'] for d in currMovies],
        imdbvotes = [d['imdbvotes'] for d in currMovies],
        genre = [d['genre'] for d in currMovies]
    )

    for single_control in controls_array:
        single_control.js_on_change('value', callback)

    inputs_column = column(*controls_array, width=320, height=1000)
    layout_row = row([ inputs_column, fig ])

    script, div = components(layout_row)
    return render_template(
        'index.html',
        plot_script=script,
        plot_div=div,
        js_resources=INLINE.render_js(),
        css_resources=INLINE.render_css(),
    )

if __name__ == "__main__":
    app.run(debug=True)
    
#https://towardsdatascience.com/hyperparameter-tuning-the-random-forest-in-python-using-scikit-learn-28d2aa77dd74
from sklearn.ensemble import RandomForestRegressor
rf = RandomForestRegressor(random_state = 42)
from pprint import pprint
# Look at parameters used by our current forest
print('Parameters currently in use:\n')
pprint(rf.get_params())

from sklearn.model_selection import RandomizedSearchCV
# Number of trees in random forest
n_estimators = [int(x) for x in np.linspace(start = 200, stop = 2000, num = 10)]
# Number of features to consider at every split
max_features = ['auto', 'sqrt']
# Maximum number of levels in tree
max_depth = [int(x) for x in np.linspace(10, 110, num = 11)]
max_depth.append(None)
# Minimum number of samples required to split a node
min_samples_split = [2, 5, 10]
# Minimum number of samples required at each leaf node
min_samples_leaf = [1, 2, 4]
# Method of selecting samples for training each tree
bootstrap = [True, False]
# Create the random grid
random_grid = {'n_estimators': n_estimators,
               'max_features': max_features,
               'max_depth': max_depth,
               'min_samples_split': min_samples_split,
               'min_samples_leaf': min_samples_leaf,
               'bootstrap': bootstrap}
pprint(random_grid)

# Use the random grid to search for best hyperparameters
# First create the base model to tune
rf = RandomForestRegressor()
# Random search of parameters, using 3 fold cross validation, 
# search across 100 different combinations, and use all available cores
rf_random = RandomizedSearchCV(estimator = rf, param_distributions = random_grid, n_iter = 100, cv = 3, verbose=2, random_state=42, n_jobs = -1)
# Fit the random search model
rf_random.fit(train_features, train_labels)

rf_random.best_params_
{'bootstrap': True,
 'max_depth': 70,
 'max_features': 'auto',
 'min_samples_leaf': 4,
 'min_samples_split': 10,
 'n_estimators': 400}
def evaluate(model, test_features, test_labels):
    predictions = model.predict(test_features)
    errors = abs(predictions - test_labels)
    mape = 100 * np.mean(errors / test_labels)
    accuracy = 100 - mape
    print('Model Performance')
    print('Average Error: {:0.4f} degrees.'.format(np.mean(errors)))
    print('Accuracy = {:0.2f}%.'.format(accuracy))
    
    return accuracy
base_model = RandomForestRegressor(n_estimators = 10, random_state = 42)
base_model.fit(train_features, train_labels)
base_accuracy = evaluate(base_model, test_features, test_labels)
Model Performance
Average Error: 3.9199 degrees.
Accuracy = 93.36%.
best_random = rf_random.best_estimator_
random_accuracy = evaluate(best_random, test_features, test_labels)
Model Performance
Average Error: 3.7152 degrees.
Accuracy = 93.73%.
print('Improvement of {:0.2f}%.'.format( 100 * (random_accuracy - base_accuracy) / base_accuracy))
Improvement of 0.40%.

from sklearn.model_selection import GridSearchCV
# Create the parameter grid based on the results of random search 
param_grid = {
    'bootstrap': [True],
    'max_depth': [80, 90, 100, 110],
    'max_features': [2, 3],
    'min_samples_leaf': [3, 4, 5],
    'min_samples_split': [8, 10, 12],
    'n_estimators': [100, 200, 300, 1000]
}
# Create a based model
rf = RandomForestRegressor()
# Instantiate the grid search model
grid_search = GridSearchCV(estimator = rf, param_grid = param_grid, 
                          cv = 3, n_jobs = -1, verbose = 2)

try out 1 * 4 * 2 * 3 * 3 * 4 = 288 combinations
# Fit the grid search to the data
grid_search.fit(train_features, train_labels)
grid_search.best_params_
{'bootstrap': True,
 'max_depth': 80,
 'max_features': 3,
 'min_samples_leaf': 5,
 'min_samples_split': 12,
 'n_estimators': 100}
best_grid = grid_search.best_estimator_
grid_accuracy = evaluate(best_grid, test_features, test_labels)
Model Performance
Average Error: 3.6561 degrees.
Accuracy = 93.83%.
print('Improvement of {:0.2f}%.'.format( 100 * (grid_accuracy - base_accuracy) / base_accuracy))
Improvement of 0.50%.
#https://github.com/WillKoehrsen/Machine-Learning-Projects/blob/master/random_forest_explained/Improving%20Random%20Forest%20Part%202.ipynb 
#https://towardsdatascience.com/ensemble-learning-bagging-boosting-3098079e5422
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import BaggingClassifier

# Load the well-known Breast Cancer dataset
# Split into train and test sets
x, y = load_breast_cancer(return_X_y=True)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.25, random_state=23)

# For simplicity, we are going to use as base estimator a Decision Tree with fixed parameters
tree = DecisionTreeClassifier(max_depth=3, random_state=23)

# The baggging ensemble classifier is initialized with:
# base_estimator = DecisionTree
# n_estimators = 5 : it's gonna be created 5 subsets to train 5 Decision Tree models
# max_samples = 50 : it's gonna be taken randomly 50 items with replacement
# bootstrap = True : means that the sampling is gonna be with replacement
bagging = BaggingClassifier(base_estimator=tree, n_estimators=5, max_samples=50, bootstrap=True)

# Training
bagging.fit(x_train, y_train)

# Evaluating
print(f"Train score: {bagging.score(x_train, y_train)}")
print(f"Test score: {bagging.score(x_test, y_test)}")

# For this basic implementation, we only need these modules
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import AdaBoostClassifier

# Load the well-known Breast Cancer dataset
# Split into train and test sets
x, y = load_breast_cancer(return_X_y=True)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.25, random_state=23)

# The base learner will be a decision tree with depth = 2
tree = DecisionTreeClassifier(max_depth=2, random_state=23)

# AdaBoost initialization
# It's defined the decision tree as the base learner
# The number of estimators will be 5
# The penalizer for the weights of each estimator is 0.1
adaboost = AdaBoostClassifier(base_estimator=tree, n_estimators=5, learning_rate=0.1, random_state=23)

# Train!
adaboost.fit(x_train, y_train)

# Evaluation
print(f"Train score: {adaboost.score(x_train, y_train)}")
print(f"Test score: {adaboost.score(x_test, y_test)}")

# For this basic implementation, we only need these modules
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingClassifier

# Load the well-known Breast Cancer dataset
# Split into train and test sets
x, y = load_breast_cancer(return_X_y=True)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.25, random_state=23)

# Gradient Boosting initialization
# The base learner is a decision tree as default
# The number of estimators is 5
# The depth for each deciion tree is 2
# The learning rate for each estimator in the sequence is 1
gradientBoosting = GradientBoostingClassifier(n_estimators=5, learning_rate=1, max_depth=2, random_state=23)

# Train!
gradientBoosting.fit(x_train, y_train)

# Evaluation
print(f"Train score: {gradientBoosting.score(x_train, y_train)}")
print(f"Test score: {gradientBoosting.score(x_test, y_test)}")

#https://medium.com/analytics-vidhya/groupby-in-pandas-your-guide-to-summarizing-and-aggregating-data-in-python-4b702405c440
obj = df.groupby('Outlet_Location_Type')
obj.groups
for name,group in obj:
    print(name,'contains',group.shape[0],'rows')
obj.get_group('Tier 1')
df.groupby('Outlet_Location_Type').agg([np.mean,np.median])
df.groupby(['Outlet_Type','Item_Type']).agg(mean_MRP=('Item_MRP',np.mean),mean_Sales=('Item_Outlet_Sales',np.mean))
df['Item_Weight'] = df.groupby(['Item_Fat_Content','Item_Type'])['Item_Weight'].transform(lambda x: x.fillna(x.mean()))
df.shape
def filter_func(x):
    return x['Item_Weight'].std() < 3
df_filter = df.groupby(['Item_Weight']).filter(filter_func)
df_filter.shape
df_apply = df.groupby(['Outlet_Establishment_Year'])['Item_MRP'].apply(lambda x: x - x.mean())
df_apply
#https://towardsdatascience.com/feature-engineering-for-machine-learning-3a5e293a5114
threshold = 0.7
#Dropping columns with missing value rate higher than threshold
data = data[data.columns[data.isnull().mean() < threshold]]

#Dropping rows with missing value rate higher than threshold
data = data.loc[data.isnull().mean(axis=1) < threshold]

#Filling all missing values with 0
data = data.fillna(0)
#Filling missing values with medians of the columns
data = data.fillna(data.median())
#Max fill function for categorical columns
data['column_name'].fillna(data['column_name'].value_counts()
.idxmax(), inplace=True)
#Dropping the outlier rows with standard deviation
factor = 3
upper_lim = data['column'].mean () + data['column'].std () * factor
lower_lim = data['column'].mean () - data['column'].std () * factor

data = data[(data['column'] < upper_lim) & (data['column'] > lower_lim)]
#Dropping the outlier rows with Percentiles
upper_lim = data['column'].quantile(.95)
lower_lim = data['column'].quantile(.05)

data = data[(data['column'] < upper_lim) & (data['column'] > lower_lim)]
data.loc[(df[column] > upper_lim),column] = upper_lim
data.loc[(df[column] < lower_lim),column] = lower_lim
data['bin'] = pd.cut(data['value'], bins=[0,30,70,100], labels=["Low", "Mid", "High"])
conditions = [
    data['Country'].str.contains('Spain'),
    data['Country'].str.contains('Italy'),
    data['Country'].str.contains('Chile'),
    data['Country'].str.contains('Brazil')]

choices = ['Europe', 'Europe', 'South America', 'South America']

data['Continent'] = np.select(conditions, choices, default='Other')
data['log+1'] = (data['value']+1).transform(np.log)
data['log'] = (data['value']-data['value'].min()+1) .transform(np.log)
encoded_columns = pd.get_dummies(data['column'])
data = data.join(encoded_columns).drop('column', axis=1)
data.groupby('id').agg(lambda x: x.value_counts().index[0])
data.pivot_table(index='column_to_group', columns='column_to_encode', values='aggregation_column', aggfunc=np.sum, fill_value = 0)
grouped = data.groupby('column_to_group')

sums = grouped[sum_cols].sum().add_suffix('_sum')
avgs = grouped[mean_cols].mean().add_suffix('_avg')

new_df = pd.concat([sums, avgs], axis=1)
#Extracting last names
data.name.str.split(" ").map(lambda x: x[-1])
data.title.str.split("(", n=1, expand=True)[1].str.split(")", n=1, expand=True)[0]
data['normalized'] = (data['value'] - data['value'].min()) / (data['value'].max() - data['value'].min())
data['date'] = pd.to_datetime(data.date, format="%d-%m-%Y")

data['day_name'] = data['date'].dt.day_name()

#https://medium.com/fintechexplained/the-problem-of-overfitting-and-how-to-resolve-it-1eb9456b1dfd
from sklearn import linear_model
model = linear_model.Lasso(alpha=0.1)
model.fit([[0,0], [1, 1], [2, 2]], [0, 1, 2])
2. RIDGE
Adds a penalty which is the square of the magnitude of the coefficients. As a result, some of the weights will be very close to 0. As a result, it ends up smoothing the effect of the features.
from sklearn.linear_model import Ridge
model = Ridge(alpha=1.0)
model.fit(X, y)

#https://towardsdatascience.com/7-data-wrangling-python-functions-in-under-5-minutes-a8d9ec7cf34b
from gapminder import gapminder
(
    gapminder
	.query("year == 1972")
    .query("lifeExp < lifeExp.mean()")
    .query("country == 'Bolivia' | country == 'Angola'").rename(columns = {
        "year" : "Year",
        "lifeExp" : "Life Expectancy"
    })
    .assign(
        con_country = lambda x: x.continent + " - " + x.country,
        rn_lifeExp = lambda x: x.lifeExp.round(0).astype(int)
    )
	.sort_values(["lifeExp", "year"], ascending = [True, False])
    .head(rows)
)
(
    gapminder
    .query("year > 1989")
    .groupby(["continent", "year"])
	.agg(
        pop_mean = ('pop', 'mean'),
        pop_sd = ('pop', 'std'),
        le_mean = ('lifeExp', 'mean'),
        le_sd = ('lifeExp', 'std')
    )
    .T
)
#https://pandas.pydata.org/pandas-docs/version/1.2.3/pandas.pdf
#https://towardsdatascience.com/do-not-use-print-for-debugging-in-python-anymore-6767b6f1866d
#pip install icecream
from icecream import ic
#outlier https://towardsdatascience.com/5-outlier-detection-methods-that-every-data-enthusiast-must-know-f917bf439210
from sklearn.neighbors import LocalOutlierFactor
data = [[1, 1], [2, 2.1], [1, 2], [2, 1], [50, 35], [2, 1.5]]
lof = LocalOutlierFactor(n_neighbors=2, metric='manhattan')
prediction = lof.fit_predict(data)
>> [ 1,  1,  1,  1, -1,  1]
#Geometric Models for Outlier Detection, where I primarily focus on Angle-Based Techniques(ABOD) and Depth-Based Techniques(Convex Hull)
from sklearn.ensemble import IsolationForest
data = [[1, 1], [2, 2.1], [1, 2], [2, 1], [50, 35], [2, 1.5]]
iforest = IsolationForest(n_estimators=5)
iforest.fit(data)
actual_data = [[1, 1.5]]
iforest.predict(actual_data)
>> 1   (Normal)
outlier_data = [[45, 55]]
iforest.predict(outlier_data)
>> -1   (Outlier)
import package_outlier as po
data = [[1, 1], [2, 2.1], [1, 2], [2, 1], [50, 35], [2, 1.5]]
result = po.LocalOutlierFactorOutlier(data)
print (result)
#https://software.intel.com/content/www/us/en/develop/training/course-anomaly-detection.html
#https://www.analyticsvidhya.com/blog/2019/02/outlier-detection-python-pyod/
#https://h1ros.github.io/posts/anomaly-detection-by-auto-encoder-deep-learning-in-pyod/
#https://lvwerra.github.io/jupyterplot/
!pip install jupyterplot
from jupyterplot import ProgressPlot
import numpy as np
pp = ProgressPlot()
for i in range(1000):
    pp.update(np.sin(i / 100))
pp.finalize()
pp = ProgressPlot(plot_names=['plot 1', 'plot 2'], x_lim=[0, 1000], y_lim=[[0, 10],[0, 100]])
for i in range(1000):
    pp.update([[(i/100)], [(i/100)**2]])

#https://www.tensorflow.org/api_docs/python/tf/experimental/numpy
import  tensorflow.experimental.numpy as tnp
import numpy as np
print(tnp.ones([2,1]) + np.ones([1, 2]))
print(tnp.ones([1, 2], dtype=tnp.int16) + tnp.ones([2, 1], dtype=tnp.uint8))
@tf.function
def f(x, y):
  return tnp.sum(x + y)
f(tnp.ones([1, 2]), tf.ones([2, 1]))
#https://towardsdatascience.com/how-to-solve-a-staff-scheduling-problem-with-python-63ae50435ba4
#admin mamba install pulp gdown -c conda-forge
import gdown
import pandas as pd
url = "https://drive.google.com/uc?id=15BPH7-3GGWBfXPJQ3stkT6SHQECbT-pt"
output = "shifts.csv"
gdown.download(url, output, quiet=False)
df = pd.read_csv("shifts.csv", index_col=0)
df = df.fillna(0).applymap(lambda x: 1 if x == "X" else x)
a = df.drop(index=["Wage rate per 9h shift ($)"], columns=["Workers Required"]).values
n = a.shape[1]
# number of time windows
T = a.shape[0]
# number of workers required per time window
d = df["Workers Required"].values
# wage rate per shift
w = df.loc["Wage rate per 9h shift ($)", :].values.astype(int)
from pulp import *
y = LpVariable.dicts("num_workers", list(range(n)), lowBound=0, cat="Integer")
prob = LpProblem("scheduling_workers", LpMinimize)
prob += lpSum([w[j] * y[j] for j in range(n)])
for t in range(T):
    prob += lpSum([a[t, j] * y[j] for j in range(n)]) >= d[t]
prob.solve()
print("Status:", LpStatus[prob.status])
for shift in range(n):	print(f"The number of workers needed for shift {shift} is {int(y[shift].value())} workers")

#https://github.com/animesh/openmp_course_2021
import numpy as np
import time
from numpy.random import seed
from numpy.random import rand
from numba import jit,cuda

size_array=4
size_vec=size_array*size_array
validate=True

def generate_array(num,size):
    seed(num)
    lst=10.*rand(size)+1.
    return lst


a=np.array(generate_array(1,size_vec))
b=np.array(generate_array(2,size_vec))
c=np.zeros(size_vec)

@cuda.jit
def mat_mul(a,b,c,size):
    row=cuda.blockIdx.y*cuda.blockDim.y+cuda.threadIdx.y
    col=cuda.blockIdx.x*cuda.blockDim.x+cuda.threadIdx.x
    for i in range(size):
        c[row*size+col]+=a[row*size+i]*b[i*size+col]


threadsperblock = (2,2)
blockspergrid_x = int(np.ceil(size_array / threadsperblock[0]))
blockspergrid_y = int(np.ceil(size_array / threadsperblock[1]))
blockspergrid = (blockspergrid_x, blockspergrid_y)
start=time.time()
mat_mul[blockspergrid, threadsperblock](a,b,c,size_array)
end=time.time()
print('Elapsed time: ',end-start)

c=np.zeros(size_vec)
start=time.time()
mat_mul[blockspergrid, threadsperblock](a,b,c,size_array)
end=time.time()
print('Elapsed time: ',end-start)

if(validate):
    a2d=np.reshape(a,(size_array,-1))
    b2d=np.reshape(b,(size_array,-1))
    c2d_numba=np.reshape(c,(size_array,-1))
    c2d=np.matmul(a2d,b2d)
    dif=np.abs(c2d_numba-c2d)
    summation=np.sum(dif)
    print(summation,summation/float(size_vec))

#https://machinelearningmastery.com/confidence-intervals-for-machine-learning/
from numpy.random import seed
from numpy.random import rand
from numpy.random import randint
from numpy import mean
from numpy import median
from numpy import percentile
# seed the random number generator
seed(1)
# generate ddataset = 0.5 + rand(1000) * 0.5
# bootstrap
scores = list()
for _ in range(100):
	# bootstrap sample
	indices = randint(0, 1000, 1000)
	sample = dataset[indices]
	# calculate and store statistic
	statistic = mean(sample)
	scores.append(statistic)
print('median=%.3f' % median(scores))
alpha = 5.0
# calculate lower percentile (e.g. 2.5)
lower_p = alpha / 2.0
# retrieve observation at lower percentile
lower = max(0.0, percentile(scores, lower_p))
print('%.1fth percentile = %.3f' % (lower_p, lower))
# calculate upper percentile (e.g. 97.5)
upper_p = (100 - alpha) + (alpha / 2.0)
# retrieve observation at upper percentile
upper = min(1.0, percentile(scores, upper_p))
print('%.1fth percentile = %.3f' % (upper_p, upper))
#https://towardsdatascience.com/find-the-difference-in-python-68bbd000e513
import difflib as dl
s1 = 'abcde'
s2 = 'fabdc'
seq_matcher = dl.SequenceMatcher(None, s1, s2)
for tag, i1, i2, j1, j2 in seq_matcher.get_opcodes():
    print(f'{tag:7}   s1[{i1}:{i2}] --> s2[{j1}:{j2}] {s1[i1:i2]!r:>6} --> {s2[j1:j2]!r}')
seq_matcher = dl.SequenceMatcher(lambda c: c in 'abc', s1, s2)
#https://tutorial.dask.org/01_dask.delayed.html
from dask.distributed import Client
client = Client(n_workers=4)
from time import sleep
def inc(x):
    sleep(1)
    return x + 1
def add(x, y):
    sleep(1)
    return x + y
x = inc(1)
y = inc(2)
z = add(x, y)
from dask import delayed
x = delayed(inc)(1)
y = delayed(inc)(2)
z = delayed(add)(x, y)
z.compute()
z.visualize()
client.close()
#https://towardsdatascience.com/3-python-pandas-tricks-for-efficient-data-analysis-6324d013ef39
df["rank"] = df.groupby("date)["sales"].rank(ascending=False).astype("int")
df.groupby(["store","rank"]).count()[["sales"]]
df.groupby(["store","rank"]).agg(rank_count = ("rank", "count"))
df = pd.concat([A, B, C]).sort_values(by="date", ignore_index=True)
#https://github.com/hyperopt/hyperopt/wiki/FMin#21-parameter-expressions preprocessors adapted in HyperOpt/Adaptive Tree of Parzen Estimators/ Sklearn are: PCA, TfidfVectorizer, StandardScalar, MinMaxScalar, Normalizer, OneHotEncoder; classifiers adapted in HyperOpt Sklearn are: SVC, LinearSVC KNeightborsClassifier. RandomForestClassifier, ExtraTreesClassifier SGDClassifier, MultinomialNB, BernoulliRBM, ColumnKMeans
#https://github.com/chanzuckerberg/cellxgene
import pickle
import time
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
def objective(x):
    return {
        'loss': x ** 2,
        'status': STATUS_OK,
        # -- store other results like this
        'eval_time': time.time(),
        'other_stuff': {'type': None, 'value': [0, 1, 2]},
        # -- attachments are handled differently
        'attachments':
            {'time_module': pickle.dumps(time.time)}
        }
trials = Trials()
best = fmin(objective,
    space=hp.uniform('x', -10, 10),
    algo=tpe.suggest,
    max_evals=100,
    trials=trials)
print(best)
msg = trials.trial_attachments(trials.trials[5])['time_module']
time_module = pickle.loads(msg)
#https://github.com/hyperopt/hyperopt-sklearn
from hpsklearn import HyperoptEstimator, any_classifier, any_preprocessing
from sklearn.datasets import load_iris
from hyperopt import tpe
import numpy as np
from hpsklearn import HyperoptEstimator, extra_trees
from sklearn.datasets import fetch_mldata
from hyperopt import tpe
import numpy as np

# Download the data and split into training and test sets

digits = fetch_mldata('MNIST original')

X = digits.data
y = digits.target

test_size = int(0.2 * len(y))
np.random.seed(13)
indices = np.random.permutation(len(X))
X_train = X[indices[:-test_size]]
y_train = y[indices[:-test_size]]
X_test = X[indices[-test_size:]]
y_test = y[indices[-test_size:]]

# Instantiate a HyperoptEstimator with the search space and number of evaluations

estim = HyperoptEstimator(classifier=extra_trees('my_clf'),
                          preprocessing=[],
                          algo=tpe.suggest,
                          max_evals=10,
                          trial_timeout=300)

# Search the hyperparameter space based on the data

estim.fit( X_train, y_train )

# Show the results

print(estim.score(X_test, y_test))
# 0.962785714286

print(estim.best_model())
# {'learner': ExtraTreesClassifier(bootstrap=True, class_weight=None, criterion='entropy',
#           max_depth=None, max_features=0.959202875857,
#           max_leaf_nodes=None, min_impurity_decrease=0.0,
#           min_impurity_split=None, min_samples_leaf=1,
#           min_samples_split=2, min_weight_fraction_leaf=0.0,
#           n_estimators=20, n_jobs=1, oob_score=False, random_state=3,
#           verbose=False, warm_start=False), 'preprocs': (), 'ex_preprocs': ()}

conda create --yes -n cellxgene python=3.7
conda activate cellxgene ; pip install cellxgene
cellxgene launch https://cellxgene-example-data.czi.technology/pbmc3k.h5ad
#http://localhost:5005/

#https://discuss.streamlit.io/t/new-pyvis-component-for-graphs/11335
pip install stvis
from pyvis import network as net
import streamlit as st
from stvis import pv_static

g=net.Network(height='500px', width='500px',heading='')
g.add_node(1)
g.add_node(2)
g.add_node(3)
g.add_edge(1,2)
g.add_edge(2,3)

pv_static(g)
#https://towardsdatascience.com/why-decorators-in-python-are-pure-genius-1e812949a81e
def startstop(func):
    def wrapper():
        print("Starting...")
        func()
        print("Finished!")
    return wrapper
def roll():
    print("Rolling on the floor laughing XD")
roll = startstop(roll)
@startstop
def roll():
    print("Rolling on the floor laughing XD")
#move to decorators.py and write something like this into your main file:
from decorators import startstop
@startstop
def roll():
    print("Rolling on the floor laughing XD")
#https://towardsdatascience.com/11-python-built-in-functions-you-should-know-877a2c2139db
def is_even(num):
    if num % 2 == 0:
        return True
    return False
f_even = filter(is_even, [1,2,3,4,5,6,7,8])
list(f_even)
locals()
#https://python.plainenglish.io/make-beautiful-water-polo-chart-in-a-few-lines-in-python-5d04f3f9335d
from pyecharts import options as opts
from pyecharts.charts import Liquid
from pyecharts.globals import SymbolType
#custom a SVG path looks like a whale
shape = ("path://M367.855,428.202c-3.674-1.385-7.452-1.966-11.146-1"
         ".794c0.659-2.922,0.844-5.85,0.58-8.719 c-0.937-10.407-7."
         "663-19.864-18.063-23.834c-10.697-4.043-22.298-1.168-29.9"
         "02,6.403c3.015,0.026,6.074,0.594,9.035,1.728 c13.626,5."
         "151,20.465,20.379,15.32,34.004c-1.905,5.02-5.177,9.115-9"
         ".22,12.05c-6.951,4.992-16.19,6.536-24.777,3.271 c-13.625"
         "-5.137-20.471-20.371-15.32-34.004c0.673-1.768,1.523-3.423"
         ",2.526-4.992h-0.014c0,0,0,0,0,0.014 c4.386-6.853,8.145-14"
         ".279,11.146-22.187c23.294-61.505-7.689-130.278-69.215-153"
         ".579c-61.532-23.293-130.279,7.69-153.579,69.202 c-6.371,"
         "16.785-8.679,34.097-7.426,50.901c0.026,0.554,0.079,1.121,"
         "0.132,1.688c4.973,57.107,41.767,109.148,98.945,130.793 c58."
         "162,22.008,121.303,6.529,162.839-34.465c7.103-6.893,17.826"
         "-9.444,27.679-5.719c11.858,4.491,18.565,16.6,16.719,28.643 "
         "c4.438-3.126,8.033-7.564,10.117-13.045C389.751,449.992,"
         "382.411,433.709,367.855,428.202z")
c = (
    Liquid()
    .add("Completion", [0.6, 0.5, 0.4, 0.3], is_outline_show=False, shape = shape)
    .set_global_opts(title_opts=opts.TitleOpts(title="% of sales target achieved",pos_left="center"))
)
c.render_notebook()
#https://levelup.gitconnected.com/hidden-power-of-polymorphism-in-python-c9e2539c1633
from . import memory, persistent  # noqa


# file storage/memory.py
def add(item: dict):
    print(f"[memory] put {item}")

def get(pk: int):
    print(f"[memory] get item with {pk=}")


# file storage/persistent.py
def add(item: dict):
    print(f"[persistent] put {item}")

def get(pk: int):
    print(f"[persistent] get item with {pk=}")
import storage.memory
import storage.persistent
use_storage(storage.memory)
# or
use_storage(storage.persistent)

#https://pub.towardsai.net/shapash-making-ml-models-understandable-by-everyone-8f96ad469eb3
import pandas as pd
from shapash.data.data_loader import data_loading
house_df, house_dict = data_loading('house_prices')
y_df=house_df['SalePrice'].to_frame()
X_df=house_df[house_df.columns.difference(['SalePrice'])]
house_df.head(3)
from category_encoders import OrdinalEncoder
categorical_features = [col for col in X_df.columns if X_df[col].dtype == 'object']
encoder = OrdinalEncoder(cols=categorical_features).fit(X_df)
X_df=encoder.transform(X_df)
ordinal_cols_mapping = [{
    "col":"ExterQual",
    "mapping": [
        ('Ex',5),
        ('Gd',4),
        ('TA',3),
        ('Fa',2),
        ('Po',1),
        ('NA',np.nan)
    ]},
]
encoder = OrdinalEncoder(mapping = ordinal_cols_mapping,
                         return_df = True)
df_train = encoder.fit_transform(train_data)

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor

Xtrain, Xtest, ytrain, ytest = train_test_split(X_df, y_df, train_size=0.75)
reg = RandomForestRegressor(n_estimators=200, min_samples_leaf=2).fit(Xtrain,ytrain)
y_pred = pd.DataFrame(reg.predict(Xtest), columns=['pred'], index=Xtest.index)
from shapash.explainer.smart_explainer import SmartExplainer
xpl = SmartExplainer(features_dict=house_dict) # Optional parameter
xpl.compile(
    x=Xtest,
    model=reg,
    preprocessing=encoder,# Optional: use inverse_transform method
    y_pred=y_pred # Optional
)
app = xpl.run_app()
app.kill()
subset = [ 168, 54, 995, 799, 310, 322, 1374,
          1106, 232, 645, 1170, 1229, 703, 66,
          886, 160, 191, 1183, 1037, 991, 482,
          725, 410, 59, 28, 719, 337, 36 ]
xpl.plot.features_importance(selection=subset)
xpl.plot.contribution_plot("OverallQual")
xpl.filter(max_contrib=8,threshold=100)
xpl.plot.local_plot(index=560)
xpl.filter(max_contrib=3,threshold=1000)
summary_df = xpl.to_pandas()
summary_df.head()
xpl.plot.compare_plot(row_num=[0, 1, 2, 3, 4], max_features=8)
#https://medium.com/statch/speeding-up-python-code-with-nim-ec205a8a5d9c
def fib(n):
    if n == 0:
        return 0
    elif n < 3:
        return 1
    return fib(n - 1) + fib(n - 2)
import nimporter
from time import perf_counter
import scratch#.nim
print('Measuring Python...')
start_py = perf_counter()
for i in range(0, 40):
    print(pmath.fib(i))
end_py = perf_counter()

print('Measuring Nim...')
start_nim = perf_counter()
for i in range(0, 40):
    print(nmath.fib(i))
end_nim = perf_counter()

print('---------')
print('Python Elapsed: {:.2f}'.format(end_py - start_py))
print('Nim Elapsed: {:.2f}'.format(end_nim - start_nim))

#https://towardsdatascience.com/a-simple-way-to-time-code-in-python-a9a175eb0172
"""Build the timefunc decorator."""

import time
import functools


def timefunc(func):
    """timefunc's doc"""

    @functools.wraps(func)
    def time_closure(*args, **kwargs):
        """time_wrapper's doc string"""
        start = time.perf_counter()
        result = func(*args, **kwargs)
        time_elapsed = time.perf_counter() - start
        print(f"Function: {func.__name__}, Time: {time_elapsed}")
        return result

    return time_closure
@timefunc
def single_thread(inputs):
    """
    Compute single threaded.
    """
    return [f(x) for x in inputs]


if __name__ == "__main__":

    demo_inputs = [randint(1, 100) for _ in range(10_000)]

    single_thread(demo_inputs)
"""Build the timefunc decorator."""

import time
import functools


def timefunc(func):
    """timefunc's doc"""

    @functools.wraps(func)
    def time_closure(*args, **kwargs):
        """time_wrapper's doc string"""
        start = time.perf_counter()
        result = func(*args, **kwargs)
        time_elapsed = time.perf_counter() - start
        print(f"Function: {func.__name__}, Time: {time_elapsed}")
        return result

    return time_closure

#https://www.youtube.com/watch?v=9Q6sLbz37gk&feature=emb_title
from requests import get
b = get('http://whatsmyip.org')
b.text
#https://pub.towardsai.net/data-preprocessing-concepts-with-python-b93c63f14bb6
#Before modeling our estimator we should always some preprocessing scaling.
# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
import numpy as np
X_train = np.array([[ 1., 0.,  2.], [ 2.,  0.,  -1.], [ 0.,  2.,
                                                             -1.]])
from sklearn.preprocessing import MinMaxScaler
min_max_scaler = MinMaxScaler()
X_train_minmax = min_max_scaler.fit_transform(X_train)
print(X_train_minmax)
#output:
array([[0.5, 0. , 1. ],
       [1. , 0. , 0. ],
       [0. , 1. , 0. ]])
from sklearn.preprocessing import RobustScaler
X = [[ 1., 0.,  2.], [ 2.,  0.,  -1.], [ 0.,  2., -1.]]
transformer = RobustScaler().fit(X)
transformer.transform(X)
#output:
array([[ 0.,  0.,  2.],
       [ 1.,  0.,  0.],
       [-1.,  2.,  0.]])
from sklearn.preprocessing import normalize
X = [[ 1., 0., 2.], [ 2., 0., -1.], [ 0., 2., -1.]]
X_normalized = normalize(X, norm=’l2')
print(X_normalized)
#output:
array([[ 0.4472136 ,  0.        ,  0.89442719],
       [ 0.89442719,  0.        , -0.4472136 ],
       [ 0.        ,  0.89442719, -0.4472136 ]])
from sklearn.preprocessing import Normalizer
X = [[ 1., 0., 2.], [ 2., 0., -1.], [ 0., 2., -1.]]
normalizer = preprocessing.Normalizer().fit(X)
normalizer.transform(X)
#output:
array([[ 0.4472136 ,  0.        ,  0.89442719],
       [ 0.89442719,  0.        , -0.4472136 ],
       [ 0.        ,  0.89442719, -0.4472136 ]])
#Get Dummies: It is used to get a new feature column with 0 and 1 encoding the categories with the help of the pandas’ library.
#Label Encoder: It is used to encode binary categories to numeric values in the sklearn library.
#One Hot Encoder: The sklearn library provides another feature to convert categories class to new numeric values of 0 and 1 with new feature columns.
#Hashing: It is more useful than one-hot encoding in the case of high dimensions. It is used when there is high cardinality in the feature.
#There are many other encoding methods like mean encoding, Helmert encoding, ordinal encoding, probability ratio encoding and, etc.
df1=pd.get_dummies(df['State'],drop_first=True)
# import the pandas library
import pandas as pd
import numpy as np
df = pd.DataFrame(np.random.randn(4, 3), index=['a', 'c', 'e',
'h'],columns=['First', 'Second', 'Three'])
df = df.reindex(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
print (df)
print ("NaN replaced with '0':")
print (df.fillna(0))
from sklearn.impute import SimpleImputer
imp = SimpleImputer(missing_values=np.nan, strategy='mean')
#When we use sparse input it is important to convert it not CSR format to avoid multiple memory copies. The CSR is compressed Sparse Rows comes in scipy.sparse.csr_matrix.
#https://docs.fast.ai/tutorial.vision.html
from fastai.vision.all import *
path = untar_data(URLs.PETS)
path = path/'images'
path.ls()
def is_cat(x): return x[0].isupper()
dls = ImageDataLoaders.from_name_func(
    path, get_image_files(path), valid_pct=0.2, seed=42,
    label_func=is_cat, item_tfms=Resize(224))
learn = cnn_learner(dls, resnet34, metrics=error_rate)
learn.fine_tune(1)
#https://youtu.be/6BPl81wGGP8?t=485
from tensorflow.keras.datasets import mnist
(train_X,train_Y),(test_X,test_Y)=mnist.load_data()
#import umap as umap
import umap.umap_ as umap
from babyplots import Babyplot
reducer=umap.UMAP(random_state=42)
import pyforest
file_path = r"*.xlsx"
files = glob.glob(file_path)
Tax= pd.read_table('Z:/ayu/S33-QUALITY-PASSED/binning/DASTool/checkm/taxonomy.tsv',index_col=0)
Labels=Tax.ffill(axis=1).species.copy()
Labels.loc[Tax.species.isnull()]+= ' '+ Labels.index[Tax.species.isnull()]
#https://github.com/fbdesignpro/sweetviz
#!pip install sweetviz
import sweetviz as sv
report = sv.analyze(my_dataframe)#feature_config = sv.FeatureConfig(skip="PassengerId", force_text=["Age"])#pairwise_analysis="on"
report.show_html() # Default arguments will generate to "SWEETVIZ_REPORT.html"
#show_notebook(  w=None,                 h=None,                 scale=None,                layout='widescreen',                filepath=None)
compare_report = sv.compare([my_dataframe, "Training Data"], [test_df, "Test Data"], "Survived", feature_config)
sumcomp_report = sv.compare_intra(my_dataframe, my_dataframe["Sex"] == "male", ["Male", "Female"], feature_config)

#https://pytorch-lightning.medium.com/introducing-lightning-flash-the-fastest-way-to-get-started-with-deep-learning-202f196b3b98
import flash
from flash.core.data import download_data
from flash.vision import ImageClassificationData, ImageClassifier

# 1. Download the data
download_data("https://pl-flash-data.s3.amazonaws.com/hymenoptera_data.zip", 'data/')

# 2. Load the data from folders
datamodule = ImageClassificationData.from_folders(
    backbone="resnet18",
    train_folder="data/hymenoptera_data/train/",
    valid_folder="data/hymenoptera_data/val/",
    test_folder="data/hymenoptera_data/test/",
)

# 3. Build the model using desired Task
model = ImageClassifier(num_classes=datamodule.num_classes)

# 4. Create the trainer (run one epoch for demo)
trainer = flash.Trainer(max_epochs=1)

# 5. Finetune the model
trainer.finetune(model, datamodule=datamodule, unfreeze_milestones=(0, 1))

# 6. Use the model for predictions
predictions = model.predict('data/hymenoptera_data/val/bees/65038344_52a45d090d.jpg')
# Expact 1 -> bee
print(predictions)

predictions = model.predict('data/hymenoptera_data/val/ants/2255445811_dabcdf7258.jpg')
# Expact 0 -> ant
print(predictions)

# 7. Save the new model!
trainer.save_checkpoint("image_classification_model.pt")
import torch
import torch.nn.functional as F
from flash.core.classification import ClassificationTask
from pytorch_lightning.metrics import Accuracy
from typing import Type, Callable, Mapping, Sequence, Union


class LinearClassifier(ClassificationTask):
    def __init__(
        self,
        num_inputs,
        num_classes,
        loss_fn: F.cross_entropy,
        optimizer: Type[torch.optim.Optimizer] = torch.optim.SGD,
        metrics: Union[pl.metrics.Metric, Mapping, Sequence, None] = [Accuracy()],
        learning_rate: float = 1e-3,
    ):
      super().__init__(
        model=None,
          loss_fn=loss_fn,
          optimizer=optimizer,
          metrics=metrics,
          learning_rate=learning_rate,
      )

      self.save_hyperparameters()

      self.linear = torch.nn.Linear(num_inputs, num_classes)

    def forward(self, x):
        return self.linear(x)

#climate dataset https://docs.google.com/spreadsheets/d/1SNe_GFimu_E2sdfpm4_XiEfVFKKHmhPRfneOsbosBnU/edit?usp=sharing
#https://towardsdatascience.com/the-coolest-data-science-library-i-found-in-2021-956af253fb2c
#!pip install -U scikit-learn
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import accuracy_score
import numpy as np
import math
from copy import copy
from sklearn.metrics import make_scorer, accuracy_score
### check if user provided initial values to perform Gridsearch
   # if yes- users parameters would replace respecitve params domain_params_dicts
def set_initial_params(dictionary, param_name, domain_array):
    if param_name in dictionary and bool(dictionary[param_name]):
        params_array = dictionary[param_name]
    else:
        params_array = domain_array
    return params_array
# each value in dict passed to GridSearchCV must be array, like {'n_estimators': [100], 'learning_rate' : [0.01]}
# but the same value provided to model must be int/str: {'n_estimators': 100, 'learning_rate' : 0.01}
# the function below converts dictwith arrays to dict with integers
def convert_dict_of_arrays(dictionary):
    ret = {}
    for key, value_arr in dictionary.items():
        ret[key] = value_arr[0]
    return ret
# update parameter values by those returned by Gridsearch
def update_model_params(model, model_params, params_to_update):
    try:
        model_params.update(params_to_update)
        model = model.__class__(**model_params)
    except:
        pass
    return model
##  create new array of parameters, which will be further researched to find optimap param values
def create_new_array(param_name, param_array, position, param_requirments):
    if position == 0 :
        lowest_val = param_array[position]*2 - param_array[position+1]
        # check formal value requirements
        if lowest_val < param_requirments[param_name]['min']:
            lowest_val = param_requirments[param_name]['min']
        new_array = [lowest_val, param_array[position], ((param_array[position+1] + param_array[position])/2) ]
    # if optimal value was the last in array - take higher values
    elif param_array[-1] == param_array[position]:
        highest_val = param_array[position]*2 + param_array[position-1]
        # check formal value requirements
        if highest_val > param_requirments[param_name]['max']:
            highest_val = param_requirments[param_name]['max']
        new_array = [((param_array[position-1] + param_array[position])/2), param_array[position], highest_val]
    else:
        new_array = [((param_array[position-1] + param_array[position])/2), param_array[position], ((param_array[position+1] + param_array[position])/2) ]
    # check data type requirements
    if param_requirments[param_name]['type'] == 'int':
        new_array[0] = math.ceil(new_array[0])
        new_array[-1] = math.floor(new_array[-1])
        new_array[1:-1] = np.round(new_array[1:-1])
    # remove duplicates:
    new_array = np.unique(new_array)
    return new_array
### perform Gridsearch over parameters and return the best model
def find_best_params(model, parameters, X_train, y_train, min_loss, scoring, n_folds, iid, initial_socre =0):
    param_requirments = {'subsample': {'max': 1, 'min': 1/len(X_train), 'type': 'float'}, # minimal value is fraction for one row
                         'colsample_bytree': {'max': 1, 'min': 1/len(X_train.columns), 'type': 'float'}, #  # minimal value is fraction for one column
                         'reg_alpha': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'reg_lambda': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'reg_scale_pos_weightlambda': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'learning_rate': {'max': 1, 'min': 1e-15, 'type': 'float'}, # technically it moght be more than 1, but it may lead to underfittting
                         'n_estimators': {'max': np.inf, 'min': 1, 'type': 'int'},
                         'max_features': {'max': np.inf, 'min': 1, 'type': 'int'},
                         'gamma': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'min_samples_leaf':{'max': np.inf, 'min': 1, 'type': 'int'}, # could be float (then i'ts percentage of all examples, but we'll use integers (number of samples) for consistency)
                         'min_samples_split': {'max': np.inf, 'min': 1, 'type': 'int'}, # could be float (then i'ts percentage of all examples, but we'll use integers (number of samples) for consistency)
                         'min_child_samples':{'max': np.inf, 'min': 1, 'type': 'int'},
                         'min_split_gain': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'min_child_weight': {'max': np.inf, 'min': 0, 'type': 'float'},
                         'max_depth': {'max': np.inf, 'min': 1, 'type': 'int'},
                         'num_leaves': {'max': np.inf, 'min': 1, 'type': 'int'}}

    assert (min_loss != 0) # if equal to 0 - would be calculated infinity
    print ("Find best parameters for: ", parameters)
    clf = GridSearchCV(model, parameters, scoring=scoring, verbose=0, cv = n_folds, refit=True, iid=iid)
    clf.fit(X_train, y_train)
    # perform further searching if metric loss is still significant
    new_score = scoring._score_func(clf.predict(X_train), y_train) # calculate new metric_value
    if new_score-initial_socre > min_loss:
        new_param_dict = {}
        for param_name, param_array in parameters.items():
            if len(param_array)>1:
                position = param_array.index(clf.best_params_[param_name])
                # crete new array of parameters for further research based on best_value's position in array
                # if optimal value was the lowest in array - take lower values
                new_array = create_new_array(param_name, param_array, position, param_requirments)
                # assign new array if it's different than the old one
                if (len(new_array) != len(param_array)) or (new_array != param_array).any():
                    new_param_dict[param_name] = list(new_array)
        if len(new_param_dict)>0:
            find_best_params(model, new_param_dict, X_train, y_train, min_loss, scoring, n_folds, iid, initial_socre = new_score)
    return (clf)
## main function- find optimal_parameters for given function
def fit_parameters(initial_model, initial_params_dict, X_train, y_train, min_loss, scoring, n_folds=5, iid=False):
    ### initial check
    available_models = ['XGBRegressor', 'GradientBoostingRegressor', 'LGBMRegressor']
    assert (type(initial_params_dict) is dict)
    assert (initial_model.__class__.__name__ in available_models)
    model=initial_model
    available_params = list(model.get_params().keys())
    # domain parameters, which will be used if no parameters provided by user
        # 1. n_estimators- should be quite low, in ranparamsge [40-120] (should be fast to checm many parameters, n_estimators will be fine-tuned later)
             # if optimal is 20, you might want to try lowering the learning rate to 0.05 and re-run grid search
             # learning rate-  0.05-0.2 powinno działać na początku
             # for LightGmax_depthBM n_estimators: must be infinite (like 9999999) and use early stopping to auto-tune (otherwise overfitting)
        # 2. num leaves- too much will lead to overfitting
             # min_samples_split: This should be ~0.5-1% of min_split_gaintotal values.
             # min_child_weight:  (sample size / 1000), nevfor p_name, p_array in params_dict.items():ertheless depedns on dataset and loss
        # 3. min_samples_leaf : a small value because of imbalanced classes, zrób kombinacje z 5 najlepszymi wartościami min_samples_split
        # 4. max_features = ‘sqrt’ : Its a general thumb-rule to start with square root.
        # others:param_pair = {'n_estimators': [final_params['n_estimators'] * n], 'learning_rate' : [final_params['learning_rate'] / n]}
             # is_unbalance: false (make your own weighting with scale_pos_weight)
             # Scale_pos_weight is the ratio of number of negative class to the positive class. Suppose, the dataset has 90 observations of negative class and 10 observations of positive class, then ideal value of scale_pos_Weight should be 9
    domain_params_dicts = [{'n_estimators': [30, 50, 70, 100, 150, 200, 300]},
                            {'max_depth': [3, 5, 7, 9], 'min_child_weight': [0.001, 0.1, 1, 5, 10, 20], 'min_samples_split': [1,2,5,10,20,30], 'num_leaves': [15, 35, 50, 75, 100,150]},
                            {'gamma': [0.0, 0.1, 0.2, 0.3, 0.4, 0.5], 'min_samples_leaf': [1,2,5,10,20,30], 'min_child_samples': [2,7,15,25,45], 'min_split_gain': [0, 0.001, 0.1, 1,5, 20]},
                            {'n_estimators': [30, 50, 70, 100, 150, 200, 300],  'max_features': range(10,25,3)},
                            {'subsample': [i/10 for i in range(4,10)], 'colsample_bytree': [i/10 for i in range(4,10)], 'feature_fraction': [i/10 for i in range(4,10)]},
                            {'reg_alpha':[1e-5, 1e-2, 0.1, 1, 25, 100], 'reg_lambda':[1e-5, 1e-2, 0.1, 1, 25, 100]}]
    # iterate over parameter anmes from domain_params_dicts, and adjust parameter value from following dictionaries
    for params_dict in domain_params_dicts:
        params ={}
        for p_name, p_array in params_dict.items():
            if (p_name in available_params):
                params[p_name] = set_initial_params(initial_params_dict, p_name, p_array)
        # save new best parameters
        best_params = find_best_params(model, params, X_train, y_train, min_loss, scoring, n_folds, iid).best_params_
        final_params = copy(model.get_params())
        model = update_model_params(model, final_params, best_params)
    # finally adjust pair (n_estimators, learning_rate)
    try:
        best_score = None
        for n in [1, 2, 4, 8, 15, 25]:
            param_pair = {'n_estimators': [final_params['n_estimators'] * n], 'learning_rate' : [final_params['learning_rate'] / n]}
            print('prediction for: ', param_pair)
            clf = GridSearchCV(model, param_pair, scoring=scoring, verbose=0, cv = n_folds, refit=True,  iid=iid)
            clf.fit(X_train, y_train)
            new_score = scoring._score_func(clf.predict(X_train), y_train) # calculate new metric_value
            # save parameters, if they give better results
            best_param_pair = param_pair
            if best_score is None:
                best_score = new_score
            elif scoring.__dict__['_sign'] == 1: # for score where greater is better
                if new_score - best_score >= min_loss:
                    best_score = new_score
                    best_param_pair = param_pair
            elif scoring.__dict__['_sign'] == -1:# for score where lower is better
                if new_score - best_score <= min_loss:
                    best_score = new_score
                    best_param_pair = param_pair
            print ('best score', best_score)
        best_param_pair = convert_dict_of_arrays(best_param_pair)
        model = update_model_params(model, final_params, best_param_pair)
    except:
        pass
    model.fit(X_train, y_train)
    return model
def rmsle(h, y):
    """
    Args:
        h - numpy array containing predictions with shape (n_samples, n_targets)
        y - numpy array containing targets with shape (n_samples, n_targets)
    """
    return np.sqrt(np.square(np.log(h + 1) - np.log(y + 1)).mean())
#!pip install xgboost
import xgboost
rmlse_score = make_scorer(rmsle, greater_is_better=False)
X_train, X_test, y_train, y_test = model_selection.train_test_split(features, target, train_size=0.71,test_size=0.29, random_state=101)
fitted_model = fit_parameters(initial_model = xgboost.XGBRegressor(), initial_params_dict = {}, X_train = X_train, y_train = y_train, min_loss = 0.01, scoring=rmlse_score, n_folds=5)
preds = fitted_model.predict(X_test)
plt.plot(preds)
plt.plot(np.arange(0,40),y_test)
feature_important = fitted_model.get_booster().get_score(importance_type='weight')
keys = list(feature_important.keys())
values = list(feature_important.values())
data = pd.DataFrame(data=values, index=keys, columns=["score"]).sort_values(by = "score", ascending=False)
data.plot(kind='barh')

#https://drive.google.com/file/d/1AGh-5GKRV8U6-xGd96zIVTUn1s9R9FC5/view
def startsWithDateAndTime(s):
    # regex pattern for date.(Works only for android. IOS Whatsapp export format is different. Will update the code soon
    pattern = '^([0-9]+)(\/)([0-9]+)(\/)([0-9][0-9]), ([0-9]+):([0-9][0-9]) (AM|PM) -'
    result = re.match(pattern, s)
    if result:
        return True
    return False

# Finds username of any given format.
def FindAuthor(s):
    patterns = [
        '([\w]+):',                        # First Name
        '([\w]+[\s]+[\w]+):',              # First Name + Last Name
        '([\w]+[\s]+[\w]+[\s]+[\w]+):',    # First Name + Middle Name + Last Name
        '([+]\d{2} \d{5} \d{5}):',         # Mobile Number (India)
        '([+]\d{2} \d{3} \d{3} \d{4}):',   # Mobile Number (US)
        '([\w]+)[\u263a-\U0001f999]+:',    # Name and Emoji
    ]
    pattern = '^' + '|'.join(patterns)
    result = re.match(pattern, s)
    if result:
        return True
    return False

def getDataPoint(line):
    splitLine = line.split(' - ')
    dateTime = splitLine[0]
    date, time = dateTime.split(', ')
    message = ' '.join(splitLine[1:])
    if FindAuthor(message):
        splitMessage = message.split(': ')
        author = splitMessage[0]
        message = ' '.join(splitMessage[1:])
    else:
        author = None
    return date, time, author, message

parsedData = [] # List to keep track of data so it can be used by a Pandas dataframe
# Upload your file here
conversationPath = '/content/WhatsApp Chat with Blabla (1).txt' # chat file
with open(conversationPath, encoding="utf-8") as fp:
    fp.readline() # Skipping first line of the file because contains information related to something about end-to-end encryption
    messageBuffer = []
    date, time, author = None, None, None
    while True:
        line = fp.readline()
        if not line:
            break
        line = line.strip()
        if startsWithDateAndTime(line):
            if len(messageBuffer) > 0:
                parsedData.append([date, time, author, ' '.join(messageBuffer)])
            messageBuffer.clear()
            date, time, author, message = getDataPoint(line)
            messageBuffer.append(message)
        else:
            messageBuffer.append(line)

df = pd.DataFrame(parsedData, columns=['Date', 'Time', 'Author', 'Message']) # Initialising a pandas Dataframe.
df["Date"] = pd.to_datetime(df["Date"])
df = df.dropna()

def split_count(text):

    emoji_list = []
    data = regex.findall(r'\X', text)
    for word in data:
        if any(char in emoji.UNICODE_EMOJI for char in word):
            emoji_list.append(word)

    return emoji_list

total_messages = df.shape[0]
media_messages = df[df['Message'] == '<Media omitted>'].shape[0]
df["emoji"] = df["Message"].apply(split_count)
emojis = sum(df['emoji'].str.len())
URLPATTERN = r'(https?://\S+)'
df['urlcount'] = df.Message.apply(lambda x: re.findall(URLPATTERN, x)).str.len()
links = np.sum(df.urlcount)
media_messages_df = df[df['Message'] == '<Media omitted>']
messages_df = df.drop(media_messages_df.index)
messages_df['Letter_Count'] = messages_df['Message'].apply(lambda s : len(s))
messages_df['Word_Count'] = messages_df['Message'].apply(lambda s : len(s.split(' ')))

# Creates a list of unique Authors - ['Manikanta', 'Teja Kura', .........]
l = messages_df.Author.unique()

for i in range(len(l)):
  # Filtering out messages of particular user
  req_df= messages_df[messages_df["Author"] == l[i]]
  # req_df will contain messages of only one particular user
  print(f'Stats of {l[i]} -')
  # shape will print number of rows which indirectly means the number of messages
  print('Messages Sent', req_df.shape[0])
  #Word_Count contains of total words in one message. Sum of all words/ Total Messages will yield words per message
  words_per_message = (np.sum(req_df['Word_Count']))/req_df.shape[0]
  print('Words per message', words_per_message)
  #media conists of media messages
  media = media_messages_df[media_messages_df['Author'] == l[i]].shape[0]
  print('Media Messages Sent', media)
  # emojis conists of total emojis
  emojis = sum(req_df['emoji'].str.len())
  print('Emojis Sent', emojis)
  #links consist of total links
  links = sum(req_df["urlcount"])
  print('Links Sent', links)
  print()
 total_emojis_list = list(set([a for b in messages_df.emoji for a in b]))
total_emojis = len(total_emojis_list)
print(total_emojis)

total_emojis_list = list([a for b in messages_df.emoji for a in b])
emoji_dict = dict(Counter(total_emojis_list))
emoji_dict = sorted(emoji_dict.items(), key=lambda x: x[1], reverse=True)
emoji_df = pd.DataFrame(emoji_dict, columns=['emoji', 'count'])
emoji_df
import plotly.express as px
fig = px.pie(emoji_df, values='count', names='emoji',
             title='Emoji Distribution')
fig.update_traces(textposition='inside', textinfo='percent+label')
fig.show()

# Creates a list of unique Authors - ['Manikanta', 'Teja Kura', .........]
l = messages_df.Author.unique()
for i in range(len(l)):
  dummy_df = messages_df[messages_df['Author'] == l[i]]
  total_emojis_list = list([a for b in dummy_df.emoji for a in b])
  emoji_dict = dict(Counter(total_emojis_list))
  emoji_dict = sorted(emoji_dict.items(), key=lambda x: x[1], reverse=True)
  print('Emoji Distribution for', l[i])
  author_emoji_df = pd.DataFrame(emoji_dict, columns=['emoji', 'count'])
  fig = px.pie(author_emoji_df, values='count', names='emoji')
  fig.update_traces(textposition='inside', textinfo='percent+label')
  fig.show()
 text = " ".join(review for review in messages_df.Message)
print ("There are {} words in all the messages.".format(len(text)))
# OUTPUT -
# There are 687467 words in all the messages.

  stopwords = set(STOPWORDS)
  stopwords.update(["ra", "ga", "na", "ani", "em", "ki", "ah","ha","la","eh","ne","le"])
  # Generate a word cloud image
  wordcloud = WordCloud(stopwords=stopwords, background_color="white").generate(text)
  # Display the generated image:
  # the matplotlib way:

  plt.figure( figsize=(10,5))
  plt.imshow(wordcloud, interpolation='bilinear')
  plt.axis("off")
  plt.show()
 date_df = messages_df.groupby("Date").sum()
date_df.reset_index(inplace=True)
fig = px.line(date_df, x="Date", y="MessageCount", title='Number of Messages as time moves on.')
fig.update_xaxes(nticks=20)
fig.show()
messages_df['Date'].value_counts().head(10).plot.barh()
plt.xlabel('Number of Messages')
plt.ylabel('Date')

def dayofweek(i):
  l = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  return l[i];
day_df=pd.DataFrame(messages_df["Message"])
day_df['day_of_date'] = messages_df['Date'].dt.weekday
day_df['day_of_date'] = day_df["day_of_date"].apply(dayofweek)
day_df["messagecount"] = 1
day = day_df.groupby("day_of_date").sum()
day.reset_index(inplace=True)

fig = px.line_polar(day, r='messagecount', theta='day_of_date', line_close=True)
fig.update_traces(fill='toself')
fig.update_layout(
  polar=dict(
    radialaxis=dict(
      visible=True,
      range=[0,6000]
    )),
  showlegend=False
)
fig.show()
messages_df['Time'].value_counts().head(10).plot.barh() plt.xlabel('Number of messages')
plt.ylabel('Time')

#https://medium.com/towards-artificial-intelligence/whatsapp-group-chat-analysis-using-python-and-plotly-89bade2bc382
#https://medium.com/swlh/how-to-create-better-ui-for-your-python-scripts-60c71924fae3
python pip install cherrypy
if __name__ == "__main__":
    import cherrypy
    import os
    class Jumbler(object):
        @cherrypy.expose
        def jumble(self, message):
            return jumble(message)
    cherrypy.config.update( {
        "server.socket_host": "0.0.0.0",
        "server.socket_port": 9090,
    } )
cherrypy.quickstart(Jumbler())
conf = {
    "/": {
        "tools.staticdir.on": True,
        "tools.staticdir.dir": os.path.dirname(os.path.abspath(__file__)),
        "tools.staticdir.index": "index.html"
    }
}
cherrypy.quickstart(Jumbler(), config=conf)
<!DOCTYPE html>
<html>
<body style="background-color: beige;">
<p>Enter your string to jumble:</p>
<input type="text" id="toJumble">
<button type="button" onclick="doJumble()">Jumble</button>
<p id="result"></p>
<script>
function doJumble() {
    var x = document.getElementById("toJumble");
    fetch("/jumble?message="+x.value).then(
        (response) => response.text().then(
            (text) => {
                let el = document.getElementById("toJumble");
                let result = el.value+" -> "+text;
                document.getElementById("result").innerHTML=result;
             }
        )
     );
}
</script>
</body>
</html>
#https://github.com/mobiusklein/ms_deisotope
import ms_deisotope
ms_deisotope.DeconvolutedPeak
from ms_deisotope import Averagine
from ms_deisotope import plot
peptide_averagine = Averagine({"C": 4.9384, "H": 7.7583, "N": 1.3577, "O": 1.4773, "S": 0.0417})
plot.draw_peaklist(peptide_averagine.isotopic_cluster(1266.321, charge=1))
#https://mobiusklein.github.io/ms_deisotope/docs/_build/html/Quickstart.html
from ms_deisotope.test.common import datafile
path = datafile("F:/SK/export/210112__solveig_AN0-(1).mzML")
reader = ms_deisotope.MSFileLoader(path)
bunch = next(reader)
bunch.precursor.is_profile
bunch.precursor.pick_peaks()
bunch.precursor.peak_set[0]
window = bunch.products[1].isolation_window
bunch.precursor.peak_set.between(window.lower_bound, window.upper_bound)
ax = bunch.annotate_precursors(nperrow=2)
#bayesian deconvolution program git clone https://github.com/michaelmarty/UniDec move unidec* folder/py scripts to lib
pip install https://download.lfd.uci.edu/pythonlibs/z4tqcw5k/numpy-1.19.5+mkl-cp38-cp38-win_amd64.whl
pip install https://download.lfd.uci.edu/pythonlibs/z4tqcw5k/scipy-1.6.0-cp38-cp38-win_amd64.whl
import unidec
file_name="210112__solveig_AN0.raw.intensityThreshold1000.PPM10.errTolDecimalPlace3.Time20210128191052.MS.txt"
folder="F:/SK/"
eng=unidec.UniDec()
eng.open_file(file_name, folder)
eng.process_data()
eng.run_unidec(silent=True)
eng.pick_peaks()
#https://labelstud.io/
pip install -U label-studio
label-studio init my_project
label-studio start my_project
#https://github.com/PRIDE-Archive/pridepy
pridepy search-protein-evidences --project_accession PXD012353
#https://alan-turing-institute.github.io/skpro/introduction.html#a-motivating-example
# Load boston housing data
X, y = load_boston(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)
# Train and predict on boston housing data using a baseline model
y_pred = DensityBaseline().fit(X_train, y_train).predict(X_test)
# Obtain the loss
loss = log_loss(y_test, y_pred, sample=True, return_std=True)
print('Loss: %f+-%f' % loss)
y_pred[0].pdf(x=42)
#conda create --name gt -c conda-forge graph-tool
#conda activate gt
#https://pypi.org/project/NiftyNet/
#pip install niftynet
#https://machinelearningmastery.com/bagging-ensemble-with-different-data-transformations/ comparison of data transform ensemble to each contributing member for regression
from numpy import mean
from numpy import std
from sklearn.datasets import make_regression
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import RepeatedKFold
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import RobustScaler
from sklearn.preprocessing import PowerTransformer
from sklearn.preprocessing import QuantileTransformer
from sklearn.preprocessing import KBinsDiscretizer
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import VotingRegressor
from sklearn.pipeline import Pipeline
from matplotlib import pyplot
# get a voting ensemble of models
def get_ensemble():
	# define the base models
	models = list()
	# normalization
	norm = Pipeline([('s', MinMaxScaler()), ('m', DecisionTreeRegressor())])
	models.append(('norm', norm))
	# standardization
	std = Pipeline([('s', StandardScaler()), ('m', DecisionTreeRegressor())])
	models.append(('std', std))
	# robust
	robust = Pipeline([('s', RobustScaler()), ('m', DecisionTreeRegressor())])
	models.append(('robust', robust))
	# power
	power = Pipeline([('s', PowerTransformer()), ('m', DecisionTreeRegressor())])
	models.append(('power', power))
	# quantile
	quant = Pipeline([('s', QuantileTransformer(n_quantiles=100, output_distribution='normal')), ('m', DecisionTreeRegressor())])
	models.append(('quant', quant))
	# kbins
	kbins = Pipeline([('s', KBinsDiscretizer(n_bins=20, encode='ordinal')), ('m', DecisionTreeRegressor())])
	models.append(('kbins', kbins))
	# define the voting ensemble
	ensemble = VotingRegressor(estimators=models)
	# return a list of tuples each with a name and model
	return models + [('ensemble', ensemble)]
# generate regression dataset
X, y = make_regression(n_samples=1000, n_features=100, n_informative=10, noise=0.1, random_state=1)
# get models
models = get_ensemble()
# evaluate each model
results = list()
for name,model in models:
	# define the evaluation method
	cv = RepeatedKFold(n_splits=10, n_repeats=3, random_state=1)
	# evaluate the model on the dataset
	n_scores = cross_val_score(model, X, y, scoring='neg_mean_absolute_error', cv=cv, n_jobs=-1)
	# report performance
	print('>%s: %.3f (%.3f)' % (name, mean(n_scores), std(n_scores)))
	results.append(n_scores)
# plot the results for comparison
pyplot.boxplot(results, labels=[n for n,_ in models], showmeans=True)
pyplot.show()
#https://blog.tensorflow.org/2020/01/hyperparameter-tuning-with-keras-tuner.html
from sklearn import ensemble
from sklearn import linear_model
def build_model(hp):
    model_type = hp.Choice('model_type', ['random_forest', 'ridge'])
    if model_type == 'random_forest':
        with hp.conditional_scope('model_type', 'random_forest'):
            model = ensemble.RandomForestClassifier(
                n_estimators=hp.Int('n_estimators', 10, 50, step=10),
                max_depth=hp.Int('max_depth', 3, 10))
    elif model_type == 'ridge':
        with hp.conditional_scope('model_type', 'ridge'):
            model = linear_model.RidgeClassifier(
                alpha=hp.Float('alpha', 1e-3, 1, sampling='log'))
    else:
        raise ValueError('Unrecognized model_type')
    return model
tuner = kt.tuners.Sklearn(
        oracle=kt.oracles.BayesianOptimization(
            objective=kt.Objective('score', 'max'),
            max_trials=10),
        hypermodel=build_model,
        directory=tmp_dir)
X, y = ...
tuner.search(X, y)
#https://levelup.gitconnected.com/python-tricks-i-can-not-live-without-87ae6aff3af8
chklist = ["a", "b", "c", "c"]
chkset = (set(chklist))
chkset.difference('a')
for i, item in enumerate(chkset, 16):print(i, item)
#http://www-connex.lip6.fr/~schwander/pyMEF/index.html
#https://github.com/khuyentran1401/Data-science
from datetime import datetime
from icecream import ic
import time
from datetime import datetime
def time_format():
    return f'{datetime.now()}|> '
ic.configureOutput(prefix=time_format,includeContext=True)
for _ in range(3):
    time.sleep(1)
    ic('42')
#https://towardsdatascience.com/10-surprisingly-useful-base-python-functions-822d86972a23
mean = lambda x : sum(x) / len(x)
import shutil
shutil.copyfile('mydatabase.db', 'archive.db')
shutil.move('/src/High.py', '/packages/High')
glob.glob('*.ipynb')
import argparse
parser = argparse.ArgumentParser(prog = 'top',description = 'Show top lines from the file')
parser.add_argument('-l', '--lines', type=int, default=10)
args = parser.parse_args()
import re
re.findall(r'\bf[a-z]*', 'which foot or hand fell fastest')
['foot', 'fell', 'fastest']
re.sub(r'(\b[a-z]+) \1', r'\1', 'cat in the the hat')
'cat in the hat'
import statistics as st
st.mean(data)
st.median(data)
st.variance(data)
from urllib.request import urlopen
data = null
with urlopen('https://fuzzylife.org/') as response: data = response
import zlib
h = " Hello, it is me, you're friend Emmett!"
print(len(h))
t = zlib.compress(h)
print(len(t))
z = decompress(t)
print(len(z))
#https://github.com/lux-org/lux
#!pip install lux-api
#!jupyter nbextension install --py luxwidget
#!jupyter nbextension enable --py luxwidget
import lux
import pandas as pd
df=pd.read_csv("L:\\promec\\HF\\Lars\\2020\\oktober\\KATHLEEN PHOSTOT SHOTGUN b\\combined\\txt-PHOScomp\\proteinGroups.txt",sep="\t",low_memory=False)
df

pip3 install fastapi
pip3 install uvicorn
pip3 install pydantic
GET request — /loggingapi/v1/logs
POST request — /loggingapi/v1/log
app = FastAPI(
    title = "Logging API",
    description = "An API for all your logging needs.",
    version = "2.0",
)
@app.get("/loggingapi/v2/logs/{appId}")
async def Logs(appId: str):
    results = storage.GetLogs(appId)
    return results
uvicorn app:app --reload
class Log(BaseModel):
    queueId: str
    message: str
    logType: str
@app.post("/loggingapi/v2/log")
async def AddLog(log: Log):
    results = storage.AddLog(log)
    return results

#https://medium.com/python-in-plain-english/abandoning-flask-for-fastapi-20105948b062
#https://github.com/Teichlab/bbknn
#!pip3 install bbknn
import bbknn
bbknn.bbknn(adata)
#https://igraph.org/python/
#!pip install python-igraph
#https://github.com/pygobject/pycairo
import cairo
with cairo.SVGSurface("example.svg", 200, 200) as surface:
    context = cairo.Context(surface)
    x, y, x1, y1 = 0.1, 0.5, 0.4, 0.9
    x2, y2, x3, y3 = 0.6, 0.1, 0.9, 0.5
    context.scale(200, 200)
    context.set_line_width(0.04)
    context.move_to(x, y)
    context.curve_to(x1, y1, x2, y2, x3, y3)
    context.stroke()
    context.set_source_rgba(1, 0.2, 0.2, 0.6)
    context.set_line_width(0.02)
    context.move_to(x, y)
    context.line_to(x1, y1)
    context.move_to(x2, y2)
    context.line_to(x3, y3)
    context.stroke()
from igraph import *
import igraph
print(igraph.__version__)
g = igraph.Graph([(0,1), (0,2), (2,3), (3,4), (4,2), (2,5), (5,0), (6,3), (5,6)])
g.vs["name"] = ["Alice", "Bob", "Claire", "Dennis", "Esther", "Frank", "George"]
g.vs["age"] = [25, 31, 18, 47, 22, 23, 50]
g.vs["gender"] = ["f", "m", "f", "m", "f", "m", "m"]
g.es["is_formal"] = [False, False, True, True, True, False, True, False, False]
g.es[0]["is_formal"] = True
g["date"] = "2009-01-10"
g.vs[3]["foo"] = "bar"
del g.vs["foo"]
g.degree()
g.edge_betweenness()
ebs = g.edge_betweenness()
max_eb = max(ebs)
[g.es[idx].tuple for idx, eb in enumerate(ebs) if eb == max_eb]
g.vs.degree()
g.es.edge_betweenness()
g.vs.select(_degree = g.maxdegree())["name"]
g.vs.find(name="Claire").degree()
g.get_adjacency()
layout = g.layout("kamada_kawai")
plot(g, layout = layout)
#layout = g.layout_reingold_tilford(root=[2])

#https://ml.dask.org/cross_validation.html
#!python -m pip install "dask[dataframe]" --upgrade
import dask.array as da
#!pip install dask-ml
from dask_ml.datasets import make_regression
from dask_ml.model_selection import train_test_split
X, y = make_regression(n_samples=125, n_features=4, random_state=0, chunks=50)
X_train, X_test, y_train, y_test = train_test_split(X, y)
X_train.compute()[:3]
#https://ml.dask.org/hyper-parameter-search.html#hyperparameter-incremental
from dask_ml.datasets import make_classification
from dask_ml.model_selection import train_test_split
import dask.dataframe as dd
from distributed import Client
client = Client()
X, y = make_classification(chunks=20, random_state=0)
X_train, X_test, y_train, y_test = train_test_split(X, y)
from sklearn.linear_model import SGDClassifier
clf = SGDClassifier(tol=1e-3, penalty='elasticnet', random_state=0)
from scipy.stats import uniform, loguniform
params = {'alpha': loguniform(1e-2, 1e0),  # or np.logspace
          'l1_ratio': uniform(0, 1)}  # or np.linspace
from dask_ml.model_selection import HyperbandSearchCV
search = HyperbandSearchCV(clf, params, max_iter=81, random_state=0)
search.fit(X_train, y_train, classes=[0, 1]);

search.best_params_
Out[14]: {'alpha': 0.12449062586158535, 'l1_ratio': 0.7040486849393368}

search.best_score_
Out[15]: 0.65

search.score(X_test, y_test)
Out[16]: 0.3
Note that when you do post-fit tasks like search.score, the underlying model’s score method is used. If that is unable to handle a larger-than-memory Dask Array, you’ll exhaust your machines memory. If you plan to use post-estimation features like scoring or prediction, we recommend using dask_ml.wrappers.ParallelPostFit.

from dask_ml.wrappers import ParallelPostFit

params = {'estimator__alpha': loguniform(1e-2, 1e0),
          'estimator__l1_ratio': uniform(0, 1)}


est = ParallelPostFit(SGDClassifier(tol=1e-3, random_state=0))

search = HyperbandSearchCV(est, params, max_iter=9, random_state=0)

search.fit(X_train, y_train, classes=[0, 1]);

search.score(X_test, y_test)
Out[22]: 0.6
#https://metagenome-atlas.github.io/
#VIDEO https://asciinema.org/a/337467
#github
ldd /bin/bash
export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu
wget https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
sh -u Anaconda3-5.3.1-Linux-x86_64.sh
conda create --name py36 python=3.6
conda activate py36
conda install -y -c bioconda -c conda-forge metagenome-atlas
module load Python/3.6.6-intel-2018b
pip install snakemake --user
pip install click --user
pip install pandas --user
pip install metagenome-atlas --user
$HOME/.local/bin/atlas
  16
    atlas init --db-dir databases path/to/fastq/files
    atlas run all

#https://towardsdatascience.com/pca-using-python-scikit-learn-e653f8989e60
import pandas as pd
url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
# load dataset into Pandas DataFrame
df = pd.read_csv(url, names=['sepal length','sepal width','petal length','petal width','target'])
from sklearn.preprocessing import StandardScaler
features = ['sepal length', 'sepal width', 'petal length', 'petal width']
# Separating out the features
x = df.loc[:, features].values
# Separating out the target
y = df.loc[:,['target']].values
# Standardizing the features
x = StandardScaler().fit_transform(x)
from sklearn.decomposition import PCA
pca = PCA(n_components=2)
principalComponents = pca.fit_transform(x)
principalDf = pd.DataFrame(data = principalComponents
             , columns = ['principal component 1', 'principal component 2'])
finalDf = pd.concat([principalDf, df[['target']]], axis = 1)
import matplotlib.pyplot as plt
fig = plt.figure(figsize = (8,8))
ax = fig.add_subplot(1,1,1)
ax.set_xlabel('Principal Component 1', fontsize = 15)
ax.set_ylabel('Principal Component 2', fontsize = 15)
ax.set_title('2 component PCA', fontsize = 20)
targets = ['Iris-setosa', 'Iris-versicolor', 'Iris-virginica']
colors = ['r', 'g', 'b']
for target, color in zip(targets,colors):
    indicesToKeep = finalDf['target'] == target
    ax.scatter(finalDf.loc[indicesToKeep, 'principal component 1']
               , finalDf.loc[indicesToKeep, 'principal component 2']
               , c = color
               , s = 50)
ax.legend(targets)
ax.grid()
plt.show()
pca.explained_variance_ratio_
from sklearn.datasets import fetch_openml
mnist = fetch_openml('mnist_784')
from sklearn.model_selection import train_test_split
# test_size: what proportion of original data is used for test set
train_img, test_img, train_lbl, test_lbl = train_test_split( mnist.data, mnist.target, test_size=1/7.0, random_state=0)
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
# Fit on training set only.
scaler.fit(train_img)
# Apply transform to both the training set and the test set.
train_img = scaler.transform(train_img)
test_img = scaler.transform(test_img)
from sklearn.decomposition import PCA
# Make an instance of the Model
pca = PCA(.95)
pca.fit(train_img)
train_img = pca.transform(train_img)
test_img = pca.transform(test_img)
from sklearn.linear_model import LogisticRegression
# all parameters not specified are set to their defaults
# default solver is incredibly slow which is why it was changed to 'lbfgs'
logisticRegr = LogisticRegression(solver = 'lbfgs')
logisticRegr.fit(train_img, train_lbl)
# Predict for One Observation (image)
logisticRegr.predict(test_img[0].reshape(1,-1))
# Predict for One Observation (image)
logisticRegr.predict(test_img[0:10])
logisticRegr.score(test_img, test_lbl)


#https://github.com/interpretml/interpret
#!pip install interpret
#https://nbviewer.jupyter.org/github/interpretml/interpret/blob/master/examples/python/notebooks/Interpretable%20Classification%20Methods.ipynb
import pandas as pd
from sklearn.model_selection import train_test_split
df = pd.read_csv(
    "https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data",
    header=None)
df.columns = [
    "Age", "WorkClass", "fnlwgt", "Education", "EducationNum",
    "MaritalStatus", "Occupation", "Relationship", "Race", "Gender",
    "CapitalGain", "CapitalLoss", "HoursPerWeek", "NativeCountry", "Income"
]
# df = df.sample(frac=0.1, random_state=1)
train_cols = df.columns[0:-1]
label = df.columns[-1]
X = df[train_cols]
y = df[label].apply(lambda x: 0 if x == " <=50K" else 1) #Turning response into 0 and 1
seed = 1
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20, random_state=seed)
from interpret.glassbox import ExplainableBoostingClassifier
ebm = ExplainableBoostingClassifier()
ebm.fit(X_train, y_train)
from interpret import show
ebm_global = ebm.explain_global()
show(ebm_global)
ebm_local = ebm.explain_local(X_test, y_test)
show(ebm_local)
show([logistic_regression, decision_tree])
#https://docs.seldon.io/projects/alibi/en/latest/methods/ALE.html
from alibi.explainers import ALE
ale = ALE(predict_fn, feature_names=feature_names, target_names=target_names)
#Following the initialization, we can immediately produce an explanation given a dataset of instances X:
exp = ale.explain(X)
#https://towardsdatascience.com/how-to-make-stunning-interactive-maps-with-python-and-folium-in-minutes-e3aff3b0ed43
#!pip install folium
#!wget https://www.betterdatascience.com/wp-content/uploads/2020/12/quakes.csv
import pandas as pd
df = pd.read_csv('quakes.csv')
df.head()
import folium
quake_map = folium.Map(
    location=[-16.495477, 174.9663341],
    zoom_start=6,
    width=1024,
    height=600
)
quake_map
quake_map = folium.Map(
    location=[-16.495477, 174.9663341],
    zoom_start=6,
    tiles='Stamen Terrain',
    width=1024,
    height=600
)
quake_map
quake_map = folium.Map(
    location=[-16.495477, 174.9663341],
    zoom_start=5,
    tiles='Stamen Terrain',
    width=1024,
    height=600
)
for _, row in df.iterrows():
    folium.CircleMarker(
        location=[row['lat'], row['long']]
    ).add_to(quake_map)

quake_map
def generate_color(magnitude):
    if magnitude <= 5:
        c_outline, c_fill = '#ffda79', '#ffda79'
        m_opacity, f_opacity = 0.2, 0.1
    else:
        c_outline, c_fill = '#c0392b', '#e74c3c'
        m_opacity, f_opacity = 1, 1
    return c_outline, c_fill, m_opacity, f_opacity


quake_map = folium.Map(
    location=[-16.495477, 174.9663341],
    zoom_start=5,
    tiles='Stamen Terrain',
    width=1024,
    height=600
)

for _, row in df.iterrows():
    c_outline, c_fill, m_opacity, f_opacity = generate_color(row['mag'])
    folium.CircleMarker(
        location=[row['lat'], row['long']],
        color=c_outline,
        fill=True,
        fillColor=c_fill,
        opacity=m_opacity,
        fillOpacity=f_opacity,
        radius=(row['mag'] ** 2) / 3
    ).add_to(quake_map)

quake_map
def generate_color(magnitude):
    if magnitude <= 5:
        c_outline, c_fill = '#ffda79', '#ffda79'
        m_opacity, f_opacity = 0.2, 0.1
    else:
        c_outline, c_fill = '#c0392b', '#e74c3c'
        m_opacity, f_opacity = 1, 1
    return c_outline, c_fill, m_opacity, f_opacity

def generate_popup(magnitude, depth):
    return f'''<strong>Magnitude:</strong> {magnitude}<br><strong>Depth:</strong> {depth} km'''


quake_map = folium.Map(
    location=[-16.495477, 174.9663341],
    zoom_start=5,
    tiles='Stamen Terrain',
    width=1024,
    height=600
)

for _, row in df.iterrows():
    c_outline, c_fill, m_opacity, f_opacity = generate_color(row['mag'])
    folium.CircleMarker(
        location=[row['lat'], row['long']],
        popup=generate_popup(row['mag'], row['depth']),
        color=c_outline,
        fill=True,
        fillColor=c_fill,
        opacity=m_opacity,
        fillOpacity=f_opacity,
        radius=(row['mag'] ** 2) / 3
    ).add_to(quake_map)

quake_map

#https://github.com/slundberg/shap
import sklearn
!pip install shap
import shap
from sklearn.model_selection import train_test_split
# print the JS visualization code to the notebook
shap.initjs()
# train a SVM classifier
X_train,X_test,Y_train,Y_test = train_test_split(*shap.datasets.iris(), test_size=0.2, random_state=0)
svm = sklearn.svm.SVC(kernel='rbf', probability=True)
svm.fit(X_train, Y_train)
# use Kernel SHAP to explain test set predictions
explainer = shap.KernelExplainer(svm.predict_proba, X_train, link="logit")
shap_values = explainer.shap_values(X_test, nsamples=100)

# plot the SHAP values for the Setosa output of the first instance
shap.force_plot(explainer.expected_value[0], shap_values[0][0,:], X_test.iloc[0,:], link="logit")
# plot the SHAP values for the Setosa output of all instances
shap.force_plot(explainer.expected_value[0], shap_values[0], X_test, link="logit")

#https://www.kaggle.com/dark06thunder/credit-card-dataset https://www.youtube.com/watch?v=H9wYemw-ZAI
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
df = pd.read_csv('credit_dataset.csv')
df.head()
ax = df['TARGET'].value_counts().plot(kind='bar', figsize=(10, 6), fontsize=13, color='#087E8B')
ax.set_title('Credit card fraud (0 = normal, 1 = fraud)', size=20, pad=30)
ax.set_ylabel('Number of transactions', fontsize=14)
for i in ax.patches:    ax.text(i.get_x() + 0.19, i.get_height() + 700, str(round(i.get_height(), 2)), fontsize=15)
# Remap to integers
df['GENDER'] = [0 if x == 'M' else 1 for x in df['GENDER']]
df['CAR'] = [1 if x == 'Y' else 0 for x in df['CAR']]
df['REALITY'] = [1 if x == 'Y' else 0 for x in df['REALITY']]
# Create dummy variables
dummy_income_type = pd.get_dummies(df['INCOME_TYPE'], prefix='INC_TYPE', drop_first=True)
dummy_edu_type = pd.get_dummies(df['EDUCATION_TYPE'], prefix='EDU_TYPE', drop_first=True)
dummy_family_type = pd.get_dummies(df['FAMILY_TYPE'], prefix='FAM_TYPE', drop_first=True)
dummy_house_type = pd.get_dummies(df['HOUSE_TYPE'], prefix='HOUSE_TYPE', drop_first=True)
# Drop unnecessary columns
to_drop = ['Unnamed: 0', 'ID', 'FLAG_MOBIL', 'INCOME_TYPE','EDUCATION_TYPE', 'FAMILY_TYPE', 'HOUSE_TYPE']
df.drop(to_drop, axis=1, inplace=True)
# Merge into a single data frame
merged = pd.concat([df, dummy_income_type, dummy_edu_type, dummy_family_type, dummy_house_type], axis=1)
merged.head()
from sklearn.preprocessing import MinMaxScaler
# Scale only columns that have values greater than 1
to_scale = [col for col in df.columns if df[col].max() > 1]
mms = MinMaxScaler()
scaled = mms.fit_transform(merged[to_scale])
scaled = pd.DataFrame(scaled, columns=to_scale)
# Replace original columns with scaled ones
for col in scaled:    merged[col] = scaled[col]
merged.head()
from sklearn.model_selection import train_test_split
X = merged.drop('TARGET', axis=1)
y = merged['TARGET']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)
print(f'''% Positive class in Train = {np.round(y_train.value_counts(normalize=True)[1] * 100, 2)}% Positive class in Test  = {np.round(y_test.value_counts(normalize=True)[1] * 100, 2)}''')
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, recall_score, confusion_matrix
# Train
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)
preds = model.predict(X_test)
# Evaluate
print(f'Accuracy = {accuracy_score(y_test, preds):.2f}\nRecall = {recall_score(y_test, preds):.2f}\n')
cm = confusion_matrix(y_test, preds)
plt.figure(figsize=(8, 6))
plt.title('Confusion Matrix (without SMOTE)', size=16)
sns.heatmap(cm, annot=True, cmap='Blues');
#https://towardsdatascience.com/how-to-effortlessly-handle-class-imbalance-with-python-and-smote-9b715ca8e5a7
#!pip install imbalanced-learn
from imblearn.over_sampling import SMOTE
sm = SMOTE(random_state=42)
X_sm, y_sm = sm.fit_resample(X, y)
print(f'''Shape of X before SMOTE: {X.shape} Shape of X after SMOTE: {X_sm.shape}''')
print('\nBalance of positive and negative classes (%):')
y_sm.value_counts(normalize=True) * 100
X_train, X_test, y_train, y_test = train_test_split(X_sm, y_sm, test_size=0.25, random_state=42)
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)
preds = model.predict(X_test)
print(f'Accuracy = {accuracy_score(y_test, preds):.2f}\nRecall = {recall_score(y_test, preds):.2f}\n')
cm = confusion_matrix(y_test, preds)
plt.figure(figsize=(8, 6))
plt.title('Confusion Matrix (with SMOTE)', size=16)
sns.heatmap(cm, annot=True, cmap='Blues');

#FFT https://www.youtube.com/watch?v=h7apO7q16V0&t=523s

#https://medium.com/swlh/the-fractal-indicator-detecting-tops-bottoms-in-markets-1d8aac0269e8
def fractal_indicator(Data, high, low, ema_lookback, min_max_lookback, where):
    Data = ema(Data, 2, ema_lookback, high, where)
    Data = ema(Data, 2, ema_lookback, low, where + 1)
    Data = volatility(Data, ema_lookback, high, where + 2)
    Data = volatility(Data, ema_lookback, low, where + 3)
    Data[:, where + 4] = Data[:, high] - Data[:, where]
    Data[:, where + 5] = Data[:, low]  - Data[:, where + 1]
    for i in range(len(Data)):
        try:
            Data[i, where + 6] = max(Data[i - min_max_lookback + 1:i + 1, where + 4])
        except ValueError:
            pass
    for i in range(len(Data)):
        try:
            Data[i, where + 7] = min(Data[i - min_max_lookback + 1:i + 1, where + 5])
        except ValueError:
            pass
    Data[:, where + 8] =  (Data[:, where +  2] + Data[:, where +  3]) / 2
    Data[:, where + 9] = (Data[:, where + 6] - Data[:, where + 7]) / Data[:, where + 8]
    return Data
#Fractal Indicator is simply a reformed version of the Rescaled Range formula created by Harold Hurst.
def adder(Data, times):

    for i in range(1, times + 1):

        z = np.zeros((len(Data), 1), dtype = float)
        Data = np.append(Data, z, axis = 1)
return Data
#Every time the Fractal Indicator reaches the 1.00 threshold while the market price has been trending downwards, we can expect that there will be a structural break in the market price, i.e. a short-term reversal to the upside. We should initiate a long position. Every time the Fractal Indicator reaches the 1.00 threshold while the market price has been trending upwards, we can expect that there will be a structural break in the market price, i.e. a short-term reversal to the downside. We should initiate a short position.
trend = 10
def signal(Data, what, closing, buy, sell):

    for i in range(len(Data)):

     if Data[i, what] < barrier and Data[i, closing] < Data[i - trend, closing]:
        Data[i, buy] = 1

     if Data[i, what] < barrier and Data[i, closing] > Data[i - trend, closing]:
        Data[i, sell] = -1
# The trend variable is the algorithm's way to see whether the market price has been trending down or up. This is to known what position to initiate (long/short) as the Fractal Indicator only shows a uniform signal which is the event of reaching 1.00
# The Data variable refers to the OHLC array
# The what variable refers to the Fractal Indicator
# The closing variable refers to the closing price
# The buy variable refers to where we should place long orders
# The sell variable refers to where we should place short orders
#institutional bid/ask spreads, it may be possible to lower the costs such as that a systematic medium-frequency strategy starts being very profitable

#https://towardsdatascience.com/introduction-to-plotnine-as-the-alternative-of-data-visualization-package-in-python-46011ebef7fe
# Dataframe manipulation
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
plt.style.use('ggplot')
# Data visualization with plotnine pip install plotnine
from plotnine import *
import plotnine
plt.figure(figsize = (6.4,4.8))
full_data = pd.read_csv('L:/promec/USERS/MarianneNymark/20200108_15-samples/QE/combined/txt/allPeptides.txtDP.csv')
print('Dimension of full data:\n{}'.format(len(full_data)),'rows and {}'.format(len(full_data.columns)),'columns')
full_data.head()
full_data['Age']=full_data['Score']
# Create a histogram
(
    ggplot(data = full_data[full_data['Age'].isna() == False])+
    geom_histogram(aes(x = 'Age'),
                   fill = '#c22d6d',
                   bins = 20)+  # Set number of bin
    labs(title = 'Histogram of Athlete Age',
         subtitle = '1896 - 2016')+
    xlab('Age')+
    ylab('Frequency')+
    theme_bw()
)
full_data['NOC']=full_data['Mass Difference']
full_data['Year']=full_data['PEP']
full_data['Medal']=full_data['Cluster Index']
medal_noc = pd.crosstab([full_data['Year'], full_data['NOC']], full_data[' file'], margins = True).reset_index()
medal_noc.columns.name = None
medal_noc = medal_noc.drop([medal_noc.shape[0] - 1], axis = 0)
medal_noc
# 2 General champion
medal_noc_year = medal_noc.loc[medal_noc.groupby('Year')['All'].idxmax()].sort_values('Year')
medal_noc_year
# Create a time series plot
(
    ggplot(data = medal_noc_year)+
    geom_area(aes(x = 'Year',
                  y = '200108_Nymark_FTSY5-I',
                  group = 1),
              size = 1,
              fill = '#FFD700',
              alpha = 0.7)+
    geom_area(aes(x = 'Year',
                  y = '200108_Nymark_FTSY5-II',
                  group = 1),
              size = 1,
              fill = '#C0C0C0',
              alpha = 0.8)+
    geom_area(aes(x = 'Year',
                  y = '200108_Nymark_FTSY5-III',
                  group = 1),
              size = 1,
              fill = '#cd7f32',
              alpha = 0.8)+
    scale_x_discrete(breaks = range(1890,2020,10))+
    labs(title = 'Area Chart of Medals Acquisition',
         subtitle = '1896 - 2016')+
    xlab('Year')+
    ylab('Frequency')+
    theme_bw()
)
medal_noc_count = pd.DataFrame(medal_noc_year['NOC'].value_counts()).reset_index()
medal_noc_count.columns = ['NOC','Count']
medal_noc_count
# Create a bar plot
(
    ggplot(data = medal_noc_count)+
    geom_bar(aes(x = 'NOC',
                 y = 'Count'),
             fill = np.where(medal_noc_count['NOC'] == 'USA', '#c22d6d', '#80797c'),
             stat = 'identity')+
    geom_text(aes(x = 'NOC',
                  y = 'Count',
                  label = 'Count'),
              nudge_y = 0.7)+
    labs(title = 'Bar plot of Countries that Won Olympics',
         subtitle = '1896 - 2016')+
    xlab('Country')+
    ylab('Frequency')+
    scale_x_discrete(limits = medal_noc_count['NOC'].tolist())+
    theme_bw()
)
# Data manipulation before making bar plot
# Top five sport of USA
# 1 Cross tabulation of medals
medal_sport = pd.crosstab([full_data['Year'], full_data['NOC'], full_data['Sport']], full_data['Medal'], margins=True).drop(index='All', axis=0).reset_index()
medal_sport
# 2 Cross tabulation of medals in sports
medal_sport_usa = medal_sport[medal_sport['NOC'] == 'USA']
medal_sport_usa_count = medal_sport_usa.groupby('Sport')['All'].count().reset_index()
medal_sport_usa_count_10 = medal_sport_usa_count.sort_values('All', ascending=False).head(10)
medal_sport_usa_count_10
# Create a bar plot
(
    ggplot(data = medal_sport_usa_count_10)+
    geom_bar(aes(x = 'Sport',
                 y = 'All',
                 width = 0.6),
             fill = np.where(medal_sport_usa_count_10['Sport'] == 'Figure Skating', '#c22d6d', '#80797c'),
             stat = 'identity')+
    geom_text(aes(x = 'Sport',
                  y = 'All',
                  label = 'All'),
              nudge_y = 0.9)+
    labs(title = 'Bar plot of Top Ten Sport Won by USA',
         subtitle = '1896 - 2016')+
    xlab('Sport')+
    ylab('Frequency')+
  scale_x_discrete(limits = medal_sport_usa_count_10['Sport'].tolist()[::-1])+
    theme_bw()+
    coord_flip()
)
# Data manipulation
data_usa_urs = full_data[full_data['NOC'].isin(['USA','URS'])]
data_usa_urs = data_usa_urs[data_usa_urs['Age'].isna() == False].reset_index(drop = True)
# Create a box plot
(
    ggplot(data = data_usa_urs)+
    geom_boxplot(aes(x = 'NOC',
                     y = 'Age'),
                     fill = '#c22d6d',
                 show_legend = False)+
    labs(title = 'Box and Whisker plot of Age',
         subtitle = '1896 - 2016')+
    xlab('Country')+
    ylab('Age')+
    coord_flip()+
    theme_bw()
)
# Data manipulation before making pie chart
# Dominant season
# 1 Select the majority season each year
data_season_year = pd.crosstab(full_data['Year'], full_data['Season']).reset_index()
data_season_year.columns.name = None
data_season_year['Status'] = ['Summer' if data_season_year.loc[i,'Summer'] > data_season_year.loc[i,'Winter'] else 'Winter' for i in range(len(data_season_year))]
data_season_year
# 2 Dominant season each year
dominant_season = data_season_year.groupby('Status')['Year'].count().reset_index()
dominant_season
# Customize colors and other settings
colors = ['#c22d6d','#80797c']
explode = (0.1,0) # Explode 1st slice
# Create a pie chart
plt.pie(dominant_season['Year'], explode = explode, labels = dominant_season['Status'], colors = colors, autopct = '%1.1f%%', shadow = False, startangle = 140)
plt.title('Piechart of Dominant Season') # Title
plt.axis('equal')
plt.show()
# Data manipulation before making time series plot
left = medal_noc_year[medal_noc_year['NOC'] == 'USA']
right = data_season_year
data_season_usa = left.merge(right, on='Year', how='left')
data_season_usa
# Create a time series plot
(
    ggplot(data = data_season_usa)+
    geom_line(aes(x = 'Year',
                  y = 'All',
                  group = 1),
              size = 1.5,
              color = '#c22d6d')+
    geom_point(aes(x = 'Year',
                   y = 'All',
                   group = 1),
               size = 3,
               color = '#000000')+
    geom_text(aes(x = 'Year',
                  y = 'All',
                  label = 'All'),
              nudge_x = 0.35,
              nudge_y = 10)+
    scale_x_discrete(breaks = range(1900,2020,10))+
    labs(title = 'Line Chart of Medals Acquisition (USA)',
         subtitle = '1896 - 2016')+
    xlab('Year')+
    ylab('Frequency')+
    theme_bw()
)
# Data manipulation before making scatter plot
# 1 Select the majority season each year
data_medals = full_data[full_data['Medal'].notna()]
left = data_medals[(data_medals['NOC'] == 'USA') & (data_medals['Medal'].notna())].groupby('Year')['Sport'].nunique().reset_index()
right = medal_noc[medal_noc['NOC'] == 'USA']
sport_medal_usa = left.merge(right, on = 'Year', how = 'left')
sport_medal_usa
corr_sport_all = np.corrcoef(sport_medal_usa['Sport'], sport_medal_usa['All'])[0,1]
# Print status
print('Pearson correlation between number of sport and total of medals is {}'.format(round(corr_sport_all,3)))
# Create a scatter plot
(
    ggplot(data = sport_medal_usa)+
    geom_point(aes(x = sport_medal_usa['Sport'],
                   y = sport_medal_usa['All'],
                   size = sport_medal_usa['All']),
               fill = '#c22d6d',
               color = '#c22d6d',
               show_legend = True)+
    labs(title = 'Scatterplot Number of Sport and Total of Medals',
         subtitle = '1896 - 2016')+
    xlab('Number of Sport')+
    ylab('Total of Medals')+
    theme_bw()
)
# Data manipulation before making box and whisker plot
data_usa_urs['Medal'] = data_usa_urs['Medal'].astype('category')
data_usa_urs['Medal'] = data_usa_urs['Medal'].cat.reorder_categories(['Gold', 'Silver', 'Bronze'])
data_usa_urs
# Create a box and whisker plot
(
    ggplot(data = data_usa_urs[data_usa_urs['Medal'].isna() == False])+
    geom_boxplot(aes(x = 'NOC',
                     y = 'Age'),
                 fill = '#c22d6d')+
    labs(title = 'Box and Whisker plot of Age',
         subtitle = '1896 - 2016')+
    xlab('Country')+
    ylab('Age')+
    theme_bw()+
    facet_grid('. ~ Medal')
)

#https://gist.githubusercontent.com/SajidLhessani/28b1a87351964ba5f310c5acf87204d5/raw/52b1aab88fe3555f78bfe7461c392738e5f9708e/full_live_graph.py
#https://www.youtube.com/watch?v=95MZRSOccEg&feature=emb_title
import numpy as np
import pandas as pd
#Data Source pip install yfinance
import yfinance as yf
#Data viz
import plotly.graph_objs as go
data = yf.download(tickers='SPY', period='1d', interval='1m')
#Interval required 1 minute
data['Middle Band'] = data['Close'].rolling(window=21).mean()
data['Upper Band'] = data['Middle Band'] + 1.96*data['Close'].rolling(window=21).std()
data['Lower Band'] = data['Middle Band'] - 1.96*data['Close'].rolling(window=21).std()
#declare figure
fig = go.Figure()
fig.add_trace(go.Scatter(x=data.index, y= data['Middle Band'],line=dict(color='blue', width=.7), name = 'Middle Band'))
fig.add_trace(go.Scatter(x=data.index, y= data['Upper Band'],line=dict(color='red', width=1.5), name = 'Upper Band (Sell)'))
fig.add_trace(go.Scatter(x=data.index, y= data['Lower Band'],line=dict(color='green', width=1.5), name = 'Lower Band (Buy)'))
#Candlestick
fig.add_trace(go.Candlestick(x=data.index,
                open=data['Open'],
                high=data['High'],
                low=data['Low'],
                close=data['Close'], name = 'market data'))
# Add titles
fig.update_layout(
    title='SPY live share price evolution',
    yaxis_title='Stock Price (USD per Shares)')
# X-Axes
fig.update_xaxes(
    rangeslider_visible=True,
    rangeselector=dict(
        buttons=list([
            dict(count=15, label="15m", step="minute", stepmode="backward"),
            dict(count=45, label="45m", step="minute", stepmode="backward"),
            dict(count=1, label="HTD", step="hour", stepmode="todate"),
            dict(count=3, label="3h", step="hour", stepmode="backward"),
            dict(step="all")
        ])
    )
)
#Show
fig.show()

#https://towardsdatascience.com/scientific-python-with-lambda-b207b1ddfcd1
x = [5,10,15]
f = lambda x : [z + 5 for z in x]
print(f(x))
#[10, 15, 20]
f = lambda x, y : [w + i for w, i in zip(x, y)]
from numpy import mean,std
norm = lambda x : [(i-mean(x)) / std(x) for i in xt]
norm(x)
#code https://towardsdatascience.com/sqlalchemy-python-tutorial-79a577141a91
#data https://github.com/animesh/datacamp/blob/master/census.sqlite?raw=true
#check https://sqlite.org/cli.html
#pip install sqlalchemy
import sqlalchemy as db
engine = db.create_engine('sqlite:///C:\\Users\\animeshs\\GD\\scripts\\census.sqlite')
connection = engine.connect()
metadata = db.MetaData()
census = db.Table('census', metadata, autoload=True, autoload_with=engine)
print(census.columns.keys())
print(repr(metadata.tables['census']))
query = db.select([census])
ResultProxy = connection.execute(query)
ResultSet = ResultProxy.fetchall()
ResultSet[:3]
#Equivalent to 'SELECT * FROM census'
while flag:
    partial_results = ResultProxy.fetchmany(50)
    if(partial_results == []):
	flag = False
ResultProxy.close()
female_pop = db.func.sum(db.case([(census.columns.sex == 'F', census.columns.pop2000)],else_=0))
query = db.select([female_pop/total_pop * 100])
total_pop = db.cast(db.func.sum(census.columns.pop2000), db.Float)
result = connection.execute(query).scalar()
print(result)#51.09467432293413v51.09467432293413
state_fact = db.Table('state_fact', metadata, autoload=True, autoload_with=engine)
query = db.select([census.columns.pop2008, state_fact.columns.abbreviation])
results = connection.execute(query).fetchall()
df = pd.DataFrame(results)
df.columns = results[0].keys()
df.head(5)
sql = "SELECT * FROM census;"
df = pd.read_sql_query(sql, engine)#.set_index('index')
# shuffle dataset, preserving index
df.sample(6)

#sql = "SELECT TOP 1 * FROM census ORDER BY newid()"
#https://stackoverflow.com/a/1253576
sql = "SELECT * FROM census ORDER BY RANDOM() limit 6"
pd.read_sql_query(sql, engine)#.set_index('index')
# shuffle dataset, preserving index
dfSample = df.sample(5)

engine = db.create_engine('sqlite:///test.sqlite') #Create test.sqlite automatically
connection = engine.connect()
metadata = db.MetaData()
emp = db.Table('emp', metadata,
              db.Column('Id', db.Integer()),
              db.Column('name', db.String(255), nullable=False),
              db.Column('salary', db.Float(), default=100.0),
              db.Column('active', db.Boolean(), default=True)
              )
metadata.create_all(engine) #Creates the table
#Inserting record one by one
query = db.insert(emp).values(Id=1, name='naveen', salary=60000.00, active=True)
ResultProxy = connection.execute(query)
In [ ]:
#Inserting many records at ones
query = db.insert(emp)
values_list = [{'Id':'2', 'name':'ram', 'salary':80000, 'active':False},
               {'Id':'3', 'name':'ramesh', 'salary':70000, 'active':True}]
ResultProxy = connection.execute(query,values_list)
In [43]:
results = connection.execute(db.select([emp])).fetchall()
df = pd.DataFrame(results)
df.columns = results[0].keys()
df.head(4)

train_frac = 0.9
test_frac = 1 - train_frac

trn_cutoff = int(len(df) * train_frac)

df_trn = df[:trn_cutoff]
df_tst = df[trn_cutoff:]

df_trn.to_sql('trn_set', engine, if_exists='replace')
df_tst.to_sql('tst_set', engine, if_exists='replace')

df_online = pd.read_csv("data/online.csv")
df_online.to_sql('Online', engine, if_exists='replace')

df_order = pd.read_csv("data/Order.csv")
df_order.to_sql('Purchase', engine, if_exists='replace')
#select count(*) from trn_set;
#select count(*) from tst_set;
#select count(*) from tst_set;select * from trn_set limit 5;
USE Shutterfly;

DROP TABLE IF EXISTS features_group_1;

CREATE TABLE IF NOT EXISTS features_group_1
SELECT o.index
  ,LEFT(o.dt, 10) AS day
  ,COUNT(*) AS order_count
  ,SUM(p.revenue) AS revenue_sum
  ,MAX(p.revenue) AS revenue_max
  ,MIN(p.revenue) AS revenue_min
  ,SUM(p.revenue) / COUNT(*) AS rev_p_order
  ,COUNT(p.prodcat1) AS prodcat1_count
  ,COUNT(p.prodcat2) AS prodcat2_count
  ,DATEDIFF(o.dt, MAX(p.orderdate)) AS days_last_order
  ,DATEDIFF(o.dt, MAX(CASE WHEN p.prodcat1 IS NOT NULL THEN p.orderdate ELSE NULL END)) AS days_last_prodcat1
  ,DATEDIFF(o.dt, MAX(CASE WHEN p.prodcat2 IS NOT NULL THEN p.orderdate ELSE NULL END)) AS days_last_prodcat2
  ,SUM(p.prodcat1 = 1) AS prodcat1_1_count
  ,SUM(p.prodcat1 = 2) AS prodcat1_2_count
  ,SUM(p.prodcat1 = 3) AS prodcat1_3_count
  ,SUM(p.prodcat1 = 4) AS prodcat1_4_count
  ,SUM(p.prodcat1 = 5) AS prodcat1_5_count
  ,SUM(p.prodcat1 = 6) AS prodcat1_6_count
  ,SUM(p.prodcat1 = 7) AS prodcat1_7_count
FROM Online AS o
JOIN Purchase AS p
  ON o.custno = p.custno
  AND p.orderdate <= o.dt
GROUP BY o.index;

ALTER TABLE `features_group_1`
  ADD KEY `ix_features_group_1_index` (`index`);
#show tables;
def load_dataset(split="trn_set", limit=None, ignore_categorical=False):
    sql = """
    SELECT o.*, f1.*, f2.*, f3.*, f4.*,
    EXTRACT(MONTH FROM o.dt) AS month
    FROM %s AS t
    JOIN Online AS o
        ON t.index = o.index
    JOIN features_group_1 AS f1
        ON t.index = f1.index
    JOIN features_group_2 AS f2
        ON t.index = f2.index
    JOIN features_group_3 AS f3
        ON t.index = f3.index
    JOIN features_group_4 AS f4
        ON t.index = f4.index
    """%split
    if limit:
        sql += " LIMIT %i"%limit

    df = pd.read_sql_query(sql.replace('\n', " ").replace("\t", " "), engine)
    df.event1 = df.event1.fillna(0)
    X = df.drop(["index", "event2", "dt", "day", "session", "visitor", "custno"], axis=1)
    Y = df.event2
    return X, Y
#https://www.tensorflow.org/probability/examples/Modeling_with_JointDistribution
import numpy as np
import tensorflow.compat.v2 as tf
import tensorflow_probability as tfp
tf.enable_v2_behavior()
tfd = tfp.distributions
tfb = tfp.bijectors
dtype = tf.float32

# Generate Data
X_np = np.linspace(0,1,100)
# w1=2, b1=1.7, w2=3.2, b2= -0.2
Y_np = 2*X_np + 1.7
Z_np = 3.2*X_np - 0.2
obs = tf.cast(tf.stack((Y_np, Z_np), 1), dtype=dtype)

# Define the model
Root = tfd.JointDistributionCoroutine.Root  # Convenient alias.
def model():
    b2 = yield Root(tfd.Normal(loc=tf.cast(0, dtype), scale=1.))
    w2 = yield Root(tfd.Normal(loc=tf.cast(0, dtype), scale=1.))
    b1 = yield Root(tfd.Normal(loc=tf.cast(0, dtype), scale=1.))
    w1 = yield Root(tfd.Normal(loc=tf.cast(0, dtype), scale=1.))
    yhat = b1[...,tf.newaxis]+w1[...,tf.newaxis]*X_np
    zhat = b2[...,tf.newaxis]+w2[...,tf.newaxis]*X_np
    obshat = tf.cast(tf.stack((yhat, zhat), 1), dtype=dtype)
    likelihood = yield tfd.Independent(
            tfd.Normal(loc=obshat, scale=1),
            reinterpreted_batch_ndims=2)

mdl_ols_coroutine = tfd.JointDistributionCoroutine(model)
target_log_prob_fn = lambda *x: tf.cast(mdl_ols_coroutine.log_prob(x + (obs, )), dtype=dtype)

print(mdl_ols_coroutine.sample(7))
# Define the chain trace operator
@tf.function(autograph=False, experimental_compile=True)
def run_chain(init_state, step_size, target_log_prob_fn, unconstraining_bijectors,
              num_steps=50, burnin=50):
    def trace_fn(_, pkr):
        return (
            pkr.inner_results.inner_results.target_log_prob,
            pkr.inner_results.inner_results.leapfrogs_taken,
            pkr.inner_results.inner_results.has_divergence,
            pkr.inner_results.inner_results.energy,
            pkr.inner_results.inner_results.log_accept_ratio
        )
    kernel = tfp.mcmc.TransformedTransitionKernel(
        inner_kernel=tfp.mcmc.NoUTurnSampler(
            target_log_prob_fn,
            step_size=step_size),
        bijector=unconstraining_bijectors)

    hmc = tfp.mcmc.DualAveragingStepSizeAdaptation(
        inner_kernel=kernel,
        num_adaptation_steps=burnin,
        step_size_setter_fn=lambda pkr, new_step_size: pkr._replace(
            inner_results=pkr.inner_results._replace(step_size=new_step_size)),
        step_size_getter_fn=lambda pkr: pkr.inner_results.step_size,
        log_accept_prob_getter_fn=lambda pkr: pkr.inner_results.log_accept_ratio
    )
    # Sampling from the chain.
    chain_state, sampler_stat = tfp.mcmc.sample_chain(
        num_results=num_steps,
        num_burnin_steps=burnin,
        current_state=init_state,
        kernel=hmc,
        trace_fn=trace_fn)
    return chain_state, sampler_stat

nchain = 1
n_steps = 5000
n_burns  = 1000
init_state = mdl_ols_coroutine.sample(nchain)
step_size = [tf.cast(i, dtype=dtype) for i in [.1, .1, .1, .1, .1]]
unconstraining_bijectors = [
   tfb.Identity(),
   tfb.Identity(),
   tfb.Identity(),
   tfb.Identity(),
   tfb.Identity(),
]

samples, sampler_stat = run_chain(init_state, step_size,
        target_log_prob_fn, unconstraining_bijectors,
        num_steps=n_steps,
        burnin=n_burns)

#Explaining ML models https://www.youtube.com/watch?v=P3n8CVbb01Q&t=1304s
#Manifold
#What-IF
#CF-alibi
#Interpret
from interpret import show#https://youtu.be/P3n8CVbb01Q?t=1249
from interpret.glassbox import ExplainableBoostingClassifier
from alibi.explainers #https://youtu.be/P3n8CVbb01Q?t=1018
PDP-scikit learn


#https://www.statsmodels.org/stable/gettingstarted.html
import statsmodels.api as sm
import pandas
from patsy import dmatrices
df = sm.datasets.get_rdataset("Guerry", "HistData").data
vars = ['Department', 'Lottery', 'Literacy', 'Wealth', 'Region']
df = df.dropna()
y, X = dmatrices('Lottery ~ Literacy + Wealth + Region', data=df, return_type='dataframe')
mod = sm.OLS(y, X)    # Describe model
res = mod.fit()       # Fit model
print(res.summary())   # Summarize model
res.params
dir(res)
sm.stats.linear_rainbow(res)
sm.graphics.plot_partregress('Lottery', 'Wealth', ['Region', 'Literacy'],data=df, obs_labels=False)
#https://pysdr.org/content/intro.html

#https://mechanicalsoup.readthedocs.io/en/stable/tutorial.html#first-contact-step-by-step
#!pip install mechanicalsoup
import mechanicalsoup
browser = mechanicalsoup.StatefulBrowser()
browser.open("http://httpbin.org/")
browser.follow_link("forms")
browser.get_current_page()
#https://nbviewer.jupyter.org/github/fastai/numerical-linear-algebra-v2/blob/master/nbs/02-Background-Removal-with-SVD.ipynb
import numpy as np
M = np.random.uniform(-40,40,[10,15])
import matplotlib.pyplot as plt
plt.imshow(M, cmap='gray');
U, s, V = np.linalg.svd(M, full_matrices=False)
np.save("U.npy", U)
np.save("s.npy", s)
np.save("V.npy", V)
U = np.load("U.npy")
s = np.load("s.npy")
V = np.load("V.npy")
print(U.shape, s.shape, V.shape)
low_rank = np.expand_dims(U[:,0], 1) * s[0] * np.expand_dims(V[0,:], 0)
dims = (5, 2)
plt.imshow(np.reshape(M[:,0] - low_rank[:,0], dims), cmap='gray');
k=5
compressed_M = U[:,:k] @ np.diag(s[:k]) @ V[:k,:]
plt.imshow(compressed_M, cmap='gray')

#https://mybinder.org/v2/gh/pygae/clifford/master?filepath=examples%2Fg3c.ipynb
!pip install clifford
from clifford.g3 import *  # import GA for 3D space
from math import e, pi
a = e1 + 2*e2 + 3*e3 # vector
R = e**(pi/4*e12)    # rotor
R*a*~R    # rotate the vector

#https://csvkit.readthedocs.io/en/latest/tutorial/2_examining_the_data.html
#sudo apt install python3-csvkit
in2csv -f ndjson promec/promec/Animesh/stanford-covid-vaccine/train.json > promec/promec/Animesh/stanford-covid-vaccine/train.in2.csv
#https://github.com/alan-turing-institute/sktime
!pip install sktime
import numpy as np
from sktime.datasets import load_airline
from sktime.forecasting.theta import ThetaForecaster
from sktime.forecasting.model_selection import temporal_train_test_split
from sktime.performance_metrics.forecasting import smape_loss
y = load_airline()
y_train, y_test = temporal_train_test_split(y)
fh = np.arange(1, len(y_test) + 1)  # forecasting horizon
forecaster = ThetaForecaster(sp=12)  # monthly seasonal periodicity
forecaster.fit(y_train)
y_pred = forecaster.predict(fh)
smape_loss(y_test, y_pred)
#fragment_ion_seriesfrom sktime.datasets import load_arrow_head
from sktime.classification.compose import TimeSeriesForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
X, y = load_arrow_head(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y)
classifier = TimeSeriesForestClassifier()
classifier.fit(X_train, y_train)
y_pred = classifier.predict(X_test)
accuracy_score(y_test, y_pred)
#forecasterimport numpy as np
from sktime.datasets import load_airline
from sktime.forecasting.compose import ReducedRegressionForecaster
from sklearn.ensemble import RandomForestRegressor
from sktime.forecasting.model_selection import temporal_train_test_split
from sktime.performance_metrics.forecasting import smape_loss
y = load_airline()
y_train, y_test = temporal_train_test_split(y)
fh = np.arange(1, len(y_test) + 1)  # forecasting horizon
regressor = RandomForestRegressor()
forecaster = ReducedRegressionForecaster(regressor, window_length=12)
forecaster.fit(y_train)
y_pred = forecaster.predict(fh)
smape_loss(y_test, y_pred)
>>> 0.12726230426056875


#https://duckdb.org/docs/api/python
#!python.exe -m pip install --upgrade pip
#!python.exe -m pip install --upgrade duckdb
import duckdb
con = duckdb.connect(database=':memory:', read_only=False)
import pandas as pd
test_df = pd.DataFrame.from_dict({"i":[1, 2, 3, 4], "j":["one", "two", "three", "four"]})
con.register('test_df_view', test_df)
con.execute('SELECT * FROM test_df_view')
con.fetchall()
# [(1, 'one'), (2, 'two'), (3, 'three'), (4, 'four')]
con.execute('CREATE TABLE test2_df_table AS SELECT * FROM test_df_view')
con.execute('SELECT * FROM test2_df_table').fetchall()

#https://dataorigami.net/blogs/napkin-folding/highlights-from-lifelines-v0-25-0
!pip install lifelines
import pandas as pd
#df = pd.DataFrame({'a': [35, 36, 40, 25, 55],'s': [60, 35, 80, 50, 100]})
df = pd.DataFrame({    'age': [35, 36, 40, 25, 55],    'salary': [60, 35, 80, 50, 100],    'age:salary': [2100, 1260, 2400, 1750, 5500],    'Intercept': [1, 1, 1, 1, 1]})
from lifelines import CoxPHFitter
from lifelines.datasets import load_rossi
rossi = load_rossi()
cph = CoxPHFitter()
cph.fit(rossi, "week", "arrest", formula="age + fin + prio + paro * mar")
cph.print_summary(columns=['coef', 'se(coef)', '-log2(p)'])
cph.fit(rossi, "week", "arrest", formula="age + fin + bs(prio, df=3)")
cph.print_summary(columns=['coef', 'se(coef)', '-log2(p)'])
from lifelines import WeibullAFTFitter
wf = WeibullAFTFitter()
wf.fit(rossi, "week", "arrest", formula="age + fin + paro * mar", ancillary="age * fin")
wf.print_summary(columns=['coef', 'se(coef)', '-log2(p)'])
#It's not displayed by default (that may change), but with the at_risk_counts kwarg in the call to KaplanMeierFitter.plot.

#https://gist.githubusercontent.com/shawlu95/73623e2aafb529413dccf89181131b3c/raw/d01ef96ce7ac1e75b34ca39d6fe6bffd6708461b/05_sql_feature_engineering_pull.py
X_trn, Y_trn = load_dataset("trn_set", limit=5)
print(X_trn.head().T)
#If your dataset is deployed on the cloud, you may be able to run distributed query. Most SQL server supports distirbuted query today. In Pandas, you need some extension called Dask DataFrame.
#If you can afford to pull data real-time, you can create SQL views instead of tables. In this way, every time you pull data in Python, your data will always be up-to-date.








#https://docs.datapane.com/tutorials/tut-deploying-a-script
import pandas as pd
import altair as alt
import datapane as dp

df = pd.read_csv('https://query1.finance.yahoo.com/v7/finance/download/GOOG?period2=1585222905&interval=1mo&events=history')

chart = alt.Chart(df).encode(
    x='Date:T',
    y='Open'
).mark_line().interactive()

r = dp.Report(dp.Table(df), dp.Plot(chart))
r.save(path='report.html', open=True)
# or r.publish(name='stock_report', open=True)

#https://github.com/karpathy/micrograd/blob/master/demo.ipynb
import random
import numpy as np
import matplotlib.pyplot as plt
from micrograd.engine import Value
from micrograd.nn import Neuron, Layer, MLP
np.random.seed(1337)
random.seed(1337)
from sklearn.datasets import make_moons, make_blobs
X, y = make_moons(n_samples=100, noise=0.1)
y = y*2 - 1 # make y be -1 or 1
# visualize in 2D
plt.figure(figsize=(5,5))
plt.scatter(X[:,0], X[:,1], c=y, s=20, cmap='jet')
# initialize a model
model = MLP(2, [16, 16, 1]) # 2-layer neural network
print(model)
print("number of parameters", len(model.parameters()))
def loss(batch_size=None):

    # inline DataLoader :)
    if batch_size is None:
        Xb, yb = X, y
    else:
        ri = np.random.permutation(X.shape[0])[:batch_size]
        Xb, yb = X[ri], y[ri]
    inputs = [list(map(Value, xrow)) for xrow in Xb]

    # forward the model to get scores
    scores = list(map(model, inputs))

    # svm "max-margin" loss
    losses = [(1 + -yi*scorei).relu() for yi, scorei in zip(yb, scores)]
    data_loss = sum(losses) * (1.0 / len(losses))
    # L2 regularization
    alpha = 1e-4
    reg_loss = alpha * sum((p*p for p in model.parameters()))
    total_loss = data_loss + reg_loss

    # also get accuracy
    accuracy = [(yi > 0) == (scorei.data > 0) for yi, scorei in zip(yb, scores)]
    return total_loss, sum(accuracy) / len(accuracy)

total_loss, acc = loss()
print(total_loss, acc)
# optimization
for k in range(100):

    # forward
    total_loss, acc = loss()

    # backward
    model.zero_grad()
    total_loss.backward()

    # update (sgd)
    learning_rate = 1.0 - 0.9*k/100
    for p in model.parameters():
        p.data -= learning_rate * p.grad

    if k % 1 == 0:
        print(f"step {k} loss {total_loss.data}, accuracy {acc*100}%")

# visualize decision boundary

h = 0.25
x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                     np.arange(y_min, y_max, h))
Xmesh = np.c_[xx.ravel(), yy.ravel()]
inputs = [list(map(Value, xrow)) for xrow in Xmesh]
scores = list(map(model, inputs))
Z = np.array([s.data > 0 for s in scores])
Z = Z.reshape(xx.shape)

fig = plt.figure()
plt.contourf(xx, yy, Z, cmap=plt.cm.Spectral, alpha=0.8)
plt.scatter(X[:, 0], X[:, 1], c=y, s=40, cmap=plt.cm.Spectral)
plt.xlim(xx.min(), xx.max())
plt.ylim(yy.min(), yy.max())

#https://blog.tensorflow.org/2020/01/hyperparameter-tuning-with-keras-tuner.html
from sklearn import ensemble
from sklearn import linear_model

def build_model(hp):
    model_type = hp.Choice('model_type', ['random_forest', 'ridge'])
    if model_type == 'random_forest':
        with hp.conditional_scope('model_type', 'random_forest'):
            model = ensemble.RandomForestClassifier(
                n_estimators=hp.Int('n_estimators', 10, 50, step=10),
                max_depth=hp.Int('max_depth', 3, 10))
    elif model_type == 'ridge':
        with hp.conditional_scope('model_type', 'ridge'):
            model = linear_model.RidgeClassifier(
                alpha=hp.Float('alpha', 1e-3, 1, sampling='log'))
    else:
        raise ValueError('Unrecognized model_type')
    return model

tuner = kt.tuners.Sklearn(
        oracle=kt.oracles.BayesianOptimization(
            objective=kt.Objective('score', 'max'),
            max_trials=10),
        hypermodel=build_model,
        directory=tmp_dir)
X, y = ...
tuner.search(X, y)

#https://www.springer.com/gp/book/9783030053178
from hyperopt import hp
space = hp.choice(’my_conditional’,[(’case 1’, 1 + hp.lognormal(’c1’, 0, 1)),(’case 2’, hp.uniform(’c2’, -10, 10)),(’case 3’, hp.choice(’c3’, [’a’, ’b’, ’c’]))])

from hpsklearn import HyperoptEstimator, svc, knn
from hyperopt import hp
# restrict the space to contain only random forest,
# k-nearest neighbors, and SVC models.
clf = hp.choice(’my_name’,[random_forest(’my_name.random_forest’),svc(’my_name.svc’),knn(’my_name.knn’)])
estim = HyperoptEstimator(classifier=clf)

import autosklearn.classification
cls = autosklearn.classification.AutoSklearnClassifier()
cls.fit(X_train, y_train)
predictions = cls.predict(X_test)

#PoSH Auto-sklearn (short for Portfolio Successive Halving,combined with Auto-sklearn)
from autonet import AutoNetClassification
cls = AutoNetClassification(min_budget=5, max_budget=20, max_runtime=120)
cls.fit(X_train, Y_train)
predictions = cls.predict(X_test)
#BOHB (Bayesian Optimization and HyperBand)

#automated deep learning; this is discussed in the following chapter on Auto-Net
#https://nbviewer.jupyter.org/github/autonomio/talos/blob/master/examples/Hyperparameter%20Optimization%20on%20Keras%20with%20Breast%20Cancer%20Data.ipynb
rom keras.models import Sequential
from keras.layers import Dropout, Dense
%matplotlib inline
import sys
sys.path.insert(0, '/Users/mikko/Documents/GitHub/talos')
import talos
# then we load the dataset
x, y = talos.templates.datasets.breast_cancer()
# and normalize every feature to mean 0, std 1
x = talos.utils.rescale_meanzero(x)
# then we load the dataset
x, y = talos.templates.datasets.breast_cancer()

# and normalize every feature to mean 0, std 1
x = talos.utils.rescale_meanzero(x)
# then we can go ahead and set the parameter space
p = {'first_neuron':[9,10,11],
     'hidden_layers':[0, 1, 2],
     'batch_size': [30],
     'epochs': [100],
     'dropout': [0],
     'kernel_initializer': ['uniform','normal'],
     'optimizer': ['Nadam', 'Adam'],
     'losses': ['binary_crossentropy'],
     'activation':['relu', 'elu'],
     'last_activation': ['sigmoid']}
# and run the experiment
t = talos.Scan(x=x,
               y=y,
               model=breast_cancer_model,
               params=p,
               experiment_name='breast_cancer',
               round_limit=10)



#https://www.kdnuggets.com/2020/05/5-great-new-features-scikit-learn.html set_config() module, one can enable the global display='diagram' option in your Jupyter
#pip install --upgrade scikit-learn
from sklearn.cluster import KMeans #Elkan algorithm now supports sparse matrices
import numpy as np
X = np.array([[1, 2], [1, 4], [1, 0],
              [10, 2], [10, 4], [10, 0]])
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
kmeans.labels_
kmeans.predict([[0, 0], [12, 3]])
kmeans.cluster_centers_

gbdt_cst = HistGradientBoostingRegressor(monotonic_cst=[1, 0]).fit(X, y)
gbdt = HistGradientBoostingRegressor(loss='poisson', learning_rate=.01)

#https://scikit-learn.org/stable/modules/linear_model.html#generalized-linear-regression
from sklearn.linear_model import TweedieRegressor
reg = TweedieRegressor(power=1, alpha=0.5, link='log')
reg.fit([[0, 0], [0, 1], [2, 2]], [0, 1, 2])
reg.coef_
reg.intercept_

n_samples, n_features = 1000, 20
rng = np.random.RandomState(0)
X, y = make_regression(n_samples, n_features, random_state=rng)
sample_weight = rng.rand(n_samples)
X_train, X_test, y_train, y_test, sw_train, sw_test = train_test_split(
    X, y, sample_weight, random_state=rng)
reg = Lasso()
reg.fit(X_train, y_train, sample_weight=sw_train)
print(reg.score(X_test, y_test, sw_test))

#https://www.kdnuggets.com/2020/05/sparse-matrix-representation-python.html
import numpy as np
from scipy import sparse
X = np.random.uniform(size=(10000, 10000))
X[X < 0.7] = 0
X_csr = sparse.csr_matrix(X)
print(f"Size in bytes of original matrix: {X.nbytes}")
print(f"Size in bytes of compressed sparse row matrix: {X_csr.data.nbytes + X_csr.indptr.nbytes + X_csr.indices.nbytes}")
#https://github.com/google-research/tapas
python tapas/run_task_main.py \
  --task="SQA" \
  --input_dir="${sqa_data_dir}" \
  --output_dir="${output_dir}" \
  --bert_vocab_file="${tapas_data_dir}/vocab.txt" \
  --mode="create_data"
#Afterwards, training can be started by running:
python tapas/run_task_main.py \
  --task="SQA" \
  --output_dir="${output_dir}" \
  --init_checkpoint="${tapas_data_dir}/model.ckpt" \
  --bert_config_file="${tapas_data_dir}/bert_config.json" \
  --mode="train" \
  --use_tpu
#This will use the preset hyper-paremters set in hparam_utils.py.
#It's recommended to start a separate eval job to continuously produce predictions for the checkpoints created by the training job. Alternatively, you can run the eval job after training to only get the final results.
python tapas/run_task_main.py \
  --task="SQA" \
  --output_dir="${output_dir}" \
  --init_checkpoint="${tapas_data_dir}/model.ckpt" \
  --bert_config_file="${tapas_data_dir}/bert_config.json" \
  --mode="predict_and_evaluate"

#https://github.com/zqfang/GSEApy/
#git clone https://github.com/zqfang/GSEApy/
#pip install gseapy
import gseapy
names = gseapy.get_library_name()
print(names[:20])
gseapy.gsea(data='expression.txt', gene_sets='gene_sets.gmt', cls='test.cls', outdir='test')
import pandas as pd
expression_dataframe = pd.DataFrame()
sample_name = ['A','A','A','B','B','B'] # always only two group,any names you like
# assign gene_sets parameter with enrichr library name or gmt file on your local computer.
gseapy.gsea(data=expression_dataframe, gene_sets='KEGG_2016', cls= sample_names, outdir='test')


#http://networksciencebook.com/chapter/5#degree-dynamics
#https://github.com/pyhf/neos
#pip install neos
#pip install git+https://github.com/gehring/fax.git
#https://blog.tensorflow.org/2020/01/hyperparameter-tuning-with-keras-tuner.html
import jax
import neos.makers as makers
import neos.cls as cls
import numpy as np
import jax.experimental.stax as stax
import jax.experimental.optimizers as optimizers
import jax.random
import time
init_random_params, predict = stax.serial(stax.Dense(1024),stax.Relu,stax.Dense(1024),stax.Relu,stax.Dense(2),stax.Softmax)
hmaker = makers.hists_from_nn_three_blobs(predict)
nnm = makers.nn_hepdata_like(hmaker)
loss = cls.cls_maker(nnm, solver_kwargs=dict(pdf_transform=True))
_, network = init_random_params(jax.random.PRNGKey(2), (-1, 2))
opt_init, opt_update, opt_params = optimizers.adam(1e-3)
def update_and_value(i, opt_state, mu):
    net = opt_params(opt_state)
    value, grad = jax.value_and_grad(loss)(net, mu)
    return opt_update(i, grad, opt_state), value, net
def train_network(N):
    cls_vals = []
    _, network = init_random_params(jax.random.PRNGKey(1), (-1, 2))
    state = opt_init(network)
    losses = []
    for i in range(N):
        start_time = time.time()
        state, value, network = update_and_value(i,state,1.0)
        epoch_time = time.time() - start_time
        losses.append(value)
        metrics = {"loss": losses}
        yield network, metrics, epoch_time
maxN = 10 # make me bigger for better results!
# Training
for i, (network, metrics, epoch_time) in enumerate(train_network(maxN)):
    print(f"epoch {i}:", f'CLs = {metrics["loss"][-1]}, took {epoch_time}s')

#https://github.com/keras-team/keras-tuner
import kerastuner as kt
from sklearn import ensemble
from sklearn import linear_model

def build_model(hp):
    model_type = hp.Choice('model_type', ['random_forest', 'ridge'])
    if model_type == 'random_forest':
        with hp.conditional_scope('model_type', 'random_forest'):
            model = ensemble.RandomForestClassifier(
                n_estimators=hp.Int('n_estimators', 10, 50, step=10),
                max_depth=hp.Int('max_depth', 3, 10))
    elif model_type == 'ridge':
        with hp.conditional_scope('model_type', 'ridge'):
            model = linear_model.RidgeClassifier(
                alpha=hp.Float('alpha', 1e-3, 1, sampling='log'))
    else:
        raise ValueError('Unrecognized model_type')
    return model

#https://github.com/keras-team/keras-tuner
tmp_dir="."
tuner = kt.Hyperband(
    build_model,
    objective='val_accuracy',
    max_epochs=30,
    hyperband_iterations=2)
tuner = kt.tuners.Sklearn(
        oracle=kt.oracles.BayesianOptimization(
            objective=kt.Objective('score', 'max'),
            max_trials=10),
        hypermodel=build_model,
        directory=tmp_dir)
X, y = [[1,2,3,4,6],[4,8,12,16,20]]
tuner.search(X+1.0, y+1.0)
tuner.search_space_summary()

#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#pip3 install tensorflow==2.0.0-rc0
#https://youtu.be/5ECD8J3dvDQ?t=455
import tensorflow as tf
print(tf.__version__)
import datetime
print(datetime.datetime.now())

inp=[0.05,0.10]
inpw=[[0.15,0.25],[0.20,0.3]]
hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

#https://jaredwinick.github.io/what_is_tf_keras/
w1 = tf.Variable(inpw)
w2 = tf.Variable(hidw)
x = tf.constant(inp)
y = tf.constant(outputr)


layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
print(layer_2)

epochs = 2
for epoch in range(epochs):
    with tf.GradientTape() as t:
        layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
        layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
        loss = y - layer_2
    #dW, dB = t.gradient(loss, [w2, bias[1]])
    print(t.gradient(loss, [w2, bias[1]]))
    #weights.assign_sub(lr * dW)
    #bias.assign_sub(lr * dB)

#https://www.tensorflow.org/tensorboard/scalars_and_keras
import numpy as np
data_size = 1000
# 80% of the data is for training.
train_pct = 0.8

train_size = int(data_size * train_pct)

# Create some input data between -1 and 1 and randomize it.
x = np.linspace(-1, 1, data_size)
np.random.shuffle(x)

# Generate the output data.
# y = 0.5x + 2 + noise
y = 0.5 * x + 2 + np.random.normal(0, 0.05, (data_size, ))

# Split into test and train pairs.
x_train, y_train = x[:train_size], y[:train_size]
x_test, y_test = x[train_size:], y[train_size:]

from datetime import datetime
from tensorflow import keras
logdir = "logs/scalars/" + datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = keras.callbacks.TensorBoard(log_dir=logdir)

model = keras.models.Sequential([
    keras.layers.Dense(16, input_dim=1),
    keras.layers.Dense(1),
])

model.compile(
    loss='mse', # keras.losses.mean_squared_error
    optimizer=keras.optimizers.SGD(lr=0.2),
)

print("Training ... With default parameters, this takes less than 10 seconds.")
training_history = model.fit(
    x_train, # input
    y_train, # output
    batch_size=train_size,
    verbose=0, # Suppress chatty output; use Tensorboard instead
    epochs=100,
    validation_data=(x_test, y_test),
    callbacks=[tensorboard_callback],
)

print("Average test loss: ", np.average(training_history.history['loss']))

#https://www.tensorflow.org/neural_structured_learning/tutorials/graph_keras_lstm_imdb
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
import matplotlib.pyplot as plt
import numpy as np
import neural_structured_learning as nsl
import tensorflow as tf
tf.compat.v1.enable_v2_behavior()
import tensorflow_hub as hub
# Resets notebook state
tf.keras.backend.clear_session()
print("Version: ", tf.__version__)
print("Eager mode: ", tf.executing_eagerly())
print("Hub version: ", hub.__version__)
print("GPU is", "available" if tf.test.is_gpu_available() else "NOT AVAILABLE")
imdb = tf.keras.datasets.imdb
(pp_train_data, pp_train_labels)= (imdb.load_data(num_words=10000))
print('Training entries: {}, labels: {}'.format(len(pp_train_data),len(pp_train_labels)))
training_samples_count = len(pp_train_data)

def build_reverse_word_index():
  # A dictionary mapping words to an integer index
  word_index = imdb.get_word_index()
  # The first indices are reserved
  word_index = {k: (v + 3) for k, v in word_index.items()}
  word_index['<PAD>'] = 0
  word_index['<START>'] = 1
  word_index['<UNK>'] = 2  # unknown
  word_index['<UNUSED>'] = 3
  return dict((value, key) for (key, value) in word_index.items())

reverse_word_index = build_reverse_word_index()

def decode_review(text):
  return ' '.join([reverse_word_index.get(i, '?') for i in text])

decode_review(pp_train_data[0])

system("jupyter" "notebook" "list")

#https://www.machinelearningplus.com/time-series/time-series-analysis-python/
from dateutil.parser import parse
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
plt.rcParams.update({'figure.figsize': (10, 7), 'figure.dpi': 120})

# Import as Dataframe
df = pd.read_csv('https://raw.githubusercontent.com/selva86/datasets/master/a10.csv', parse_dates=['date'])
df.head()
ser = pd.read_csv('https://raw.githubusercontent.com/selva86/datasets/master/a10.csv', parse_dates=['date'], index_col='date')
ser.head()

# dataset source: https://github.com/rouseguy
df = pd.read_csv('https://raw.githubusercontent.com/selva86/datasets/master/MarketArrivals.csv')
df = df.loc[df.market=='MUMBAI', :]
df.head()

# Time series data source: fpp pacakge in R.
import matplotlib.pyplot as plt
df = pd.read_csv('https://raw.githubusercontent.com/selva86/datasets/master/a10.csv', parse_dates=['date'], index_col='date')

# Draw Plot
def plot_df(df, x, y, title="", xlabel='Date', ylabel='Value', dpi=100):
    plt.figure(figsize=(16,5), dpi=dpi)
    plt.plot(x, y, color='tab:red')
    plt.gca().set(title=title, xlabel=xlabel, ylabel=ylabel)
    plt.show()

plot_df(df, x=df.index, y=df.value, title='Monthly anti-diabetic drug sales in Australia from 1992 to 2008.')


from statsmodels.tsa.stattools import grangercausalitytests
df = pd.read_csv('https://raw.githubusercontent.com/selva86/datasets/master/a10.csv', parse_dates=['date'])
df['month'] = df.date.dt.month
grangercausalitytests(df[['value', 'month']], maxlag=2)

#https://peerj.com/preprints/27736.pdf
from pyopenms import *
seq = AASequence.fromString("DFPIANGER")
seq_formula = seq.getFormula()
print("Peptide", seq, "has molecular formula", seq_formula)


tsg = TheoreticalSpectrumGenerator()
spec1 = MSSpectrum()
spec2 = MSSpectrum()
peptide = AASequence.fromString("DFPIANGER")
# standard behavior is adding b- and y-ions of charge 1
p = Param()
p.setValue(b"add_b_ions", b"false", b"Add peaks of b-ions to the spectrum")
tsg.setParameters(p)
tsg.getSpectrum(spec1, peptide, 1, 1)
p.setValue(b"add_b_ions", b"true", b"Add peaks of a-ions to the spectrum")
p.setValue(b"add_metainfo", b"true", "")
tsg.setParameters(p)
tsg.getSpectrum(spec2, peptide, 1, 2)
print("Spectrum 1 has", spec1.size(), "peaks.")
print("Spectrum 2 has", spec2.size(), "peaks.")

# Iterate over annotated ions and their masses
for ion, peak in zip(spec2.getStringDataArrays()[0], spec2):
    print(ion, peak.getMZ())


#YOLO base https://github.com/Microsoft/vcpkg
#https://dsbyprateekg.blogspot.com/2019/12/how-can-i-install-and-use-darknet.html
#https://en.m.wikipedia.org/wiki/Kelly_criterion
#! pip install sympy
from sympy import *
x,b,p = symbols('x b p')
y = p*log(1+b*x) + (1-p)*log(1-x)
solve(diff(y,x), x)#[-(1 - p - b*p)/b]


#https://openai.com/blog/deep-double-descent/
import safety_gym
import gym
env = gym.make('Safexp-PointGoal1-v0')
next_observation, reward, done, info = env.step(action)
info
#https://github.com/openai/safety-starter-agents

#cluster https://nbviewer.jupyter.org/github/KrishnaswamyLab/PHATE/blob/master/Python/tutorial/EmbryoidBody.ipynb
!pip install --user --upgrade phate scprep
#demo https://www.krishnaswamylab.org/projects/phate/eb-web-tool
import os
import scprep
download_path = os.path.expanduser("~")
print(download_path)
if not os.path.isdir(os.path.join(download_path, "scRNAseq", "T0_1A")):
    # need to download the data
    scprep.io.download.download_and_extract_zip(
        "https://data.mendeley.com/datasets/v6n743h5ng"
        "/1/files/7489a88f-9ef6-4dff-a8f8-1381d046afe3/scRNAseq.zip?dl=1",
        download_path)
import pandas as pd
import numpy as np
import phate
import scprep
sparse=True
T1 = scprep.io.load_10X(os.path.join(download_path, "scRNAseq", "T0_1A"), sparse=sparse, gene_labels='both')
T2 = scprep.io.load_10X(os.path.join(download_path, "scRNAseq", "T2_3B"), sparse=sparse, gene_labels='both')
T3 = scprep.io.load_10X(os.path.join(download_path, "scRNAseq", "T4_5C"), sparse=sparse, gene_labels='both')
T4 = scprep.io.load_10X(os.path.join(download_path, "scRNAseq", "T6_7D"), sparse=sparse, gene_labels='both')
T5 = scprep.io.load_10X(os.path.join(download_path, "scRNAseq", "T8_9E"), sparse=sparse, gene_labels='both')
T1.head()
scprep.plot.plot_library_size(T1, percentile=20)
filtered_batches = []
for batch in [T1, T2, T3, T4, T5]:
    batch = scprep.filter.filter_library_size(batch, percentile=20, keep_cells='above')
    batch = scprep.filter.filter_library_size(batch, percentile=75, keep_cells='below')
    filtered_batches.append(batch)
del T1, T2, T3, T4, T5 # removes objects from memory
EBT_counts, sample_labels = scprep.utils.combine_batches(
    filtered_batches,
    ["Day 00-03", "Day 06-09", "Day 12-15", "Day 18-21", "Day 24-27"],
    append_to_cell_names=True
)
del filtered_batches # removes objects from memory
EBT_counts.head()
EBT_counts = scprep.filter.filter_rare_genes(EBT_counts, min_cells=10)
EBT_counts = scprep.normalize.library_size_normalize(EBT_counts)
mito_genes = scprep.select.get_gene_set(EBT_counts, starts_with="MT-") # Get all mitochondrial genes. There are 14, FYI.
scprep.plot.plot_gene_set_expression(EBT_counts, genes=mito_genes, percentile=90)
EBT_counts, sample_labels = scprep.filter.filter_gene_set_expression(EBT_counts, sample_labels, genes=mito_genes,percentile=90, keep_cells='below')
EBT_counts = scprep.transform.sqrt(EBT_counts)
phate_operator = phate.PHATE(n_jobs=-2)
Y_phate = phate_operator.fit_transform(EBT_counts)
scprep.plot.scatter2d(Y_phate, c=sample_labels, figsize=(12,8), cmap="Spectral",ticks=False, label_prefix="PHATE")
phate_operator.set_params(knn=4, decay=15, t=12)
# phate_operator = phate.PHATE(knn=4, decay=15, t=12, n_jobs=-2)
Y_phate = phate_operator.fit_transform(EBT_counts)
scprep.plot.scatter2d(Y_phate, c=sample_labels, figsize=(12,8), cmap="Spectral",ticks=False, label_prefix="PHATE")

#https://www.youtube.com/watch?v=B4p6gvPs-gM
!cd ../CellBender/examples/remove_background
!python generate_tiny_10x_pbmc.py
!$HOME/.local/bin/cellbender remove-background      --input ./tiny_raw_gene_bc_matrices/GRCh38      --output ./tiny_10x_pbmc.h5      --expected-cells 500   --total-droplets-included 5000

#walrus operator?https://www.geeksforgeeks.org/walrus-operator-in-python-3-8/
data = [10, 14, 34, 49, 70, 77]
prev = 0
[-prev + (prev := x) for x in data]
#[10, 4, 20, 15, 21, 7]
(1/3)*3==1#True
#https://0.30000000000000004.com/
(0.1+0.2)==0.3#False
#https://github.com/ruggleslab/blackSheep
import blacksheep
import pandas as pd
values = pd.read_csv('phospho_common_samples_data.csv', index_col=0)
annotations = pd.read_csv('annotations_common_samples.csv', index_col=0)
#values = deva.read_in_values('blacksheep_supp/vignettes/brca/phospho_common_samples_data.csv')
#annotations = deva.read_in_values('brca/annotations_common_samples.csv')
annotations = blacksheep.binarize_annotations(annotations)

# Run outliers comparative analysis
outliers, qvalues = blacksheep.deva(
    values, annotations,
    save_outlier_table=True,
    save_qvalues=True,
    save_comparison_summaries=True
)

# Pull out results
qvalues_table = qvalues.df
vis_table = outliers.frac_table

# Make heatmaps for significant genes
for col in annotations.columns:
    axs = blacksheep.plot_heatmap(annotations, qvalues_table, col, vis_table, savefig=True)
#https://github.com/ruggleslab/blacksheep_supp/blob/dev/vignettes/running_outliers.ipynb
# Normalize values
phospho = blacksheep.read_in_values('') #Fill in file here
protein = blacksheep.read_in_values('') #Fill in file here


#https://tensorsignatures.readthedocs.io/en/latest/tutorials.html#getting-started
# pip install tensorsignatures==0.4.0
import tensorsignatures as ts
data_set = ts.TensorSignatureData(seed=573, rank=3, samples=100, dimensions=[3, 5], mutations=1000)
snv = data_set.snv()
snv.shape
snv_collapsed = snv.sum(axis=(0,1,2,3,))
snv_coding = snv[0,].sum(axis=(0,1,2,4))
snv_template = snv[1,].sum(axis=(0,1,2,4))
import matplotlib.pyplot as plt
import numpy as np
fig, axes = plt.subplots(3, 3, sharey=True, sharex=True)
for i, ax in enumerate(np.ravel(axes)):
   ax.bar(np.arange(96), snv_collapsed[:, i], color=ts.DARK_PALETTE)
   ax.set_title('Sample {}'.format(i))
   if i%3==0: ax.set_ylabel('Counts')
   if i>=6: ax.set_xlabel('Mutation type')
fig, axes = plt.subplots(1, 2, sharey=True)
axes[0].bar(np.arange(96), snv_coding, color=ts.DARK_PALETTE)
axes[0].set_title('Coding strand mutations')
axes[1].bar(np.arange(96), snv_template, color=ts.DARK_PALETTE)
axes[1].set_title('Template strand mutations')
plt.figure(figsize=(16, 3))
ts.plot_signatures(data_set.S.reshape(3,3,-1,96,3))
#git clone https://github.com/WarrenWeckesser/heatmapcluster.git
#cd heatmapcluster
#python setup.py install
import numpy as np
import matplotlib.pyplot as plt
from heatmapcluster import heatmapcluster
def make_data(size, seed=None):
    if seed is not None:
        np.random.seed(seed)
    s = np.random.gamma([7, 6, 5], [6, 8, 6], size=(size[1], 3)).T
    i = np.random.choice(range(len(s)), size=size[0])
    x = s[i]
    t = np.random.gamma([8, 5, 6], [3, 3, 2.1], size=(size[0], 3)).T
    j = np.random.choice(range(len(t)), size=size[1])
    x += 1.1*t[j].T
    x += 2*np.random.randn(*size)
    row_labels = [('R%02d' % k) for k in range(x.shape[0])]
    col_labels = [('C%02d' % k) for k in range(x.shape[1])]
    return x, row_labels, col_labels
x, row_labels, col_labels = make_data(size=(64, 48), seed=123)
h = heatmapcluster(x, row_labels, col_labels,
                   num_row_clusters=3, num_col_clusters=0,
                   label_fontsize=6,
                   xlabel_rotation=-75,
                   cmap=plt.cm.coolwarm,
                   show_colorbar=True,
                   top_dendrogram=True)
plt.show()
from scipy.cluster.hierarchy import linkage
h = heatmapcluster(x, row_labels, col_labels,
                   num_row_clusters=3, num_col_clusters=0,
                   label_fontsize=6,
                   xlabel_rotation=-75,
                   cmap=plt.cm.coolwarm,
                   show_colorbar=True,
                   top_dendrogram=True,
                   row_linkage=lambda x: linkage(x, method='average',
                                                 metric='correlation'),
                   col_linkage=lambda x: linkage(x.T, method='average',
                                                 metric='correlation'),
                   histogram=True)
#https://www.analyticsvidhya.com/blog/2019/10/mathematics-behind-machine-learning/
#https://www.analyticsvidhya.com/blog/2019/10/how-to-build-knowledge-graph-text-using-spacy/ , https://www.analyticsvidhya.com/blog/2019/09/introduction-information-extraction-python-spacy/
import re
import pandas as pd
import bs4
import requests
import spacy
from spacy import displacy
#python3 -m spacy download en_core_web_sm --user
nlp = spacy.load('en_core_web_sm')

from spacy.matcher import Matcher
from spacy.tokens import Span

import networkx as nx

import matplotlib.pyplot as plt
from tqdm import tqdm

pd.set_option('display.max_colwidth', 200)
%matplotlib inline
candidate_sentences = pd.read_csv("/home/animeshs/Downloads/wiki_sentences_v2.csv")
candidate_sentences.shape
candidate_sentences['sentence'].sample(10)
doc = nlp("the drawdown process is governed by astm standard d823")

for tok in doc:
  print(tok.text, "...", tok.dep_)

#https://www.wandb.com/
# Install Weights & Biases to track training. First create an account at wandb.com
!pip install wandb -q --user
!wandb login
# Download the dermatology dataset
!wget https://archive.ics.uci.edu/ml/machine-learning-databases/dermatology/dermatology.data
# modified from https://github.com/dmlc/xgboost/blob/master/demo/multiclass_classification/train.py

#%%wandb

import wandb
import numpy as np
import xgboost as xgb

wandb.init(project="xgboost-dermatology")

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

xg_train = xgb.DMatrix(train_X, label=train_Y)
xg_test = xgb.DMatrix(test_X, label=test_Y)
# setup parameters for xgboost
param = {}
# use softmax multi-class classification
param['objective'] = 'multi:softmax'
# scale weight of positive examples
param['eta'] = 0.1
param['max_depth'] = 6
param['silent'] = 1
param['nthread'] = 4
param['num_class'] = 6
wandb.config.update(param)

watchlist = [(xg_train, 'train'), (xg_test, 'test')]
num_round = 5
bst = xgb.train(param, xg_train, num_round, watchlist, callbacks=[wandb.xgboost.wandb_callback()])
# get prediction
pred = bst.predict(xg_test)
error_rate = np.sum(pred != test_Y) / test_Y.shape[0]
print('Test error using softmax = {}'.format(error_rate))
wandb.summary['Error Rate'] = error_rate


#https://gluon-ts.mxnet.io/?fbclid=IwAR0lmYbqAKpCcfqbaxpeK3AKENcNnVEEESztJKGBjH_SZ8LeauKsTRRq85Q
from gluonts.dataset import common
from gluonts.model import deepar
from gluonts.trainer import Trainer

import pandas as pd

url = "https://raw.githubusercontent.com/numenta/NAB/master/data/realTweets/Twitter_volume_AMZN.csv"
df = pd.read_csv(url, header=0, index_col=0)
data = common.ListDataset([{"start": df.index[0],
                            "target": df.value[:"2015-04-05 00:00:00"]}],
                          freq="5min")

trainer = Trainer(epochs=10)
estimator = deepar.DeepAREstimator(freq="5min", prediction_length=12, trainer=trainer)
predictor = estimator.train(training_data=data)

prediction = next(predictor.predict(data))
print(prediction.mean)
prediction.plot(output_file='graph.png')



#https://machinelearningmastery.com/expectation-maximization-em-algorithm/
from numpy import hstack
from numpy.random import normal
from sklearn.mixture import GaussianMixture
# generate a sample
X1 = normal(loc=20, scale=5, size=3000)
X2 = normal(loc=40, scale=5, size=7000)
X = hstack((X1, X2))
# reshape into a table with one column
X = X.reshape((len(X), 1))
# fit model
model = GaussianMixture(n_components=2, init_params='random')
model.fit(X)
# predict latent values
yhat = model.predict(X)
# check latent value for first few points
print(yhat[:100])
# check latent value for last few points
print(yhat[-100:])

#https://polynote.org/docs/01-installation.html
#wget https://github.com/polynote/polynote/releases/download/0.2.10/polynote-dist-2.12.tar.gz
#tar xvzf polynote-dist-2.12.tar.gz
#sudo apt install default-jdk
#export JAVA_HOME=/usr/lib/jvm/default-java/
#wget http://apache.uib.no/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
#export SPARK_HOME=/home/animeshs/spark-2.4.4-bin-hadoop2.7/
#export PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"
#spark-submit
#pip3 install jep jedi pyspark virtualenv --user
#./polynote/polynote.py
#http://127.0.0.1:8192/

#https://machinelearningmastery.com/what-is-bayesian-optimization/


#Causal Inference Week 1 Course Overview https://www.coursera.org/learn/causal-inference/lecture/dugVq
#https://www.inference.vc/the-secular-bayesian-using-belief-distributions-without-really-believing/
#https://fairmlbook.org/causal.html
#https://github.com/adebayoj/fairml
#python3 -m pip install https://github.com/adebayoj/fairml/archive/master.zip --user
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from fairml import audit_model
from fairml import plot_generic_dependence_dictionary
propublica_data = pd.read_csv(
    filepath_or_buffer="./doc/example_notebooks/"
    "propublica_data_for_fairml.csv")
compas_rating = propublica_data.score_factor.values
propublica_data = propublica_data.drop("score_factor", 1)
clf = LogisticRegression(penalty='l2', C=0.01)
clf.fit(propublica_data.values, compas_rating)
total, _ = audit_model(clf.predict, propublica_data)
print(total)
fig = plot_dependencies(
    total.get_compress_dictionary_into_key_median(),
    reverse_values=False,
    title="FairML feature dependence"
)
plt.savefig("fairml_ldp.eps", transparent=False, bbox_inches='tight')

##!/usr/bin/env python
from platform import python_version
print(python_version())
from pathlib import Path
home=Path.home()
print(home)
#plotting
import matplotlib.pyplot as plt
plt.style.use('dark_background')

#check setup
import os
print(os.getenv())
import pwd
print(pwd.getpwuid(os.getuid()))

#sudo pip install --upgrade pip
#sudo python3 -m pip install --upgrade pip
#sudo python3 -m pip install --upgrade tensorflow
#sudo python3 -m pip install --upgrade tfp-nightly
#https://medium.com/tensorflow/introducing-tensorflow-probability-dca4c304e245
import tensorflow as tf
from tensorflow_probability import edward2 as ed
def model(features):
  # Set up fixed effects and other parameters.
  intercept = tf.get_variable("intercept", [])
  service_effects = tf.get_variable("service_effects", [])
  student_stddev_unconstrained = tf.get_variable(
      "student_stddev_pre", [])
  instructor_stddev_unconstrained = tf.get_variable(
      "instructor_stddev_pre", [])
  # Set up random effects.
  student_effects = ed.MultivariateNormalDiag(
      loc=tf.zeros(num_students),
      scale_identity_multiplier=tf.exp(
          student_stddev_unconstrained),
      name="student_effects")
  instructor_effects = ed.MultivariateNormalDiag(
      loc=tf.zeros(num_instructors),
      scale_identity_multiplier=tf.exp(
          instructor_stddev_unconstrained),
      name="instructor_effects")
  # Set up likelihood given fixed and random effects.
  ratings = ed.Normal(
      loc=(service_effects * features["service"] +
           tf.gather(student_effects, features["students"]) +
           tf.gather(instructor_effects, features["instructors"]) +
           intercept),
      scale=1.,
      name="ratings")
  return ratings
model([1,2,3,4])
#https://www.tensorflow.org/probability/api_docs/python/tfp/mcmc/SimpleStepSizeAdaptation
import tensorflow as tf
print("TensorFlow version: {}".format(tf.__version__))
#tf.enable_eager_execution()
print("Eager execution: {}".format(tf.executing_eagerly()))
import tensorflow_probability as tfp
tfd = tfp.distributions

target_log_prob_fn = tfd.Normal(loc=0., scale=1.).log_prob
num_burnin_steps = 500
num_results = 500
num_chains = 64
step_size = 0.1
# Or, if you want per-chain step size:
# step_size = tf.fill([num_chains], step_size)

kernel = tfp.mcmc.HamiltonianMonteCarlo(
    target_log_prob_fn=target_log_prob_fn,
    num_leapfrog_steps=2,
    step_size=step_size)
kernel = tfp.mcmc.SimpleStepSizeAdaptation(
    inner_kernel=kernel, num_adaptation_steps=int(num_burnin_steps * 0.8))

# The chain will be stepped for num_results + num_burnin_steps, adapting for
# the first num_adaptation_steps.
samples, [step_size, log_accept_ratio] = tfp.mcmc.sample_chain(
    num_results=num_results,
    num_burnin_steps=num_burnin_steps,
    current_state=tf.zeros(num_chains),
    kernel=kernel,
    trace_fn=lambda _, pkr: [pkr.inner_results.accepted_results.step_size,
                             pkr.inner_results.log_accept_ratio])

# ~0.75
p_accept = tf.reduce_mean(tf.exp(tf.minimum(log_accept_ratio, 0.)))
#https://towardsdatascience.com/quantum-physics-visualization-with-python-35df8b365ff
import matplotlib.pyplot as plt
import numpy as np
#Constants
h = 6.626e-34
m = 9.11e-31
#Values for L and x
x_list = np.linspace(0,1,100)
L = 1
def psi(n,L,x):
    return np.sqrt(2/L)*np.sin(n*np.pi*x/L)
def psi_2(n,L,x):
    return np.square(psi(n,L,x))
plt.figure(figsize=(15,10))
plt.suptitle("Wave Functions", fontsize=18)
for n in range(1,4):
    #Empty lists for energy and psi wave
    psi_2_list = []
    psi_list = []
    for x in x_list:
        psi_2_list.append(psi_2(n,L,x))
        psi_list.append(psi(n,L,x))
    plt.subplot(3,2,2*n-1)
    plt.plot(x_list, psi_list)
    plt.xlabel("L", fontsize=13)
    plt.ylabel("Ψ", fontsize=13)
    plt.xticks(np.arange(0, 1, step=0.5))
    plt.title("n="+str(n), fontsize=16)
    plt.grid()
    plt.subplot(3,2,2*n)
    plt.plot(x_list, psi_2_list)
    plt.xlabel("L", fontsize=13)
    plt.ylabel("Ψ*Ψ", fontsize=13)
    plt.xticks(np.arange(0, 1, step=0.5))
    plt.title("n="+str(n), fontsize=16)
    plt.grid()
plt.tight_layout(rect=[0, 0.03, 1, 0.95])

#https://towardsdatascience.com/python-based-plotting-with-matplotlib-8e1c301e2799
from mpl_toolkits.mplot3d import Axes3D #https://stackoverflow.com/questions/3810865/matplotlib-unknown-projection-3d-error
import matplotlib.pyplot as plt
import numpy as np
#Probability of 1s
def prob_1s(x,y,z):
    r=np.sqrt(np.square(x)+np.square(y)+np.square(z))
    #Remember.. probability is psi squared!
    return np.square(np.exp(-r)/np.sqrt(np.pi))
#Random coordinates
x=np.linspace(0,1,30)
y=np.linspace(0,1,30)
z=np.linspace(0,1,30)
elements = []
probability = []
for ix in x:
    for iy in y:
        for iz in z:
            #Serialize into 1D object
            elements.append(str((ix,iy,iz)))
            probability.append(prob_1s(ix,iy,iz))

#Ensure sum of probability is 1
probability = probability/sum(probability)
#Getting electron coordinates based on probabiliy
coord = np.random.choice(elements, size=100000, replace=True, p=probability)
elem_mat = [i.split(',') for i in coord]
elem_mat = np.matrix(elem_mat)
x_coords = [float(i.item()[1:]) for i in elem_mat[:,0]]
y_coords = [float(i.item()) for i in elem_mat[:,1]]
z_coords = [float(i.item()[0:-1]) for i in elem_mat[:,2]]
#Plotting
fig = plt.figure(figsize=(10,10))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x_coords, y_coords, z_coords, alpha=0.05, s=2)
ax.set_title("Hydrogen 1s density")
plt.show()



#https://www.eadan.net/blog/german-tank-problem/
import numpy as np
num_tanks = 1000
num_captured = 15
serial_numbers = np.arange(1, num_tanks + 1)
num_simulations = 100_000
def capture_tanks(serial_numbers, n):
     """Capture `n` tanks, uniformly, at random."""
     return np.random.choice(serial_numbers, n, replace=False)
simulations = [
    capture_tanks(serial_numbers, num_captured)
    for _ in range(num_simulations)
]

import matplotlib.pyplot as plt
first_estimates = [max(s) for s in simulations]
plt.hist(first_estimates)
avg_first_estimates = np.mean(first_estimates)

def max_plus_avg_spacing(simulation):
    m = max(simulation)
    avg_spacing = (m / num_captured) - 1
    return m + avg_spacing
new_estimates = [max_plus_avg_spacing(s) for s in simulations]
plt.hist(new_estimates)
avg_new_estimates = np.mean(new_estimates)

print(np.std(first_estimates))  #=> 57
print(np.std(new_estimates))    #=> 62

import pymc3 as pm
captured = [499, 505, 190, 427, 185, 572, 818, 721,912, 302, 765, 231, 547, 410, 884]
print(max_plus_avg_spacing(captured))   #=> 971.8

with pm.Model():
    num_tanks = pm.DiscreteUniform(
        "num_tanks",
	lower=max(captured),
	upper=2000
    )
    likelihood = pm.DiscreteUniform(
        "observed",
	lower=1,
	upper=num_tanks,
	observed=captured
    )
    posterior = pm.sample(10000, tune=1000)
pm.plot_posterior(posterior, credible_interval=0.95)
#https://stackoverflow.com/questions/25735153/plotting-a-fast-fourier-transform-in-python
#%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
import scipy.fftpack

fig = plt.figure(figsize=[14,4])
N = 600           # Number of samplepoints
Fs = 800.0
T = 1.0 / Fs      # N_samps*T (#samples x sample period) is the sample spacing.
N_fft = 80        # Number of bins (chooses granularity)
x = np.linspace(0, N*T, N)     # the interval
y = np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)   # the signal

# removing the mean of the signal
mean_removed = np.ones_like(y)*np.mean(y)
y = y - mean_removed

# Compute the fft.
yf = scipy.fftpack.fft(y,n=N_fft)
xf = np.arange(0,Fs,Fs/N_fft)

##### Plot the fft #####
ax = plt.subplot(121)
pt, = ax.plot(xf,np.abs(yf), lw=2.0, c='b')
p = plt.Rectangle((Fs/2, 0), Fs/2, ax.get_ylim()[1], facecolor="grey", fill=True, alpha=0.75, hatch="/", zorder=3)
ax.add_patch(p)
ax.set_xlim((ax.get_xlim()[0],Fs))
ax.set_title('FFT', fontsize= 16, fontweight="bold")
ax.set_ylabel('FFT magnitude (power)')
ax.set_xlabel('Frequency (Hz)')
plt.legend((p,), ('mirrowed',))
ax.grid()

##### Close up on the graph of fft#######
# This is the same histogram above, but truncated at the max frequence + an offset.
offset = 1    # just to help the visualization. Nothing important.
ax2 = fig.add_subplot(122)
ax2.plot(xf,np.abs(yf), lw=2.0, c='b')
ax2.set_xticks(xf)
ax2.set_xlim(-1,int(Fs/6)+offset)
ax2.set_title('FFT close-up', fontsize= 16, fontweight="bold")
ax2.set_ylabel('FFT magnitude (power) - log')
ax2.set_xlabel('Frequency (Hz)')
ax2.hold(True)
ax2.grid()

plt.yscale('log')

import numpy as np
import matplotlib.pyplot as plt
import scipy.fftpack

# Number of samplepoints
N = 600
# sample spacing
T = 1.0 / 800.0
x = np.linspace(0.0, N*T, N)
y = 10 + np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)
yf = scipy.fftpack.fft(y)
xf = np.linspace(0.0, 1.0/(2.0*T), N/2)

plt.subplot(2, 1, 1)
plt.plot(xf, 2.0/N * np.abs(yf[0:N/2]))
plt.subplot(2, 1, 2)
plt.plot(xf[1:], 2.0/N * np.abs(yf[0:N/2])[1:])
"""
Discrete Fourier Transforms - FFT.py

The underlying code for these functions is an f2c translated and modified
version of the FFTPACK routines.

fft(a, n=None, axis=-1)
ifft(a, n=None, axis=-1)
rfft(a, n=None, axis=-1)
irfft(a, n=None, axis=-1)
hfft(a, n=None, axis=-1)
ihfft(a, n=None, axis=-1)
fftn(a, s=None, axes=None)
ifftn(a, s=None, axes=None)
rfftn(a, s=None, axes=None)
irfftn(a, s=None, axes=None)
fft2(a, s=None, axes=(-2,-1))
ifft2(a, s=None, axes=(-2, -1))
rfft2(a, s=None, axes=(-2,-1))
irfft2(a, s=None, axes=(-2, -1))
"""
__all__ = ['fft','ifft', 'rfft', 'irfft', 'hfft', 'ihfft', 'rfftn',
           'irfftn', 'rfft2', 'irfft2', 'fft2', 'ifft2', 'fftn', 'ifftn',
           'refft', 'irefft','refftn','irefftn', 'refft2', 'irefft2']

from numpy.core import asarray, zeros, swapaxes, shape, conjugate, take
import fftpack_lite as fftpack
from helper import *

_fft_cache = {}
_real_fft_cache = {}

def _raw_fft(a, n=None, axis=-1, init_function=fftpack.cffti,
             work_function=fftpack.cfftf, fft_cache = _fft_cache ):
    a = asarray(a)

    if n == None: n = a.shape[axis]

    if n < 1: raise ValueError("Invalid number of FFT data points (%d) specified." % n)

    try:
        wsave = fft_cache[n]
    except(KeyError):
        wsave = init_function(n)
        fft_cache[n] = wsave

    if a.shape[axis] != n:
        s = list(a.shape)
        if s[axis] > n:
            index = [slice(None)]*len(s)
            index[axis] = slice(0,n)
            a = a[index]
        else:
            index = [slice(None)]*len(s)
            index[axis] = slice(0,s[axis])
            s[axis] = n
            z = zeros(s, a.dtype.char)
            z[index] = a
            a = z

    if axis != -1:
        a = swapaxes(a, axis, -1)
    r = work_function(a, wsave)
    if axis != -1:
        r = swapaxes(r, axis, -1)
    return r


def fft(a, n=None, axis=-1):
    """fft(a, n=None, axis=-1)

    Return the n point discrete Fourier transform of a. n defaults to
    the length of a. If n is larger than the length of a, then a will
    be zero-padded to make up the difference.  If n is smaller than
    the length of a, only the first n items in a will be used.

    The packing of the result is "standard": If A = fft(a, n), then A[0]
    contains the zero-frequency term, A[1:n/2+1] contains the
    positive-frequency terms, and A[n/2+1:] contains the negative-frequency
    terms, in order of decreasingly negative frequency. So for an 8-point
    transform, the frequencies of the result are [ 0, 1, 2, 3, 4, -3, -2, -1].

    This is most efficient for n a power of two. This also stores a cache of
    working memory for different sizes of fft's, so you could theoretically
    run into memory problems if you call this too many times with too many
    different n's."""

    return _raw_fft(a, n, axis, fftpack.cffti, fftpack.cfftf, _fft_cache)


def ifft(a, n=None, axis=-1):
    """ifft(a, n=None, axis=-1)

    Return the n point inverse discrete Fourier transform of a.  n
    defaults to the length of a. If n is larger than the length of a,
    then a will be zero-padded to make up the difference. If n is
    smaller than the length of a, then a will be truncated to reduce
    its size.

    The input array is expected to be packed the same way as the output of
    fft, as discussed in it's documentation.

    This is the inverse of fft: ifft(fft(a)) == a within numerical
    accuracy.

    This is most efficient for n a power of two. This also stores a cache of
    working memory for different sizes of fft's, so you could theoretically
    run into memory problems if you call this too many times with too many
    different n's."""

    a = asarray(a).astype(complex)
    if n == None:
        n = shape(a)[axis]
    return _raw_fft(a, n, axis, fftpack.cffti, fftpack.cfftb, _fft_cache) / n


def rfft(a, n=None, axis=-1):
    """rfft(a, n=None, axis=-1)

    Return the n point discrete Fourier transform of the real valued
    array a. n defaults to the length of a. n is the length of the
    input, not the output.

    The returned array will be the nonnegative frequency terms of the
    Hermite-symmetric, complex transform of the real array. So for an 8-point
    transform, the frequencies in the result are [ 0, 1, 2, 3, 4]. The first
    term will be real, as will the last if n is even. The negative frequency
    terms are not needed because they are the complex conjugates of the
    positive frequency terms. (This is what I mean when I say
    Hermite-symmetric.)

    This is most efficient for n a power of two."""

    a = asarray(a).astype(float)
    return _raw_fft(a, n, axis, fftpack.rffti, fftpack.rfftf, _real_fft_cache)


def irfft(a, n=None, axis=-1):
    """irfft(a, n=None, axis=-1)

    Return the real valued n point inverse discrete Fourier transform
    of a, where a contains the nonnegative frequency terms of a
    Hermite-symmetric sequence. n is the length of the result, not the
    input. If n is not supplied, the default is 2*(len(a)-1). If you
    want the length of the result to be odd, you have to say so.

    If you specify an n such that a must be zero-padded or truncated, the
    extra/removed values will be added/removed at high frequencies. One can
    thus resample a series to m points via Fourier interpolation by: a_resamp
    = irfft(rfft(a), m).

    This is the inverse of rfft:
    irfft(rfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(complex)
    if n == None:
        n = (shape(a)[axis] - 1) * 2
    return _raw_fft(a, n, axis, fftpack.rffti, fftpack.rfftb,
                    _real_fft_cache) / n


def hfft(a, n=None, axis=-1):
    """hfft(a, n=None, axis=-1)
    ihfft(a, n=None, axis=-1)

    These are a pair analogous to rfft/irfft, but for the
    opposite case: here the signal is real in the frequency domain and has
    Hermite symmetry in the time domain. So here it's hermite_fft for which
    you must supply the length of the result if it is to be odd.

    ihfft(hfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(complex)
    if n == None:
        n = (shape(a)[axis] - 1) * 2
    return irfft(conjugate(a), n, axis) * n


def ihfft(a, n=None, axis=-1):
    """hfft(a, n=None, axis=-1)
    ihfft(a, n=None, axis=-1)

    These are a pair analogous to rfft/irfft, but for the
    opposite case: here the signal is real in the frequency domain and has
    Hermite symmetry in the time domain. So here it's hfft for which
    you must supply the length of the result if it is to be odd.

    ihfft(hfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(float)
    if n == None:
        n = shape(a)[axis]
    return conjugate(rfft(a, n, axis))/n


def _cook_nd_args(a, s=None, axes=None, invreal=0):
    if s is None:
        shapeless = 1
        if axes == None:
            s = list(a.shape)
        else:
            s = take(a.shape, axes)
    else:
        shapeless = 0
    s = list(s)
    if axes == None:
        axes = range(-len(s), 0)
    if len(s) != len(axes):
        raise ValueError, "Shape and axes have different lengths."
    if invreal and shapeless:
        s[axes[-1]] = (s[axes[-1]] - 1) * 2
    return s, axes


def _raw_fftnd(a, s=None, axes=None, function=fft):
    a = asarray(a)
    s, axes = _cook_nd_args(a, s, axes)
    itl = range(len(axes))
    itl.reverse()
    for ii in itl:
        a = function(a, n=s[ii], axis=axes[ii])
    return a


def fftn(a, s=None, axes=None):
    """fftn(a, s=None, axes=None)

    The n-dimensional fft of a. s is a sequence giving the shape of the input
    an result along the transformed axes, as n for fft. Results are packed
    analogously to fft: the term for zero frequency in all axes is in the
    low-order corner, while the term for the Nyquist frequency in all axes is
    in the middle.

    If neither s nor axes is specified, the transform is taken along all
    axes. If s is specified and axes is not, the last len(s) axes are used.
    If axes are specified and s is not, the input shape along the specified
    axes is used. If s and axes are both specified and are not the same
    length, an exception is raised."""

    return _raw_fftnd(a,s,axes,fft)

def ifftn(a, s=None, axes=None):
    """ifftn(a, s=None, axes=None)

    The inverse of fftn."""

    return _raw_fftnd(a, s, axes, ifft)


def fft2(a, s=None, axes=(-2,-1)):
    """fft2(a, s=None, axes=(-2,-1))

    The 2d fft of a. This is really just fftn with different default
    behavior."""

    return _raw_fftnd(a,s,axes,fft)


def ifft2(a, s=None, axes=(-2,-1)):
    """ifft2(a, s=None, axes=(-2, -1))

    The inverse of fft2d. This is really just ifftn with different
    default behavior."""

    return _raw_fftnd(a, s, axes, ifft)


def rfftn(a, s=None, axes=None):
    """rfftn(a, s=None, axes=None)

    The n-dimensional discrete Fourier transform of a real array a. A real
    transform as rfft is performed along the axis specified by the last
    element of axes, then complex transforms as fft are performed along the
    other axes."""

    a = asarray(a).astype(float)
    s, axes = _cook_nd_args(a, s, axes)
    a = rfft(a, s[-1], axes[-1])
    for ii in range(len(axes)-1):
        a = fft(a, s[ii], axes[ii])
    return a

def rfft2(a, s=None, axes=(-2,-1)):
    """rfft2(a, s=None, axes=(-2,-1))

    The 2d fft of the real valued array a. This is really just rfftn with
    different default behavior."""

    return rfftn(a, s, axes)

def irfftn(a, s=None, axes=None):
    """irfftn(a, s=None, axes=None)

    The inverse of rfftn. The transform implemented in ifft is
    applied along all axes but the last, then the transform implemented in
    irfft is performed along the last axis. As with
    irfft, the length of the result along that axis must be
    specified if it is to be odd."""

    a = asarray(a).astype(complex)
    s, axes = _cook_nd_args(a, s, axes, invreal=1)
    for ii in range(len(axes)-1):
        a = ifft(a, s[ii], axes[ii])
    a = irfft(a, s[-1], axes[-1])
    return a

def irfft2(a, s=None, axes=(-2,-1)):
    """irfft2(a, s=None, axes=(-2, -1))

    The inverse of rfft2. This is really just irfftn with
    different default behavior."""

    return irfftn(a, s, axes)

# Deprecated names
from numpy import deprecate
refft = deprecate(rfft, 'refft', 'rfft')
irefft = deprecate(irfft, 'irefft', 'irfft')
refft2 = deprecate(rfft2, 'refft2', 'rfft2')
irefft2 = deprecate(irfft2, 'irefft2', 'irfft2')
refftn = deprecate(rfftn, 'refftn', 'rfftn')
irefftn = deprecate(irfftn, 'irefftn', 'irfftn')


import numpy as np
from scipy import fftpack


np.random.seed(1234)

time_step = 0.02
freqinp=0.2
period = 1/freqinp

time_vec = np.arange(0, 20, time_step)
sig = np.sin(2 * np.pi / period * time_vec) + \
      0.5 * np.random.randn(time_vec.size)

print 10

sample_freq = fftpack.fftfreq(sig.size, d=time_step)
sig_fft = fftpack.fft(sig)
pidxs = np.where(sample_freq > 0)
freqs, power = sample_freq[pidxs], np.abs(sig_fft)[pidxs]
freq = freqs[power.argmax()]

print freq, 24


from statistics import  *
from math import  *
from fractions import Fraction as F

def fib(n):
   if n == 0 or n == 1:
      return n
   else:
      return fib(n-1) + fib(n-2)
fiblis=[fib(n) for n in range(16)]
print(F(1,2),fiblis,mean(fiblis),stdev(fiblis),pstdev(fiblis)) #
print(stdev(fiblis)*sqrt(F(15,16)))


"""
nary - convert integer to a number with an arbitrary base.
"""

__all__ = ['nary']

_alphabet='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
def _getalpha(r):
    if r>=len(_alphabet):
        return '_'+nary(r-len(_alphabet),len(_alphabet))
    return _alphabet[r]

def nary(number, base=64):
    """
    Return string representation of a number with a given base.
    """
    if isinstance(number, str):
        number = eval(number)
    n = number
    s = ''
    while n:
        n1 = n // base
        r = n - n1*base
        n = n1
        s = _getalpha(r) + s
    return s

def encode(string):
    import md5
    return nary('0x'+md5.new(string).hexdigest())

#print nary(12345124254252525522512324,64)

import pdb
def combine(s1,s2):      # define subroutine combine, which...
    s3 = s1 + s2 + s1    # sandwiches s2 between copies of s1, ...
    s3 = '"' + s3 +'"'   # encloses it in double quotes,...
    return s3            # and returns it.

a = "aaa"
pdb.set_trace()
b = "bbb"
c = "ccc"
final = combine(a,b)
print final


my_list = [12, 5, 13, 8, 9, 65]
def bubble(bad_list):
    length = len(bad_list) - 1
    sorted = False

    while not sorted:
        sorted = True
        for i in range(length):
            if bad_list[i] > bad_list[i+1]:
                sorted = False
                bad_list[i], bad_list[i+1] = bad_list[i+1], bad_list[i]

bubble(my_list)
print my_list

"""
http://stackoverflow.com/questions/895371/bubble-sort-homework
n <enter>
<enter>
p <variable>
q
c
l
s
r
source http://pythonconquerstheuniverse.wordpress.com/category/python-debugger/
http://www.youtube.com/watch?v=bZZTeKPRSLQ
"""

import Numeric
def foo(a):
    a = Numeric.array(a)
    m,n = a.shape
    for i in range(m):
        for j in range(n):
            a[i,j] = a[i,j] + 10*(i+1) + (j+1)
    return a

#playing with output of https://github.com/animesh/RawRead
import pandas as pd
#df=pd.read_table('/home/animeshs/Documents/RawRead/20150512_BSA_The-PEG-envelope.raw.intensity0.charge0.FFT.txt')#, low_memory=False)
df=pd.read_table('/home/animeshs/Documents/RawRead/20150512_BSA_The-PEG-envelope.raw.profile.intensity0.charge0.MS.txt')
df.describe()
df.hist()
import numpy as np
log2df=np.log2(df)#['intensity'])
log2df.hist()

#check with https://github.com/animesh/ann/blob/master/ann/Program.cs
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidden=2
hidw=[[0.4,0.45],[0.5,0.55]]
outputc=2
outputr=[0.01,0.99]
bias=[0.35,0.6]
cons=[1,1]
lr=0.5
error=1
itr=1000

#https://github.com/jcjohnson/pytorch-examples/blob/master/README.md  numpy
import numpy as np
x=np.asarray(inp)
y=np.asarray(outputr)
b=np.asarray(bias)
w1=np.asarray(inpw)
w1=w1.T
w2=np.asarray(hidw)
w2=w2.T
print(x,y,b,w1,w2)

h=1/(1+np.exp(-(x.dot(w1)+bias[0])))
y_pred=1/(1+np.exp(-(h.dot(w2)+bias[1])))
0.5*np.square(y_pred - y).sum()

w3=w2-lr*np.outer((y_pred - y)*(1-y_pred)*y_pred,h).T
w2-lr*(y_pred[1] - y[1])*(1-y_pred[1])*y_pred[1]*h[1]
w2-lr*(y_pred[0] - y[0])*(1-y_pred[0])*y_pred[0]*h[0]
w4=w1-lr*sum((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x

h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()

w3-=lr*(y_pred - y)*(1-y_pred)*y_pred*h
w4=w4-lr*sum(((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x
h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()


import random
import torch
N=22
scale=10
D_in, H, D_out = N*scale*scale, N*scale*scale, N*scale

class DynamicNet(torch.nn.Module):
    def __init__(self, D_in, H, D_out):
        super(DynamicNet, self).__init__()
        self.input_linear = torch.nn.Linear(D_in, H)
        self.middle_linear = torch.nn.Linear(H, H)
        self.output_linear = torch.nn.Linear(H, D_out)
    def forward(self, x):
        h_relu = self.input_linear(x).clamp(min=0)
        for _ in range(random.randint(0, int(N/scale))):
            h_relu = self.middle_linear(h_relu).clamp(min=0)
        y_pred = self.output_linear(h_relu)
        return y_pred

x = torch.randn(N, D_in)
y = torch.randn(N, D_out)

model = DynamicNet(D_in, H, D_out)

criterion = torch.nn.MSELoss(reduction='sum')
optimizer = torch.optim.SGD(model.parameters(), lr=1e-4, momentum=0.9)


import numpy as np
import dask.array as da
x = da.random.random((100000, 2000), chunks=(10000, 2000))
y = da.from_array(x, chunks=(100))
y.mean().compute()

import time

t0 = time.time()
q, r = da.linalg.qr(x)
test = da.all(da.isclose(x, q.dot(r)))
assert(test.compute()) # compute(get=dask.threaded.get) by default
print(time.time() - t0)
# python -m TBB intelCompilerTest.py

%matplotlib inline
import pandas as pd
import matplotlib.pyplot as plt
plt.hist(np.random.random_sample(10000))

import tensorflow as tf
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
a = tf.constant(12)
b = tf.constant(32)
print(sess.run(a * b))

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

sc.stop()

import findspark
findspark.init()
import pyspark
conf = pyspark.SparkConf()
conf.setAppName("pepXMLtoJSON")
conf.set("spark.executor.memory", "8g").set(
    "spark.executor.cores", "3").set("spark.cores.max", "12")
conf.set("spark.jars.packages", "com.databricks:spark-xml_2.11:0.4.1")
sc = pyspark.SparkContext(conf=conf)
rdd = sc.parallelize(reversed([1, 2, 3, 4]))
rdd.map(lambda s: s**s**s).take(4)

from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)
df = sqlContext.read.format('com.databricks.spark.xml').options(
    rootTag='msms_pipeline_analysis', rowTag='spectrum_query').load('jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.xml')
df.show()
selectedData = df.select("search_result")
selectedData.printSchema
selectedData.collect().take(2)
selectedData = selectedData.toJSON
selectedData.saveAsTextFile(
    "jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.json")

```python
inpF <-"L://Animesh/mouseSILAC/dePepSS1LFQ1/proteinGroups.txt"
data <- read.delim(inpF, row.names = 1, sep = "\t", header = T)
summary(data)
```

import pandas as pd
table = pd.read_excel('L://Animesh/Lymphoma/TrpofSuperSILACpTtestImp.xlsx')
#table = pd.read_excel('/home/animeshs/scripts/vals.xlsx')
%matplotlib inline
import numpy as np
x=np.linspace(0.0, 100.0, num=500)
import matplotlib.pyplot as plt
plt.plot(x,np.sin(x))
x=2*x
plt.show()
table.A0A024QZX5.plot.hist(alpha=0.5)

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

import matplotlib.pyplot as plt
import numpy as np
from pyteomics import fasta, parser, mass, achrom, electrochem, auxiliary
print 'Cleaving the proteins with trypsin...'
unique_peptides = set()
for description, sequence in fasta.read('uniprot-proteome-human.fasta'):
    new_peptides = parser.cleave(sequence, parser.expasy_rules['trypsin'])
    unique_peptides.update(new_peptides)
print('Done, {0} sequences obtained!'.format(len(unique_peptides)))
peptides = [{'sequence': i} for i in unique_peptides]
#peptides = [peptide for peptide in peptides if peptide['length'] <= 100]
unique_peptides
proteins = fasta.read('uniprot-proteome-human.fasta')
proteins.reset


def fragments(peptide, types, maxcharge):
    for i in range(1, len(peptide)):
        for ion_type in types:
            for charge in range(1, maxcharge + 1):
                if ion_type[0] in 'abc':
                    yield mass.fast_mass(
                        peptide[:i], ion_type=ion_type, charge=charge)
                else:
                    yield mass.fast_mass(
                        peptide[i:], ion_type=ion_type, charge=charge)


theor_spectrum = list(fragments('MIGQK', ('b', 'y'), maxcharge=1))
print(theor_spectrum)
import pandas as pd
# massaa => https://en.wikipedia.org/w/index.php?title=Proteinogenic_amino_acid&section=2
aamm = pd.read_table('/home/animeshs/scripts/massaa')
aamm.dtypes
aamm['Mon. Mass§ (Da)']
# https://en.wikipedia.org/wiki/De_novo_peptide_sequencing
mmH2O = 18.01056
mmProton = 1.00728
pep = 'GLSDGEWQQVLNVWGK'
# http://www.ionsource.com/tutorial/DeNovo/b_and_y.htm
# pep='MIGQK'
tMass = 0.0
bIon = 0.0
bIon_list = []
yIon_list = []
pep_list = []
for b in range(0, len(pep)):
    pep_list.append(pep[b])
    tMass = tMass + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values
    bIon = bIon + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values[0]
    bIon_list.append(bIon + mmProton)
    yIon = 0.0
    for y in range(b, len(pep)):
        yIon = yIon + aamm[aamm['Short'] ==
                           pep[y]]['Mon. Mass§ (Da)'].values[0]
    yIon_list.append(yIon + mmH2O + mmProton)
print(pep_list, bIon_list, bIon_list, tMass + mmH2O)
import matplotlib.pyplot as plt
plt.stem(yIon_list, bIon_list, 'r')
plt.stem(bIon_list, bIon_list, 'b')
plt.xticks(bIon_list, pep_list)


from pomegranate import *
import numpy as np
import pylab as plt

data = np.concatenate((np.random.randn(250, 1) * 2.75 + 1.25, np.random.randn(500, 1) * 1.2 + 7.85))
np.random.shuffle(data)
data = table['Monoisotopic mass'].values
plt.hist(data, edgecolor='c', color='c', bins=100)
#d = GeneralMixtureModel( [NormalDistribution(2.5, 1), NormalDistribution(8, 1)] )
d = GeneralMixtureModel([aamm['Mon. Mass§ (Da)'].values])
labels = d.predict(data)
print(labels[:5])
print("{} 1 labels, {} 0 labels".format(
    labels.sum(), labels.shape[0] - labels.sum()))
plt.hist(data[labels == 0], edgecolor='r', color='r', bins=20)
plt.hist(data[labels == 1], edgecolor='c', color='c', bins=20)


d.fit(data, verbose=True)

train_data = get_training_data()
test_data = get_test_data()

# Construct the module, providing any configuration necessary.
linear_regression_module = snt.Linear(output_size=FLAGS.output_size)

# Connect the module to some inputs, any number of times.
train_predictions = linear_regression_module(train_data)
test_predictions = linear_regression_module(test_data)

df = pd.DataFrame({
    'Letter': ['a', 'a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'],
    'X': [4, 3, 5, 2, 1, 7, 7, 5, 9],
    'Y': [0, 4, 3, 6, 7, 10, 11, 9, 13],
    'Z': [0.2, 2, 3, 1, 2, 3, 1, 2, 3]
})


df

# wget http://www.unimod.org/modifications_list.php?pagesize=13800
import pandas as pd
table = pd.read_table('/home/animeshs/scripts/unimod')
%matplotlib inline
table['Monoisotopic mass'].plot.hist(alpha=0.6)
table['Average mass'].plot.hist(alpha=0.4)


for i in range(4):
    print(i)


import numpy as np
import tensorflow as tf

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)

Xtr, Ytr = mnist.train.next_batch(5000)  # 5000 for training (nn candidates)
Xte, Yte = mnist.test.next_batch(200)  # 200 for testing

# tf Graph Input
xtr = tf.placeholder("float", [None, 784])
xte = tf.placeholder("float", [784])

# Nearest Neighbor calculation using L1 Distance
# Calculate L1 Distance
distance = tf.reduce_sum(
    tf.abs(tf.add(xtr, tf.negative(xte))), reduction_indices=1)
# Prediction: Get min distance index (Nearest neighbor)
pred = tf.arg_min(distance, 0)

accuracy = 0.

# Initializing the variables
init = tf.global_variables_initializer()

# Launch the graph
with tf.Session() as sess:
    sess.run(init)

    # loop over test data
    for i in range(len(Xte)):
        # Get nearest neighbor
        nn_index = sess.run(pred, feed_dict={xtr: Xtr, xte: Xte[i, :]})
        # Get nearest neighbor class label and compare it to its true label
        print("Test", i, "Prediction:", np.argmax(Ytr[nn_index]),
              "True Class:", np.argmax(Yte[i]))
        # Calculate accuracy
        if np.argmax(Ytr[nn_index]) == np.argmax(Yte[i]):
            accuracy += 1. / len(Xte)
    print("Done!")
    print("Accuracy:", accuracy)
from pyNN.recording import gather
import numpy
from mpi4py import MPI
import time

comm = MPI.COMM_WORLD

for x in range(7):
    N = pow(10, x)
    local_data = numpy.empty((N,2))
    local_data[:,0] = numpy.ones(N, dtype=float)*comm.rank
    local_data[:,1] = numpy.random.rand(N)

    start_time = time.time()
    all_data = gather(local_data)
    #print comm.rank, "local", local_data
    if comm.rank == 0:
    #    print "all", all_data
        print N, time.time()-start_time



#https://threader.app/thread/1105139360226140160
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0
tf.executing_eagerly()
tf.test.is_gpu_available()#:with tf.device("/gpu:0"):
#tf.keras.backend.clear_session()

def create_model():
  return tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(512, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10, activation='softmax')
  ])

model = create_model()
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

log_dir="logs\\fit\\" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)

model.fit(x=x_train,
          y=y_train,
          epochs=5,
          validation_data=(x_test, y_test),
          callbacks=[tensorboard_callback])

# Source: https://stackoverflow.com/a/49555937
import tensorflow as tf
from tensorboard import main as tb
tb.logger=log_dir



@tf.custom_gradient
def log1pexp(x):
  e = tf.exp(x)
  def grad(dy):
    return dy * (1 - 1 / (1 + e))
  return tf.math.log(1 + e), grad


def grad_log1pexp(x):
  with tf.GradientTape() as tape:
    tape.watch(x)
    value = log1pexp(x)
  return tape.gradient(value, x)

grad_log1pexp(tf.constant(100.))#.numpy()

regularization = tf.nn.l2_loss(w1) + tf.nn.l2_loss(w2)
loss = tf.reduce_mean(tf.square(layer_2 - y))
learning_rate = lr

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(2,1)),
  tf.keras.layers.Dense(2, activation='relu'),
  tf.keras.layers.Dense(2, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

#model.fit(x.reshape(2,1), y, epochs=1,steps_per_epoch=1)
#model.fit([[2,1],[1,2],[1,1]], y, epochs=1,steps_per_epoch=1)
#model.evaluate(x, y)


#https://www.tensorflow.org/alpha/guide/autograph
@tf.function
def simple_nn_layer(x, y):
  return tf.nn.relu(tf.matmul(x, y))


x = tf.random.uniform((3, 3))
y = tf.random.uniform((3, 3))

simple_nn_layer(x, y)

def square_if_positive_vectorized(x):
  return tf.where(x > 0, x ** 2, x)

square_if_positive_vectorized(tf.range(-5, 5))

from tensorflow.keras import layers
original_dim = 784
intermediate_dim = 64
latent_dim = 32

class Sampling(layers.Layer):
  """Uses (z_mean, z_log_var) to sample z, the vector encoding a digit."""

  def call(self, inputs):
    z_mean, z_log_var = inputs
    batch = tf.shape(z_mean)[0]
    dim = tf.shape(z_mean)[1]
    epsilon = tf.keras.backend.random_normal(shape=(batch, dim))
    return z_mean + tf.exp(0.5 * z_log_var) * epsilon
# Define encoder model.
original_inputs = tf.keras.Input(shape=(original_dim,), name='encoder_input')
x = layers.Dense(intermediate_dim, activation='relu')(original_inputs)
z_mean = layers.Dense(latent_dim, name='z_mean')(x)
z_log_var = layers.Dense(latent_dim, name='z_log_var')(x)
z = Sampling()((z_mean, z_log_var))
encoder = tf.keras.Model(inputs=original_inputs, outputs=z, name='encoder')

# Define decoder model.
latent_inputs = tf.keras.Input(shape=(latent_dim,), name='z_sampling')
x = layers.Dense(intermediate_dim, activation='relu')(latent_inputs)
outputs = layers.Dense(original_dim, activation='sigmoid')(x)
decoder = tf.keras.Model(inputs=latent_inputs, outputs=outputs, name='decoder')

# Define VAE model.
outputs = decoder(z)
vae = tf.keras.Model(inputs=original_inputs, outputs=outputs, name='vae')

# Add KL divergence regularization loss.
kl_loss = - 0.5 * tf.reduce_sum(
    z_log_var - tf.square(z_mean) - tf.exp(z_log_var) + 1)
vae.add_loss(kl_loss)

# Train.
optimizer = tf.keras.optimizers.Adam(learning_rate=1e-3)
vae.compile(optimizer, loss=tf.keras.losses.MeanSquaredError())
(x_train, _), _ = tf.keras.datasets.mnist.load_data()
x_train = x_train.reshape(60000, 784).astype('float32') / 255
vae.fit(x_train, x_train, epochs=3, batch_size=64)


#https://www.tensorflow.org/tensorboard/r2/get_started
import datetime
current_time = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
train_log_dir = 'logs/gradient_tape/' + current_time + '/train'
test_log_dir = 'logs/gradient_tape/' + current_time + '/test'
train_summary_writer = tf.summary.create_file_writer(train_log_dir)
test_summary_writer = tf.summary.create_file_writer(test_log_dir)
tf.summary.summary_scope
#train_loss.reset_states()
#test_loss.reset_states()
#train_accuracy.reset_states()
#test_accuracy.reset_states()

#!python3 -m tensorflow.tensorboard  --logdir logs/gradient_tape
#python -m tensorflow.tensorboard
#%tensorboard --logdir logs/gradient_tape

import pandas as pd
data = pd.read_csv('F:/OneDrive - NTNU/UTR/data2.csv')
data.head()
data.describe()

import matplotlib.pyplot as plt
import numpy as np
data['RFPlog']=np.log2(data['Fluorescence'])
data['RFPlog'].hist()

data['ReadsLog']=np.log2(data['#Reads Col'])
data['ReadsLog'].hist()
plt.scatter(data['RFPlog'],data['ReadsLog'])
plt.scatter(data['RFPlog'],data['ReadsLog'])

from functools import reduce
DNAortho = ('A','1000') , ('T','0100') ,  ('G','0010'), ('C','0001')
data['DNASeqOrtho']=reduce(lambda a, kv: a.str.replace(*kv), DNAortho, data['Sequence'])
print(data['DNASeqOrtho'])


df = data.dropna(axis=1, how='all')
df = df.dropna(axis=0, how='all')

input=df['DNASeqOrtho'].apply(lambda x: pd.Series(list(x)))
input = input.dropna(axis=1, how='all')
input = input.dropna(axis=0, how='all')
input.describe()

output=data['RFPlog']
output.describe()

import seaborn as sns
corr=input.corr()
sns.heatmap(corr)
#sns.pairplot(input)
#https://colab.research.google.com/github/kweinmeister/notebooks/blob/master/tensorflow-shap-college-debt.ipynb#scrollTo=NSmjv4K4sl8C
def build_model(df):
  model = keras.Sequential([
    layers.Dense(16, activation=tf.nn.relu, input_shape=[len(df.keys())]),
    layers.Dense(16, activation=tf.nn.relu),
    layers.Dense(1)
  ])

  # TF 2.0: optimizer = tf.keras.optimizers.RMSprop()
  optimizer = tf.keras.optimizers.RMSprop()
  # optimizer = tf.train.RMSPropOptimizer(learning_rate=0.001)

  model.compile(loss='mse',
                optimizer=optimizer,
                metrics=['mae'])
  return model

model = build_model(df_train_normed)
model.summary()

class PrintDot(keras.callbacks.Callback):
  def on_epoch_end(self, epoch, logs):
    if epoch % 100 == 0: print('')
    print('.', end='')

EPOCHS = 1000
early_stop = keras.callbacks.EarlyStopping(monitor='val_loss', patience=50)

history = model.fit(
  df_train_normed, train_labels,
  epochs=EPOCHS, validation_split = 0.2, verbose=0,
  callbacks=[early_stop, PrintDot()])
 hist = pd.DataFrame(history.history)
hist['epoch'] = history.epoch

def plot_history(history):
  plt.figure()
  plt.xlabel('Epoch')
  plt.ylabel('Mean Absolute Error')
  plt.plot(hist['epoch'], hist['mean_absolute_error'],
           label='Train Error')
  plt.plot(hist['epoch'], hist['val_mean_absolute_error'],
           label = 'Val Error')
  plt.legend()
plot_history(history)


import shap
shap.initjs()
df_train_normed_summary = shap.kmeans(df_train_normed.values, 25)
explainer = shap.KernelExplainer(model.predict, df_train_normed_summary)
shap_values = explainer.shap_values(df_train_normed.values)
shap.summary_plot(shap_values[0], df_train)
INSTANCE_NUM = 0
shap.force_plot(explainer.expected_value[0], shap_values[0][INSTANCE_NUM], df_train.iloc[INSTANCE_NUM,:])
NUM_ROWS = 10
shap.force_plot(explainer.expected_value[0], shap_values[0][0:NUM_ROWS], df_train.iloc[0:NUM_ROWS])
shap.dependence_plot('FIRST_GEN', shap_values[0], df_train, interaction_index='PPTUG_EF')
explainer = shap.DeepExplainer(model, df_train_normed)
shap_values = explainer.shap_values(df_train_normed.values)
shap.summary_plot(shap_values[0], df_train)


import autokeras as ak
clf = ak.ImageClassifier()
clf.fit(input, output)
results = clf.predict(input)



import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train),(x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(512, activation=tf.nn.relu),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation=tf.nn.softmax)
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test, y_test)




def variable_summaries(var):
  """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""
  with tf.name_scope('summaries'):
    mean = tf.reduce_mean(var)
    tf.summary.scalar('mean', mean)
    with tf.name_scope('stddev'):
      stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
    tf.summary.scalar('stddev', stddev)
    tf.summary.scalar('max', tf.reduce_max(var))
    tf.summary.scalar('min', tf.reduce_min(var))
    tf.summary.histogram('histogram', var)

def nn_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.relu):
  """Reusable code for making a simple neural net layer.

  It does a matrix multiply, bias add, and then uses relu to nonlinearize.
  It also sets up name scoping so that the resultant graph is easy to read,
  and adds a number of summary ops.
  """
  # Adding a name scope ensures logical grouping of the layers in the graph.
  with tf.name_scope(layer_name):
    # This Variable will hold the state of the weights for the layer
    with tf.name_scope('weights'):
      weights = weight_variable([input_dim, output_dim])
      variable_summaries(weights)
    with tf.name_scope('biases'):
      biases = bias_variable([output_dim])
      variable_summaries(biases)
    with tf.name_scope('Wx_plus_b'):
      preactivate = tf.matmul(input_tensor, weights) + biases
      tf.summary.histogram('pre_activations', preactivate)
    activations = act(preactivate, name='activation')
    tf.summary.histogram('activations', activations)
    return activations

#hidden1 = nn_layer(x_train, 784, 500, 'layer1')

with tf.name_scope('dropout'):
  keep_prob = tf.placeholder(tf.float32)
  tf.summary.scalar('dropout_keep_probability', keep_prob)
  dropped = tf.nn.dropout(hidden1, keep_prob)

# Do not apply softmax activation yet, see below.
y = nn_layer(dropped, 500, 10, 'layer2', act=tf.identity)

with tf.name_scope('cross_entropy'):
  # The raw formulation of cross-entropy,
  #
  # tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.softmax(y)),
  #                               reduction_indices=[1]))
  #
  # can be numerically unstable.
  #
  # So here we use tf.losses.sparse_softmax_cross_entropy on the
  # raw logit outputs of the nn_layer above.
  with tf.name_scope('total'):
    cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
tf.summary.scalar('cross_entropy', cross_entropy)

with tf.name_scope('train'):
  train_step = tf.train.AdamOptimizer(FLAGS.learning_rate).minimize(
      cross_entropy)

with tf.name_scope('accuracy'):
  with tf.name_scope('correct_prediction'):
    correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
  with tf.name_scope('accuracy'):
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
tf.summary.scalar('accuracy', accuracy)

# Merge all the summaries and write them out to /tmp/mnist_logs (by default)
merged = tf.summary.merge_all()
train_writer = tf.summary.FileWriter(FLAGS.summaries_dir + '/train',
                                      sess.graph)
test_writer = tf.summary.FileWriter(FLAGS.summaries_dir + '/test')
tf.global_variables_initializer().run()



# Train the model, and also write summaries.
# Every 10th step, measure test-set accuracy, and write test summaries
# All other steps, run train_step on training data, & add training summaries

def feed_dict(train):
  """Make a TensorFlow feed_dict: maps data onto Tensor placeholders."""
  if train or FLAGS.fake_data:
    xs, ys = mnist.train.next_batch(100, fake_data=FLAGS.fake_data)
    k = FLAGS.dropout
  else:
    xs, ys = mnist.test.images, mnist.test.labels
    k = 1.0
  return {x: xs, y_: ys, keep_prob: k}

for i in range(FLAGS.max_steps):
  if i % 10 == 0:  # Record summaries and test-set accuracy
    summary, acc = sess.run([merged, accuracy], feed_dict=feed_dict(False))
    test_writer.add_summary(summary, i)
    print('Accuracy at step %s: %s' % (i, acc))
  else:  # Record train set summaries, and train
    summary, _ = sess.run([merged, train_step], feed_dict=feed_dict(True))
    train_writer.add_summary(summary, i)




tensorboard --logdir=path/to/log-directory



def variable_summaries(var):
  """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""
  with tf.name_scope('summaries'):
    mean = tf.reduce_mean(var)
    tf.summary.scalar('mean', mean)
    with tf.name_scope('stddev'):
      stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
    tf.summary.scalar('stddev', stddev)
    tf.summary.scalar('max', tf.reduce_max(var))
    tf.summary.scalar('min', tf.reduce_min(var))
    tf.summary.histogram('histogram', var)

def nn_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.relu):
  """Reusable code for making a simple neural net layer.

  It does a matrix multiply, bias add, and then uses ReLU to nonlinearize.
  It also sets up name scoping so that the resultant graph is easy to read,
  and adds a number of summary ops.
  """
  # Adding a name scope ensures logical grouping of the layers in the graph.
  with tf.name_scope(layer_name):
    # This Variable will hold the state of the weights for the layer
    with tf.name_scope('weights'):
      weights = weight_variable([input_dim, output_dim])
      variable_summaries(weights)
    with tf.name_scope('biases'):
      biases = bias_variable([output_dim])
      variable_summaries(biases)
    with tf.name_scope('Wx_plus_b'):
      preactivate = tf.matmul(input_tensor, weights) + biases
      tf.summary.histogram('pre_activations', preactivate)
    activations = act(preactivate, name='activation')
    tf.summary.histogram('activations', activations)
    return activations

hidden1 = nn_layer(x, 784, 500, 'layer1')

with tf.name_scope('dropout'):
  keep_prob = tf.placeholder(tf.float32)
  tf.summary.scalar('dropout_keep_probability', keep_prob)
  dropped = tf.nn.dropout(hidden1, keep_prob)

# Do not apply softmax activation yet, see below.
y = nn_layer(dropped, 500, 10, 'layer2', act=tf.identity)

with tf.name_scope('cross_entropy'):
  # The raw formulation of cross-entropy,
  #
  # tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.softmax(y)),
  #                               reduction_indices=[1]))
  #
  # can be numerically unstable.
  #
  # So here we use tf.losses.sparse_softmax_cross_entropy on the
  # raw logit outputs of the nn_layer above, and then average across
  # the batch.
  with tf.name_scope('total'):
    cross_entropy = tf.losses.sparse_softmax_cross_entropy(
        labels=y_, logits=y)
tf.summary.scalar('cross_entropy', cross_entropy)

with tf.name_scope('train'):
  train_step = tf.train.AdamOptimizer(FLAGS.learning_rate).minimize(
      cross_entropy)

with tf.name_scope('accuracy'):
  with tf.name_scope('correct_prediction'):
    correct_prediction = tf.equal(tf.argmax(y, 1), y_)
  with tf.name_scope('accuracy'):
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
tf.summary.scalar('accuracy', accuracy)

# Merge all the summaries and write them out to
# /tmp/tensorflow/mnist/logs/mnist_with_summaries (by default)
merged = tf.summary.merge_all()
train_writer = tf.summary.FileWriter(FLAGS.log_dir + '/train', sess.graph)
test_writer = tf.summary.FileWriter(FLAGS.log_dir + '/test')
tf.global_variables_initializer().run()



import tensorflow as tf
import numpy as np

X_train = (np.random.sample((10000,5)))
y_train =  (np.random.sample((10000,1)))
X_train.shape

feature_columns = [
      tf.feature_column.numeric_column('x', shape=X_train.shape[1:])]
DNN_reg = tf.estimator.DNNRegressor(feature_columns=feature_columns,
# Indicate where to store the log file
     model_dir='train/linreg',
     hidden_units=[500, 300],
     optimizer=tf.train.AdamOptimizer(
          learning_rate=0.1,
          l1_regularization_strength=0.001
      )
)

# Train the estimator
train_input = tf.estimator.inputs.numpy_input_fn(
     x={"x": X_train},
     y=y_train, shuffle=False,num_epochs=None)
DNN_reg.train(train_input,steps=3000)


import tensorflow as tf

k = tf.float32

# Make a normal distribution, with a shifting mean
mean_moving_normal = tf.random_normal(shape=[1000], mean=(5*k), stddev=1)
# Record that distribution into a histogram summary
tf.summary.histogram("normal/moving_mean", mean_moving_normal)

# Setup a session and summary writer
sess = tf.Session()
writer = tf.summary.FileWriter("/tmp/histogram_example")

summaries = tf.summary.merge_all()

# Setup a loop and write the summaries to disk
N = 400
for step in range(N):
  k_val = step/float(N)
  summ = sess.run(summaries, feed_dict={k: k_val})
  writer.add_summary(summ, global_step=step)


import tensorflow as tf
import tensorflow_probability as tfp

# Pretend to load synthetic data set.
features = tfp.distributions.Normal(loc=0., scale=1.).sample(int(100e3))
labels = tfp.distributions.Bernoulli(logits=1.618 * features).sample()

# Specify model.
model = tfp.glm.Bernoulli()

# Fit model given data.
coeffs, linear_response, is_converged, num_iter = tfp.glm.fit(
    model_matrix=features[:, tf.newaxis],
    response=tf.cast(labels,tf.float32),
    model=model)

#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#!sudo pip3 install tf-nightly-2.0-preview #guide https://threader.app/thread/1105139360226140160
import tensorflow as tf
print(tf.__version__)
#tf.enable_eager_execution()
tf.executing_eagerly()
tf.test.is_gpu_available()#:with tf.device("/gpu:0"):
tf.keras.backend.clear_session()

inp=[0.05,0.10]
inpw=[[0.15,0.25],[0.20,0.3]]
hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

w1 = tf.Variable(inpw)
w2 = tf.Variable(hidw)
x = tf.constant(inp)
y = tf.constant(outputr)

layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
print(layer_2)

@tf.custom_gradient
def log1pexp(x):
  e = tf.exp(x)
  def grad(dy):
    return dy * (1 - 1 / (1 + e))
  return tf.math.log(1 + e), grad


def grad_log1pexp(x):
  with tf.GradientTape() as tape:
    tape.watch(x)
    value = log1pexp(x)
  return tape.gradient(value, x)

grad_log1pexp(tf.constant(100.))#.numpy()

regularization = tf.nn.l2_loss(w1) + tf.nn.l2_loss(w2)
loss = tf.reduce_mean(tf.square(layer_2 - y))
learning_rate = lr

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(2,1)),
  tf.keras.layers.Dense(2, activation='relu'),
  tf.keras.layers.Dense(2, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

#model.fit(x.reshape(2,1), y, epochs=1,steps_per_epoch=1)
#model.fit([[2,1],[1,2],[1,1]], y, epochs=1,steps_per_epoch=1)
#model.evaluate(x, y)


#https://www.tensorflow.org/alpha/guide/autograph
@tf.function
def simple_nn_layer(x, y):
  return tf.nn.relu(tf.matmul(x, y))


x = tf.random.uniform((3, 3))
y = tf.random.uniform((3, 3))

simple_nn_layer(x, y)

def square_if_positive_vectorized(x):
  return tf.where(x > 0, x ** 2, x)

square_if_positive_vectorized(tf.range(-5, 5))

from tensorflow.keras import layers
original_dim = 784
intermediate_dim = 64
latent_dim = 32

class Sampling(layers.Layer):
  """Uses (z_mean, z_log_var) to sample z, the vector encoding a digit."""

  def call(self, inputs):
    z_mean, z_log_var = inputs
    batch = tf.shape(z_mean)[0]
    dim = tf.shape(z_mean)[1]
    epsilon = tf.keras.backend.random_normal(shape=(batch, dim))
    return z_mean + tf.exp(0.5 * z_log_var) * epsilon
# Define encoder model.
original_inputs = tf.keras.Input(shape=(original_dim,), name='encoder_input')
x = layers.Dense(intermediate_dim, activation='relu')(original_inputs)
z_mean = layers.Dense(latent_dim, name='z_mean')(x)
z_log_var = layers.Dense(latent_dim, name='z_log_var')(x)
z = Sampling()((z_mean, z_log_var))
encoder = tf.keras.Model(inputs=original_inputs, outputs=z, name='encoder')

# Define decoder model.
latent_inputs = tf.keras.Input(shape=(latent_dim,), name='z_sampling')
x = layers.Dense(intermediate_dim, activation='relu')(latent_inputs)
outputs = layers.Dense(original_dim, activation='sigmoid')(x)
decoder = tf.keras.Model(inputs=latent_inputs, outputs=outputs, name='decoder')

# Define VAE model.
outputs = decoder(z)
vae = tf.keras.Model(inputs=original_inputs, outputs=outputs, name='vae')

# Add KL divergence regularization loss.
kl_loss = - 0.5 * tf.reduce_sum(
    z_log_var - tf.square(z_mean) - tf.exp(z_log_var) + 1)
vae.add_loss(kl_loss)

# Train.
optimizer = tf.keras.optimizers.Adam(learning_rate=1e-3)
vae.compile(optimizer, loss=tf.keras.losses.MeanSquaredError())
(x_train, _), _ = tf.keras.datasets.mnist.load_data()
x_train = x_train.reshape(60000, 784).astype('float32') / 255
vae.fit(x_train, x_train, epochs=3, batch_size=64)


#https://www.tensorflow.org/tensorboard/r2/get_started
import datetime
current_time = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
train_log_dir = 'logs/gradient_tape/' + current_time + '/train'
test_log_dir = 'logs/gradient_tape/' + current_time + '/test'
train_summary_writer = tf.summary.create_file_writer(train_log_dir)
test_summary_writer = tf.summary.create_file_writer(test_log_dir)
tf.summary.summary_scope
#train_loss.reset_states()
#test_loss.reset_states()
#train_accuracy.reset_states()
#test_accuracy.reset_states()

#!python3 -m tensorflow.tensorboard  --logdir logs/gradient_tape
#python -m tensorflow.tensorboard
#%tensorboard --logdir logs/gradient_tape

import pandas as pd
data = pd.read_csv('F:/OneDrive - NTNU/UTR/data2.csv')
data.head()
data.describe()

import matplotlib.pyplot as plt
import numpy as np
data['RFPlog']=np.log2(data['Fluorescence'])
data['RFPlog'].hist()

data['ReadsLog']=np.log2(data['#Reads Col'])
data['ReadsLog'].hist()
plt.scatter(data['RFPlog'],data['ReadsLog'])
plt.scatter(data['RFPlog'],data['ReadsLog'])

from functools import reduce
DNAortho = ('A','1000') , ('T','0100') ,  ('G','0010'), ('C','0001')
data['DNASeqOrtho']=reduce(lambda a, kv: a.str.replace(*kv), DNAortho, data['Sequence'])
print(data['DNASeqOrtho'])


df = data.dropna(axis=1, how='all')
df = df.dropna(axis=0, how='all')

input=df['DNASeqOrtho'].apply(lambda x: pd.Series(list(x)))
input = input.dropna(axis=1, how='all')
input = input.dropna(axis=0, how='all')
input.describe()

output=data['RFPlog']
output.describe()

import seaborn as sns
corr=input.corr()
sns.heatmap(corr)
#sns.pairplot(input)
#https://colab.research.google.com/github/kweinmeister/notebooks/blob/master/tensorflow-shap-college-debt.ipynb#scrollTo=NSmjv4K4sl8C
def build_model(df):
  model = keras.Sequential([
    layers.Dense(16, activation=tf.nn.relu, input_shape=[len(df.keys())]),
    layers.Dense(16, activation=tf.nn.relu),
    layers.Dense(1)
  ])

  # TF 2.0: optimizer = tf.keras.optimizers.RMSprop()
  optimizer = tf.keras.optimizers.RMSprop()
  # optimizer = tf.train.RMSPropOptimizer(learning_rate=0.001)

  model.compile(loss='mse',
                optimizer=optimizer,
                metrics=['mae'])
  return model

model = build_model(df_train_normed)
model.summary()

class PrintDot(keras.callbacks.Callback):
  def on_epoch_end(self, epoch, logs):
    if epoch % 100 == 0: print('')
    print('.', end='')

EPOCHS = 1000
early_stop = keras.callbacks.EarlyStopping(monitor='val_loss', patience=50)

history = model.fit(
  df_train_normed, train_labels,
  epochs=EPOCHS, validation_split = 0.2, verbose=0,
  callbacks=[early_stop, PrintDot()])
 hist = pd.DataFrame(history.history)
hist['epoch'] = history.epoch

def plot_history(history):
  plt.figure()
  plt.xlabel('Epoch')
  plt.ylabel('Mean Absolute Error')
  plt.plot(hist['epoch'], hist['mean_absolute_error'],
           label='Train Error')
  plt.plot(hist['epoch'], hist['val_mean_absolute_error'],
           label = 'Val Error')
  plt.legend()
plot_history(history)


import shap
shap.initjs()
df_train_normed_summary = shap.kmeans(df_train_normed.values, 25)
explainer = shap.KernelExplainer(model.predict, df_train_normed_summary)
shap_values = explainer.shap_values(df_train_normed.values)
shap.summary_plot(shap_values[0], df_train)
INSTANCE_NUM = 0
shap.force_plot(explainer.expected_value[0], shap_values[0][INSTANCE_NUM], df_train.iloc[INSTANCE_NUM,:])
NUM_ROWS = 10
shap.force_plot(explainer.expected_value[0], shap_values[0][0:NUM_ROWS], df_train.iloc[0:NUM_ROWS])
shap.dependence_plot('FIRST_GEN', shap_values[0], df_train, interaction_index='PPTUG_EF')
explainer = shap.DeepExplainer(model, df_train_normed)
shap_values = explainer.shap_values(df_train_normed.values)
shap.summary_plot(shap_values[0], df_train)


import autokeras as ak
clf = ak.ImageClassifier()
clf.fit(input, output)
results = clf.predict(input)



import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train),(x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(512, activation=tf.nn.relu),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation=tf.nn.softmax)
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test, y_test)




def variable_summaries(var):
  """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""
  with tf.name_scope('summaries'):
    mean = tf.reduce_mean(var)
    tf.summary.scalar('mean', mean)
    with tf.name_scope('stddev'):
      stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
    tf.summary.scalar('stddev', stddev)
    tf.summary.scalar('max', tf.reduce_max(var))
    tf.summary.scalar('min', tf.reduce_min(var))
    tf.summary.histogram('histogram', var)

def nn_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.relu):
  """Reusable code for making a simple neural net layer.

  It does a matrix multiply, bias add, and then uses relu to nonlinearize.
  It also sets up name scoping so that the resultant graph is easy to read,
  and adds a number of summary ops.
  """
  # Adding a name scope ensures logical grouping of the layers in the graph.
  with tf.name_scope(layer_name):
    # This Variable will hold the state of the weights for the layer
    with tf.name_scope('weights'):
      weights = weight_variable([input_dim, output_dim])
      variable_summaries(weights)
    with tf.name_scope('biases'):
      biases = bias_variable([output_dim])
      variable_summaries(biases)
    with tf.name_scope('Wx_plus_b'):
      preactivate = tf.matmul(input_tensor, weights) + biases
      tf.summary.histogram('pre_activations', preactivate)
    activations = act(preactivate, name='activation')
    tf.summary.histogram('activations', activations)
    return activations

#hidden1 = nn_layer(x_train, 784, 500, 'layer1')

with tf.name_scope('dropout'):
  keep_prob = tf.placeholder(tf.float32)
  tf.summary.scalar('dropout_keep_probability', keep_prob)
  dropped = tf.nn.dropout(hidden1, keep_prob)

# Do not apply softmax activation yet, see below.
y = nn_layer(dropped, 500, 10, 'layer2', act=tf.identity)

with tf.name_scope('cross_entropy'):
  # The raw formulation of cross-entropy,
  #
  # tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.softmax(y)),
  #                               reduction_indices=[1]))
  #
  # can be numerically unstable.
  #
  # So here we use tf.losses.sparse_softmax_cross_entropy on the
  # raw logit outputs of the nn_layer above.
  with tf.name_scope('total'):
    cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
tf.summary.scalar('cross_entropy', cross_entropy)

with tf.name_scope('train'):
  train_step = tf.train.AdamOptimizer(FLAGS.learning_rate).minimize(
      cross_entropy)

with tf.name_scope('accuracy'):
  with tf.name_scope('correct_prediction'):
    correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
  with tf.name_scope('accuracy'):
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
tf.summary.scalar('accuracy', accuracy)

# Merge all the summaries and write them out to /tmp/mnist_logs (by default)
merged = tf.summary.merge_all()
train_writer = tf.summary.FileWriter(FLAGS.summaries_dir + '/train',
                                      sess.graph)
test_writer = tf.summary.FileWriter(FLAGS.summaries_dir + '/test')
tf.global_variables_initializer().run()



# Train the model, and also write summaries.
# Every 10th step, measure test-set accuracy, and write test summaries
# All other steps, run train_step on training data, & add training summaries

def feed_dict(train):
  """Make a TensorFlow feed_dict: maps data onto Tensor placeholders."""
  if train or FLAGS.fake_data:
    xs, ys = mnist.train.next_batch(100, fake_data=FLAGS.fake_data)
    k = FLAGS.dropout
  else:
    xs, ys = mnist.test.images, mnist.test.labels
    k = 1.0
  return {x: xs, y_: ys, keep_prob: k}

for i in range(FLAGS.max_steps):
  if i % 10 == 0:  # Record summaries and test-set accuracy
    summary, acc = sess.run([merged, accuracy], feed_dict=feed_dict(False))
    test_writer.add_summary(summary, i)
    print('Accuracy at step %s: %s' % (i, acc))
  else:  # Record train set summaries, and train
    summary, _ = sess.run([merged, train_step], feed_dict=feed_dict(True))
    train_writer.add_summary(summary, i)




tensorboard --logdir=path/to/log-directory



def variable_summaries(var):
  """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""
  with tf.name_scope('summaries'):
    mean = tf.reduce_mean(var)
    tf.summary.scalar('mean', mean)
    with tf.name_scope('stddev'):
      stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
    tf.summary.scalar('stddev', stddev)
    tf.summary.scalar('max', tf.reduce_max(var))
    tf.summary.scalar('min', tf.reduce_min(var))
    tf.summary.histogram('histogram', var)

def nn_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.relu):
  """Reusable code for making a simple neural net layer.

  It does a matrix multiply, bias add, and then uses ReLU to nonlinearize.
  It also sets up name scoping so that the resultant graph is easy to read,
  and adds a number of summary ops.
  """
  # Adding a name scope ensures logical grouping of the layers in the graph.
  with tf.name_scope(layer_name):
    # This Variable will hold the state of the weights for the layer
    with tf.name_scope('weights'):
      weights = weight_variable([input_dim, output_dim])
      variable_summaries(weights)
    with tf.name_scope('biases'):
      biases = bias_variable([output_dim])
      variable_summaries(biases)
    with tf.name_scope('Wx_plus_b'):
      preactivate = tf.matmul(input_tensor, weights) + biases
      tf.summary.histogram('pre_activations', preactivate)
    activations = act(preactivate, name='activation')
    tf.summary.histogram('activations', activations)
    return activations

hidden1 = nn_layer(x, 784, 500, 'layer1')

with tf.name_scope('dropout'):
  keep_prob = tf.placeholder(tf.float32)
  tf.summary.scalar('dropout_keep_probability', keep_prob)
  dropped = tf.nn.dropout(hidden1, keep_prob)

# Do not apply softmax activation yet, see below.
y = nn_layer(dropped, 500, 10, 'layer2', act=tf.identity)

with tf.name_scope('cross_entropy'):
  # The raw formulation of cross-entropy,
  #
  # tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.softmax(y)),
  #                               reduction_indices=[1]))
  #
  # can be numerically unstable.
  #
  # So here we use tf.losses.sparse_softmax_cross_entropy on the
  # raw logit outputs of the nn_layer above, and then average across
  # the batch.
  with tf.name_scope('total'):
    cross_entropy = tf.losses.sparse_softmax_cross_entropy(
        labels=y_, logits=y)
tf.summary.scalar('cross_entropy', cross_entropy)

with tf.name_scope('train'):
  train_step = tf.train.AdamOptimizer(FLAGS.learning_rate).minimize(
      cross_entropy)

with tf.name_scope('accuracy'):
  with tf.name_scope('correct_prediction'):
    correct_prediction = tf.equal(tf.argmax(y, 1), y_)
  with tf.name_scope('accuracy'):
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
tf.summary.scalar('accuracy', accuracy)

# Merge all the summaries and write them out to
# /tmp/tensorflow/mnist/logs/mnist_with_summaries (by default)
merged = tf.summary.merge_all()
train_writer = tf.summary.FileWriter(FLAGS.log_dir + '/train', sess.graph)
test_writer = tf.summary.FileWriter(FLAGS.log_dir + '/test')
tf.global_variables_initializer().run()



import tensorflow as tf
import numpy as np

X_train = (np.random.sample((10000,5)))
y_train =  (np.random.sample((10000,1)))
X_train.shape

feature_columns = [
      tf.feature_column.numeric_column('x', shape=X_train.shape[1:])]
DNN_reg = tf.estimator.DNNRegressor(feature_columns=feature_columns,
# Indicate where to store the log file
     model_dir='train/linreg',
     hidden_units=[500, 300],
     optimizer=tf.train.AdamOptimizer(
          learning_rate=0.1,
          l1_regularization_strength=0.001
      )
)

# Train the estimator
train_input = tf.estimator.inputs.numpy_input_fn(
     x={"x": X_train},
     y=y_train, shuffle=False,num_epochs=None)
DNN_reg.train(train_input,steps=3000)


import tensorflow as tf

k = tf.float32

# Make a normal distribution, with a shifting mean
mean_moving_normal = tf.random_normal(shape=[1000], mean=(5*k), stddev=1)
# Record that distribution into a histogram summary
tf.summary.histogram("normal/moving_mean", mean_moving_normal)

# Setup a session and summary writer
sess = tf.Session()
writer = tf.summary.FileWriter("/tmp/histogram_example")

summaries = tf.summary.merge_all()

# Setup a loop and write the summaries to disk
N = 400
for step in range(N):
  k_val = step/float(N)
  summ = sess.run(summaries, feed_dict={k: k_val})
  writer.add_summary(summ, global_step=step)


#https://threader.app/thread/1105139360226140160
import tensorflow as tf
print(tf.__version__)
import datetime
print(datetime.datetime.now())
tf.keras.backend.clear_session()
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0
print("Eager:",tf.executing_eagerly())
print("GPU:",tf.test.is_gpu_available())#:with tf.device("/gpu:0"):
#tf.keras.backend.clear_session()

def create_model():
  return tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(512, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10, activation='softmax')
  ])

model = create_model()
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

log_dir="/mnt/f/scripts/logs/" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
model.fit(x=x_train,
          y=y_train,
          epochs=5,
          validation_data=(x_test, y_test),
          callbacks=[tensorboard_callback])
#target https://levelup.gitconnected.com/dont-just-leetcode-follow-the-coding-patterns-instead-4beb6a197fdb
Sliding Window
Islands (Matrix Traversal)
Two Pointers
Fast & Slow Pointers
Merge Intervals
Cyclic Sort
In-place Reversal of a LinkedList
Tree Breadth-First Search
Tree Depth First Search
Two Heaps
Subsets
Modified Binary Search
Bitwise XOR
Top ‘K’ Elements
K-way Merge
Topological Sort
0/1 Knapsack
Fibonacci Numbers
Palindromic Subsequence
Longest Common Substring