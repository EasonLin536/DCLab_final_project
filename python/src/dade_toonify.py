import sys
import cv2
import time
import numpy as np

start_time = time.time()

i_filename = sys.argv[1]
o_filename = sys.argv[2]

grayImg = cv2.imread(i_filename, 0)
medianBlurImg = cv2.medianBlur(grayImg, 7)
edgeImg = cv2.Canny(medianBlurImg, 100, 200)

print("--- %s seconds for canny ---" % (time.time() - start_time))

colorImg = cv2.imread(i_filename)
# bilateralImg = cv2.bilateralFilter(colorImg, 9, 41, 41)
# medianBlurImg = cv2.medianBlur(colorImg, 7)
quantizeImg = np.floor(colorImg / 32) * 32
cv2.imwrite(o_filename, quantizeImg)

#finalImg = np.copy(quantizeImg)
#for i in range(quantizeImg.shape[0]):
#	for j in range(quantizeImg.shape[1]):
#		if edgeImg[i][j] != 0:
#			finalImg[i][j][:] = 0

#cv2. imwrite(o_filename, finalImg)


print("--- %s seconds for all ---" % (time.time() - start_time))
