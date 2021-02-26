#!pip install --upgrade pip
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
