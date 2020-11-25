import sys

# imgName:  character string of the file name of the image to be rendered.
# T:        the approximation threshold defining how close the stroke
#           colour is to original image. Higher T -> rougher painting.
# fg:       grid size. Scales the increment or spacing of the brush stroke
#           grid size. Step size is the brush radius size scaled by fg.  
# fs:       blur factor. Scales the standard deviation of Gaussian filter. 
#           Smaller -> more noise (more impressionist).
# fc:       curvature filter. Limits or exaggerates the brush stroke 
#           curvature.
# maxLen:   maximum length of stroke. Shorter stroke makes painting more
#           Pointillist.
# minLen:   minimum length of stroke. Longer stroke makes painting more
#           Expressionist.
# brushR:   brush sizes. A list of n brush sizes (radius). Fewer leads to
#           better performance.
# C:        canvas constant paint colour (background).

# A classic parameter set is the Impressionist style: T = 50, fg = 1, 
# fs = 0.5, fc = 1, maxLen = 16, minLen = 4, brushR = [8,4,2]

img_fname = sys.argv[1]
T         = 50
fg        = 1
fs        = 0.5
fc        = 1
maxLen    = 16
minLen    = 4
brushR    = [8,4,2] # largest brush strokes painted first
