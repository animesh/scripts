### A Pluto.jl notebook ###
# v0.14.0
using Markdown
using InteractiveUtils
# ╔═╡ 3f1c5cd3-2020-45e1-b4e7-8cbb967ef092
using WAV
# ╔═╡ 1b1f4b61-9e97-4cbb-acec-5f7f36ac80c5
using Plots
# ╔═╡ 234cbb60-9547-11eb-3d9c-739a1958d633
#youtube-dl -i --extract-audio --audio-format wav --audio-quality 0  "https://www.youtube.com/watch?v=38C1htPhqEY"
#youtube-dl -i --extract-audio --audio-format wav --audio-quality 0  "https://www.youtube.com/watch?v=38C1htPhqEY" #idol
#youtube-dl -i --extract-audio --audio-format wav --audio-quality 0  "https://www.youtube.com/watch?v=e5rKKL37kHQ" #beyonce
#sound = wavread("C:\\Users\\animeshs\\GD\\julia-1.6.0-win64\\Pawandeep ने दिया 'Teri Mitti' पे एक Emotional Performance _ Indian Idol Season 12-38C1htPhqEY.wav")
sound = wavread("C:\\Users\\animeshs\\GD\\julia-1.6.0-win64\\Beyoncé - Halo (Acoustic)-e5rKKL37kHQ.wav")
using Plots
plot(sound)
signals = sound[1][:,1]#1-channel
#Pkg.add("Plots")
plot(signals,x_lims=(200200,202200))
#Pkg.add("FFTW")
using FFTW
#?fft
signal_fft=fft(signals)
length(signal_fft)
length(signals)
plot(signal_fft[1:1000])
plot(abs.(signal_fft))
plot(abs.(signal_fft[102200:202200]))
plot(abs.(signal_fft),x_lims=(1,100000))
#plots https://drive.google.com/file/d/1k1CjM7BKy4NOnkXodDQ6uBc7oGcf1Y6T/view?usp=sharing
# ╔═╡ b6c343b0-5fc4-4e40-b430-2bb49f8c65ea
# ╔═╡ Cell order:
# ╠═234cbb60-9547-11eb-3d9c-739a1958d633
# ╠═3f1c5cd3-2020-45e1-b4e7-8cbb967ef092
# ╠═05b8a7a0-255d-4ae6-bc30-d96883772a0d
# ╠═1b1f4b61-9e97-4cbb-acec-5f7f36ac80c5
# ╠═4bb17e32-79ea-4806-b2a2-1fe973999be2
# ╠═b6c343b0-5fc4-4e40-b430-2bb49f8c65ea
