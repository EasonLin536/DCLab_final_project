import cv2
import numpy as np
from makeStroke import makeStroke
from style import *
from estimate import *

# NumPy for MATLAB users
# http://mathesaurus.sourceforge.net/matlab-numpy.html


def grayScale(image):
    gray = ((image[:, :, 0] * 114 + image[:, :, 1] * 587 + image[0, 0, 2] * 229 + 500) / 1000).astype(np.uint8).clip(0, 255)
    return gray


def mySobelX(image):
    operatorX = np.array(([[1, 0, 1], [2, 0, -2], [1, 0, -1]]), np.int8)
    gradX = cv2.filter2D(src=image, kernel=operatorX, ddepth=-1).astype(np.uint8).clip(0, 255)
    return gradX

def mySobelY(image):
    operatorY = np.array(([[1, 2, 1], [0, 0, 0], [-1, -2, -1]]), np.int8)
    gradY = cv2.filter2D(src=image, kernel=operatorY, ddepth=-1).astype(np.uint8).clip(0, 255)
    return gradY


def paintLayer(canvas, refImage, brushSize, fg=1):
    # canvas : image with single color
    # refImage : blurred source image
    # brush : brush size

    layer = np.zeros(refImage.shape)
    # Calculate difference
    diffImage = difference(canvas, refImage)
    # Calculate gradient
    gray = grayScale(refImage)
    gradX = mySobelX(gray)
    gradY = mySobelY(gray)
    # gradX = cv2.Sobel(gray, -1, 1, 0, ksize=3)
    # gradY = cv2.Sobel(gray, -1, 0, 1, ksize=3)
    gradM = (abs(gradX) + abs(gradY)) * 0.25

    height, width, _ = refImage.shape
    grid = fg * brushSize
    print("brushSize:", brushSize)
    print('grid =', grid)
    print("x range: 0 ~", height - grid + 1)
    print("y range: 0 ~", width - grid + 1)
    xorder = np.arange(grid, height - grid + 1, grid)
    yorder = np.arange(grid, width - grid + 1, grid)
    np.random.seed(87)
    np.random.shuffle(xorder)
    np.random.shuffle(yorder)
    # print("xorder:", xorder)
    for x0 in list(xorder):
        for y0 in list(yorder):
            gridRegion = diffImage[x0 - grid // 2 + 1: x0 + grid //
                                   2 + 1, y0 - grid // 2 + 1: y0 + grid // 2 + 1]
            gridErr = np.sum(gridRegion) / (grid ** 2)

            # print(gridRegion)
            # print("x0, y0:", x0, y0)
            if gridErr > T:
                ind = np.unravel_index(
                    np.argmax(gridRegion, axis=None), gridRegion.shape)
                x = ind[0] + x0
                y = ind[1] + y0
                # print("x, y:", x, y)
                dxF, dyF, strokeLen, finish = 0, 0, 0, 0 
                strokeColor = refImage[x, y]
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
                while True:
                    if finish:
                        # print("finish")
                        break
                    # print("(x, y)=", x, y)
                    xMax = refImage.shape[0] - tipX
                    xMin = 1 + tipX
                    yMax = refImage.shape[1] - tipY
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
                        area = layer[x - tipX: x + tipX + 1, y - tipY: y + tipY + 1, 0: 3]
                        # print("area", area.shape)
                        # print("layer:", layer.shape)
                        painted = (area * brush != 0)
                        clean = (painted == 0)
                        layer[x - tipX: x + tipX + 1, y - tipY: y + tipY + 1, 0: 3] \
                            = area + brush * clean
                    stroke, dxF, dyF, strokeLen, finish = makeStroke(
                        brushSize, x, y, refImage, canvas, gradX, gradY, gradM, strokeLen, dxF, dyF, strokeColor)
                    x = stroke[0]
                    y = stroke[1]
                # return gradM
                # return layer
    return layer


def difference(canvas, refImage):
    # diff_ch0 = (canvas[:, :, 0] - refImage[:, :, 0]) ** 2
    # diff_ch1 = (canvas[:, :, 1] - refImage[:, :, 1]) ** 2
    # diff_ch2 = (canvas[:, :, 2] - refImage[:, :, 2]) ** 2
    diff_ch0 = np.array(abs(canvas[0] - refImage[:, :, 0])).astype(np.uint8)
    diff_ch1 = np.array(abs(canvas[1] - refImage[:, :, 1])).astype(np.uint8)
    diff_ch2 = np.array(abs(canvas[2] - refImage[:, :, 2])).astype(np.uint8)
    # return (diff_ch0 + diff_ch1 + diff_ch2) ** 0.5
    return (diff_ch0 + diff_ch1 + diff_ch2)


def circle(R):
    if R < 3:
        R = R+1
    c = np.zeros((R, R))
    # x is index or number???
    # start from 0 or 1??
    for x in np.arange(R - 1, -1, -1):
        y = square((R - x) * (R + x))
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
