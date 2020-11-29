import cv2
import numpy as np
from makeStroke import makeStroke
from style import *


def paintLayer(canvas, refImage, brush):
    # canvas : image with single color
    # refImage : blurred source image
    # brush : brush size

    layer = np.zeros(canvas.shape)
    # Calculate difference
    diffImage = difference(canvas, refImage)
    # Calculate gradient
    gray = cv2.cvtColor(refImage, cv2.COLOR_BGR2GRAY)
    gradX = cv2.Sobel(gray, -1, 1, 0, ksize=3)
    gradY = cv2.Sobel(gray, -1, 0, 1, ksize=3)
    gradM = (gradX ** 2 + gradY ** 2) ** 0.5

    height, width, _ = canvas.shape
    grid = fg * brush
    print('grid =', grid)
    for x in range(0, height - grid + 1):
        for y in range(0, width - grid + 1):
            gridRegion = diffImage[x : x + grid, y : y + grid]
            gridErr = np.sum(gridRegion) / (grid ** 2)

            print(gridRegion)

            if gridErr > T:
                ind = np.unravel_index(np.argmax(gridRegion, axis=None), gridRegion.shape)
                x1 = ind[0] + x
                y1 = ind[1] + y
                stroke, strokeColor = makeStroke(brush, x1, y1, refImage, canvas, gradX, gradY, gradM)

            # TODO : Paint strokes on canvas

    # return gradM
    # return layer


def difference(canvas, refImage):
    diff_ch0 = (canvas[:, :, 0] - refImage[:, :, 0]) ** 2
    diff_ch1 = (canvas[:, :, 1] - refImage[:, :, 1]) ** 2
    diff_ch2 = (canvas[:, :, 2] - refImage[:, :, 2]) ** 2
    
    return (diff_ch0 + diff_ch1 + diff_ch2) ** 0.5