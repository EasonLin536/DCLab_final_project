import os
import sys
import time
import copy
import numpy as np
from PIL import Image

from scipy.ndimage.filters import convolve
from scipy.signal import medfilt2d

width = 640
height = 480

## Utility funciton
def grayscale(rgb):
    return (np.dot(rgb[..., :3], [0.299, 0.587, 0.114])).astype(int)

def SerialIn(img, kernal_size=3):
    H, W = img.shape

    # to serial input
    resulting_img = []
    D = range(256)
    for i in range(H-kernal_size+1):
        row = []
        for j in range(W):
            pack = []
            for k in range(kernal_size):
                temp = img[i+k][j]
                if(temp not in D):
                    print(temp)
                assert(temp in D)
                pack.append(temp)
            row.append(pack)
        resulting_img.append(row)
    return resulting_img

def Padding(orig_img, padnum=1, printPad=False, noPad=False, file=False):
    # When doing Median and Sobel, padnum = 1; when doing Gaussian, padnum = 2

    # padding
    if not noPad:
        img = np.pad(orig_img, padnum, mode='edge')
    else:
        img = orig_img

    if printPad:
        print(img)

    return img

def show_edge(img):
    img = np.where(img==False, 255, img)
    img = np.where(img==True, 0, img)
    img_final = Image.fromarray(img.astype(np.int32))
    img_final.show()

# ================== Gaussian Filter ================== #
def Gaussian(img, debug=False, file=False):
    H, W = img.shape
    serial = SerialIn(img, kernal_size=3)

    img_gau = []

    if file:
        i_pixel = []
        golden = []

    for i in range(H-2):
        A = serial[i][0:2]

        gau_row = []

        for j in range(W-2):
            A.append(serial[i][j+2])
            # TODO
            
            gau = ((A[0][0]+A[0][2]+A[2][0]+A[2][2]) >> 4) + \
                  ((A[1][0]+A[0][1]+A[2][1]+A[1][2]) >> 3) + \
                  (A[1][1] >> 2)
            
            gau_row.append(gau)

            if file:
                # input string
                str_in = ""
                for a in range(5):
                    for b in range(5):
                        str_tmp = hex(A[a][b])[2:]
                        if len(str_tmp) == 1:
                            str_tmp = "0" + str_tmp
                        str_in += str_tmp
                i_pixel.append(str_in)

                golden.append(hex(gau)[2:])

            del A[0]

        img_gau.append(gau_row)


    if file:
        with open("pattern/Gaussian/out_golden.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, golden)))
        with open("pattern/Gaussian/i_pixel.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, i_pixel)))
        

    # return type should be a 2-dimensional numpy array representing the grayscale of the image.
    # Elements in the numpy array should be integer type within 0~31.
    img_pad = Padding(np.array(img_gau), padnum=2)
    return img_pad


# ================== Sobel Convolution================== #
def sign(number): # extend number to 8 bits  
    if number >= 0: return 0
    else: return 1

def sobel_col0(img_col):
    sum0=(img_col[0])
    sum1=(img_col[1])<<1
    sum2=(img_col[2])
    return sum0+sum1+sum2

def sobel_col2(img_col):
    sum0=(img_col[0]*-1)
    sum1=(img_col[1]*-2)
    sum2=(img_col[2]*-1)
    return sum0+sum1+sum2

def sobel_col3(img_col):
    sum0=(img_col[0])
    sum2=(img_col[2]*-1)
    return sum0+sum2

def sobel_col4(img_col):
    sum0=(img_col[0])<<1
    sum2=(img_col[2])*-2
    return sum0+sum2

def sobel_col5(img_col):
    sum0=(img_col[0])
    sum2=(img_col[2])*-1
    return sum0+sum2

def sign_XOR(Gx_MSB,Gy_MSB):
    return Gx_MSB ^ Gy_MSB

def tangent_22_5(G):
    return (G>>2) + (G>>3) + (G>>5) + (G>>7)

def angle_judge(sign,Gxt,Gyt):
    if ((not Gxt) and (not Gyt)): 
        if(sign): return 3#01 45
        else : return 1#11 135
    else :
        if(Gxt): return 0 #  0
        else : return 2 #10 90

def compare_bool(n1,n2):
    if n1>n2 : return True
    else : return False

def Sobel(img, debug=False, file=False):
    H, W = img.shape
    serial = SerialIn(img, kernal_size=3)
    count = 0

    if file:
        i_pixel = []
        golden_ang = []
        golden_grad = []

    img_angle = []
    img_gradient = []
    for i in range(H - 2):
        A = serial[i][0:2]

        angle_row = []
        gradient_row = []
        for j in range(W - 2):
            A.append(serial[i][j+2])

            sum0 = sobel_col0(A[0])
            sum2 = sobel_col2(A[2])
            sum3 = sobel_col3(A[0])
            sum4 = sobel_col4(A[1])
            sum5 = sobel_col5(A[2])

            count += 1

            Gx = sum0 + sum2
            Gy = sum3 + sum4 + sum5
            Gx_val = abs(Gx)
            Gy_val = abs(Gy)
            Gradient = ((Gx_val + Gy_val) >> 2)
            if Gradient > 255 :
                Gradient = 255

            Gx_tan = tangent_22_5(Gx_val)
            Gy_tan = tangent_22_5(Gy_val)
            
            Gxt = compare_bool(Gx_tan,Gy_val)
            Gyt = compare_bool(Gy_tan,Gx_val)
            co_sign = sign_XOR(sign(Gx),sign(Gy))
            angle = angle_judge(co_sign,Gxt,Gyt)
            
            angle_row.append(angle)
            gradient_row.append(Gradient)

            if file:
                # input string
                str_in = ""
                for a in range(3):
                    for b in range(3):
                        str_tmp = hex(A[a][b])[2:]
                        if len(str_tmp) == 1:
                            str_tmp = "0" + str_tmp
                        str_in += str_tmp
                i_pixel.append(str_in)

                golden_grad.append(hex(Gradient)[2:])
                golden_ang.append(hex(angle)[2:])

            del A[0]

        img_angle.append(angle_row)
        img_gradient.append(gradient_row)

    if file:
        with open("pattern/Sobel/golden_grad.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, golden_grad)))
        with open("pattern/Sobel/golden_ang.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, golden_ang)))
        with open("pattern/Sobel/i_pixel.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, i_pixel)))

    # First return:     return type should be a 2-dimensional numpy array representing the gradient of the image.
    #                   Elements in the numpy array should be integer type within 0~31.
    # Second return:    return type should be a 2-dimensional numpy array representing the edge angle of the image.
    #                   Elements in the numpy array should be 2-bit binary strings, ex: "01".
    img_grad_pad = Padding(np.array(img_gradient), padnum=1)
    return img_grad_pad, np.array(img_angle)


def NonMax(gradient, angle, debug=False, file=False):
    H, W = angle.shape
    serial = SerialIn(gradient, kernal_size=3)

    if file:
        i_pixel = []
        i_angle = []
        golden = []

    img_med = []
    for i in range(H):
        A = serial[i][0:2]

        med_row = []
        for j in range(W):
            A.append(serial[i][j+2])
            ang = angle[i][j]

            # MUX
            if ang  == 0:
                pix1 = A[0][1]
                pix2 = A[2][1]
            elif ang == 1:
                pix1 = A[0][2]
                pix2 = A[2][0]
            elif ang == 2:
                pix1 = A[1][0]
                pix2 = A[1][2]
            elif ang == 3:
                pix1 = A[0][0]
                pix2 = A[2][2]
            else:
                print("Error: \"ang\" value error!!")


            if A[1][1] >= pix1 and A[1][1] >= pix2:
                result = A[1][1]
            else:
                result = 0

            med_row.append(result)

            if file:
                # input string
                str_in = ""
                for a in range(3):
                    for b in range(3):
                        str_tmp = hex(A[a][b])[2:]
                        if len(str_tmp) == 1:
                            str_tmp = "0" + str_tmp
                        str_in += str_tmp
                i_pixel.append(str_in)
                i_angle.append(hex(ang)[2:])
                golden.append(hex(result)[2:])

            del A[0]

        img_med.append(med_row)

    if file:
        with open("pattern/NonMax/out_golden.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, golden)))
        with open("pattern/NonMax/i_grad.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, i_pixel)))
        with open("pattern/NonMax/i_angle.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, i_angle)))

    # return type should be a 2-dimensional numpy array representing the modified gradient of the image.
    # Elements in the numpy array should be integer type within 0~31.
    img_pad = Padding(np.array(img_med), padnum=1)
    return img_pad


def Hysteresis(img, debug=False, file=False):
    H, W = img.shape
    serial = SerialIn(img, kernal_size=3)
    count = 0

    # TODO
    weak = 5
    strong = 20

    if file:
        i_pixel = []
        golden = []

    img_med = []
    for i in range(H-2):
        A = serial[i][0:2]

        med_row = []
        for j in range(W-2):
            A.append(serial[i][j+2])

            result = None
            if A[1][1] <= weak:
                result = 1
            elif A[1][1] >= strong:
                result = 0
            else:
                for p in range(3):
                    for q in range(3):
                        if result == 0:
                            pass
                        else:
                            if A[p][q] >= strong:
                                result = 0
                            else:
                                result = 1

            count += 1

            med_row.append(result)

            if file:
                # input string
                str_in = ""
                for a in range(3):
                    for b in range(3):
                        str_tmp = hex(A[a][b])[2:]
                        if len(str_tmp) == 1:
                            str_tmp = "0" + str_tmp
                        str_in += str_tmp
                i_pixel.append(str_in)
                        
                golden.append(result)

            del A[0]

        img_med.append(med_row)

    if file:
        with open("pattern/Hysteresis/out_golden.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, golden)))
        with open("pattern/Hysteresis/i_pixel.dat", 'w') as f:
            f.write('\n'.join(map("{}".format, i_pixel)))
        
    # return type should be a 2-dimensional numpy array representing the modified gradient of the image.
    # Elements in the numpy array should be ???(True or False?).
    return np.array(img_med)


def main():
    save = True
    file = False
    global height, width
    in_fname = sys.argv[1]
    out_dir = sys.argv[2]
    if os.path.isdir(f"output/{out_dir}") is False:
        os.makedirs(f"output/{out_dir}")

    img = Image.open(in_fname)
    img = img.resize((width, height), Image.ANTIALIAS)
    img = grayscale(np.asarray(img))
    # Image.fromarray((img*8).astype(np.uint8)).show()
    if save:
        Image.fromarray((img).astype(np.uint8)).save(f"output/{out_dir}/init.jpg")


    height = height - 2
    width = width - 2

    print("=== Gaussian ===")
    img_gau = Gaussian(img, file=file)
    if save:
        Image.fromarray((img_gau).astype(np.uint8)).save(f"output/{out_dir}/gau.jpg")

    print("=== Sobel ===")
    img_grad, img_angle = Sobel(img, file=file)
    if save:
        Image.fromarray((img_grad).astype(np.uint8)).save(f"output/{out_dir}/grad.jpg")
        Image.fromarray((img_angle*64).astype(np.uint8)).save(f"output/{out_dir}/angle.jpg")

    print("=== NonMax ===")
    img_sup = NonMax(img_grad, img_angle, file=file)
    if save:
        Image.fromarray((img_sup).astype(np.uint8)).save(f"output/{out_dir}/sup.jpg")

    print("=== Hysteresis ===")
    img_final = Hysteresis(img_sup, file=file)
    Image.fromarray((img_final*255).astype(np.uint8)).save(f"output/{out_dir}/final.jpg")


def test():
    img = np.array([[1,2,3],[4,5,6],[7,8,9]])
    print(medfilt2d(img.astype(np.uint8), 3))


if __name__ == '__main__':
    start_time = time.time()
    main()
    print("--- %s seconds ---" % (time.time() - start_time))
