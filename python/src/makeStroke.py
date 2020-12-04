import math
import numpy as np
from style import *



def makeStroke(R, x0, y0, refImage, canvas, gradX, gradY, gradM):
    # x0, y0 : initial image coordinate
    # gradX, gradY : gradient direction
    # gradM : gradient magnitude
    
    strokeColor = refImage[x0, y0]
    x = x0
    y = y0
    dxF = 0  # final gradient change
    dyF = 0
    K = [[x, y]]  # points of stroke

    for i in range(0, maxLen):  # stroke is limited by the maximum length
        # coordinate must be within image dimensions
        if x < 0 or y < 0 or x >= refImage.shape[0] or y >= refImage.shape[1]:
            break

        refColor = refImage[x, y]  # refColor at coordinate
        canvasColor = canvas[x, y]  # refColor of canvas
        diffR = abs(int(refColor[0]) - int((canvasColor[0]))
                    ) < abs(int(refColor[0]) - int(strokeColor[0]))
        diffG = abs(int(refColor[1]) - int((canvasColor[1]))
                    ) < abs(int(refColor[1]) - int(strokeColor[1]))
        diffB = abs(int(refColor[2]) - int((canvasColor[2]))
                    ) < abs(int(refColor[2]) - int(strokeColor[2]))
        diffColor = (diffR and diffG and diffB)

        # returns stroke if refColor difference exceeded
        if i > minLen and diffColor:
            break

        if gradM[x, y] == 0:  # returns if gradient zero
            break

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
        dx = dx / ((dx ** 2 + dy ** 2) ** 0.5)
        dy = dy / ((dx ** 2 + dy ** 2) ** 0.5)

        # advances coordinate by integer amount of gradient scaled by
        # brush size
        x = math.floor(x + R * dx)
        y = math.floor(y + R * dy)
        dxF = dx
        dyF = dy
        K.append([x, y])  # updates stroke points

    return np.array(K), strokeColor
    # return stroke, strokeColor
