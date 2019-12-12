#https://peerj.com/preprints/27736/
from pyopenms import *
seq = AASequence.fromString("DFPIANGER")
seq_formula = seq.getFormula()
#print("Peptide", seq, "has molecular formula", seq_formula)
print(seq_formula.calculateTheoreticalIsotopesNumber())
print(seq.getFormula)
#https://pyopenms.readthedocs.io/en/latest/digestion.html#proteolytic-digestion-with-lys-c
from urllib.request import urlretrieve
urlretrieve ("http://www.uniprot.org/uniprot/P02769.fasta", "bsa.fasta")
dig = ProteaseDigestion()
dig.setEnzyme('Lys-C')
bsa = "".join([l.strip() for l in open("bsa.fasta").readlines()[1:]])
bsa = AASequence.fromString(bsa)
result = []
dig.digest(bsa, result)
print(result[4].toString())
len(result) # 57 peptides
from pyopenms import *
SimpleSearchEngineAlgorithm().search("example.mzML","search.fasta", protein_ids, peptide_ids)
for peptide_id in peptide_ids:
    print (35*"=")
    print ("Peptide ID m/z:", peptide_id.getMZ())
    print ("Peptide ID rt:", peptide_id.getRT())
    print ("Peptide scan index:", peptide_id.getMetaValue("scan_index"))
    print ("Peptide scan name:", peptide_id.getMetaValue("scan_index"))
    print ("Peptide ID score type:", peptide_id.getScoreType())
        # PeptideHits
        for hit in peptide_id.getHits():
        print(" - Peptide hit rank:", hit.getRank())
        print(" - Peptide hit charge:", hit.getCharge())
        print(" - Peptide hit sequence:", hit.getSequence())
        z = hit.getCharge()
        mz = hit.getSequence().getMonoWeight(Residue.ResidueType.Full, z) / z
        print(" - Peptide hit monoisotopic m/z:", mz)
        print(" - Peptide ppm error:", abs(mz - peptide_id.getMZ())/mz *10**6 )
        print(" - Peptide hit score:", hit.getScore())

tsg = TheoreticalSpectrumGenerator()
thspec = MSSpectrum()
p = Param()
p.setValue("add_metainfo", "true")
tsg.setParameters(p)
peptide = AASequence.fromString("RPGADSDIGGFGGLFDLAQAGFR")
tsg.getSpectrum(thspec, peptide, 1, 1)
#PeerJ Preprints | https://doi.org/10.7287/peerj.preprints.27736v1 18 | CC BY 4.0 Open Access | rec: 16 May 2019, publ: 16 May 2019
# Iterate over annotated ions and their masses
for ion, peak in zip(thspec.getStringDataArrays()[0], thspec):
print(ion, peak.getMZ())
e = MSExperiment()
MzMLFile().load("searchfile.mzML", e)
print ("Spectrum native id", e[2].getNativeID() )
mz,i = e[2].get_peaks()
peaks = [(mz,i) for mz,i in zip(mz,i) if i > 1500 and mz > 300]
for peak in peaks:
print (peak[0], "mz", peak[1], "int")

#https://openai.com/blog/procgen-benchmark/
! pip install procgen --user
#$ python -m procgen.interactive --env-name starpilot # human
import gym
env = gym.make('procgen:procgen-coinrun-v0')
obs = env.reset()
while True:
    obs, rew, done, info = env.step(env.action_space.sample())
    env.render()
    if done:
        break
#https://openai.com/blog/safety-gym/
#https://github.com/openai/safety-gym
import safety_gym
import gym
env = gym.make('Safexp-PointGoal1-v0')
next_observation, reward, done, info = env.step(action)
info
#https://github.com/openai/safety-starter-agents


#https://openai.com/blog/deep-double-descent/
