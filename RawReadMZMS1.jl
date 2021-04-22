#using Pkg
#Pkg.add("DataFrames")
#Pkg.add("CSV")
using DataFrames,CSV
df=DataFrame(CSV.File("L:/promec/Elite/LARS/2021/april/olej/second run SAX 2/210408_FT_SAX_urt3_210416151908.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv.combined.csv",normalizenames=true))
names(df)
using Plots
#Pkg.add("PlotThemes")
using PlotThemes
#Plots.showtheme(:dark)
theme(:gruvbox_dark)
histogram(df.MZ1)
#Pkg.add("StatsPlots")
using StatsPlots
@df df plot(:MZ1, [:MZ1210408_EL250_SAX_urt3_210416121234_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv :MZ1210408_FT_SAX_urt3_210416095759_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv])
@df df marginalhist(:MZ1210408_EL250_SAX_urt3_210416121234_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv, :MZ1210408_FT_SAX_urt3_210416095759_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv)
@df df violin(:MZ1)
boxplot!(["MZ1210408_EL250_SAX_urt3_210416121234_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv" "MZ1210408_FT_SAX_urt3_210416095759_raw_intensityThreshold1000_errTolDecimalPlace3_MZ1R_csv"], df, leg = false)
#Pkg.add("Turing")
using Turing
@model function gdemo(x, y)
  s ~ InverseGamma(2, 3)
  m ~ Normal(0, sqrt(s))
  x ~ Normal(m, sqrt(s))
  y ~ Normal(m, sqrt(s))
end
chn = sample(gdemo(1/mean(df.MZ1), 1/std(df.MZ1)), HMC(0.1, 5), 1000)
describe(chn)
plot(chn)
savefig("dfMZ1plot.svg")
