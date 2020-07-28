/*
 * CartesianCoordinate.swift 
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


/// A cartesian_coordinate is a general coordinate for representing positions
/// on a tow dimensional plane.
///
/// This coordinate describes the position through the x and y axes. The
/// `CartesianCoordinate` is generally used for the coordinate system of the
/// soccer field. This describes the world (or more specifically the field)
/// in terms of the location of each side of the soccer field. The home side
/// is in the west, whereas the away side is in the east. Because of this, it
/// may not be a good idea to repurpose this coordinate for use in other
/// applications since the x and y coordinates of this coordinate must be in
/// centimetres.
///
/// The field coordinate system can be depicted graphically as follows:
/// ```
///                                    ^
///                                    |
///                                  -x|
///      --------------------------------------------------------------
///     |                              |                               |
///     |                  180 degrees |                               |
///     |                             -|-          * (-90cm, 120cm)    |
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
public struct CartesianCoordinate: CTypeWrapper {

// MARK: Properties
    
    /// The x coordinate of the position in centimetres.
    public var x: Centimetres_t
    
    /// The y coordinate of the position in centimetres.
    public var y: Centimetres_t

// MARK: Converting to/from the Underlying C Type
    
    /// Represent this coordinate using the underlying C type
    /// `gu_cartesian_coordinate`.
    public var rawValue: gu_cartesian_coordinate {
        return gu_cartesian_coordinate(x: self.x.rawValue, y: self.y.rawValue)
    }
    
    /// Create a new `CartesianCoordinate` by copying the values from the
    /// underlying c type `gu_cartesian_coordinate`.
    ///
    /// - Parameter other: An instance of `gu_cartesian_coordinate` which
    /// contains the values that will be copied.
    public init(_ other: gu_cartesian_coordinate) {
        self.init(
            x: Centimetres_t(rawValue: other.x),
            y: Centimetres_t(rawValue: other.y)
        )
    }
    
// MARK: Creating a CartesianCoordinate

    /// Create a new `CartesianCoordinate`.
    ///
    /// - Parameter x: The x coordinate of the position within the field.
    ///
    /// - Parameter y: The y coordinate of the position within the field.
    public init(x: Centimetres_t = 0, y: Centimetres_t = 0) {
        self.x = x
        self.y = y
    }
    
// MARK: Calculating Coordinates Around The Field

    /// Calculate the position of a coordinate in relation to this coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// - Parameter coord: The position of the coordinate in relation to
    /// this coordinate.
    ///
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    public func cartesianCoordinate(at coord: RelativeCoordinate) -> CartesianCoordinate {
        return CartesianCoordinate(rr_coord_to_cartesian_coord_from_source(coord.rawValue, self.rawValue))
    }

    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
    }

    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
    }

    /// Calculate the position of an object in an image in relation to this
    /// coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// - Parameter coord: The point in the image representing the object.
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
    /// - Returns: A new `CartesianCoordinate` calculated in relation to this
    /// coordinate.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cartesianCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
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
    public func unsafeCartesianCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.unsafeRelativeCoordinate(cameraPivot: cameraPivot, camera: camera))
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
    public func unsafeCartesianCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.unsafeRelativeCoordinate(cameraPivot: cameraPivot, camera: camera))
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
    public func unsafeCartesianCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate {
        return cartesianCoordinate(at: coord.unsafeRelativeCoordinate(cameraPivot: cameraPivot, camera: camera))
    }
    
// MARK: Calculating Relative Coordinates to Objects on the Field
    
    /// Calculate the `RelativeCoordinate` to a target coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// - Parameter coord: The target coordinate.
    ///
    /// - Returns: A new `RelativeCoordinate` pointing towards `coord` from
    /// this coordinate.
    public func relativeCoordinate(to coord: CartesianCoordinate) -> RelativeCoordinate {
        return RelativeCoordinate(cartesian_coord_to_rr_coord_from_source(self.rawValue, coord.rawValue))
    }

    /// Calculate the `RelativeCoordinate` to a target coordinate.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// - Parameter coord: The target coordinate.
    ///
    /// - Returns: A new `RelativeCoordinate` pointing towards `coord` from
    /// this coordinate.
    public func relativeCoordinate(to coord: FieldCoordinate) -> RelativeCoordinate {
        self.relativeCoordinate(to: coord.position)
    }
    
// MARK: Safe Calculations for Calculating Image Coordinate to Objects on the Field

    /// Calculate a point in an image from a specific camera representing an
    /// object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `PercentCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func percentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate? {
        return self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    /// Calculate a point in an image from a specific camera representing an
    /// object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `PercentCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func percentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate? {
        return self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `PixelCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func pixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `PixelCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func pixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `CameraCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// - Returns: When successful, a new `CameraCoordinate` representing the
    /// object in the camera. When unsuccessful (for example when the camera
    /// cannot actually see the object) then `nil` is returned.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func cameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }
    
    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the calculated coordinate falls within the
    /// bounds of the image when the calculated coordinate is outside the image
    /// within the given tolerance. The tolerance represents a percentage of the
    /// image resolution. This tolerance is applied to each axis, therefore the
    /// x value of the coordinate will be adjusted to `resWidth - 1` if and only
    /// if `x > resWidth && x < resWidth + resWidth * tolerance`. Similarly the
    /// y value of the coordinate will be adjusted to `resHeight - 1` if and
    /// only if `y > resHeight && y < resHeight + resHeight * tolerance`.
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `CameraCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedCameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).clampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the calculated coordinate falls within the
    /// bounds of the image when the calculated coordinate is outside the image
    /// within the given tolerance. The tolerance represents a percentage of the
    /// image resolution. This tolerance is applied to each axis, therefore the
    /// x value of the coordinate will be adjusted to `resWidth - 1` if and only
    /// if `x > resWidth && x < resWidth + resWidth * tolerance`. Similarly the
    /// y value of the coordinate will be adjusted to `resHeight - 1` if and
    /// only if `y > resHeight && y < resHeight + resHeight * tolerance`.
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `CameraCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedCameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).clampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given `tolerance`.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     xmin = -floor((resWidth - 1) / 2.0)
    ///     xmax = ceil((resWidth - 1) / 2.0)
    ///     ymin = -floor((resHeight - 1) / 2.0)
    ///     ymax = ceil((resHeight - 1) / 2.0)
    ///     if x < xmin && x >= xmin - resWidth * tolerance
    ///         x = xmin
    ///     if x > xmax && x >= xmax + resWidth * tolerance
    ///         x = xmax
    ///     if y < ymin && y >= ymin - resHeight * tolerance
    ///         y = ymin
    ///     if y > ymax && y >= ymax + resHeight * tolerance
    ///         y = ymax
    /// ```
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `PixelCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).clampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given `tolerance`.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     xmin = -floor((resWidth - 1) / 2.0)
    ///     xmax = ceil((resWidth - 1) / 2.0)
    ///     ymin = -floor((resHeight - 1) / 2.0)
    ///     ymax = ceil((resHeight - 1) / 2.0)
    ///     if x < xmin && x >= xmin - resWidth * tolerance
    ///         x = xmin
    ///     if x > xmax && x >= xmax + resWidth * tolerance
    ///         x = xmax
    ///     if y < ymin && y >= ymin - resHeight * tolerance
    ///         y = ymin
    ///     if y > ymax && y >= ymax + resHeight * tolerance
    ///         y = ymax
    /// ```
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `PixelCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).clampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given `tolerance`.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     if x < -1.0 && x >= -1.0 - tolerance
    ///         x = -1.0
    ///     if x > 1.0 && x <= 1.0 + tolerance
    ///         x = 1.0
    ///     if y < -1.0 && y >= -1.0 - tolerance
    ///         y = -1.0
    ///     if y > 1.0 && y <= 1.0 + tolerance
    ///         y = 1.0
    /// ```
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `PercentCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPercentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, tolerance: Percent_f) -> PercentCoordinate? {
        self.relativeCoordinate(to: coord).clampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera, tolerance: tolerance)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// This function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given `tolerance`.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     if x < -1.0 && x >= -1.0 - tolerance
    ///         x = -1.0
    ///     if x > 1.0 && x <= 1.0 + tolerance
    ///         x = 1.0
    ///     if y < -1.0 && y >= -1.0 - tolerance
    ///         y = -1.0
    ///     if y > 1.0 && y <= 1.0 + tolerance
    ///         y = 1.0
    /// ```
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image.
    ///
    /// - Returns: When successful, a new `PercentCoordinate` representing the
    /// object in the camera. This function returns nil when the calculated
    /// coordinate falls outside the image bounds and the given `tolerance`.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func clampedPercentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, tolerance: Percent_f) -> PercentCoordinate? {
        self.relativeCoordinate(to: coord).clampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera, tolerance: tolerance)
    }
    
// MARK: Unsafe Calculations for Calculating Image Coordinate to Objects on the Field
    
    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `cameraCoordinate(to:cameraPivot:camera:resWidth:resHeight:)`
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeCameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).unsafeCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `cameraCoordinate(to:cameraPivot:camera:resWidth:resHeight:)`
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeCameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).unsafeCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `pixelCoordinate(to:cameraPivot:camera:resWidth:resHeight:)`
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafePixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).unsafePixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `pixelCoordinate(to:cameraPivot:camera:resWidth:resHeight:)`
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafePixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).unsafePixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `percentCoordinate(to:cameraPivot:camera:)`
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafePercentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).unsafePercentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
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
    /// actually see the object at `coord`. If you would like to use a version
    /// of this function that performs this bounds check then use
    /// `percentCoordinate(to:cameraPivot:camera:)`
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafePercentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).unsafePercentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }
    
    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance represents a percentage of the image resolution. This
    /// tolerance is applied to each axis, therefore the x value
    /// of the coordinate will be adjusted to `resWidth - 1` if and only if
    /// `x > resWidth && x < resWidth + resWidth * tolerance`. Similarly the y
    /// value of the coordinate will be adjusted to `resHeight - 1` if and only
    /// if `y > resHeight && y < resHeight + resHeight * tolerance`.
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When not nil,
    /// the `x` and `y` values of the calculated coordinate that fall outside
    /// the bounds of the resolution of the image, but fall within the tolerance
    /// such that `x > resWidth && x <= resWidth + resWidth * tolerance` and
    /// `y > resHeight && y < resHeight + resHeight * tolerance`, will be moved
    /// to the maximum possible value that is still within the image
    /// (`x = resWidth - 1`, `y = resHeight - 1`). When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedCameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f? = nil) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).unsafeClampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance represents a percentage of the image resolution. This
    /// tolerance is applied to each axis, therefore the x value
    /// of the coordinate will be adjusted to `resWidth - 1` if and only if
    /// `x > resWidth && x < resWidth + resWidth * tolerance`. Similarly the y
    /// value of the coordinate will be adjusted to `resHeight - 1` if and only
    /// if `y > resHeight && y < resHeight + resHeight * tolerance`.
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When not nil,
    /// the `x` and `y` values of the calculated coordinate that fall outside
    /// the bounds of the resolution of the image, but fall within the tolerance
    /// such that `x > resWidth && x <= resWidth + resWidth * tolerance` and
    /// `y > resHeight && y < resHeight + resHeight * tolerance`, will be moved
    /// to the maximum possible value that is still within the image
    /// (`x = resWidth - 1`, `y = resHeight - 1`). When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `CameraCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedCameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f? = nil) -> CameraCoordinate {
        return self.relativeCoordinate(to: coord).unsafeClampedCameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     xmin = -floor((resWidth - 1) / 2.0)
    ///     xmax = ceil((resWidth - 1) / 2.0)
    ///     ymin = -floor((resHeight - 1) / 2.0)
    ///     ymax = ceil((resHeight - 1) / 2.0)
    ///     if x < xmin && x >= xmin - resWidth * tolerance
    ///         x = xmin
    ///     if x > xmax && x >= xmax + resWidth * tolerance
    ///         x = xmax
    ///     if y < ymin && y >= ymin - resHeight * tolerance
    ///         y = ymin
    ///     if y > ymax && y >= ymax + resHeight * tolerance
    ///         y = ymax
    /// ```
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedPixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f? = nil) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).unsafeClampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a pixel within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     xmin = -floor((resWidth - 1) / 2.0)
    ///     xmax = ceil((resWidth - 1) / 2.0)
    ///     ymin = -floor((resHeight - 1) / 2.0)
    ///     ymax = ceil((resHeight - 1) / 2.0)
    ///     if x < xmin && x >= xmin - resWidth * tolerance
    ///         x = xmin
    ///     if x > xmax && x <= xmax + resWidth * tolerance
    ///         x = xmax
    ///     if y < ymin && y >= ymin - resHeight * tolerance
    ///         y = ymin
    ///     if y > ymax && y <= ymax + resHeight * tolerance
    ///         y = ymax
    /// ```
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `PixelCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedPixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: Pixels_u, resHeight: Pixels_u, tolerance: Percent_f? = nil) -> PixelCoordinate {
        return self.relativeCoordinate(to: coord).unsafeClampedPixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight, tolerance: tolerance)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     if x < -1.0 && x >= -1.0 - tolerance
    ///         x = -1.0
    ///     if x > 1.0 && x <= 1.0 + tolerance
    ///         x = 1.0
    ///     if y < -1.0 && y >= -1.0 - tolerance
    ///         y = -1.0
    ///     if y > 1.0 && y <= 1.0 + tolerance
    ///         y = 1.0
    /// ```
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedPercentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, tolerance: Percent_f? = nil) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).unsafeClampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera, tolerance: tolerance)
    }

    /// Calculate a point within a specific image from a specific camera
    /// representing an object at a given position.
    ///
    /// Since a `CartesianCoordinate` does not contain a heading, we assume
    /// here that we are facing at zero degrees.
    ///
    /// When `tolerance` is not nil then this function ensures that the
    /// calculated coordinate falls within the bounds of the image when the
    /// calculated coordinate is outside the image within the given tolerance.
    /// The tolerance is represented as a percentage of the image resolution
    /// and is applied to each axis. The coordinate will be
    /// adjusted under the following conditions:
    /// ```
    ///     if x < -1.0 && x >= -1.0 - tolerance
    ///         x = -1.0
    ///     if x > 1.0 && x <= 1.0 + tolerance
    ///         x = 1.0
    ///     if y < -1.0 && y >= -1.0 - tolerance
    ///         y = -1.0
    ///     if y > 1.0 && y <= 1.0 + tolerance
    ///         y = 1.0
    /// ```
    ///
    /// If the `tolerance` is nil then all calculated pixels that fall outside
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
    /// - Parameter tolerance: A percentage of the resolution indicating an
    /// area outside the image which, if the coordinate falls within, ajusts the
    /// coordinate so that it is within the image. When the tolerance is nil
    /// then all calculated coordinates that fall outside the image resolution
    /// bounds will be adjusted so that they are within the image.
    ///
    /// - Returns: A new `PercentCoordinate` representing the object in the
    /// camera.
    ///
    /// - Warning: When tolerance is not nil, and the coordinate falls outside
    /// the specified tolerance, then the coordinate returned from this function
    /// will be outside the image resolution bounds.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    /// - SeeAlso: `CameraPivot`.
    public func unsafeClampedPercentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, tolerance: Percent_f? = nil) -> PercentCoordinate {
        self.relativeCoordinate(to: coord).unsafeClampedPercentCoordinate(cameraPivot: cameraPivot, camera: camera, tolerance: tolerance)
    }

}

extension CartesianCoordinate: Equatable, Hashable, Codable {}
