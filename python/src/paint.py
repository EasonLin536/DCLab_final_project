import numpy as np
from blur import blur
from paintLayer import paintLayer
from style import *


def paint(sourceImg, brushR):
    # Empty painting
    oilImg = np.zeros(sourceImg.shape)
    # Paint the image with multiple brushes
    # Blur original image
    refImage = blur(sourceImg)
    for brush in sorted(brushR, reverse=True):
        # Empty canvas with single color
        canvas = C
        
        # Paint a layer
        layer = paintLayer(canvas, refImage, brush)

        blank = (layer == 0)
        oilImg = (oilImg) * (oilImg != 0) * blank + layer
    # oilImg = layer

    return oilImg
