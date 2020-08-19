#%%
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from matplotlib import pyplot
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import f1_score
from sklearn.metrics import auc
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import pandas as pd

#%%
df=pd.read_csv(r"C:\Users\L20565\OneDrive - E.ON\CRD_CHK_RETRO_REF_S6.csv")
EQF_RNILF04 = df.loc[:, ["BAD_FLAG","BAD_FLAG_365","EQF.RNILF04"]]
EQF_RNILF04['EQF.RNILF04'].replace('', np.nan, inplace=True)
EQF_RNILF04.dropna(subset=['EQF.RNILF04'], inplace=True)

# %%
scaler = MinMaxScaler()
EQF_RNILF04_minmax=scaler.fit_transform(EQF_RNILF04)
EQF_RNILF04_df[3]=1-EQF_RNILF04_df[2]


#%%
rocauc = roc_auc_score(EQF_RNILF04_df[0], EQF_RNILF04_df[3])
#ENOLF_rocauc = roc_auc_score(bad_Flag, ENOLF)
#print('RNOLF04: ROC AUC=%.3f' % (RNOLF04_rocauc))
#print('ENOLF: ROC AUC=%.3f' % (ENOLF_rocauc))
# %%
fpr, tpr,_= roc_curve(EQF_RNILF04_df[0], EQF_RNILF04_df[3])
#ENOLF_fpr, ENOLF_tpr,_ = roc_curve(bad_Flag, ENOLF)

# plot the roc curve for the model
#pyplot.plot(RNOLF04_fpr, RNOLF04_tpr, linestyle='-', label='RNOLF04')
pyplot.plot(fpr, tpr, linestyle='-', label='RNILF04')
# axis labels
pyplot.xlabel('False Positive Rate')
pyplot.ylabel('True Positive Rate')
# show the legend
pyplot.legend()
# show the plot
pyplot.show()
#print('RNOLF04: ROC AUC=%.3f' % (RNOLF04_rocauc))
print('RNILF04: ROC AUC=%.3f' % (rocauc))
# %%
RNOLF04_precision, RNOLF04_recall, _ = precision_recall_curve(bad_Flag, RNOLF04)
RNOLF04_auc = auc(RNOLF04_recall, RNOLF04_precision)

ENOLF_precision, ENOLF_recall, _ = precision_recall_curve(bad_Flag, ENOLF)
ENOLF_auc =  auc(ENOLF_recall, ENOLF_precision)
# %%
# summarize scores
#print('Logistic: f1=%.3f auc=%.3f' % (lr_f1, lr_auc))
# plot the precision-recall curves
#no_skill = len(testy[testy==1]) / len(testy)
#pyplot.plot([0, 1], [no_skill, no_skill], linestyle='--', label='No Skill')
pyplot.plot(ENOLF_recall, ENOLF_precision, linestyle='-', label='ENOLF')
pyplot.plot(RNOLF04_recall, RNOLF04_precision, linestyle='-', label='RNOLF04')
# axis labels
pyplot.xlabel('Recall')
pyplot.ylabel('Precision')
# show the legend
pyplot.legend()
# show the plot
pyplot.show()
print('RNOLF04:  prAUC=%.3f' % (RNOLF04_auc))
print('ENOLF:  prAUC=%.3f' % (ENOLF_auc))
# %%
