#%%
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from matplotlib import pyplot
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import f1_score
from sklearn.metrics import auc

import pandas as pd

#%%
df=pd.read_csv(r"C:\Users\L20565\OneDrive - E.ON\Sample_Data_RNOLF.csv")
bad_Flag = df.loc[:, "Bad_Flag_2"]
RNOLF04=df.loc[:,"RNOLF04_inverse"]
RNOLN01=df.loc[:,"RNOLN01_inverse"]
#print(label)

#%%
RNOLF04_rocauc = roc_auc_score(bad_Flag, RNOLF04)
RNOLN01_rocauc = roc_auc_score(bad_Flag, RNOLN01)
#print('RNOLF04: ROC AUC=%.3f' % (RNOLF04_rocauc))
#print('RNOLN01: ROC AUC=%.3f' % (RNOLN01_rocauc))
# %%
RNOLF04_fpr, RNOLF04_tpr,_= roc_curve(bad_Flag, RNOLF04)
RNOLN01_fpr, RNOLN01_tpr,_ = roc_curve(bad_Flag, RNOLN01)

# plot the roc curve for the model
pyplot.plot(RNOLF04_fpr, RNOLF04_tpr, linestyle='-', label='RNOLF04')
pyplot.plot(RNOLN01_fpr, RNOLN01_tpr, linestyle='-', label='RNOLN01')
# axis labels
pyplot.xlabel('False Positive Rate')
pyplot.ylabel('True Positive Rate')
# show the legend
pyplot.legend()
# show the plot
pyplot.show()
print('RNOLF04: ROC AUC=%.3f' % (RNOLF04_rocauc))
print('RNOLN01: ROC AUC=%.3f' % (RNOLN01_rocauc))
# %%
RNOLF04_precision, RNOLF04_recall, _ = precision_recall_curve(bad_Flag, RNOLF04)
RNOLF04_auc = auc(RNOLF04_recall, RNOLF04_precision)

RNOLN01_precision, RNOLN01_recall, _ = precision_recall_curve(bad_Flag, RNOLN01)
RNOLN01_auc =  auc(RNOLN01_recall, RNOLN01_precision)
# %%
# summarize scores
#print('Logistic: f1=%.3f auc=%.3f' % (lr_f1, lr_auc))
# plot the precision-recall curves
#no_skill = len(testy[testy==1]) / len(testy)
#pyplot.plot([0, 1], [no_skill, no_skill], linestyle='--', label='No Skill')
pyplot.plot(RNOLN01_recall, RNOLN01_precision, linestyle='-', label='RNOLN01')
pyplot.plot(RNOLF04_recall, RNOLF04_precision, linestyle='-', label='RNOLF04')
# axis labels
pyplot.xlabel('Recall')
pyplot.ylabel('Precision')
# show the legend
pyplot.legend()
# show the plot
pyplot.show()
print('RNOLF04:  prAUC=%.3f' % (RNOLF04_auc))
print('RNOLN01:  prAUC=%.3f' % (RNOLN01_auc))
# %%
