#!/bin/env python3

from matplotlib import pyplot as plt

def process_data(fname):
    d = []
    with open(fname, 'r') as f:
        a = f.read().split('\n')
        a = [i.strip() for i in a if i.strip() != ""]
        a = [int(i, 16) for i in a]
        for i in a:
            d.append(i >> 16)
            d.append(i & 0xFFFF)
    return d
if __name__ == "__main__":
    import sys
    d = process_data(sys.argv[1])
    plt.plot(d)
    plt.show()
