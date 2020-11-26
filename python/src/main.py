import sys
from paint import paint


imgName = sys.argv[1]
T       = 50
fg      = 1
fs      = 0.5
fc      = 1
maxLen  = 16
minLen  = 4
brushR  = [8, 4, 2] # largest brush strokes painted first

# Read image
# Paint
paint(sourceImg, T, fg, fs, fc, maxLen, minLen, brushR, C)