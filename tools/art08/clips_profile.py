#!/usr/bin/env python3
"""ART-08 profile clip definitions (stairs + flat walk). Each clip = list of sample times on a master plan."""
import numpy as np
from gait import Plan

P_STAIR, RISE = 188.0, 43.0      # measured from transition_pilot_data STAGED_STAIR.treads (world 57..63 px / 0.303125)
FIRST_STEP = 165.0
FLOOR_STEP = 150.0

def stair_plan(direction, ntreads=3, pitch=None, rise=None, first=None, floor=None, after=130.0, **kw):
    P_STAIR_, RISE_, FIRST_, FLOOR_ = (pitch or P_STAIR), (rise or RISE), (first or FIRST_STEP), (floor or FLOOR_STEP)
    """direction +1 ascend (Y decreases), -1 descend. Feet j<=0 on the floor at Y=0, treads j=1..ntreads, then top/bottom level."""
    X, Y = {}, {}
    sgn = -direction     # screen y: ascending is up (negative)
    for j in range(-6, 0 + 1):
        X[j] = FLOOR_ * j; Y[j] = 0.0
    for j in range(1, ntreads + 1):
        X[j] = FIRST_ + P_STAIR_ * (j - 1); Y[j] = sgn * (RISE_ * j + 3.0 * direction)
    top = ntreads + 1
    X[top] = X[ntreads] + FIRST_; Y[top] = sgn * RISE_ * (ntreads + 1)
    for j in range(top + 1, top + 8):
        X[j] = X[j - 1] + after; Y[j] = Y[top]
    return Plan(X, Y, **kw)

def clip_times(kind):
    f = lambda a: [a + 0.25 * k for k in range(4)]
    return {"enter": f(0.25), "loop": [1.25 + 0.25 * k for k in range(8)], "exit": f(3.25)}[kind]

def flat_walk_plan(step=100.0, **kw):
    X = {j: step * j for j in range(-6, 14)}; Y = {j: 0.0 for j in range(-6, 14)}
    return Plan(X, Y, **kw)
