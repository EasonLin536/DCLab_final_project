import sys
import cv2
import numpy as np
from paint import paint
from style import *

if __name__ == '__main__':
    imgName = sys.argv[1]
    saveName = sys.argv[2]

    """    Read image    """
    sourceImg = cv2.imread(imgName)  # nparray[width, height, (BGR)]

    """      Paint      """
    oilImg = paint(sourceImg, brushR)

    """    Save image    """
    cv2.imwrite(saveName, oilImg)
