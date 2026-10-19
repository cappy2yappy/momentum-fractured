#!/usr/bin/env python3
"""ART-08 profile clip definitions (stairs + flat walk). Each clip = list of sample times on a master plan."""
import numpy as np
from gait import Plan

P_STAIR, RISE = 188.0, 43.0      # measured from transition_pilot_data STAGED_STAIR.treads (world 57..63 px / 0.303125)
FIRST_STEP = 165.0
FLOOR_STEP = 150.0

def stair_plan(direction, ntreads=3, **kw):
    """direction +1 ascend (Y decreases), -1 descend. Feet j<=0 on the floor at Y=0, treads j=1..ntreads, then top/bottom level."""
    X, Y = {}, {}
    sgn = -direction     # screen y: ascending is up (negative)
    for j in range(-6, 0 + 1):
        X[j] = FLOOR_STEP * j; Y[j] = 0.0
    for j in range(1, ntreads + 1):
        X[j] = FIRST_STEP + P_STAIR * (j - 1); Y[j] = sgn * (RISE * j + 3.0 * direction)
    top = ntreads + 1
    X[top] = X[ntreads] + FIRST_STEP; Y[top] = sgn * RISE * (ntreads + 1)
    for j in range(top + 1, top + 8):
        X[j] = X[j - 1] + 130.0; Y[j] = Y[top]
    return Plan(X, Y, **kw)

def clip_times(kind):
    f = lambda a: [a + 0.25 * k for k in range(4)]
    return {"enter": f(0.25), "loop": [1.25 + 0.25 * k for k in range(8)], "exit": f(3.25)}[kind]

def flat_walk_plan(step=100.0, **kw):
    X = {j: step * j for j in range(-6, 14)}; Y = {j: 0.0 for j in range(-6, 14)}
    return Plan(X, Y, **kw)
