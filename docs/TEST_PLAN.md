# Test Plan

## Objective

Verify that the autonomous UAV completes its mission safely and produces all expected outputs.

## Acceptance Criteria

| Test | Pass Condition |
|---|---|
| Project initialization | No missing-function or missing-field errors |
| Takeoff | Drone reaches commanded takeoff altitude |
| Waypoint navigation | All waypoints are reached in order |
| Bird avoidance | APF activates when the bird is detected |
| Dynamic clearance | Minimum surface clearance remains positive |
| Wind compensation | Mission remains stable under enabled wind |
| Occupancy mapping | Coverage exceeds 80% |
| FPV orientation | Bird left/right motion matches the 3D world |
| Landing alignment | Final heading is approximately 0° |
| Touchdown | Vertical speed is below configured threshold |
| Ground lock | Position and velocity remain zero after touchdown |
| Logging | CSV and MAT files are created |
| Recording | MP4 file is created and playable |
| Reporting | PNG performance plots are generated |

## Recommended Regression Runs

### Baseline

```matlab
config.wind.enabled = false;
config.bird.enabled = false;
```

Expected: shortest route and no APF activity.

### Bird Only

```matlab
config.wind.enabled = false;
config.bird.enabled = true;
```

Expected: visible avoidance deviation and positive bird clearance.

### Wind Only

```matlab
config.wind.enabled = true;
config.bird.enabled = false;
```

Expected: route recovery with moderate lateral deviation.

### Full Mission

```matlab
config.wind.enabled = true;
config.bird.enabled = true;
```

Expected: successful mission, mapping, recording, and refined landing.

### Compensation Comparison

Run once with:

```matlab
config.wind.compensationEnabled = true;
```

and once with:

```matlab
config.wind.compensationEnabled = false;
```

Compare average and maximum lateral deviation.

## Evidence to Save

- Final dashboard screenshot
- MP4 recording
- Mission summary CSV
- Bird-clearance plot
- Speed-and-wind plot
- Occupancy-map result
- Command Window mission summary
