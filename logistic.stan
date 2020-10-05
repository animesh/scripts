//    http://mc-stan.org/loo/articles/loo2-with-rstan.html
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
// The input data is a vector 'y' of length 'N'.
// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
data {
  int<lower=0> N;             // number of data points
  int<lower=0> P;             // number of predictors (including intercept)
  matrix[N,P] X;              // predictors (including 1s for intercept)
  int<lower=0,upper=1> y[N];  // binary outcome
}
parameters {
  vector[P] beta;
}
model {
  beta ~ normal(0, 1);
  y ~ bernoulli_logit(X * beta);
}
generated quantities {
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = bernoulli_logit_lpmf(y[n] | X[n] * beta);
  }
}
