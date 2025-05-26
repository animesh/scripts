#ln -s /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/Data /mnt/promec-ns9036k/Data  #server
#module load git/2.42.0-GCCcore-13.2.0
#module load Python/3.11.5-GCCcore-13.2.0
#python3 -m pip install minio
#ln -s /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/Data $HOME/.
#python3 scripts/shareLink.py 123sharepromec321 Data 211207_Apsana.1725452013.tar
#pip3 install minio
import sys
if len(sys.argv)!=4:    sys.exit("REQUIRED: minio\n","USAGE: python shareLink.py <minio-user-passwd> <path> <file>")
key = sys.argv[1]
dirpath = sys.argv[2]
name = sys.argv[3]
import minio
minio_client=minio.Minio("server-server-drive.promec.sigma2.no",access_key="promecshare",secret_key=key)
url = minio_client.presigned_get_object(dirpath, name)
print(url)

