#https://towardsdatascience.com/how-to-create-an-app-to-classify-dogs-using-fastai-and-streamlit-af3e75f0ee28
import fastbook
fastbook.setup_book()
from fastbook import *
from fastai.vision.widgets import *
from pathlib import Path
#https://portal.azure.com/#blade/Microsoft_Bing_Api/KeySetting.ReactView/id/%2Fsubscriptions%2Fb14b5c82-e316-4008-935e-585324d5302b%2FresourceGroups%2FfuzzyLife%2Fproviders%2FMicrosoft.Bing%2Faccounts%2Fimg
key = os.environ.get('AZURE_SEARCH_KEY', 'XXX')
results = search_images_bing(key, 'mass spectra')
ims = results.attrgot('content_url')
len(ims)
img_types = 'MSMS','MS1','MS2'
path = Path('MS')
if not path.exists():
    path.mkdir()
    for o in img_types:
        dest = (path/o)
        dest.mkdir(exist_ok=True)
        results = search_images_bing(key, f'{o} mass spectra')
        download_images(dest, urls=results.attrgot('contentUrl'))
fns = get_image_files(path)
failed = verify_images(fns)
failed.map(Path.unlink)
MS = DataBlock(
    blocks=(ImageBlock, CategoryBlock), 
    get_items=get_image_files, 
    splitter=RandomSplitter(valid_pct=0.2, seed=1),
    get_y=parent_label,
    item_tfms=Resize(128))
dls = MS.dataloaders(path)
dls.valid.show_batch(max_n=4, nrows=1)
MS = MS.new(item_tfms=RandomResizedCrop(128, min_scale=0.3))
dls = MS.dataloaders(path)
dls.train.show_batch(max_n=4, nrows=1, unique=True)
MS = MS.new(item_tfms=Resize(128), batch_tfms=aug_transforms())
dls = MS.dataloaders(path)
dls.train.show_batch(max_n=8, nrows=2, unique=True)
MS = MS.new(
    item_tfms=RandomResizedCrop(224, min_scale=0.5),
    batch_tfms=aug_transforms())
dls = MS.dataloaders(path)
learn = cnn_learner(dls, resnet18, metrics=error_rate)
learn.fine_tune(4)
interp = ClassificationInterpretation.from_learner(learn)
interp.plot_confusion_matrix()
interp.plot_top_losses(10, nrows=2)
for idx in cleaner.delete(): cleaner.fns[idx].unlink()
for idx,cat in cleaner.change(): shutil.move(str(cleaner.fns[idx]), path/cat)
learn.export('MS.pkl')
path = Path()
learn_inf = load_learner(path/'MS.pkl')
#classifier.py and run: streamlit run dog_classifier.py https://www.streamlit.io/sharing
'''
from fastai.vision.widgets import *
from fastai.vision.all import *

from pathlib import Path

import streamlit as st

class Predict:
    def __init__(self, filename):
        self.learn_inference = load_learner(Path()/filename)
        self.img = self.get_image_from_upload()
        if self.img is not None:
            self.display_output()
            self.get_prediction()
    
    @staticmethod
    def get_image_from_upload():
        uploaded_file = st.file_uploader("Upload Files",type=['png','jpeg', 'jpg'])
        if uploaded_file is not None:
            return PILImage.create((uploaded_file))
        return None

    def display_output(self):
        st.image(self.img.to_thumb(500,500), caption='Uploaded Image')

    def get_prediction(self):

        if st.button('Classify'):
            pred, pred_idx, probs = self.learn_inference.predict(self.img)
            st.write(f'Prediction: {pred}; Probability: {probs[pred_idx]:.04f}')
        else: 
            st.write(f'Click the button to classify') 

if __name__=='__main__':

    file_name='dog.pkl'

    predictor = Predict(file_name)
'''

