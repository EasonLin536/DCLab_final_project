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
    dxF = 0 # final gradient change
    dyF = 0
    K = [[x, y]] # points of stroke

    for i in range(0, maxLen): # stroke is limited by the maximum length
        # coordinate must be within image dimensions
        if x < 0 or y < 0 or x == refImage.shape[0] or y == refImage.shape[1]:
            break
        
        refColor = refImage[x, y] # refColor at coordinate
        canvasColor = canvas[x, y] # refColor of canvas
        diffR = abs(refColor[0] - canvasColor[0]) < abs(refColor[0] - strokeColor[0])
        diffR = abs(refColor[1] - canvasColor[1]) < abs(refColor[1] - strokeColor[1])
        diffG = abs(refColor[2] - canvasColor[2]) < abs(refColor[2] - strokeColor[2])
        diffColor = (diffR and diffG and diffB)
        
        # returns stroke if refColor difference exceeded
        if i > minLen and diffColor: 
            break

        if gradM[x, y] == 0: # returns if gradient zero
            break

        # normal gradient to stroke path
        dx = -gradY[x, y]
        dy = gradX[x, y]
        if (dxF * dx + dyF * dy < 0): # ensures positve normal gradient
            dx = -dx
            dy = -dy

        # gradient curvature
        dx = fc * dx + (1 - fc) * dxF
        dy = fc * dy + (1 - fc) * dyF
        # normalises gradient
        dx = dx / (dx ** 2 + dy ** 2) ** 0.5
        dy = dy / (dx ** 2 + dy ** 2) ** 0.5
        # advances coordinate by integer amount of gradient scaled by
        # brush size
        x = math.floor(x + R * dx)
        y = math.floor(y + R * dy)
        dxF = dx
        dyF = dy
        K.append([x, y]) # updates stroke points

    return K, strokeColor
    # return stroke, strokeColor