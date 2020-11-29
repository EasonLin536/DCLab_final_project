import numpy as np
from blur import blur
from paintLayer import paintLayer
from style import *


def paint(sourceImg, brushR):
    # Empty painting
    oilImg = np.zeros(sourceImg.shape)
    # Paint the image with multiple brushes
    for brush in sorted(brushR, reverse=True):
        # Empty canvas with single color
        canvas = np.ones(sourceImg.shape)
        canvas[:, :, 0] = C[0]*canvas[:, :, 0]
        canvas[:, :, 1] = C[1]*canvas[:, :, 1]
        canvas[:, :, 2] = C[2]*canvas[:, :, 2]
        # Blur original image
        refImage = blur(sourceImg, brush)
        # Paint a layer
        layer = paintLayer(canvas, refImage, brush)

        blank = (layer == 0)
        notlayer = canvas * blank
        oilImg = (oilImg)*(oilImg != 0)*blank + (oilImg != 0) * \
            (layer != 0)*(layer)+(notlayer+layer)*(oilImg == 0)
    # oilImg = layer

    return oilImg
