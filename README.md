# GUCoordinates

*Swift convenience wrappers around gucoordinates*

## Quick Start

Let's say for this scenario we are using the cameras on the nao robot:
```swift
import GUCoordinates

let naoHead = CameraPivot(
    yaw: 0.0,
    pitch: 0.0,
    height: 41.7,
    cameras: [
        // Top Camera
        Camera(
            height: 6.364,
            centerOffset: 5.871,
            vDirection: 1.2,
            vFov: 47.64,
            hFov: 60.97
        ),
        // Bottom Camera
        Camera(
            height: 1.774,
            centerOffset: 5.071,
            vDirection: 39.7,
            vFov: 47.64,
            hFov: 60.97
        )
    ]
)
// Camera indexes
let topCamera = 0
let bottomCamera = 1
```

And vision recognises a ball at a specific pixel in the camera:
```swift
let cameraPixel = CameraCoordinate(x: 909, y: 866, resWidth: 1920, resHeight: 1080)
```

Vision posts the sighting in centered pixel coordinates:
```swift
let ballPixel = cameraPixel.pixelCoordinate // PixelCoordinate(x: -50, y: -326, resWidth: 1920, resHeight: 1080)
```

Then where is the ball in relation to the robot?
```swift
guard let ballRelativeFromRobot = ballPixel.relativeCoordinate(cameraPivot: naoHead, camera: bottomCamera) else {
    fatalError("Pixel is in the sky.")
}
ballRelativeFromRobot // RelativeCoordinate(direction: 2, distance: 26)
```

Let's say that our robot is at a specific position on the field:
```swift
let fieldPosition = FieldCoordinate(position: CartesianCoordinate(x: -90, y: 120), heading: 70)
```

What if we want the field position of the ball?
```swift
let ballPosition = fieldPosition.cartesianCoordinate(at: ballRelativeFromRobot) // CartesianCoordinate(x: -82, y: 145)
```

Why don't we get that without converting to a relative coordinate first:
```swift
guard let easyBallPosition = fieldPosition.cartesianCoordinate(at: ballPixel, cameraPivot: naoHead, camera: bottomCamera) else {
    fatalError("Pixel is in the sky.")
}
easyBallPosition // CartesianCoordinate(x: -82, y: 145)
```

Let's say that we have a goal on the field at a specific position:
```swift
let goalPosition = CartesianCoordinate(x: 0, y: 450)
```

So where is the goal in relation to the ball? Or rather, in what direction
and how far do we have to kick the ball to score a goal?
```swift
let goalRelativeFromBall = ballPosition.relativeCoordinate(to: goalPosition) // RelativeCoordinate(direction: 75, distance: 316)
```

Or maybe we want to pass to a team mate:
```swift
let teamMate = FieldCoordinate(position: CartesianCoordinate(x: 60, y: 210), heading: 100)
let teamMateRelativeFromBall = ballPosition.relativeCoordinate(to: teamMate) // RelativeCoordinate(direction: 25, distance: 156)
```

Let's assume that we read the goal relative location from kalman:
```swift
let goalRelativeFromRobot = fieldPosition.relativeCoordinate(to: goalPosition) // RelativeCoordinate(direction: 5, distance: 342)
```

What if we don't actually know where we are on the field, but can see
the ball and the goal from kalman? Let's calculate the relative angle from the
ball to the goal:
```swift
let goalRelativeFromRelativeBall = ballRelativeFromRobot.relativeCoordinate(to: goalRelativeFromRobot) // RelativeCoordinate(direction: 5, distance: 316)
```
