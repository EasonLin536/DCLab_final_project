import cv2
import math
import numpy as np
from style import *


def blur(sourceImg, brush):
    # sourceImg : origninal image, type: nparray
    # brush : brush size
    # blurImage : image after blurring

    # sigma = fs * brush
    # ksize = 2 * math.ceil(2 * sigma) + 1
    # print("Blurring image with sigma =", sigma)
    blurImage = cv2.GaussianBlur(sourceImg, (5, 5), 1)

    return blurImage