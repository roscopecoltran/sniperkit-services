from hdfs3 import HDFileSystem
import time

def main():
	start = int(time.time() * 1000)
	hdfs = HDFileSystem(host='10.200.10.1', port=10500)
	'''with hdfs.open('/user/kingofshadows/myfile.txt', 'wb') as f:
		f.write('Hello, world!')
	with hdfs.open('/user/kingofshadows/myfile.txt', 'rb') as f:
		print(f.read())
	hdfs.ls('/')'''
	hdfs.put('/test-files/10653954_330928323779441_1670298960_n.jpg', 'img1.jpg')
	print(str(int(time.time()*1000) - start) + ' milliseconds.')

main()
