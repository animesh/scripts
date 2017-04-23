function [muA, fullVarA, muB, fullVarB] = estimateNBParams(countDM, sFactors, condA, condB)
% Return estimated parameters for negative binomial distribution for two
% conditions. 
% countDM  - DataMatrix containing the count table 
% sFactors - DataMatrix containing the size factor for each condition

baseMean = estimateBaseParams(countDM, sFactors, 'MeanAndVar');

% Get variances fit
[rawVarSmooth_X_A, rawVarSmooth_Y_A] = estimateBaseParams(countDM(:, condA),...
                                                 sFactors(1, condA),...
                                                 'SmoothFunc');
[rawVarSmooth_X_B, rawVarSmooth_Y_B] = estimateBaseParams(countDM(:, condB),...
                                                 sFactors(1, condB),...
                                                 'SmoothFunc');
% Fit for each condition
rawVar_A = interp1(rawVarSmooth_X_A, rawVarSmooth_Y_A, log(baseMean),...
                   'linear', 'extrap');
rawVar_B = interp1(rawVarSmooth_X_B, rawVarSmooth_Y_B, log(baseMean),...
                   'linear', 'extrap');
                   
%%
% Add the bias correction term
zConst_A = sum(1 ./sFactors(1, condA), 2) / length(sFactors(1, condA));
rawVar_A = max(rawVar_A - baseMean * zConst_A, baseMean*(1e-8));
zConst_B = sum(1 ./sFactors(1, condB), 2) / length(sFactors(1, condB));
rawVar_B = max(rawVar_B - baseMean * zConst_B, baseMean*(1e-8));

% Raw SCV estimate
rawSCV_A_fit = rawVar_A ./ (baseMean .^2);
rawSCV_B_fit = rawVar_B ./ (baseMean .^2);

% Adjust SCV for Bias (see script)
load scvBiasCorrectionFits
nA = sum(condA);
nB = sum(condB);
if nA < size(scvBiasCorrectionFits, 2)
    rawSCV_A = max(interp1(scvBiasCorrectionFits(:,nA),...
                   scvBiasCorrectionFits(:,1), rawSCV_A_fit,...
        'linear', 'extrap'), rawSCV_A_fit*(1e-8));
end

if nB < size(scvBiasCorrectionFits, 2)
    rawSCV_B = max(interp1(scvBiasCorrectionFits(:,nB),...
                   scvBiasCorrectionFits(:,1), rawSCV_B_fit,...
        'linear', 'extrap'), rawSCV_B_fit*(1e-8));
end

% Means for conditions A and B
muA = baseMean * sum(sFactors(1, condA), 2);
muB = baseMean * sum(sFactors(1, condB), 2);

% Full variance estimated for conditions A and B
fullVarA = max(muA + rawSCV_A .* (baseMean .^2) *...
                     sum(sFactors(1, condA).^2, 2), muA * (1+1e-8));
fullVarB = max(muB + rawSCV_B .* (baseMean .^2) *...
                     sum(sFactors(1, condB).^2, 2), muB * (1+1e-8));
end

% This function is not used. It contains the script for creating the
% scvBiasCorrection matrix.
function estimateSCVBiasCorrection
% To add comments
true_raw_scv = [linspace(0,2,100)'; linspace(2, 10, 20)'];
true_raw_scv = true_raw_scv(2:end);
max_n_repl = 15;
mu = 100000;
n_genes = 10000;
%%
scvBiasCorrectionFits = zeros(length(true_raw_scv), max_n_repl);
scvBiasCorrectionFits(:,1) = true_raw_scv;

for i = 2:max_n_repl
    nbinom_t = @(x)(nbinrnd(1/x, 1/(mu*x+1), n_genes, i));
    est_scv = @(k)(mean(var(k(sum(k,2)>0, :), 0, 2) ./...
                  (mean(k(sum(k,2)>0, :), 2)).^2));
    final_fun = @(x)(est_scv(nbinom_t(x)));
    scvBiasCorrectionFits(:,i) = arrayfun(final_fun, true_raw_scv);
end

save scvBiasCorrectionFits scvBiasCorrectionFits
end