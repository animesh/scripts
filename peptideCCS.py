#git lfs install
#git clone https://huggingface.co/datasets/animesh/autonlp-data-peptides
#https://www.tensorflow.org/tutorials/load_data/csv
import pandas as pd
peptideCCS_train=pd.read_csv("L:\promec\Animesh\pepCCS.csv")
peptideCCS_train.info()
peptideCCS_train[' CCS'].hist()
peptideCCS_train_scores = peptideCCS_train.pop(' CCS')
peptideCCS_train_scores.hist()
peptideCCS_train=peptideCCS_train.pop('Sequence ')
del peptideCCS_train
peptides=''.join(peptideCCS_train)
from collections import Counter
c = Counter(peptides)
cf=pd.DataFrame(c.items())
cf=cf.sort_values(1)
print(cf)
import tensorflow as tf
print(tf.__version__)
#C:\Users\animeshs\AppData\Local\Programs\Spyder\Python\python.exe -m pip install tensorflow-text
import tensorflow_text as tf_text
docs = tf.data.Dataset.from_tensor_slices([['Never tell me the odds.'], ["It's a trap!"]])
tokenizer = tf_text.WhitespaceTokenizer()
tokenized_docs = docs.map(lambda x: tokenizer.tokenize(x))
iterator = iter(tokenized_docs)
print(next(iterator).to_list())
print(next(iterator).to_list())

dataset = load_dataset("animesh/autonlp-data-peptides", split='validation[:10%]')

"""# Main datasets API

This notebook is a quick dive in the main user API for loading datasets in `datasets`
"""

# install datasets
!pip install datasets
# Make sure that we have a recent version of pyarrow in the session before we continue - otherwise reboot Colab to activate it
import pyarrow
if int(pyarrow.__version__.split('.')[1]) < 16 and int(pyarrow.__version__.split('.')[0]) == 0:
    import os
    os.kill(os.getpid(), 9)

# Let's import the library. We typically only need at most four methods:
from datasets import list_datasets, list_metrics, load_dataset, load_metric
from pprint import pprint

"""## Listing the currently available datasets and metrics"""

# Currently available datasets and metrics
datasets = list_datasets()
metrics = list_metrics()
print(f"🤩 Currently {len(datasets)} datasets are available on the hub:")
pprint(datasets, compact=True)
print(f"🤩 Currently {len(metrics)} metrics are available on the hub:")
pprint(metrics, compact=True)

# You can access various attributes of the datasets before downloading them
peptide_dataset = list_datasets(with_details=True)[datasets.index('animesh/autonlp-data-peptides')]
pprint(peptide_dataset.__dict__)  # It's a simple python dataclass

"""## An example with peptide"""

# Downloading and loading a dataset
#dataset = load_dataset('animesh/autonlp-data-peptides', split='validation[:10%]')
dataset = load_dataset('animesh/autonlp-data-peptides', split='train')

dataset.column_names

dataset[' CCS']

"""This call to `datasets.load_dataset()` does the following steps under the hood:

1. Download and import in the library the **peptide python processing script** from HuggingFace AWS bucket if it's not already stored in the library. You can find the peptide processing script [here](https://github.com/huggingface/datasets/tree/master/datasets/peptide/peptide.py) for instance.

   Processing scripts are small python scripts which define the info (citation, description) and format of the dataset and contain the URL to the original peptide JSON files and the code to load examples from the original peptide JSON files.


2. Run the peptide python processing script which will:
    - **Download the peptide dataset** from the original URL (see the script) if it's not already downloaded and cached.
    - **Process and cache** all peptide in a structured Arrow table for each standard splits stored on the drive.

      Arrow table are arbitrarily long tables, typed with types that can be mapped to numpy/pandas/python standard types and can store nested objects. They can be directly access from drive, loaded in RAM or even streamed over the web.
    

3. Return a **dataset built from the splits** asked by the user (default: all); in the above example we create a dataset with the first 10% of the validation split.
"""

# Informations on the dataset (description, citation, size, splits, format...)
# are provided in `dataset.info` (a simple python dataclass) and also as direct attributes in the dataset object
pprint(dataset.info.__dict__)

"""## Inspecting and using the dataset: elements, slices and columns

The returned `Dataset` object is a memory mapped dataset that behave similarly to a normal map-style dataset. It is backed by an Apache Arrow table which allows many interesting features.
"""

print(dataset)

"""You can query it's length and get items or slices like you would do normally with a python mapping."""

print(f"Dataset len(dataset): {len(dataset)}")

# Or get slices with several examples:
print("\n👉Slice of the two items 'dataset[10:12]':")
pprint(dataset[10:12])

"""The `__getitem__` method will return different format depending on the type of query:

- Items like `dataset[0]` are returned as dict of elements.
- Slices like `dataset[10:20]` are returned as dict of lists of elements.
- Columns like `dataset['question']` are returned as a list of elements.

This may seems surprising at first but in our experiments it's actually a lot easier to use for data processing than returning the same format for each of these views on the dataset.

In particular, you can easily iterate along columns in slices, and also naturally permute consecutive indexings with identical results as showed here by permuting column indexing with elements and slices:

### Dataset are internally typed and structured

The dataset is backed by one (or several) Apache Arrow tables which are typed and allows for fast retrieval and access as well as arbitrary-size memory mapping.

This means respectively that the format for the dataset is clearly defined and that you can load datasets of arbitrary size without worrying about RAM memory limitation (basically the dataset take no space in RAM, it's directly read from drive when needed with fast IO access).
"""

# You can inspect the dataset column names and types 
print("Column names:")
pprint(dataset.column_names)
print("Features:")
pprint(dataset.features)

"""### Additional misc properties"""

# Datasets also have shapes informations
print("The number of rows", dataset.num_rows, "also available as len(dataset)", len(dataset))
print("The number of columns", dataset.num_columns)
print("The shape (rows, columns)", dataset.shape)

"""## Modifying the dataset with `dataset.map`

Now that we know how to inspect our dataset we also want to update it. For that there is a powerful method `.map()` which is inspired by `tf.data` map method and that you can use to apply a function to each examples, independently or in batch.

`.map()` takes a callable accepting a dict as argument (same dict as the one returned by `dataset[i]`) and iterate over the dataset by calling the function on each example.
"""

# Let's print the length of each `context` string in our subset of the dataset
# (10% of the validation i.e. 1057 examples)

dataset.map(lambda example: print(len(example['Sequence ']), end=','))

import matplotlib.pyplot as plt
import numpy as np
#plt.theme('dark')
plt.hist(np.log2(dataset[' CCS']))

"""The above examples was a bit verbose. We can control the logging level of 🤗 Datasets with it's logging module:

"""

# Let's keep it verbose for our tutorial though
from datasets import logging
logging.set_verbosity_info()

"""The above example had no effect on the dataset because the method we supplied to `.map()` didn't return a `dict` or a `abc.Mapping` that could be used to update the examples in the dataset.

In such a case, `.map()` will return the same dataset (`self`).

Now let's see how we can use a method that actually modify the dataset.

### Modifying the dataset example by example

The main interest of `.map()` is to update and modify the content of the table and leverage smart caching and fast backend.

To use `.map()` to update elements in the table you need to provide a function with the following signature: `function(example: dict) -> dict`.
"""

# Let's add a prefix 'My cute title: ' to each of our titles

def add_prefix_to_title(example):
    example['title'] = 'My cute title: ' + example['title']
    return example

prefixed_dataset = dataset.map(add_prefix_to_title)

print(prefixed_dataset.unique('title'))  # `.unique()` is a super fast way to print the unique elemnts in a column (see the doc for all the methods)

"""This call to `.map()` compute and return the updated table. It will also store the updated table in a cache file indexed by the current state and the mapped function.

A subsequent call to `.map()` (even in another python session) will reuse the cached file instead of recomputing the operation.

You can test this by running again the previous cell, you will see that the result are directly loaded from the cache and not re-computed again.

The updated dataset returned by `.map()` is (again) directly memory mapped from drive and not allocated in RAM.

The function you provide to `.map()` should accept an input with the format of an item of the dataset: `function(dataset[0])` and return a python dict.

The columns and type of the outputs can be different than the input dict. In this case the new keys will be added as additional columns in the dataset.

Bascially each dataset example dict is updated with the dictionary returned by the function like this: `example.update(function(example))`.
"""

# Since the input example dict is updated with our function output dict,
# we can actually just return the updated 'title' field
titled_dataset = dataset.map(lambda example: {'title': 'My cutest title: ' + example['title']})

print(titled_dataset.unique('title'))

"""#### Removing columns
You can also remove columns when running map with the `remove_columns=List[str]` argument.
"""

# This will remove the 'title' column while doing the update (after having send it the the mapped function so you can use it in your function!)
less_columns_dataset = dataset.map(lambda example: {'new_title': 'Wouhahh: ' + example['title']}, remove_columns=['title'])

print(less_columns_dataset.column_names)
print(less_columns_dataset.unique('new_title'))

"""#### Using examples indices
With `with_indices=True`, dataset indices (from `0` to `len(dataset)`) will be supplied to the function which must thus have the following signature: `function(example: dict, indice: int) -> dict`
"""

# This will add the index in the dataset to the 'question' field
with_indices_dataset = dataset.map(lambda example, idx: {'question': f'{idx}: ' + example['question']},
                                   with_indices=True)

pprint(with_indices_dataset['question'][:5])

"""### Modifying the dataset with batched updates

`.map()` can also work with batch of examples (slices of the dataset).

This is particularly interesting if you have a function that can handle batch of inputs like the tokenizers of HuggingFace `tokenizers`.

To work on batched inputs set `batched=True` when calling `.map()` and supply a function with the following signature: `function(examples: Dict[List]) -> Dict[List]` or, if you use indices, `function(examples: Dict[List], indices: List[int]) -> Dict[List]`).

Bascially, your function should accept an input with the format of a slice of the dataset: `function(dataset[:10])`.
"""

!pip install transformers

# Let's import a fast tokenizer that can work on batched inputs
# (the 'Fast' tokenizers in HuggingFace)
from transformers import BertTokenizerFast, logging as transformers_logging
transformers_logging.set_verbosity_warning()
tokenizer = BertTokenizerFast.from_pretrained('bert-base-cased')

# Now let's batch tokenize our dataset 'context'
encoded_dataset = dataset.map(lambda example: tokenizer(example['Sequence ']), batched=True)
#print("encoded_dataset[0]")
pprint(encoded_dataset[0], compact=True)

# we have added additional columns
pprint(encoded_dataset.column_names)

# Now our dataset comprise the labels for the start and end position
# as well as the offsets for converting back tokens
# in span of the original string for evaluation
print("column_names", encoded_dataset.column_names)
print("start_positions", encoded_dataset[:5])

"""## formatting outputs for PyTorch, Tensorflow, Numpy, Pandas

Now that we have tokenized our inputs, we probably want to use this dataset in a `torch.Dataloader` or a `tf.data.Dataset`.

To be able to do this we need to tweak two things:

- format the indexing (`__getitem__`) to return numpy/pytorch/tensorflow tensors, instead of python objects, and probably
- format the indexing (`__getitem__`) to return only the subset of the columns that we need for our model inputs.

  We don't want the columns `id` or `title` as inputs to train our model, but we could still want to keep them in the dataset, for instance for the evaluation of the model.
    
This is handled by the `.set_format(type: Union[None, str], columns: Union[None, str, List[str]])` where:

- `type` define the return type for our dataset `__getitem__` method and is one of `[None, 'numpy', 'pandas', 'torch', 'tensorflow']` (`None` means return python objects), and
- `columns` define the columns returned by `__getitem__` and takes the name of a column in the dataset or a list of columns to return (`None` means return all columns).
"""

columns_to_return = ['input_ids', 'token_type_ids', 'attention_mask']
encoded_dataset.set_format(type='torch', columns=columns_to_return)
# Our dataset indexing output is now ready for being used in a pytorch dataloader
pprint(encoded_dataset[1], compact=True)

# Note that the columns are not removed from the dataset, just not returned when calling __getitem__
# Similarly the inner type of the dataset is not changed to torch.Tensor, the conversion and filtering is done on-the-fly when querying the dataset
print(encoded_dataset.column_names)

# We can remove the formatting with `.reset_format()`
# or, identically, a call to `.set_format()` with no arguments
encoded_dataset.reset_format()
pprint(encoded_dataset[1], compact=True)

# The current format can be checked with `.format`,
# which is a dict of the type and formatting
pprint(encoded_dataset.format)

"""# Wrapping this all up (PyTorch)

Let's wrap this all up with the full code to load and prepare peptide for training a PyTorch model from HuggingFace `transformers` library.


"""

!pip install transformers

import torch 
from datasets import load_dataset
from transformers import BertTokenizerFast

# Load our training dataset and tokenizer
dataset = load_dataset('peptide')
tokenizer = BertTokenizerFast.from_pretrained('bert-base-cased')

def get_correct_alignement(context,  CCS):
    """ Some original examples in peptide have indices wrong by 1 or 2 character. We test and fix this here. """
    gold_text =  CCS['text'][0]
    start_idx =  CCS[' CCS_start'][0]
    end_idx = start_idx + len(gold_text)
    if context[start_idx:end_idx] == gold_text:
        return start_idx, end_idx       # When the gold label position is good
    elif context[start_idx-1:end_idx-1] == gold_text:
        return start_idx-1, end_idx-1   # When the gold label is off by one character
    elif context[start_idx-2:end_idx-2] == gold_text:
        return start_idx-2, end_idx-2   # When the gold label is off by two character
    else:
        raise ValueError()

# Tokenize our training dataset
def convert_to_features(example_batch):
    # Tokenize contexts and questions (as pairs of inputs)
    encodings = tokenizer(example_batch['context'], example_batch['question'], truncation=True)

    # Compute start and end tokens for labels using Transformers's fast tokenizers alignement methods.
    start_positions, end_positions = [], []
    for i, (context,  CCS) in enumerate(zip(example_batch['context'], example_batch[' CCSs'])):
        start_idx, end_idx = get_correct_alignement(context,  CCS)
        start_positions.append(encodings.char_to_token(i, start_idx))
        end_positions.append(encodings.char_to_token(i, end_idx-1))
    encodings.update({'start_positions': start_positions, 'end_positions': end_positions})
    return encodings

encoded_dataset = dataset.map(convert_to_features, batched=True)

# Format our dataset to outputs torch.Tensor to train a pytorch model
columns = ['input_ids', 'token_type_ids', 'attention_mask', 'start_positions', 'end_positions']
encoded_dataset.set_format(type='torch', columns=columns)

# Instantiate a PyTorch Dataloader around our dataset
# Let's do dynamic batching (pad on the fly with our own collate_fn)
def collate_fn(examples):
    return tokenizer.pad(examples, return_tensors='pt')
dataloader = torch.utils.data.DataLoader(encoded_dataset['train'], collate_fn=collate_fn, batch_size=8)

# Let's load a pretrained Bert model and a simple optimizer
from transformers import BertForQuestion CCSing
model = BertForQuestion CCSing.from_pretrained('distilbert-base-cased', return_dict=True)
optimizer = torch.optim.Adam(model.parameters(), lr=1e-5)

# Now let's train our model
device = 'cuda' if torch.cuda.is_available() else 'cpu'

model.train().to(device)
for i, batch in enumerate(dataloader):
    batch.to(device)
    outputs = model(**batch)
    loss = outputs.loss
    loss.backward()
    optimizer.step()
    model.zero_grad()
    print(f'Step {i} - loss: {loss:.3}')
    if i > 5:
        break

"""# Wrapping this all up (Tensorflow)

Let's wrap this all up with the full code to load and prepare peptide for training a Tensorflow model (works only from the version 2.2.0)
"""

import tensorflow as tf
import datasets
from transformers import BertTokenizerFast

# Load our training dataset and tokenizer
train_tf_dataset = datasets.load_dataset('peptide', split="train")
tokenizer = BertTokenizerFast.from_pretrained('bert-base-cased', return_dict=True)

# Tokenize our training dataset
# The only one diff here is that start_positions and end_positions
# must be single dim list => [[23], [45] ...]
# instead of => [23, 45 ...]
def convert_to_tf_features(example_batch):
    # Tokenize contexts and questions (as pairs of inputs)
    encodings = tokenizer(example_batch['context'], example_batch['question'], truncation=True)

    # Compute start and end tokens for labels using Transformers's fast tokenizers alignement methods.
    start_positions, end_positions = [], []
    for i, (context,  CCS) in enumerate(zip(example_batch['context'], example_batch[' CCSs'])):
        start_idx, end_idx = get_correct_alignement(context,  CCS)
        start_positions.append([encodings.char_to_token(i, start_idx)])
        end_positions.append([encodings.char_to_token(i, end_idx-1)])
    
    if start_positions and end_positions:
      encodings.update({'start_positions': start_positions, 'end_positions': end_positions})
    return encodings

train_tf_dataset = train_tf_dataset.map(convert_to_tf_features, batched=True)

def remove_none_values(example):
  return not None in example["start_positions"] or not None in example["end_positions"]

train_tf_dataset = train_tf_dataset.filter(remove_none_values, load_from_cache_file=False)
columns = ['input_ids', 'token_type_ids', 'attention_mask', 'start_positions', 'end_positions']
train_tf_dataset.set_format(type='tensorflow', columns=columns)
features = {x: train_tf_dataset[x].to_tensor(default_value=0, shape=[None, tokenizer.model_max_length]) for x in columns[:3]} 
labels = {"output_1": train_tf_dataset["start_positions"].to_tensor(default_value=0, shape=[None, 1])}
labels["output_2"] = train_tf_dataset["end_positions"].to_tensor(default_value=0, shape=[None, 1])
tfdataset = tf.data.Dataset.from_tensor_slices((features, labels)).batch(8)

# Let's load a pretrained TF2 Bert model and a simple optimizer
from transformers import TFBertForQuestion CCSing

model = TFBertForQuestion CCSing.from_pretrained("bert-base-cased")
loss_fn = tf.keras.losses.SparseCategoricalCrossentropy(reduction=tf.keras.losses.Reduction.NONE, from_logits=True)
opt = tf.keras.optimizers.Adam(learning_rate=3e-5)
model.compile(optimizer=opt,
              loss={'output_1': loss_fn, 'output_2': loss_fn},
              loss_weights={'output_1': 1., 'output_2': 1.},
              metrics=['accuracy'])

# Now let's train our model

model.fit(tfdataset, epochs=1, steps_per_epoch=3)

"""# Metrics API

`datasets` also provides easy access and sharing of metrics.

This aspect of the library is still experimental and the API may still evolve more than the datasets API.

Like datasets, metrics are added as small scripts wrapping common metrics in a common API.

There are several reason you may want to use metrics with `datasets` and in particular:

- metrics for specific datasets like GLUE or peptide are provided out-of-the-box in a simple, convenient and consistant way integrated with the dataset,
- metrics in `datasets` leverage the powerful backend to provide smart features out-of-the-box like support for distributed evaluation in PyTorch

## Using metrics

Using metrics is pretty simple, they have two main methods: `.compute(predictions, references)` to directly compute the metric and `.add(prediction, reference)` or `.add_batch(predictions, references)` to only store some results if you want to do the evaluation in one go at the end.

Here is a quick gist of a standard use of metrics (the simplest usage):
```python
from datasets import load_metric
sacrebleu_metric = load_metric('sacrebleu')

# If you only have a single iteration, you can easily compute the score like this
predictions = model(inputs)
score = sacrebleu_metric.compute(predictions, references)

# If you have a loop, you can "add" your predictions and references at each iteration instead of having to save them yourself (the metric object store them efficiently for you)
for batch in dataloader:
    model_input, targets = batch
    predictions = model(model_inputs)
    sacrebleu_metric.add_batch(predictions, targets)
score = sacrebleu_metric.compute()  # Compute the score from all the stored predictions/references
```

Here is a quick gist of a use in a distributed torch setup (should work for any python multi-process setup actually). It's pretty much identical to the second example above:
```python
from datasets import load_metric
# You need to give the total number of parallel python processes (num_process) and the id of each process (process_id)
bleu_metric = datasets.load_metric('sacrebleu', process_id=torch.distributed.get_rank(),b num_process=torch.distributed.get_world_size())

for batch in dataloader:
    model_input, targets = batch
    predictions = model(model_inputs)
    sacrebleu_metric.add_batch(predictions, targets)
score = sacrebleu_metric.compute()  # Compute the score on the first node by default (can be set to compute on each node as well)
```

Example with a NER metric: `seqeval`
"""

!pip install seqeval
ner_metric = load_metric('seqeval')
references = [['O', 'O', 'O', 'B-MISC', 'I-MISC', 'I-MISC', 'O'], ['B-PER', 'I-PER', 'O']]
predictions =  [['O', 'O', 'B-MISC', 'I-MISC', 'I-MISC', 'I-MISC', 'O'], ['B-PER', 'I-PER', 'O']]
ner_metric.compute(predictions=predictions, references=references)

"""# Adding a new dataset or a new metric

They are two ways to add new datasets and metrics in `datasets`:

- datasets can be added with a Pull-Request adding a script in the `datasets` folder of the [`datasets` repository](https://github.com/huggingface/datasets)

=> once the PR is merged, the dataset can be instantiate by it's folder name e.g. `datasets.load_dataset('peptide')`. If you want HuggingFace to host the data as well you will need to ask the HuggingFace team to upload the data.

- datasets can also be added with a direct upload using `datasets` CLI as a user or organization (like for models in `transformers`). In this case the dataset will be accessible under the gien user/organization name, e.g. `datasets.load_dataset('thomwolf/peptide')`. In this case you can upload the data yourself at the same time and in the same folder.

See more information in [the dataset sharing section of the documentation](https://huggingface.co/docs/datasets/share_dataset.html).
"""




# In[74]:
from tflite_model_maker import configs
from tflite_model_maker import ExportFormat
from tflite_model_maker import model_spec
from tflite_model_maker import image_classifier
from tflite_model_maker.image_classifier import DataLoader
assert tf.__version__.startswith('2')

# In[74]:
tf.get_logger().setLevel('ERROR')
#data_path = tf.keras.utils.get_file('flower_photos','https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz',untar=True)
data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\train'
#data_path='/mnt/f/Pneumonia/chest_xray/chest_xray/train'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
model = image_classifier.create(train_data)
print(model)
loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)

data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\test'
#data_path='/mnt/f/Pneumonia/chest_xray/chest_xray/test'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
print(train_data, test_data)
loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)

loss, accuracy = model.evaluate(train_data)

print(loss,accuracy)


# In[74]:


model.export(export_dir='.')


# In[75]:


model.evaluate_tflite('model.tflite', test_data)


# In[72]:


import pickle
filenaM = "tfliteModel.pkl"
with open(filenaM, 'wb') as file:
    pickle.dump(model, file)
