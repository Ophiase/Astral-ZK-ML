import numpy as np

UPPER_BOUND_FELT252 = 3618502788666131213697322783095070105623107215331596699973092056135872020481
UPPER_BOUND__I128 = (2**127) - 1 # included

# wfloat for wsad as felt252
def wfloat_to_float(x) -> float :
    return float(
        (x - UPPER_BOUND_FELT252) if x > UPPER_BOUND__I128 \
        else x
    ) * 1e-6

# wfloat for wsad as felt252
def wfloat(x : float) :
    as_wsad = int(x*1e6)
    return (
        as_wsad + UPPER_BOUND_FELT252 if as_wsad < 0 \
        else as_wsad
    )

def to_hex(x: int) -> str:
    return f"0x{x:0x}"

def from_hex(x : str) -> int:
    return int(x, 16)

def matrix_to_wfloat(matrix) :
    x = "array!["
    for line in matrix :
        x += "array!["
        for e in line :
            x += f"{wfloat(e)}, "
        x = x[:-1] + "].span(), "
    return x[:-1] + "].span()"

def matrix_as_felt_string(matrix) -> str :
    result = f"{len(matrix)}, "
    for x in matrix[:-1]:
        result += f"{vector_as_felt_string(x)}, "
    return result + vector_as_felt_string(matrix[-1])

def vector_as_felt_string(vector) -> str :
    result = f"{len(vector)}, "
    for x in vector[:-1] :
        result += f"{wfloat(x)}, "
    return result + f"{wfloat(vector[-1])}"