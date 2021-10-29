### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 18e4f150-1eaf-11ec-0dfa-5feeb4c0626b
using Distributed

# ╔═╡ 8073be21-c42d-4616-9c62-32f47115334a
using NetworkInference

# ╔═╡ 33b974c0-ad65-4ef4-ba75-d6a00a184664
using LightGraphs

# ╔═╡ ad2c4547-1e59-4b33-9631-cccaa908df78
using GraphPlot

# ╔═╡ 78a6ff1e-8d1d-4867-b5c6-16d4070213df
using CUDA

# ╔═╡ 9caf1d37-8d66-42f4-9159-01ab5e1b1ae1
nprocs()

# ╔═╡ 5e78af02-24a5-4a50-85f3-71d6aa797fde
Base.Threads.nthreads()

# ╔═╡ 555dd90a-d544-4357-93b2-322c395f8c25
if haskey(ENV, "JULIA_NUM_THREADS")
	@info "Number of threads:", ENV["JULIA_NUM_THREADS"]
else
	@warn "No treads; restart julia as `julia -t 8`"
end

# ╔═╡ 33ca448d-20a0-4319-af45-227af15d1364
@Base.Threads.threads for i in 1:6
    println("thread #", Base.Threads.threadid(), " is starting task #$i")
    sleep(rand()) # pretend we're actually working
    println("thread #", Base.Threads.threadid(), " is finished")
end

# ╔═╡ 48eab231-0206-49c2-a8ce-799db2912ebc
#https://github.com/SmartTensors/SmartTensorsTutorials.jl/blob/main/notebooks/Julia_Introduction/Julia_Parallelization.ipynb

# ╔═╡ 58ab8844-8e6a-48bf-a9e0-7393e2e55c40
function parallel_estimate_pi2(n)
    4.0 * mapreduce(i -> (isodd(i) ? -1 : 1) / (2i + 1), +, 0:n)
end

# ╔═╡ ffa9a6f3-9d66-4ccc-9a93-7f5a1216fbca
@BenchmarkTools.btime parallel_estimate_pi2(100_000_000)

# ╔═╡ 07efee21-ba84-4971-8776-ba54d6d762f0
#https://github.com/Tchanders/NetworkInference.jl

# ╔═╡ 91f79dc5-e7e4-42cb-891d-e56e2c7986d3
#https://github.com/Tchanders/network_inference_tutorials/blob/master/notebooks/infer_network.ipynb

# ╔═╡ 3319b0df-f753-442e-a82c-537e27c91748
#dataset_name="https://raw.githubusercontent.com/Tchanders/network_inference_tutorials/master/simulated_datasets/100_ecoli1_large.txt"

# ╔═╡ b79e8c18-38dd-468e-b3c2-bd9a5582a537
#https://github.com/Tchanders/network_inference_tutorials/blob/master/simulated_datasets/50_yeast1_large.txt

# ╔═╡ bee744f2-1edc-4e71-8168-73f90eb2fea3
begin
	number_of_genes = 50
	# "ecoli1", "ecoli2", "yeast1", "yeast2" or "yeast3"
	organism = "yeast1"
	# "large", "medium", or "small"
	dataset_size = "large"
	# ...Or override dataset_name to point to your data file:
	#dataset_name = string("../simulated_datasets/", number_of_genes, "_", organism, "_", dataset_size, ".txt")
	#dataset_name = string("50_yeast1_large.txt")
	dataset_name = string("dataMManno.txt")
	# Choose an algorithm
	# PIDCNetworkInference(), PUCNetworkInference(), CLRNetworkInference() or MINetworkInference()
	algorithm = PIDCNetworkInference()
	# Keep the top x% highest-scoring edges
	# 0.0 < threshold < 1.0
	threshold = 0.1
end

# ╔═╡ e9aadaff-620c-430c-a745-c4ca1182a8e6
dataset_name

# ╔═╡ d38addd2-9c87-4629-80a4-8fadfdba6734
@time genes = get_nodes(dataset_name);

# ╔═╡ 8bb6a7a6-4a14-4dd3-8b12-bf20f2033971
genes

# ╔═╡ 5a83cb57-79e1-437e-bb9b-09b6b902f15f
@time network = InferredNetwork(algorithm, genes);

# ╔═╡ 41d548a8-4260-44fd-99fa-6aa14d5c2b8b
begin
	adjacency_matrix, labels_to_ids, ids_to_labels = get_adjacency_matrix(network, threshold)
	graph = LightGraphs.SimpleGraphs.SimpleGraph(adjacency_matrix)
	number_of_nodes = size(adjacency_matrix)[1]
	nodelabels = []
	for i in 1 : number_of_nodes
	    push!(nodelabels, ids_to_labels[i])
	end
end

# ╔═╡ 389d31b9-f5db-442f-9c8a-da6fafdf14ce
gplot(graph, nodelabel = nodelabels)

# ╔═╡ a484c4d5-faae-42cb-9786-69edd863f2f5
CUDA.version()

# ╔═╡ 48d9686f-302e-4f08-8009-52d98f361724
M = rand(2^12, 2^12)

# ╔═╡ e9543d87-3ca8-4ca4-9422-ad661fafc89a
	function benchmark_matmul_cpu(M)
	    M * M
	    return
	end

# ╔═╡ a46c5ec1-7eef-44b6-a542-34b465c45120
@btime benchmark_matmul_cpu(M)

# ╔═╡ 1a21170f-3951-489f-a550-541e3b825d55
M_on_gpu = cu(M)

# ╔═╡ 93df6236-6c83-41ef-87a9-0dae84a91af4
M_on_gpu

# ╔═╡ 68bc963e-dafc-4d7b-be59-493de7925f95
function benchmark_matmul_gpu(M)
    CUDA.@sync M * M
    return
end

# ╔═╡ b71d46aa-8bad-427b-a095-47af59e61804
@btime benchmark_matmul_gpu($M_on_gpu)

# ╔═╡ fd011728-9eb5-4dc1-a707-3c8fa0b890b0
benchmark_matmul_gpu(M_on_gpu)

# ╔═╡ ca27fd47-444b-4201-9c74-f007aa4b18ee
using BenchmarkTools

# ╔═╡ 80ec80f3-74ea-481f-86dd-5a1f4a63c143
using BenchmarkTools

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"
NetworkInference = "6b44d3db-2bc5-5ac3-b70f-26aa69b1b11b"

[compat]
BenchmarkTools = "~1.2.0"
CUDA = "~2.6.3"
GraphPlot = "~0.4.4"
LightGraphs = "~1.3.5"
NetworkInference = "~0.1.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[BFloat16s]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "4af69e205efc343068dc8722b8dfec1ade89254a"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.1.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "DataStructures", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "MacroTools", "Memoize", "NNlib", "Printf", "Random", "Reexport", "Requires", "SparseArrays", "Statistics", "TimerOutputs"]
git-tree-sha1 = "6893a46f357eabd44ce0fc1f9a264120a1a3a732"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "2.6.3"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bd4afa1fdeec0c8b89dad3c6e92bc6e3b0fec9ce"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.6.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "c6461fc7c35a4bb8d00905df7adafcff1fe3a6bc"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.2"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Discretizers]]
deps = ["DataStructures", "SpecialFunctions", "Statistics", "StatsBase"]
git-tree-sha1 = "5ec6df784844d2d6fbcb630998505f85d27bbd0b"
uuid = "6e83dbb3-75ca-525b-8ae2-3751f0dd50b4"
version = "3.2.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "StaticArrays", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "501c11d708917ca09ce357bed163dbaf0f30229f"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.23.12"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "502b3de6039d5b78c76118423858d981349f3823"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.9.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[GPUArrays]]
deps = ["AbstractFFTs", "Adapt", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "df5b8569904c5c10e84c640984cfff054b18c086"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "6.4.1"

[[GPUCompiler]]
deps = ["DataStructures", "ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "Scratch", "Serialization", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "ef2839b063e158672583b9c09d2cf4876a8d3d55"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.10.0"

[[GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "LightGraphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "dd8f15128a91b0079dfe3f4a4a1e190e54ac7164"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.4.4"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[InformationMeasures]]
deps = ["Discretizers"]
git-tree-sha1 = "874d48f2026e8faf3fd55c86973fd028b02cd1a0"
uuid = "96684042-fbdc-5399-9b8e-d34e539a126c"
version = "0.3.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LLVM]]
deps = ["CEnum", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "f57ac3fd2045b50d3db081663837ac5b4096947e"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "3.9.0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NNlib]]
deps = ["Adapt", "ChainRulesCore", "Compat", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "5203a4532ad28c44f82c76634ad621d7c90abcbd"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.7.29"

[[NetworkInference]]
deps = ["DelimitedFiles", "Distributed", "Distributions", "InformationMeasures", "Pkg", "SharedArrays", "Test"]
git-tree-sha1 = "bc63f91bc035351871388c70d5f10b59822d2c55"
uuid = "6b44d3db-2bc5-5ac3-b70f-26aa69b1b11b"
version = "0.1.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "95a4038d1011dfdbde7cecd2ad0ac411e53ab1bc"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.10.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["OpenSpecFun_jll"]
git-tree-sha1 = "d8d8b8a9f4119829410ecd706da4cc8594a1e020"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "0.10.3"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da4cf579416c81994afd6322365d00916c79b8ae"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "0.12.5"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "46d7ccc7104860c38b11966dd1f72ff042f382e4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.10"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─18e4f150-1eaf-11ec-0dfa-5feeb4c0626b
# ╠═9caf1d37-8d66-42f4-9159-01ab5e1b1ae1
# ╠═5e78af02-24a5-4a50-85f3-71d6aa797fde
# ╠═555dd90a-d544-4357-93b2-322c395f8c25
# ╠═33ca448d-20a0-4319-af45-227af15d1364
# ╟─48eab231-0206-49c2-a8ce-799db2912ebc
# ╠═58ab8844-8e6a-48bf-a9e0-7393e2e55c40
# ╠═ca27fd47-444b-4201-9c74-f007aa4b18ee
# ╟─ffa9a6f3-9d66-4ccc-9a93-7f5a1216fbca
# ╠═07efee21-ba84-4971-8776-ba54d6d762f0
# ╠═8073be21-c42d-4616-9c62-32f47115334a
# ╠═91f79dc5-e7e4-42cb-891d-e56e2c7986d3
# ╠═3319b0df-f753-442e-a82c-537e27c91748
# ╠═b79e8c18-38dd-468e-b3c2-bd9a5582a537
# ╠═bee744f2-1edc-4e71-8168-73f90eb2fea3
# ╠═e9aadaff-620c-430c-a745-c4ca1182a8e6
# ╠═d38addd2-9c87-4629-80a4-8fadfdba6734
# ╠═8bb6a7a6-4a14-4dd3-8b12-bf20f2033971
# ╠═5a83cb57-79e1-437e-bb9b-09b6b902f15f
# ╠═33b974c0-ad65-4ef4-ba75-d6a00a184664
# ╠═ad2c4547-1e59-4b33-9631-cccaa908df78
# ╠═41d548a8-4260-44fd-99fa-6aa14d5c2b8b
# ╠═389d31b9-f5db-442f-9c8a-da6fafdf14ce
# ╠═78a6ff1e-8d1d-4867-b5c6-16d4070213df
# ╠═a484c4d5-faae-42cb-9786-69edd863f2f5
# ╠═80ec80f3-74ea-481f-86dd-5a1f4a63c143
# ╠═48d9686f-302e-4f08-8009-52d98f361724
# ╠═e9543d87-3ca8-4ca4-9422-ad661fafc89a
# ╠═a46c5ec1-7eef-44b6-a542-34b465c45120
# ╠═1a21170f-3951-489f-a550-541e3b825d55
# ╠═93df6236-6c83-41ef-87a9-0dae84a91af4
# ╠═68bc963e-dafc-4d7b-be59-493de7925f95
# ╠═b71d46aa-8bad-427b-a095-47af59e61804
# ╠═fd011728-9eb5-4dc1-a707-3c8fa0b890b0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
