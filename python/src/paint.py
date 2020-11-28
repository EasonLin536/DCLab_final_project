import numpy as np
from blur import blur
from paintLayer import paintLayer


def paint(sourceImg, T, fg, fs, fc, maxLen, minLen, brushR, C):
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

    # Empty painting
    oilImg = np.zeros(sourceImg.shape)
    # Paint the image with multiple brushes
    for brush in brushR:
        # Empty canvas with single color
        canvas = np.ones(sourceImg.shape)
        canvas[:, :, 0] = C[0]
        canvas[:, :, 1] = C[1]
        canvas[:, :, 2] = C[2]
        # Blur original image
        refImage = blur(sourceImg, fs, brush)
        # Paint a layer
        layer = paintLayer(canvas, refImage, T, fg, brush)

    # oilImg = canvas

    return oilImg