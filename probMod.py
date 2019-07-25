#https://docs.pymc.io/notebooks/stochastic_volatility.html
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_context('talk')
import pymc3 as pm
from pymc3.distributions.timeseries import GaussianRandomWalk
from scipy import optimize

import pandas as pd
n = 400
returns = pd.read_csv(pm.get_data("SP500.csv"), index_col='date')['change']
returns[:5]

fig, ax = plt.subplots(figsize=(14, 8))
returns.plot(label='S&P500')
ax.set(xlabel='time', ylabel='returns')
ax.legend()

with pm.Model() as model:
    step_size = pm.Exponential('sigma', 50.)
    s = GaussianRandomWalk('s', sigma=step_size,
                           shape=len(returns))

    nu = pm.Exponential('nu', .1)

    r = pm.StudentT('r', nu=nu,
                    lam=pm.math.exp(-2*s),
                    observed=returns)

with model:
    trace = pm.sample(tune=2000, target_accept=0.9)

pm.traceplot(trace, var_names=['sigma', 'nu']);


fig, ax = plt.subplots()

plt.plot(trace['s'].T, 'b', alpha=.03);
ax.set(title=str(s), xlabel='time', ylabel='log volatility');


fig, ax = plt.subplots(figsize=(14, 8))
returns.plot(ax=ax)
ax.plot(np.exp(trace[s].T), 'r', alpha=.03);
#ax.set(xlabel='time', ylabel='returns')
ax.legend(['S&P500', 'stoch vol']);

#Hoffman & Gelman. (2011). The No-U-Turn Sampler: Adaptively Setting Path Lengths in Hamiltonian Monte Carlo.
#to try pyro-https://www.youtube.com/watch?v=Cp5ybCC0urg
#http://www.deeplearningbook.org/contents/monte_carlo.html
