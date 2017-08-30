from concurrent.futures import ThreadPoolExecutor
import argparse
import glob
import random
import requests
import sys
import time
import uuid

parser = argparse.ArgumentParser(description='Benchmark Pavlov Match.')
parser.add_argument('images_dir', metavar='IMAGES_DIR', type=str, help='directory with images to test')
parser.add_argument('-u', dest='url', default='http://localhost:8888', type=str, help='the URL of Match')
parser.add_argument('-i', dest='iterations', default=1000, type=int, help='number of iterations during the benchmark')
parser.add_argument('-c', dest='concurrency', default=10, type=int, help='concurrency of requests during the benchmark')
args = parser.parse_args()

images = glob.glob(args.images_dir + '/*')
print('benchmarking with {} images, {} iterations, {} concurrency'.format(len(images), args.iterations, args.concurrency))

def run(i):
    start = time.time()
    img = random.choice(images)
    filepath = uuid.uuid4()
    requests.post(args.url + '/add', files={'image': open(img, 'r')}, data={'filepath': filepath})
    requests.post(args.url + '/search', files={'image': open(img, 'r')})
    end = time.time()
    print('elapsed: {}'.format(end - start))

if __name__ == '__main__':
    total_start = time.time()
    executor = ThreadPoolExecutor(max_workers=args.concurrency)

    try:
        for x in executor.map(run, range(args.iterations)): pass
    except KeyboardInterrupt:
        print('shutting down...')
        executor.shutdown()

    total_end = time.time()
    total_elapsed = total_end - total_start
    avg_elapsed = total_elapsed / args.iterations
    print('total elapsed: {}, avg elapsed: {}'.format(total_elapsed, avg_elapsed))
    sys.exit(0)
