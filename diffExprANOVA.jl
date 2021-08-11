# -*- coding: utf-8 -*- https://github.com/bkamins/Julia-DataFrames-Tutorial repository).
#[confidence intervals](https://en.wikipedia.org/wiki/Confidence_interval)
#[density estimators](https://en.wikipedia.org/wiki/Density_estimation)
#[probit model](https://en.wikipedia.org/wiki/Probit_model)
#[bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics))
#using Pkg
#Pkg.add("DataFrames")
using DataFrames
#Pkg.add("CSV")
using CSV
#Pkg.add("CategoricalArrays")
using CategoricalArrays
#Pkg.add("Plots")
using Plots
#using Bootstrap
#using Chain
#using GLM
#using Random
#using StatsPlots
#using Statistics
cd("L:/promec/Animesh/Aida/")
pwd()
fileName="Supplementary Table 2 for working purpose.xlsxgene.csv"
readlines(fileName)
df_raw = CSV.read(fileName, DataFrame)
describe(df_raw)
df = select(df_raw,
#:Group => x -> recode(x, "M" => 1, "G" => 0  => :M²),
#:TFRC.1  => ByRow(x -> x^2) => :TFRC²,
Between(1,5),# => isnumeric,
#Between(:TFRC.1, :PLOD3.5),
            :Group => categorical,
            renamecols=false)
describe(df)
histogram(df[:,1])
@chain df begin
    groupby(:Group)
    combine([:1, :5] .=> mean)
end
[:1, :5] .=> mean
@chain df begin
    groupby(:Group)
    combine(names(df, Real) .=> mean)
end
@chain df begin
    groupby([:Group, :TFRP])
    combine(nrow)
end
@chain df begin
    groupby([:Group, :TFRC.1])
    combine(nrow)
    unstack(:Group, :TFRC.1, :nrow)
end
@chain df begin
    groupby([:Group, :1])
    combine(nrow)
    unstack(:Group, :1, :nrow)
    select(:Group, [:no, :yes] => ByRow((x, y) -> y / (x + y)) => :1_yes)
end
@chain df begin
    groupby(:Group)
    combine(:1 => (x -> mean(x .== "yes")) => :1_yes)
end
gd = groupby(df, :Group)
gd[1]
gd[(Group=0,)]
gd[Dict(:Group => 0)]
gd[(0,)]
@df df density(:"SCP2.2",group=:Group)
#probit = glm(@formula(Group ~ lnnlinc + age + age² + educ + nyc + noc + foreign),df, Binomial(), ProbitLink())
probit = glm(Term(:Group) ~ sum(Term.(propertynames(df)[1:end-1])),df)
Term(:Group) ~ sum(Term.(propertynames(df)[1:end-1]))
#@formula(Group ~ lnnlinc + age + age² + educ + nyc + noc + foreign)
#probit = glm(@formula(Group ~ lnnlinc + age + age^2 + educ + nyc + noc + foreign),df, Binomial(), ProbitLink())
#@formula(Group ~ lnnlinc + age + age^2 + educ + nyc + noc + foreign)
#df_pred = DataFrame(lnnlinc=10.0, age= 2.0:0.01:6.2, educ = 9, nyc = 0, noc = 1, foreign = "yes")
probit_pred = predict(probit, df_pred, interval=:confidence)
plot(df_pred.age, Matrix(probit_pred), labels=["Group" "lower" "upper"],
     xlabel="age", ylabel="Pr(Group=1)")
function boot_sample(df)
    df_boot = df[rand(1:nrow(df), nrow(df)), :]
    probit_boot = glm(Term(:Group) ~ sum(Term.(propertynames(df)[1:end-1])),
                      df_boot, Binomial(), ProbitLink())
    return (; (Symbol.(coefnames(probit_boot)) .=> coef(probit_boot))...)
end
function run_boot(df, reps)
    coef_boot = DataFrame()
    for _ in 1:reps
        push!(coef_boot, boot_sample(df))
    end
    return coef_boot
end
Random.seed!(42)
@time coef_boot = run_boot(df, 1000)
conf_boot = mapcols(x -> quantile(x, [0.025, 0.975]), coef_boot)
confint(probit)
conf_param = DataFrame(permutedims(confint(probit)), names(conf_boot))
append!(conf_boot, conf_param)
insertcols!(conf_boot, 1, :statistic => ["boot lo", "boot hi", "parametric lo", "parametric hi"])
conf_boot_t = permutedims(conf_boot, :statistic)
insertcols!(conf_boot_t, 2, :estimate => coef(probit))
select!(conf_boot_t, :statistic, :estimate, 3:6 .=> x -> abs.(x .- conf_boot_t.estimate), renamecols=false)
scatter(0.05 .+ (1:8), conf_boot_t.estimate,
        yerror=(conf_boot_t."boot lo", conf_boot_t."boot hi"),
        label="bootstrap",
        xticks=(1:8, conf_boot_t.statistic), xrotation=45)
scatter!(-0.05 .+ (1:8), conf_boot_t.estimate,
         yerror=(conf_boot_t."parametric lo", conf_boot_t."parametric hi"),
         label="parametric")
function boot_probit(df_boot)
    probit_boot = glm(@formula(Group ~ lnnlinc + age + age^2 + educ + nyc + noc + foreign),
                      df_boot, Binomial(), ProbitLink())
    return (; (Symbol.(coefnames(probit_boot)) .=> coef(probit_boot))...)
end
Random.seed!(42)
@time bs = bootstrap(boot_probit, df, BasicSampling(1000))
bs_ci = confint(bs, PercentileConfInt(0.95))
conf_boot_t.bootstrap = [(ci[1], ci[1] - ci[2], ci[3] - ci[1]) for ci in bs_ci]
conf_boot_t
select!(conf_boot_t, Not(:bootstrap), :bootstrap => ["estimate 2", "boot lo 2", "boot hi 2"])
select(conf_boot_t, :statistic, r"estimate", r"lo", r"hi")
sort(conf_boot_t, :estimate)
