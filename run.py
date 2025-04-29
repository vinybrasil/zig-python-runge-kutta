import numpy as np

import ctypes

import time
from numba import jit


class SolverClass:
    def __init__(self):
        self.ziglibrary = ctypes.CDLL(
            "zigcode/libmain.so"
        )

    def calcular(self, h, xrange_0, xrange_1, yinit_0):
        self.ziglibrary.main.argtypes = [
            ctypes.c_longdouble,
            ctypes.c_longdouble,
            ctypes.c_longdouble,
            ctypes.c_longdouble,
        ]

        self.ziglibrary.main.restype = ctypes.POINTER(ctypes.c_longdouble)

        return self.ziglibrary.main(h, xrange_0, xrange_1, yinit_0)

@jit(nopython=True)
def RK4Ordem(yinit, xrange_0, xrange_1, h):
    n = int((xrange_1 - xrange_0) / h)

    xsol = np.zeros(n + 1)
    ysol = np.zeros(n + 1)
    ysol[0] = yinit
    xsol[0] = xrange_0

    x = xsol[0]
    y = ysol[0]

    for i in range(1, n + 1):
        k1 = h * evaluate(x, y)
        k2 = h * evaluate(x + h / 2, y + k1 * (h / 2))
        k3 = h * evaluate(x + h / 2, y + k2 * (1 / 2))
        k4 = h * evaluate(x + h, y + k3)

        y = y + (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4)
        x = x + h

        xsol[i] = x
        ysol[i] = y

    return [xsol, ysol]


@jit(nopython=True)
def evaluate(x, y):
    return 4 * x - 2 * x * y


h = 0.000_001 #max: 0.000_000_1
xrange_0, xrange_1 = (0.0, 2.0)
yinit = 1.0
n = int((xrange_1 - xrange_0) / h)

print(f"number of points: {n}")

## normal execution
start_time = time.time()
[ts, ys] = RK4Ordem(yinit, xrange_0, xrange_1, h)
print(f"jit: {time.time() - start_time}")

## zig execution
start_time = time.time()
classe = SolverClass()
result = classe.calcular(h=h, xrange_0=xrange_0, xrange_1=xrange_1, yinit_0=yinit)
result_a = [result[i] for i in range(n + 1)]
classe.ziglibrary.free_results(result, n + 1)
print(f"zig: {time.time() - start_time}")
