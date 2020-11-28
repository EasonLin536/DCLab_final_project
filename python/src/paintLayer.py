import numpy as np
# from makeStroke import makeStroke


def paintLayer(canvas, refImage, T, fg, brush):
    # canvas : image with single color
    # refImage : blurred source image
    # brush : brush size

    layer = np.zeros(canvas.shape)
    diffImage = difference(canvas, refImage)
    
    height, width, _ = canvas.shape
    grid = fg * brush
    for x in range(0, height - grid + 1):
        for y in range(0, width - grid + 1):
            gridRegion = diffImage[x : x + grid, y : y + grid]
            gridErr = np.sum(gridRegion) / (grid ** 2)

            if gridErr > T:
                ind = np.unravel_index(np.argmax(gridRegion, axis=None), gridRegion.shape)
                x1 = ind[0] + x
                y1 = ind[1] + y
                stroke = makeStroke(brush, x1, y1, refImage)
                
            break
        break

    return layer 


def difference(canvas, refImage):
    diff_ch0 = (canvas[:, :, 0] - refImage[:, :, 0]) ** 2
    diff_ch1 = (canvas[:, :, 1] - refImage[:, :, 1]) ** 2
    diff_ch2 = (canvas[:, :, 2] - refImage[:, :, 2]) ** 2
    
    return (diff_ch0 + diff_ch1 + diff_ch2) ** 0.5