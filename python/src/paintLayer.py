import cv2
import numpy as np
from makeStroke import makeStroke
from style import *

# NumPy for MATLAB users
# http://mathesaurus.sourceforge.net/matlab-numpy.html


def paintLayer(canvas, refImage, brushSize, fg=1):
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
    grid = fg * brushSize
    print("canvas shape:", canvas.shape)
    print("brushSize:", brushSize)
    print('grid =', grid)
    print("x range: 0 ~", height - grid + 1)
    print("y range: 0 ~", width - grid + 1)
    xorder = np.arange(grid, height - grid + 1, grid)
    yorder = np.arange(grid, width - grid + 1, grid)
    np.random.seed(87)
    np.random.shuffle(xorder)
    np.random.shuffle(yorder)
    print("xorder:", xorder)
    for x in list(xorder):
        for y in list(yorder):
            gridRegion = diffImage[x - grid // 2 + 1: x + grid //
                                   2 + 1, y - grid // 2 + 1: y + grid // 2 + 1]
            gridErr = np.sum(gridRegion) / (grid ** 2)

            # print(gridRegion)

            if gridErr > T:
                ind = np.unravel_index(
                    np.argmax(gridRegion, axis=None), gridRegion.shape)
                x1 = ind[0] + x
                y1 = ind[1] + y
                stroke, strokeColor = makeStroke(
                    brushSize, x1, y1, refImage, canvas, gradX, gradY, gradM)

                if len(stroke) != 0:
                    tip = circle(brushSize)
                    tipX = int(np.floor(tip.shape[1]/2))
                    tipY = int(np.floor(tip.shape[0]/2))
                    # print("strokeColor:\n", strokeColor)
                    tipR = tip * strokeColor[0]
                    tipG = tip * strokeColor[1]
                    tipB = tip * strokeColor[2]
                    brush = np.dstack((tipR, tipG, tipB))
                    # TODO : Paint strokes on canvas
                    # print("stroke shape", stroke.shape)
                    # print("stroke:\n", stroke)
                    for p in range(stroke.shape[0]):
                        x = stroke[p, 1]
                        y = stroke[p, 0]
                        xMax = refImage.shape[1] - tipX
                        xMin = 1 + tipX
                        yMax = refImage.shape[0] - tipY
                        yMin = 1 + tipY
                        if x >= xMin and x < xMax and y >= yMin and y < yMax:
                            # print("x:", x)
                            # print("y:", y)
                            # print("xMax:", xMax)
                            # print("xMin:", xMin)
                            # print("yMax:", yMax)
                            # print("yMin:", yMin)
                            # print("tipX:", tipX)
                            # print("tipY:", tipY)
                            area = layer[y - tipY: y + tipY +
                                         1, x - tipX: x + tipX + 1, 0: 3]
                            # print("area", area.shape)
                            # print("layer:", layer.shape)
                            painted = (area * brush != 0)
                            clean = (painted == 0)
                            layer[y - tipY: y + tipY + 1, x - tipX: x + tipX + 1, 0: 3] \
                                = area + brush * clean
                    # return gradM
                    # return layer
    return layer


def difference(canvas, refImage):
    diff_ch0 = (canvas[:, :, 0] - refImage[:, :, 0]) ** 2
    diff_ch1 = (canvas[:, :, 1] - refImage[:, :, 1]) ** 2
    diff_ch2 = (canvas[:, :, 2] - refImage[:, :, 2]) ** 2

    return (diff_ch0 + diff_ch1 + diff_ch2) ** 0.5


def circle(R):
    if R < 3:
        R = R+1
    c = np.zeros((R, R))
    # x is index or number???
    # start from 0 or 1??
    for x in np.arange(R - 1, -1, -1):
        y = (R**2-x**2)**0.5
        y = int(np.floor(y))
        c[np.arange(y - 1, -1, -1), x] = np.ones(y)
    end0 = c.shape[0]-1
    end1 = c.shape[1]-1
    c_ = c[np.arange(end0, 0, -1), :]
    c_ = c_[:, np.arange(end1, 0, -1)]
    c = np.concatenate(
        (np.concatenate((c_, c[np.arange(end0, 0, -1), :]), axis=1),
         np.concatenate((c[:, np.arange(end1, 0, -1)], c), axis=1)), axis=0)
    # print(c)
    return c
