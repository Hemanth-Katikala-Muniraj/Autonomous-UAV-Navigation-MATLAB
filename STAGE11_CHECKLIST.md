# Stage 11 Publishing Checklist

## Repository

- [ ] Rename project folder clearly
- [ ] Add `README.md`
- [ ] Add `LICENSE`
- [ ] Add `.gitignore`
- [ ] Add architecture and test documents
- [ ] Remove duplicate checkpoint folders from the repository
- [ ] Remove personal absolute paths from committed code
- [ ] Confirm `main.m` runs from the repository root
- [ ] Run `scripts/validateProject.m`

## Evidence

- [ ] Add final dashboard screenshot
- [ ] Add one bird-avoidance screenshot
- [ ] Add one landing screenshot
- [ ] Add four generated performance plots
- [ ] Add a short MP4 or GIF preview
- [ ] Add final mission metrics to README

## GitHub

```bash
git init
git add .
git commit -m "Initial autonomous UAV MATLAB project"
git branch -M main
git remote add origin <YOUR_REPOSITORY_URL>
git push -u origin main
```

## Recommended Repository Name

```text
Autonomous-UAV-Navigation-MATLAB
```

## Recommended GitHub Description

```text
MATLAB autonomous UAV simulation with LiDAR, APF obstacle avoidance, occupancy mapping, dynamic bird avoidance, wind compensation, FPV visualization, refined landing, telemetry logging, and MP4 recording.
```

## Portfolio Title

```text
Autonomous UAV Navigation and Dynamic Obstacle Avoidance in MATLAB
```
