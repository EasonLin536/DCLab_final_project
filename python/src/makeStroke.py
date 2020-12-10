import math
import numpy as np
from style import *
from estimate import *


def makeStroke(R, x0, y0, refColor, canvas, gradX, gradY, gradM, strokeLen, dxF, dyF, strokeColor):
    # x0, y0 : initial image coordinate
    # gradX, gradY : gradient direction
    # gradM : gradient magnitude

    # strokeColor = refImage[x0, y0]
    x = x0
    y = y0
    # dxF = 0  # final gradient change
    # dyF = 0
    finish = False

    # for i in range(0, maxLen):  # stroke is limited by the maximum length
    # coordinate must be within image dimensions
    # if x < 0 or y < 0 or x >= refImage.shape[0] or y >= refImage.shape[1]:
    #     finish = True
    #     # print("output of range")
    # else:

    # refColor = refImage[x, y]  # refColor at coordinate
    canvasColor = canvas  # refColor of canvas
    diffR = abs(int(refColor[0]) - int((canvasColor[0]))
                ) < abs(int(refColor[0]) - int(strokeColor[0]))
    diffG = abs(int(refColor[1]) - int((canvasColor[1]))
                ) < abs(int(refColor[1]) - int(strokeColor[1]))
    diffB = abs(int(refColor[2]) - int((canvasColor[2]))
                ) < abs(int(refColor[2]) - int(strokeColor[2]))
    diffColor = (diffR and diffG and diffB)
    # returns stroke if refColor difference exceeded
    if (strokeLen > minLen and diffColor) or gradM[x, y] == 0 or strokeLen == maxLen:
        # print("break 3")
        finish = True
    else:
        # if gradM[x, y] == 0:  # returns if gradient zero
        #     finish = True
        # normal gradient to stroke path
        dx = -gradY[x, y]
        dy = gradX[x, y]
        if (dxF * dx + dyF * dy < 0):  # ensures positve normal gradient
            dx = -dx
            dy = -dy
        # gradient curvature
        dx = fc * dx + (1 - fc) * dxF
        dy = fc * dy + (1 - fc) * dyF
        # normalises gradient
        d = dx ** 2 + dy ** 2
        dx = dx / square(d)
        dy = dy / square(d)
        # print(d ** 0.5)
        # advances coordinate by integer amount of gradient scaled by
        # brush size
        x = math.floor(x + R * dx)
        y = math.floor(y + R * dy)
        dxF = dx
        dyF = dy
        # K.append([x, y])  # updates stroke points

    strokeLen += 1

    return [x, y], dxF, dyF, strokeLen, finish
    # return np.array(K), strokeColor
