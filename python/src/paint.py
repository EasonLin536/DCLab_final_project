import numpy as np
from blur import blur
from paintLayer import paintLayer
from style import *


def paint(sourceImg, brushR):
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
        refImage = blur(sourceImg, brush)
        # Paint a layer
        layer = paintLayer(canvas, refImage, brush)

    oilImg = layer

    return oilImg