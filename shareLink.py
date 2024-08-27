#pip3 install minio
import sys
if len(sys.argv)!=3:    sys.exit("REQUIRED: minio\n","USAGE: python shareLink.py <minio-user-passwd> <file>")
key = sys.argv[1]
name = sys.argv[2]
import minio
minio_client=minio.Minio("server-drive.promec.sigma2.no",access_key="promecshare",secret_key=key)
url = minio_client.presigned_get_object("raw", name)
print(url)
