def square(num):
    if num >= 2 ** 16:
        return 2 ** 8
    # elif num >= 2 ** 15:
    #     return 2 ** 7 + 2 ** 6
    elif num >= 2 ** 14:
        return 2 ** 7
    # elif num >= 2 ** 13:
    #     return 2 ** 6 + 2 ** 5
    elif num >= 2 ** 12:
        return 2 ** 6
    # elif num >= 2 ** 11:
    #     return 2 ** 5 + 2 ** 4
    elif num >= 2 ** 10:
        return 2 ** 5
    elif num >= 2 ** 8:
        return 2 ** 4
    elif num >= 100:
        return 10
    elif num >= 81:
        return 9
    elif num >= 64:
        return 8
    elif num >= 49:
        return 7
    elif num >= 36:
        return 6
    elif num >= 25:
        return 5
    elif num >= 16:
        return 4
    elif num >= 9:
        return 3
    elif num >= 4:
        return 2
    else:
        return 1