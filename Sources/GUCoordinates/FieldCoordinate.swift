/*
 * FieldCoordinate.swift 
 * Coordinates 
 *
 * Created by Callum McColl on 09/07/2020.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import CGUCoordinates
import GUUnits


/// A field_coordinate is a coordinate for an object that faces a certain
/// direction (such as a robot) on the field.
///
/// The coordinate describes the location of the object on the field
/// (with position) as well as the direction that the object is facing
/// (with heading).
///
/// The field coordinate system can be depicted graphically as follows:
/// ```
///                                    ^
///                                    |
///                                  -x|
///      --------------------------------------------------------------
///     |                              |                               |
///     |                  180 degrees |                               |
///     |                             -|-         *-> (-90cm, 120cm, 90 degrees)
///     |-                           / | \                            -|
///  -y | |                         |  |  | 90 degrees               | | y
/// <---|-|-------------------------|--+--|--------------------------|-|--->
///     | |             270 degrees |  |  |                          | |
///     |-                           \ | /                            -|
///     |                             -|-                              |
///     |                              | 0 degrees                     |
///     |                              |                               |
///      --------------------------------------------------------------
///                                    |
///                HOME               x|              AWAY
///                                    V
/// ```
///
/// When describing objects that face in certain directions it is important
/// to disregard this coordinate and instead use `FieldCoordinate`.
public struct FieldCoordinate: CTypeWrapper {

// MARK: Properties
    
    /// The position of the object on the field.
    ///
    /// If the field is viewed where the home side is in the west and the
    /// away side is in the east, then the x asix runs north to south. The
    /// y axis runs west to east. A negative x value indicates a position
    /// in the northern half of the field while a positive x value indicates
    /// a position in the southern half of the field. A negative y value
    /// indicates a position in the western side of the field whereas a positive
    /// y value indicates a position in the eastern side of the field. A value
    /// of zero for both x and y indicate that the object is in the middle of
    /// the field.
    ///
    /// As an example, if we take an actual full sized 100 meter field, then
    /// the middle of the goal line on the home side of the field would be at
    /// the coordinates (0, -50). The middle of the away goal line would be
    /// (0, 50). The middle line which separates the two sides of a field which
    /// is 60 meters wide runs from the points (-30, 0) to (30, 0).
    public var position: CartesianCoordinate

    /// The direction where the object is facing.
    ///
    /// If the field is viewed where the home side is in the west and the away
    /// side is in the ast, then the direction runs counter clockwise where the
    /// zero direction faces directly south. Therefore, 90 degrees points
    /// directly east, 180 degrees points directly north and 270 degrees points
    /// directly west.
    public var heading: Angle

// MARK: Converting to/from the Underlying C Type
    
    /// Represent this coordinate using the underlying C type
    /// `gu_field_coordinate`.
    public var rawValue: gu_field_coordinate {
        return gu_field_coordinate(
            position: self.position.rawValue,
            heading: self.heading.degrees_t.rawValue
        )
    }
    
    /// Create a new `FieldCoordinate` by copying the values from the
    /// underlying c type `gu_field_coordinate`.
    ///
    /// - Parameter other: An instance of `gu_field_coordinate` which
    /// contains the values that will be copied.
    public init(_ other: gu_field_coordinate) {
        self.init(
            position: CartesianCoordinate(other.position),
            heading: Angle(Degrees_t(rawValue: other.heading))
        )
    }
    
// MARK: Creating a FieldCoordinate

    /// Create a new `FieldCoordinate`.
    ///
    /// - Parameter position: The position within the field.
    ///
    /// - Parameter heading: The direction that this coordinate is facing
    public init(position: CartesianCoordinate = CartesianCoordinate(), heading: Angle = .zero) {
        self.position = position
        self.heading = heading
    }
    
// MARK: Checking Visibility of Object Around The Field
    
    /// Can the camera see the object?
    ///
    /// - Parameter coord: The location of the object on the field.
    ///
    /// - Parameter cameraPivot: The camera pivot which the camera is attached
    /// to.
    ///
    /// - Parameter camera: The camera index for the camera in the camera
    /// pivots `cameras` array.
    ///
    /// - Returns: True if the specified camera can see the object, False
    /// otherwise.
    public func canSee(objectAt coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> Bool {
        return cameraPivot.canSee(object: self.relativeCoordinate(to: coord), inCamera: camera)
    }
    
    /// Can the camera see the object?
    ///
    /// - Parameter coord: The location of the object on the field.
    ///
    /// - Parameter cameraPivot: The camera pivot which the camera is attached
    /// to.
    ///
    /// - Parameter camera: The camera index for the camera in the camera
    /// pivots `cameras` array.
    ///
    /// - Returns: True if the specified camera can see the object, False
    /// otherwise.
    public func canSee(objectAt coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> Bool {
        return cameraPivot.canSee(object: self.relativeCoordinate(to: coord), inCamera: camera)
    }
    
// MARK: Calculating Coordinates Around The Field

    /// Calculate the position of a coordinate in relation to this coordinate.
    ///
    /// - Parameter coord: The position of the coordinate in relation to
    /// this coordinate.
    ///
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    public func cartesianCoordinate(at coord: RelativeCoordinate) -> CartesianCoordinate {
        return CartesianCoordinate(rr_coord_to_cartesian_coord_from_field(coord.rawValue, self.rawValue))
    }

    /// Calculate the position of a coordinate in relation to this coordinate.
    ///
    /// - Parameter coord: The position of the coordinate in relation to
    /// this coordinate.
    ///
    /// - Parameter heading: The direction in which the new coordinate
    /// is facing.
    ///
    /// - Returns: A new `FieldCoordinate` calculated in relation to this
    /// coordinate.
    public func fieldCoordinate(at coord: RelativeCoordinate, heading: Degrees_t) -> FieldCoordinate {
        return FieldCoordinate(rr_coord_to_field_coord_from_source(coord.rawValue, self.rawValue, heading.rawValue))
    }

    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot pixel in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the point represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera))
    }
    
    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot pixel in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the point represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera))
    }
    
    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The point in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the point represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the point in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera))
    }
    
    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter heading: The direction in which the new coordinate
    /// is facing.
    ///
    /// - Returns: A new `FieldCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func fieldCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int, heading: Degrees_t) -> FieldCoordinate {
        return fieldCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera), heading: heading)
    }
    
    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter heading: The direction in which the new coordinate
    /// is facing.
    ///
    /// - Returns: A new `FieldCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func fieldCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int, heading: Degrees_t) -> FieldCoordinate {
        return fieldCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera), heading: heading)
    }
    
    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// - Parameter coord: The point in the image representing the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the point represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter heading: The direction in which the new coordinate
    /// is facing.
    ///
    /// - Returns: A new `FieldCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - Warning: Only use this function if you are positive that the point in
    /// the image represented by `coord` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func fieldCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int, heading: Degrees_t) -> FieldCoordinate {
        return fieldCoordinate(at: coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera), heading: heading)
    }

// MARK: Calculating Relative Coordinates to Objects on the Field
    
    /// Calculate the `RelativeCoordinate` to a target coordinate.
    ///
    /// - Parameter coord: The target coordinate.
    ///
    /// - Returns: A new `RelativeCoordinate` pointing towards `coord` from
    /// this coordinate.
    public func relativeCoordinate(to coord: CartesianCoordinate) -> RelativeCoordinate {
        return RelativeCoordinate(field_coord_to_rr_coord_to_target(self.rawValue, coord.rawValue))
    }

    /// Calculate the `RelativeCoordinate` to a target coordinate.
    ///
    /// - Parameter coord: The target coordinate.
    ///
    /// - Returns: A new `RelativeCoordinate` pointing towards `coord` from
    /// this coordinate.
    public func relativeCoordinate(to coord: FieldCoordinate) -> RelativeCoordinate {
        return self.relativeCoordinate(to: coord.position)
    }

// MARK: Calculating Image Coordinate to Objects on the Field
    
    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func pixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func pixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func percentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: This function does not check whether the calculated coordinate
    /// is within the bounds of the `resWidth` and `resHeight`. As such you
    /// should only use this function if you are positive that the camera can
    /// actually see the object at `coord`.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func percentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }
    
    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedCameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).clampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedCameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).clampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).clampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).clampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPercentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).clampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// All calculated pixels that fall outside
    /// the bounds of the image are moved to the edge of the image to ensure
    /// that the function always calculates a coordinate within the image
    /// bounds.
    ///
    /// - Parameter coord: The position of the object.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `coord`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that
    /// we are placing the object in.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPercentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).clampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

}

extension FieldCoordinate: Equatable, Hashable, Codable {}
