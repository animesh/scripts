function pval = computePVal(kA, muA, varA, kB, muB, varB)
% Compute the p-value for rnaseqdedemo.

pval = ones(size(kA));
p_A = muA ./varA;
r_A = (muA.^2)./(varA-muA);
p_B = muB./varB;
r_B = (muB.^2)./(varB-muB);

kS = kA + kB;
p_obs_0 = nbinpdf(kA, r_A, p_A) .* nbinpdf(kB, r_B, p_B);

nf_idx = isfinite(p_obs_0);

p_obs = p_obs_0(nf_idx) * ( 1 + 1e-7 );
k_exp = ceil(kS(nf_idx).*muA(nf_idx)./(muA(nf_idx)+muB(nf_idx)));

kS = kS(nf_idx);
p_A = p_A(nf_idx);
r_A=r_A(nf_idx);
p_B = p_B(nf_idx);
r_B=r_B(nf_idx);

pval_0 = pval(nf_idx);

LL_P = nbinpdf(zeros(size(r_A)), r_A, p_A) .* nbinpdf(k_exp, r_B, p_B);
LR_P = nbinpdf(k_exp, r_A, p_A) .* nbinpdf(kS-k_exp, r_B, p_B);

RL_P = nbinpdf(k_exp, r_A, p_A) .* nbinpdf(kS-k_exp, r_B, p_B);
RR_P = nbinpdf(kS, r_A, p_A) .* nbinpdf(zeros(size(r_A)), r_B, p_B);

parfor i = 1:sum(nf_idx)
    [total_L, obs_total_L] = sumProbs(0, k_exp(i), kS(i), p_obs(i),...
        p_A(i), r_A(i),...
        p_B(i), r_B(i),...
        LL_P(i), LR_P(i));
    [total_R, obs_total_R] = sumProbs(k_exp(i)+1, kS(i), kS(i), p_obs(i),...
        p_A(i), r_A(i),...
        p_B(i), r_B(i),...
        RL_P(i), RR_P(i));
    
    pval_0(i) = min((obs_total_L+obs_total_R)/(total_L+total_R), 1);
end

pval(~nf_idx) = nan;
pval(nf_idx) = pval_0;
end

function [total, obs_total] = sumProbs(kL, kR, kS, pO, pA, rA, pB, rB, L_val, R_val)
total = L_val + R_val;
obs_total = 0;

if (L_val <= pO)
    obs_total = obs_total + L_val;
end

if (R_val <= pO)
    obs_total = obs_total + R_val;
end

oldL_val = L_val;
oldR_val = R_val;
step = 1;
while(kL < kR)
    if (abs(oldR_val - R_val)/oldR_val > 0.01)
        addLeft = true;
    elseif(abs(oldL_val - L_val)/oldL_val > 0.01)
        addLeft = false;
    else
        addLeft = L_val > R_val;
    end
    
    if addLeft
        oldL_val = L_val;
        if(kL + step > kR)
            step = kR - kL;
        end
        kL = kL + step;
        L_val = nbinpdf(kL, rA, pA) * nbinpdf(kS-kL, rB, pB);
        
        if( step == 1 )
            total = total + L_val;
        else
            total = total + min( L_val, oldL_val ) * step;
        end
        
        if( L_val <= pO )
            if step == 1
                obs_total = obs_total + L_val;
            else
                if( oldL_val <= pO )
                    obs_total = obs_total + max(L_val, oldL_val)*step;
                else
                    obs_total = obs_total + max(L_val, oldL_val)*step ...
                                          *abs((pO-L_val)/(oldL_val-L_val));
                end
            end
        end
        
        if (abs(oldL_val - L_val)/oldL_val) < 1e-4
            step = max( step + 1, ceil(step * 1.5 ));
        end
    else %addRight
        oldR_val = R_val;
        if( kR - step < kL )
            step = kR - kL;
        end
        
        kR = kR - step;
        R_val = nbinpdf(kR, rA, pA) * nbinpdf(kS-kR, rB, pB);
        
        if step == 1
            total = total + R_val;
        else
            total = total + min( R_val, oldR_val ) * step;
        end
        
        if R_val <= pO
            if step == 1
                obs_total = obs_total + R_val;
            else
                if oldR_val <= pO
                    obs_total = obs_total + max(R_val, oldR_val ) * step;
                else
                    obs_total = obs_total + max(R_val, oldR_val ) * step...
                                       * abs((pO-R_val) / (oldR_val-R_val));
                end
            end
        end
        
        if (abs((oldR_val - R_val ))/oldR_val) < 1e-4
            step = max( step + 1, ceil(step * 1.5));
        end
    end
end
end
