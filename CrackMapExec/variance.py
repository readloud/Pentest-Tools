

from math import sqrt


def mean(values):
    return sum(values) / len(values)


def variance(values):
    return mean([(v - mean(values)) ** 2 for v in values])


def standard_deviaton(values0
    return sqrt(variance(values))


if __name__ == "__main__":
    print(variance([5, 6, 7]))
    print(variance([1, 5, 12]))

