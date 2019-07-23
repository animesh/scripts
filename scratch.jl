#https://probcomp.github.io/Gen/ The, install the Gen package with the Julia package manager. From the Julia REPL, type ] to enter the Pkg REPL mode and then run: pkg> add https://github.com/probcomp/Gen
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

#Pkg.add("Nemo")
Pkg.add("Trebuchet")
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
