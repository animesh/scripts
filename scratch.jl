#setup
#https://julialang-s3.julialang.org/bin/winnt/x64/1.6
versioninfo()
#using Pkg
Pluto.run(host="10.20.93.253",port=8889)
http://10.20.93.118:8889/?secret=NhWiCckC
#GPU https://youtu.be/v9bFRg4rUfk
#Pkg.add("CUDA")
using CUDA
CUDA.version()
CUDA.functional()
CuDevice(0)
Mem.alloc
r=CUDA.rand(10000,10000)
sum(r)
CUDA.@time sum(r)
CUDA.@profile sum(r)
CUDA.@time r.+r# reverse(r)
using LinearAlgebra
@btime norm(r)
#CNN https://youtu.be/aa3JkX_cj_I

#https://juliagpu.gitlab.io/CUDA.jl/tutorials/introduction/
N = 2^20
x = fill(1.0f0, N)  # a vector filled with 1.0 (Float32)
y = fill(2.0f0, N)  # a vector filled with 2.0
y .+= x
using Test
@test all(y .== 3.0f0)
function sequential_add!(y, x)
    for i in eachindex(y, x)
        @inbounds y[i] += x[i]
    end
    return nothing
end
fill!(y, 2)
sequential_add!(y, x)
@test all(y .== 3.0f0)
function parallel_add!(y, x)
    Threads.@threads for i in eachindex(y, x)
        @inbounds y[i] += x[i]
    end
    return nothing
end
fill!(y, 2)
parallel_add!(y, x)
@test all(y .== 3.0f0)
using BenchmarkTools
@btime sequential_add!($y, $x)
@btime parallel_add!($y, $x)
x_d = CUDA.fill(1.0f0, N)  # a vector stored on the GPU filled with 1.0 (Float32)
y_d = CUDA.fill(2.0f0, N)  # a vector stored on the GPU filled with 2.0
y_d .+= x_d
@test all(Array(y_d) .== 3.0f0)
@btime add_broadcast!($y_d, $x_d)
function gpu_add2_print!(y, x)
    index = threadIdx().x    # this example only requires linear indexing, so just use `x`
    stride = blockDim().x
    @cuprintln("thread $index, block $stride")
    for i = index:stride:length(y)
        @inbounds y[i] += x[i]
    end
    return nothing
end
@cuda threads=16 gpu_add2_print!(y_d, x_d)
synchronize()

#https://github.com/JuliaLang/IJulia.jl
#using Pkg
#https://github.com/Gnimuc/CImGui.jl
#Pkg.add("CImGui")
using CImGui
#include(joinpath(pathof(CImGui), "..", "..", "demo", "demo.jl"))
include(joinpath(pathof(CImGui), "..", "..", "examples", "demo.jl"))
#https://github.com/JuliaPlots/StatsPlots.jl
#Pkg.add("StatsPlots") # install the package if it isn't installed
using StatsPlots # no need for `using Plots` as that is reexported here
gr(size=(400,300))
#https://github.com/JuliaStats/RDatasets.jl
#Pkg.add("RDatasets")
covellipse([0,2], [2 1; 1 4], n_std=2, aspect_ratio=1, label="cov1")
covellipse!([1,0], [1 -0.5; -0.5 3], showaxes=true, label="cov2")
import RDatasets
iris = RDatasets.dataset("datasets", "iris")
iris.Species
#http://juliagizmos.github.io/Interact.jl/latest/deploying/
#Pkg.add("Interact") # install the package if it isn't installed
#using Interact
#ui = button()
#display(ui)
using StatsPlots, Interact
#Pkg.add("Blink")
using Blink
w = Window()
body!(w, dataviewer(iris))
#https://github.com/SciML/ModelingToolkit.jl
#Pkg.add("ModelingToolkit")
#Pkg.add("OrdinaryDiffEq")
dist = Gamma(2)
scatter(dist, leg=false)
bar!(dist, func=cdf, alpha=0.3)
x = rand(Normal(), 100)
y = rand(Cauchy(), 100)
plot(
 qqplot(x, y, qqline = :fit), # qqplot of two samples, show a fitted regression line
 qqplot(Cauchy, y),           # compare with a Cauchy distribution fitted to y; pass an instance (e.g. Normal(0,1)) to compare with a specific distribution
 qqnorm(x, qqline = :R)       # the :R default line passes through the 1st and 3rd quartiles of the distribution
)
#https://en.wikipedia.org/wiki/Andrews_plot
using RDatasets
iris = dataset("datasets", "iris")
@df eltypes(iris)
iris[!,:Species]
@df iris andrewsplot((iris[!,:Species]), cols(1:4), legend = :topleft)
#https://datatofish.com/export-dataframe-to-csv-julia/
#Pkg.add("CSV")
using CSV
CSV.write("iris.csv", iris)
#Pkg.add("DataFrames")
using DataFrames
iris = CSV.read("iris.csv", NamedTuple)
iris = CSV.read("iris.csv",DataFrame)
using Pkg
#CSV.read(joinpath(Pkg.dir("DataFrames"), "test/data/iris.csv"))
plot(iris.PetalLength)
plot(iris.Species)
@df iris scatter(
    :SepalLength,
    :SepalWidth,
    group = :Species,
    m = (0.5, [:cross :hex :star7], 12),
    bg = RGB(0.2, 0.2, 0.2)
)
@df iris andrewsplot(:Species,cols(:SepalLength,:SepalLength,:SepalLength,:SepalLength))#,legend = :topleft)
#https://statisticswithjulia.org/StatisticsWithJuliaDRAFT.pdf
using RDatasets, StatsPlots
@df iris andrewsplot(:Species, cols(1:4),line=(fill=[:blue :red :green]), legend=:topleft)
iris = dataset("datasets", "iris")
@df iris violin(:Species, :SepalLength,fill=:blue, xlabel="Species", ylabel="Sepal Length")
using ModelingToolkit, OrdinaryDiffEq
@parameters t σ ρ β
@variables x(t) y(t) z(t)
@derivatives D'~t
eqs = [D(D(x)) ~ σ*(y-x),
       D(y) ~ x*(ρ-z)-y,
       D(z) ~ x*y - β*z]
sys = ODESystem(eqs)
sys = ode_order_lowering(sys)
u0 = [D(x) => 2.0,
      x => 1.0,
      y => 0.0,
      z => 0.0]
p  = [σ => 28.0,
      ρ => 10.0,
      β => 8/3]
tspan = (0.0,100.0)
prob = ODEProblem(sys,u0,tspan,p,jac=true)
sol = solve(prob,Tsit5())
using Plots; plot(sol,vars=(x,y))

@parameters t σ ρ β
@variables x(t) y(t) z(t)
@derivatives D'~t
eqs = [D(x) ~ σ*(y-x),
       D(y) ~ x*(ρ-z)-y,
       D(z) ~ x*y - β*z]
lorenz1 = ODESystem(eqs,name=:lorenz1)
lorenz2 = ODESystem(eqs,name=:lorenz2)
@variables a
@parameters γ
connections = [0 ~ lorenz1.x + lorenz2.y + a*γ]
connected = ODESystem(connections,t,[a],[γ],systems=[lorenz1,lorenz2])
u0 = [lorenz1.x => 1.0,
      lorenz1.y => 0.0,
      lorenz1.z => 0.0,
      lorenz2.x => 0.0,
      lorenz2.y => 1.0,
      lorenz2.z => 0.0,
      a => 2.0]
p  = [lorenz1.σ => 10.0,
      lorenz1.ρ => 28.0,
      lorenz1.β => 8/3,
      lorenz2.σ => 10.0,
      lorenz2.ρ => 28.0,
      lorenz2.β => 8/3,
      γ => 2.0]
tspan = (0.0,100.0)
prob = ODEProblem(connected,u0,tspan,p)
sol = solve(prob,Rodas5())
using Plots; plot(sol,vars=(a,lorenz1.x,lorenz2.z))

#https://github.com/animesh/Distributions.jl
#Pkg.add("Distributions")
#https://juliastats.org/Distributions.jl/stable/starting/
using Random, Distributions
Random.seed!(123)
d = Normal()
x = rand(d, 1000)
fit(Normal, x)
truncated(Normal(0,1))#,l,u)
#Pkg.add("IJulia")
#using IJulia
#julia>notebook()
#https://youtu.be/g8RkArhtCc4?t=738
#Pkg.add("WAV")
using WAV
#!c:\ffmpeg-2020-12-12-git-5148740e79-essentials_build\bin\ffmpeg.exe -i ..\..\Desktop\Documents\Lydinnspillinger\chk.m4a  chk.wav
sound = wavread("chk.wav")
signals = sound[1][:,1]#1-channel
#Pkg.add("Plots")
using Plots
plot(signals,x_lims=(200200,202200))
#Pkg.add("FFTW")
using FFTW
?fft
signal_fft=fft(signals)
length(signal_fft)
length(signals)
plot(signal_fft[1:1000])
plot(abs.(signal_fft))
plot(abs.(signal_fft[102200:202200]))
#https://towardsdatascience.com/scientific-python-with-lambda-b207b1ddfcd1
norm(x) = [i = (i-mean(x)) / std(x) for i in xt]
norm()
norm(x::Array) = [i = (i-mean(x)) / std(x) for i in xt]
norm(x::Int64) = (x - x) / std(x)
#https://github.com/Evizero/UnicodePlots.jl
Pkg.add("UnicodePlots")
using UnicodePlots
histogram(randn(1000) .* 0.1, nbins = 15, closed = :left)
heatmap(collect(0:30) * collect(0:30)', xscale=0.1, yscale=0.1, xoffset=-2.5, colormap=:inferno)

#https://probcomp.github.io/Gen/ The, install the Gen package with the Julia package manager. From the Julia REPL, type ] to enter the Pkg REPL mode and then run: pkg> add https://github.com/probcomp/Gen
Pkg.add(url="https://github.com/probcomp/Gen")
#https://probcomp.github.io/Gen/intro-to-modeling/Introduction%20to%20Modeling%20in%20Gen
using Gen
@gen function sine_model(xs::Vector{Float64})
    n = length(xs)
    phase = @trace(uniform(0, 2 * pi), :phase)
    period = @trace(gamma(5, 1), :period)
    amplitude = @trace(gamma(1, 1), :amplitude)
    for (i, x) in enumerate(xs)
        mu = amplitude * sin(2 * pi * x / period + phase)
        @trace(normal(mu, 0.1), (:y, i))
    end
    return n
end;
function render_sine_trace(trace; show_data=true)
    xs = get_args(trace)[1]
    xmin = minimum(xs)
    xmax = maximum(xs)
    if show_data
        ys = [trace[(:y, i)] for i=1:length(xs)]
        scatter(xs, ys, c="black")
    end
    phase = trace[:phase]
    period = trace[:period]
    amplitude = trace[:amplitude]
    test_points = collect(range(xmin, stop=xmax, length=100))
    plot(test_points, amplitude * sin.(2 * pi * test_points / period .+ phase))
    ax = gca()
    ax[:set_xlim]((xmin, xmax))
    ax[:set_ylim]((xmin, xmax))
end;
xs = [-5., -4., -3., -.2, -1., 0., 1., 2., 3., 4., 5.];
traces = [Gen.simulate(sine_model, (xs,)) for _=1:12];
#import Pkg
#Pkg.add("PyPlot")
using PyPlot
figure(figsize=(16, 8))
for (i, trace) in enumerate(traces)
    subplot(3, 6, i)
    render_sine_trace(trace)
end

#using Pkg
#Pkg.add("Calculus")
using Calculus
Calculus.gradient(x -> 3x^2 + 2x + 1, 5) # (32,)

Pkg.add("Trebuchet")
Pkg.add("Nemo")
using Nemo
R, x = FiniteField(7, 11, "x")
#(Finite field of degree 11 over F_7,x)
S, y = PolynomialRing(R, "y")
#(Univariate Polynomial Ring in y over Finite field of degree 11 over F_7,y)
T = ResidueRing(S, y^3 + 3x*y + 1)
#Residue ring of Univariate Polynomial Ring in y over Finite field of degree 11 over F_7 modulo y^3+(3*x)*y+(1)
U, z = PolynomialRing(T, "z")
#(Univariate Polynomial Ring in z over Residue ring of Univariate Polynomial Ring in y over Finite field of degree 11 over F_7 modulo y^3+(3*x)*y+(1),z)
f = (3y^2 + y + x)*z^2 + ((x + 2)*y^2 + x + 1)*z + 4x*y + 3;
g = (7y^2 - y + 2x + 7)*z^2 + (3y^2 + 4x + 1)*z + (2x + 1)*y + 1;
s = f^12;
t = (s + g)^12;
@time resultant(s, t)
#0.426612 seconds (705.88 k allocations: 52.346 MB, 2.79% gc time)
#(x^10+4*x^8+6*x^7+3*x^6+4*x^5+x^4+6*x^3+5*x^2+x)*y^2+(5*x^10+x^8+4*x^7+3*x^5+5*x^4+3*x^3+x^2+x+6)*y+(2*x^10+6*x^9+5*x^8+5*x^7+x^6+6*x^5+5*x^4+4*x^3+x+3)
#] add https://github.com/tpapp/DynamicHMCExamples.jl
#https://github.com/FluxML/model-zoo/blob/cdda5cad3e87b216fa67069a5ca84a3016f2a604/games/differentiable-programming/trebuchet/DiffRL.jl

Pkg.add("VegaLite")
using Soss
hello = @model μ,x begin
       σ ~ HalfCauchy()
       x ~ Normal(μ,σ) |> iid
       end

data = (μ=1, x=[2,4,5])
lda

graphEdges(hello)
logdensity(hello)

using DynamicHMC
DynamicHMC.nuts(hello, data=data).samples

using Flux, Trebuchet
using Flux.Tracker: forwarddiff
using Statistics: mean

using Trebuchet
gradient((wind, angle, weight) -> Trebuchet.shoot(wind, angle, weight),-2, 45, 200) # (4.02, -0.99, 0.051)
using Pkg
Pkg.add("Gadfly")

Pkg.add("Trebuchet")
using Gadfly
Gadfly.plot([sin, cos,tan], -20*pi, 20*pi)
Pkg.add("Soss")
Pkg.add("Mocha")
Pkg.test("Mocha")

using Mocha

data  = HDF5DataLayer(name="train-data",source="train-data-list.txt",batch_size=64)
conv  = ConvolutionLayer(name="conv1",n_filter=20,kernel=(5,5),bottoms=[:data],tops=[:conv])
pool  = PoolingLayer(name="pool1",kernel=(2,2),stride=(2,2),bottoms=[:conv],tops=[:pool])
conv2 = ConvolutionLayer(name="conv2",n_filter=50,kernel=(5,5),bottoms=[:pool],tops=[:conv2])
pool2 = PoolingLayer(name="pool2",kernel=(2,2),stride=(2,2),bottoms=[:conv2],tops=[:pool2])
fc1   = InnerProductLayer(name="ip1",output_dim=500,neuron=Neurons.ReLU(),bottoms=[:pool2],
                          tops=[:ip1])
fc2   = InnerProductLayer(name="ip2",output_dim=10,bottoms=[:ip1],tops=[:ip2])
loss  = SoftmaxLossLayer(name="loss",bottoms=[:ip2,:label])

backend = DefaultBackend()
init(backend)

common_layers = [conv, pool, conv2, pool2, fc1, fc2]
net = Net("MNIST-train", backend, [data, common_layers..., loss])

exp_dir = "snapshots"
solver_method = SGD()
params = make_solver_parameters(solver_method, max_iter=10000, regu_coef=0.0005,
    mom_policy=MomPolicy.Fixed(0.9),
    lr_policy=LRPolicy.Inv(0.01, 0.0001, 0.75),
    load_from=exp_dir)
solver = Solver(solver_method, params)

setup_coffee_lounge(solver, save_into="$exp_dir/statistics.jld", every_n_iter=1000)

# report training progress every 100 iterations
add_coffee_break(solver, TrainingSummary(), every_n_iter=100)

# save snapshots every 5000 iterations
add_coffee_break(solver, Snapshot(exp_dir), every_n_iter=5000)

# show performance on test data every 1000 iterations
data_test = HDF5DataLayer(name="test-data",source="test-data-list.txt",batch_size=100)
accuracy = AccuracyLayer(name="test-accuracy",bottoms=[:ip2, :label])
test_net = Net("MNIST-test", backend, [data_test, common_layers..., accuracy])
add_coffee_break(solver, ValidationPerformance(test_net), every_n_iter=1000)

solve(solver, net)

destroy(net)
destroy(test_net)
shutdown(backend)

Pkg.add("DataFrames")
using DataFrames
data = readtable("Z:\\USERS\\Lymphoma\\dataLarsImpTtestBHcorr.txt",separator = '\t')
plot(data[:x1_19913],data[:x1_19913])
head(data,10)
describe(data[:x1_19913])
describe(data[:x10_29288])
showcols(data)

 Pkg.add("ScikitLearn")
 using ScikitLearn
@sk_import preprocessing: LabelEncoder
labelencoder = LabelEncoder()
categories = [2 3 4 5 6 12 13]

for col in categories
    train[col] = fit_transform!(labelencoder, train[col])
end


#https://medium.com/@ODSC/reinforcement-learning-vs-differentiable-programming-48528f464795?source=email-51edc4174b8c-1557027412126-digest.reader------0-58------------------585c497f_b359_40d6_9661_ae5703bd5c26-1&sectionName=top
using Pkg
Pkg.add("Gadfly")
using Gadfly
Gadfly.plot([sin, cos,tan], -20*pi, 20*pi)
#https://github.com/JuliaOpt/JuMP.jl/blob/master/examples/cannery.jl
