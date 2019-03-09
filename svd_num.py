#https://nbviewer.jupyter.org/github/fastai/numerical-linear-algebra-v2/blob/master/nbs/02-Background-Removal-with-SVD.ipynb
import numpy as np
M = np.random.uniform(-40,40,[10,15])
import matplotlib.pyplot as plt
plt.imshow(M, cmap='gray');
U, s, V = np.linalg.svd(M, full_matrices=False)
np.save("U.npy", U)
np.save("s.npy", s)
np.save("V.npy", V)
U = np.load("U.npy")
s = np.load("s.npy")
V = np.load("V.npy")
print(U.shape, s.shape, V.shape)
low_rank = np.expand_dims(U[:,0], 1) * s[0] * np.expand_dims(V[0,:], 0)
dims = (5, 2)
plt.imshow(np.reshape(M[:,0] - low_rank[:,0], dims), cmap='gray');
k=5
compressed_M = U[:,:k] @ np.diag(s[:k]) @ V[:k,:]
plt.imshow(compressed_M, cmap='gray')
