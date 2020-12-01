import sys
import cv2
import numpy as np
from paint import paint
from style import *

if __name__ == '__main__':
    try:
        imgName = sys.argv[1]
        saveName = sys.argv[2]
    except:
        imgName = "../input/view.jpg"
        saveName = "../output/view.jpg"

    """    Read image    """
    sourceImg = cv2.imread(imgName)  # nparray[width, height, (BGR)]

    """      Paint      """
    oilImg = paint(sourceImg, brushR)

    """    Save image    """
    cv2.imwrite(saveName, oilImg)
