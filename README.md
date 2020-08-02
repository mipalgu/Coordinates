GUCoordinates
============
*Swift convenience wrappers around gucoordinates*

---

# Table Of Contents

- [Quick Start](#quick-start)
- [Coordinate Systems](#coordinate-systems)
  * [Image Coordinate Systems](#image-coordinate-systems)
    + [Camera Coordinates](#camera-coordinates)
    + [Centered Pixel Coordinates](#centered-pixel-coordinates)
    + [Percentage Coordinates](#percentage-coordinates)
  * [The Relative Coordinate System](#the-relative-coordinate-system)
  * [The Field Coordinate System](#the-field-coordinate-system)
    + [Cartesian Coordinate](#cartesian-coordinate)
    + [Field Coordinate](#field-coordinate)
- [Converting Between Coordinate Systems](#converting-between-coordinate-systems)
  * [Converting Between Image Coordinate Systems](#converting-between-image-coordinate-systems)
  * [Converting Between Image Coordinate Systems and the Relative Coordinate System](#converting-between-image-coordinate-systems-and-the-relative-coordinate-system)
    + [Converting To Relative Coordinates](#converting-to-relative-coordinates)
    + [Converting To Image Coordinates](#converting-to-image-coordinates)
      - [Clamped Conversions](#clamped-conversions)
  * [Converting Between the Relative Coordinate System and the Field Coordinate Systems](#converting-between-the-relative-coordinate-system-and-the-field-coordinate-systems)
  * [Converting From Any Coordinate System to Any Other Coordinate System](#converting-from-any-coordinate-system-to-any-other-coordinate-system)

---

# Quick Start

Let's say for this scenario we are using the cameras on the nao robot:
```swift
import GUCoordinates

let naoHead = CameraPivot(
    pitch: 0.0,
    yaw: 0.0,
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

---

# Coordinate Systems

GUCoordinates is a library containing conversion functions between several coordinate
systems. We classify the coordinates systems in general as

1. image coordinate systems,
2. the relative coordinate system, and,
3. the field coordinate system.

## Image Coordinate Systems

There are three coordinate systems used to represent images, these are

1. Camera Coordinates
2. Centered Pixel Coordinates
3. Percentage Coordinates

### Camera Coordinates
___

The camera coordinate system is the coordinate system representing images that come
directly from a camera. This is the coordinate system classicaly used in computer science
where the top left hand corner contains the (0, 0) point where the x increases to the right
and the y increases down. There are no negative values allowed. The `CameraCoordinate`
struct represents a coordinate in this coordinate system and is defined using four fields
(`x`, `y`, `resWidth`, `resHeight`) representing the x coordinate, y coordinate, width of the
image resolution and height of the image resolution respectively. The coordinate system
can be represented graphically as follows:
 ```
  (0,0)          x       resWidth
    * ---------------------->|
    |
    |
    |
  y |
    |
    |
    |
    V
   ---
 resHeight
```

### Centered Pixel Coordinates
___

Centered Pixel Coordinates is the coordinate system posted by vision.  The
`PixelCoordinate` struct represents the coordinate of a pixel within an image
in centered pixel coordinates. This coordinate system is defined using
four fields: (`x`, `y`, `resWidth`, `resHeight`) representing the x and y coordinate, the width
of the image resolution and the height of the image resolution respectively. The x and y
fields must conform to the following constraints:
    `-floor((resWidth - 1) / 2) <= x <= ceil((resWidth - 1) / 2)`,
    `-floor((resHeight - 1) / 2) <= y <= ceil((resHeight - 1) / 2)`.
This places the (0, 0) point in the center of the image. The coordinate
system can be depicted graphically as follows:
```
                           ceil((resHeight - 1) / 2)
                                      ---
                                       ^
                                       |
                                      y|
                                       |
                              -x       |        x
-floor((resWidth - 1) / 2) |<----------|---------->| ceil((resWidth - 1) / 2)
                                 (0,0)*|
                                       |
                                     -y|
                                       |
                                       V
                                      ---
                          -floor((resHeight - 1) / 2)
```
Importantly here, the (0, 0) pixel is in the 3rd quadrant. This is because
when even numbers are used for `resWidth` and `resHeight`, the (0, 0) point
would be between pixels. Below is a table detailing the bounds for common
resolutions:

           Resolution      |                    left/rightmost pixel                |               bottom/topmost pixel
     (resWidth, resHeight) | (-floor((resWidth - 1) / 2), ceil((resWidth - 1) / 2)) | (-floor((resHeight - 1) / 2), ceil(resHeight - 1) / 2)
    -----------------------+--------------------------------------------------------+--------------------------------------------------------
     (640, 480)            | (-319, 320)                                            | (-239, 240)
     (800, 600)            | (-399, 400)                                            | (-299, 300)
     (1280, 720)           | (-639, 640)                                            | (-359, 360)
     (1920, 1080)          | (-959, 960)                                            | (-539, 540)

### Percentage Coordinates
___

The percentage coordinate system is the useful for algorithms that don't require the image
resolution. The `PercentCoordinate` struct represents a point within this coordinate
system and is defined using two fields: (`x`, `y`) representing the x and y coordinates. The
(0, 0) point is in the center of the image. This would infer that the coordinate system is the
normal cartesian coordinate system, however, the x and y fields must conform to the
following constraints:
    `-1.0 <= x <= 1.0`,
    `-1.0 <= y <= 1.0`.

The coordinate system can be depicted graphically as follows:
 ```
                  1.0
                  ---
                   ^
                   |
                  y|
                   |
          -x       |(0,0)   x
  -1.0 |<----------*---------->| 1.0
                   |
                   |
                 -y|
                   |
                   V
                  ---
                 -1.0
```

## The Relative Coordinate System

The `RelativeCoordinate` struct represents a coordinate within this coordinate system.
The relative coordinate system describes the distance and direction that one coordinate
is from another. We categorise these two coordinates as the source and
the target. The target is where the `RelativeCoordinate` is pointing
towards and the source is where the `RelativeCoordinate` is pointing from.
`RelativeCoordinate` is a polar coordinate in the form of phi, r where phi
is the direction and r is the distance to the coordinate.

The direction is an angle in degrees. A positive value for direction
indicates that the target is on the left. A negative value indicates that
the target is on the right. A value of zero indicates that the target is
directly in front of source. The relative coordinate system can be depicted graphically
as follows:
```text
                                       0 degrees
                                                 * (-10 degrees, 40 cm)
                           \               |               /
                            \              |              /
                             \             |             /
                              \     ||| ///|/// |||     /
                               \|//        |        //|/
                            |// \          |          / //|
                         |//     \         |         /     //|
                       |//        \   / ///|/// /   /        //|
                     |//          |\/      |      //|          //|
                    |//        |//  \      |      /  //|        //|
                   |//       |//     \     |     /     //|       //|
                  |//      |//        \    |    /        //|      //|
                 |//      |//          \/ -|- //          //|      //|
                 //|     ,//         /- \  |  / -/         //,     |//
                `//`     |//        |-   \ | /   -|        //|     `//`
                |//      |//        -     \|/     -        //|      //|
  90 degrees    |/-      |//       |-      V      -|       //|      -/|    -90 degrees
                |//      |//        -    (0,0)    -        //|      //|
                ,//,     |//        |-           -|        //|     ,//,
                 //|     `//         /-         -/         //`     |//
                 |//      |//           / - - /           //|      //|
                  |//      |//                           //|      //|
                   |//       |//                       //|       //|
                    |//        |//                   //|        //|
                     |//          |//             //|          //|
                       |//            / /// /// /            //|
                         |//                               //|
                            |//                         //|
                                |//                 //|
                                    ||| /// /// |||


                                    +/- 180 degrees
```

## The Field Coordinate System

The field coordinate systems describe where object are in the world.
Cartesian coordinates are generally used for the coordinate system of the
soccer field. This describes the world (or more specifically the soccer field)
in terms of the location of each side of the soccer field.

If the field is viewed where the home side is in the west and the
away side is in the east, then the x axis runs north to south. The
y axis runs west to east. A negative x value indicates a position
in the northern half of the field while a positive x value indicates
a position in the southern half of the field. A negative y value
indicates a position in the western side of the field whereas a positive
y value indicates a position in the eastern side of the field. A value
of zero for both x and y indicate that the object is in the middle of
the field.

There are two structs used to describe object within this coordinate system:

1. `CartesianCoordinate`, and,
2. `FieldCoordinates`

### Cartesian Coordinate
___

This coordinate describes the position through the x and y axes. As an example, if we take
an actual full sized 100 meter field, then
the middle of the goal line on the home side of the field would be at
the coordinates (0, -50). The middle of the away goal line would be
(0, 50). The middle line which separates the two sides of a field which 
is 60 meters wide runs from the points (-30, 0) to (30, 0). 

The cartesian coordiante can be depicted graphically as follows:
 ```
                                    ^
                                    |
                                  -x|
      --------------------------------------------------------------
     |                              |                               |
     |                              |                               |
     |                             -|-          * (-90cm, 120cm)    |
     |-                           / | \                            -|
  -y | |                         |  |  |                          | | y
 <---|-|-------------------------|--+--|--------------------------|-|--->
     | |                         |  |  |                          | |
     |-                           \ | /                            -|
     |                             -|-                              |
     |                              |                               |
     |                              |                               |
      --------------------------------------------------------------
                                    |
                HOME               x|              AWAY
                                    V
```

Note that this coordinate does not handle objects that can face (or have a bearing/heading)
in a certain direction. For this requirement, use a `FieldCoordinate`.

### Field Coordinate
___

A field coordinate represents an object on the soccer field that not only has a position,
but also has a direction which the object is facing.  A `FieldCoordinate` is defined using
two fields (`position`, `heading`) representing the position on the field (a
`CartesianCoordinate`) and the direction (degrees) which the object is facing.

The direction runs counter clockwise where 0 degrees
faces directly south; therefore, 90 degrees points
directly east, 180 degrees points directly north and 270 degrees points
directly west.

A `FieldCoordinate` can be depicted graphically as follows:
```
                                   ^
                                   |
                                 -x|
     --------------------------------------------------------------
    |                              |                               |
    |                  180 degrees |                               |
    |                             -|-         *-> (-90cm, 120cm, 90 degrees)
    |-                           / | \                            -|
 -y | |                         |  |  | 90 degrees               | | y
<---|-|-------------------------|--+--|--------------------------|-|--->
    | |             270 degrees |  |  |                          | |
    |-                           \ | /                            -|
    |                             -|-                              |
    |                              | 0 degrees                     |
    |                              |                               |
     --------------------------------------------------------------
                                   |
               HOME               x|              AWAY
                                   V
```

---

# Converting Between Coordinate Systems

Several conversion functions are available which make converting between different
coordinate systems trivial. In general, it is possible to convert between all coordinate
systems in both directions:
```
    camera    --->   pixel     --->  percent    --->  relative   ---> cartesian
  coordinate       coordinate       coordinate       coordinate       coordinate
  
                                                         |                |   
                                                         |                |
                                                         |                V
                                                         |
                                                         |--------->    field
                                                         
                                                         |----------  coordinate
                                                         |
                                                         |                |
                                                         |                |
                                                         V                V
                                                                          
    camera    <---   pixel     <---  percent    <---  relative   <--- cartesian
  coordinate       coordinate       coordinate       coordinate       coordinate
```

however, there is some error that propogates since different coordinate systems have different
precisions:
```
camera coordinate != camera coordinate -> field coordinate -> camera coordinate
camera coordinate ~= camera coordinate -> field coordinate -> camera coordinate
```

## Converting Between Image Coordinate Systems

In general, converting between images is very straightforward. Any of the image coordinate
system structs (`CameraCoordinate`, `PixelCoordinate`, `PercentCoordinate`) contain
getters and functions for performing the conversions:
```swift
let cameraCoordinate = CameraCoordinate(x: 12, y: 23, resWidth: 640, resHeight: 480)
let pixelCoordinate = cameraCoordinate.pixelCoordinate
let percentCoordinate = cameraCoordinate.percentCoordinate
```

However, converting from percent coordinate requires that you provide the resolution width
and height of the image:
```swift
let percentCoordinate = PercentCoordinate(x: -0.2, y: 0.5)
let pixelCoordinate = percentCoordinate.pixelCoordinate(resWidth: 640, resHeight: 480)
let cameraCoordinate = percentCoordinate.cameraCoordinate(resWidth: 640, resHeight: 480)
```

This does however, let you represent the same position in images with different resolutions:
```swift
let cameraCoordinate = CameraCoordinate(x: 12, y: 23, resWidth: 640, resHeight: 480)
let percentCoordinate = cameraCoordinate.percentCoordinate
let newCameraCoordinate = percentCoordinate.cameraCoordinate(resWidth: 1920, resHeight: 1080)
```

## Converting Between Image Coordinate Systems and the Relative Coordinate System

Converting between the image coordinate systems and the relative coordinate system
is more complicated. Firstly information such as the height and field of view of the
camera is required to know how a pixel in an image for example translates to a distance
and direction. The `CameraPivot` and `Camera` structs are provided for this purpose.

The `CameraPivot` struct provides the necessary information regarding the pivot point
that a camera is attached to. If a camera is on the ground, then there is no pivot point.
If the camera is on the end of a stick then the pivot point is the bottom of the stick.
If the camera is on the head of the robot, then the pivot point is the neck of the robot.

The `Camera`  struct provides information on a camera which is attached to a
`CameraPivot`. The way this works, is that the `Camera` struct provides information about
the camera (such as field of view and orientation) as well as information on where the camera
is situation in relation to the `CameraPivot`. The `CameraPivot` describes where that pivot
is in relation to the wider world.

The following is an example of how the `CameraPivot` and `Camera` structs work to
describe the cameras on a Nao robot:
```swift
let naoHead = CameraPivot(
    pitch: 0.0,
    yaw: 0.0,
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

The `yaw` and `pitch` fields represent the orientation of the neck joint. The `height` is the
distance from the ground vertically to the neck. The `cameras` array contains information
about the each of the cameras: the `height` is the distance vertically from the neck to the
base of the camera, the `centerOffset` represents how far the camera is from
the center of the robot, the `vDirection` represents the vertical orientation of
the camera from the horizontal line, the `vFov` and `hFov` represent the vertical and
horizontal field of view of the camera respectively.

### Converting To Relative Coordinates
___

Converting an image coordinate to a relative coordinate may fail. This is because the
algorithm that converts from image coordinates to relative coordinates can only gauge the
distance of objects that are on the ground. If the pixel repesents on object that is not
along the ground, then the conversion will fail.
The conversion functions will always return a result, however,
if there is a situation where the conversion fails, then the resulting values will be estimated ---
the distance will be set to the largest possible value for objects in the sky for example.

In general, there are checks that can be performed before attempting the conversion which
will inform you if the conversion will fail:
```swift
// Is the image coordinate pointing to an object on the ground?
if naoHead.objectOnGround(percentCoordinate, forCamera: topCamera) {
    // We can safely convert the image coordinate.
    let relativeCoordinate = percentCoordinate.relativeCoordinate(cameraPivot: naoHead, camera: topCamera)
}
```

### Converting To Image Coordinates
___

Converting from a relative coordinate to an image coordinate may fail when the object
described by the relative coordinate is not viewable by the camera. Again, because of this,
the conversion functions will always return
a result, however, the resulting image coordinate will not be bound by the usual bounds
of the coordinate system. For example, for percentage coordinates, this means that the x
and y values may go above 1.0 and below -1.0.

Again, there are safety checks that can be performed before the conversion which allow
you to know if the camera can see the object:
```swift
let relativeCoordinate = RelativeCoordinate(direction: -160, distance: 10)
if naoHead.canSee(object: relativeCoordinate, inCamera: topCamera) {
    // The camera can see the object.
    let percentCoordinate = relativeCoordinate.percentCoordinate(cameraPivot: naoHead, camera: topCamera)
}
```

#### Clamped Conversions

In rare circumstances, particularly when the object is at the edge of the cameras view,
converting from relative to image coordinates will place the object outside the bounds of
the image. If this is unacceptable, then `clamped` variants of the conversion functions are
available. These conversion function variants will adjust the result of the
conversion so that the resulting coordinate is within the coordinate system's bounds:
```swift
let relativeCoordinate = RelativeCoordinate(direction: 30, distance: 108)
let alwaysClamped = relativeCoordinate.clampedPercentCoordinate(cameraPivot: naoHead, camera: topCamera) // Always will clamp the result to [-1.0, 1.0]
}
```

## Converting Between the Relative Coordinate System and the Field Coordinate Systems

Converting between the relative coordinate system and the field coordinate systems is
straightforward. It is possible to get the relative coordinate to specific points on the field
and calculate new positions on the field from a relative coordinate:
```swift
let fieldPosition = FieldCoordinate(position: CartesianCoordinate(x: -90, y: 120), heading: 70)
let ballPosition = CartesianCoordinate(x: -82, y: 145)
let relativeCoordinate = fieldPosition.relativeCoordinate(to: ballPosition)
let reversedBallPosition = fieldPosition.cartesianCoordinate(at: relativeCoordinate)
```

## Converting From Any Coordinate System to Any Other Coordinate System

There exist shortcut function which allow you to convert from any coordinate system to
any other coordinate system. These are composed from all the conversion functions
previously discussed:
```swift
let fieldPosition = FieldCoordinate(
        position: CartesianCoordinate(x: -90, y: 120),
        heading: 70
    )

// Calculate the field position of an object from camera coordinates.
let cameraCoordinate = CameraCoordinate(x: 12, y: 23, resWidth: 640, resHeight: 480)
let cartesianCoordinate = fieldPosition.cartesianCoordinate(
        at: cameraCoordinate,
        cameraPivot: naoHead,
        camera: bottomCamera
    )

// Calculate the camera coordinate of an object on the field.
let ballPosition = CartesianCoordinate(x: -82, y: 145)
let ballInCamera = fieldPosition.clampedCameraCoordinate(
        to: ballPosition,
        cameraPivot: naoHead,
        camera: bottomCamera,
        resWidth: 640,
        resHeight: 480,
        tolerance: 0.04
    )
```

