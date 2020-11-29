import cv2
import numpy as np
from makeStroke import makeStroke
from style import *

# NumPy for MATLAB users
# http://mathesaurus.sourceforge.net/matlab-numpy.html


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
            gridRegion = diffImage[x: x + grid, y: y + grid]
            gridErr = np.sum(gridRegion) / (grid ** 2)

            print(gridRegion)

            if gridErr > T:
                ind = np.unravel_index(
                    np.argmax(gridRegion, axis=None), gridRegion.shape)
                x1 = ind[0] + x
                y1 = ind[1] + y
                stroke, strokeColor = makeStroke(
                    brush, x1, y1, refImage, canvas, gradX, gradY, gradM)

                if len(stroke) != 0:
                    tip = circle(brush)
                    tipX = np.floor(tip.shape[1]/2)
                    tipY = np.floor(tip.shape[0]/2)
                    tipR = tip @ strokeColor[0, 0, 0]
                    tipG = tip @ strokeColor[0, 0, 1]
                    tipB = tip @ strokeColor[0, 0, 2]
                    brush = np.array([tipR, tipG, tipB])
                    # TODO : Paint strokes on canvas
                    for p in range(stroke.shape[1]):
                        pass

                    # return gradM
                    # return layer


def difference(canvas, refImage):
    diff_ch0 = (canvas[:, :, 0] - refImage[:, :, 0]) ** 2
    diff_ch1 = (canvas[:, :, 1] - refImage[:, :, 1]) ** 2
    diff_ch2 = (canvas[:, :, 2] - refImage[:, :, 2]) ** 2

    return (diff_ch0 + diff_ch1 + diff_ch2) ** 0.5


def circle(R):
    if R < 3:
        R = R+1
    c = np.zeros(R)
    # x is index or number???
    # start from 0 or 1??
    for x in arange(R, 0, -1):
        y = (R**2-(x-1)**2)**0.5
        y = np.floor(y)
        c[arange(y, 0, -1), x] = np.ones(y, 1)
    end0 = c.shape[0]-1
    end1 = c.shape[1]-1
    c = np.concatenate((
        c[arange(end0, 1, -1), arange(end1, 1, -1)],
        c[arange(end0, 1, -1), :],
        c[:, arange(endq, 1, -1)],
        c
    ))
    return c
