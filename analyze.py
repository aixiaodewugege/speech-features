import json
import pprint
from sklearn import linear_model
from sklearn import tree
from sklearn import cross_validation
from sklearn.gaussian_process import GaussianProcess
import numpy as np

allData = json.load(open('speech_features_output_00mpc.json', 'r'))
scores = json.load(open('scores.json', 'r'))

def reorder(array,key,order):
    arrayDict = dict(zip(map(lambda (x): x[key],array),array))
    return map(lambda (x): arrayDict[x], order)

order = ['031a','032a','033a','034a','035a','036a','037a','038a','040a','041a','042a']
allData = reorder(allData,'name',order)

y = np.array(scores['scores'])

def firstMeans(data):
    x = np.array(data['means'])
    if len(x.shape) == 3:
        x = np.delete(x,np.s_[1:],2).squeeze()
        data['means'] = x.tolist()

map(firstMeans,allData)

def meanDiff(data):
    X = np.squeeze(np.array(data['means']))
    return X[0,:] - X[1,:]

def allMeans(data):
    X = np.squeeze(np.array(data['means']))
    return np.hstack((X[0,:],X[1,:]))

def speakerAmeans(data):
    X = np.squeeze(np.array(data['means']))
    return X[0,:]

def speakerBmeans(data):
    X = np.squeeze(np.array(data['means']))
    return X[1,:]

def alpha(data):
    return np.array(data['alphas']).diagonal()
    return X

def alphaDiff(data):
    X = np.array(data['alphas']).diagonal()
    return X[0]

def speakerAalpha(data):
    X = np.array(data['alphas']).diagonal()
    return X[0]

def speakerBalpha(data):
    X = np.array(data['alphas']).diagonal()
    return X[1]

features = ['meanDiff']

results = {}
for feature in features:
    X = np.array(map(locals()[feature],allData))
    X = X.transpose() if X.shape[0] == 1 else X
    loo = cross_validation.LeaveOneOut(len(X))
    cv_scores = {}
    def getScores(label,clf):
        label = "%15s" % label
        #['accuracy', 'adjusted_rand_score', 'average_precision', 'f1', 'log_loss', 'mean_squared_error', 'precision', 'r2', 'recall', 'roc_auc']
        cv = cross_validation.cross_val_score(clf,X,y,'mean_squared_error',loo)
        raw_score = np.sqrt(-cv)
        cv_scores[label] = {}
        cv_scores[label]['  mean']   = np.mean(raw_score)
        cv_scores[label]['median'] = np.median(raw_score)
        cv_scores[label]['   max'] = np.max(raw_score)
    #
    # clf = linear_model.SGDRegressor()
    # clf = GaussianProcess(corr='absolute_exponential', theta0=1e-5, thetaL=1e-10, thetaU=1e-5,random_start=25)
    # clf = tree.DecisionTreeRegressor(random_state=0)
    #
    clf = linear_model.Ridge(alpha=1e-7, fit_intercept=True)
    getScores('Ridge',clf)
    #
    clf = linear_model.Lasso(alpha=1e-5)
    getScores('Lasso',clf)
    #
    clf = linear_model.LinearRegression(fit_intercept=True)
    getScores('Linear',clf)
    #
    results["%20s" % feature] = cv_scores

pprint.pprint(results)