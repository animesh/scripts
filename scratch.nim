import nimpy
proc fib(n: int): int {.exportpy.} =
    if n == 0:
        return 0
    elif n < 3:
        return 1
    return fib(n-1) + fib(n-2)
