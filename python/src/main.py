import sys
import cv2
import numpy as np
from paint import paint


imgName  = sys.argv[1]
saveName = sys.argv[2]
T        = 50
fg       = 1
fs       = 0.5
fc       = 1
maxLen   = 16
minLen   = 4
brushR   = [8] # largest brush strokes painted first
C        = [128, 128, 128] # background color

# Read image
sourceImg = cv2.imread(imgName) # nparray[width, height, (BGR)]
# Paint
oilImg = paint(sourceImg, T, fg, fs, fc, maxLen, minLen, brushR, C)
# Save image
cv2.imwrite(saveName, oilImg)