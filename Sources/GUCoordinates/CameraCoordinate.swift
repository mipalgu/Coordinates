/*
 * CameraCoordinate.swift 
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

/// A `CameraCoordinate` represents a coordinate of a pixel within an image
/// where the (0, 0) coordinate is in the top left hand corner of the image.
/// The x increases to the right, and the y coordinate increases down. A
/// `CameraCoordinate` is defined using 4 fields: (x, y, resWidth, resHeight)
/// depicted graphically as follows:
/// ```
///   (0,0)          x       resWidth
///     * ---------------------->|
///     |
///     |
///     |
///   y |
///     |
///     |
///     |
///     V
///    ---
/// resHeight
/// ```
///
/// The x and y fields must conform to the following constraints:
///     `0 <= x < resWidth`, `0 <= y < resHeight`.
public struct CameraCoordinate: CTypeWrapper {

// MARK: Properties
    
    /// The x coordinate of the pixel within the image.
    ///
    /// - Attention: The x coordinate must be in the range of:
    ///     `0 <= x < resWidth`
    public var x: pixels_u

    /// The y coordinate of the pixel within the image.
    ///
    /// - Attention: The y coordinate must be in the range of:
    ///     `0 <= y <= `resHeight`
    public var y: pixels_u

    /// The width of the resolution of the image. For example: 1920.
    public var resWidth: pixels_u

    /// The height of the resolution of the image. For example: 1080.
    public var resHeight: pixels_u

// MARK: Converting to/from the Underlying C Type

    /// Represent this coordinate using the underlying C type
    /// `gu_camera_coordinate`.
    public var rawValue: gu_camera_coordinate {
        return gu_camera_coordinate(x: self.x, y: self.y, res_width: self.resWidth, res_height: self.resHeight)
    }
    
    /// Create a new `CameraCoordinate` by copying the values from the
    /// underlying c type `gu_camera_coordinate`.
    ///
    /// - Parameter other: An instance of `gu_camera_coordinate` which contains
    /// the values that will be copied.
    public init(_ other: gu_camera_coordinate) {
        self.x = other.x
        self.y = other.y
        self.resWidth = other.res_width
        self.resHeight = other.res_height
    }

    /// Create a new `CameraCoordinate`.
    ///
    /// - Parameter x: The x coordinate of the pixel within the image.
    ///
    /// - Parameter y: The y coordinate of the pixel within the image.
    ///
    /// - Parameter resWidth: The width of the resolution of the image.
    ///
    /// - Parameter resHeight: The height of the resolution of the image.
    public init(x: pixels_u = 0, y: pixels_u = 0, resWidth: pixels_u = 0, resHeight: pixels_u = 0) {
        self.x = x
        self.y = y
        self.resWidth = resWidth
        self.resHeight = resHeight
    }
    
// MARK: Converting To Other Image Coordinates
    
    /// Convert this coordinate to a `PixelCoordinate`.
    ///
    /// This creates a new `PixelCoordinate` which represents this coordinate
    /// in centered pixel coordinates.
    ///
    /// - SeeAlso: `PixelCoordinate`.
    public var pixelCoordinate: PixelCoordinate {
        return PixelCoordinate(cam_coord_to_px_coord(self.rawValue));
    }

    /// Convert this coordinate to a `PercentCoordinate`.
    ///
    /// This creates a new `PercentCoordinate` which represents this coordinate
    /// in centered percentage coordinates.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    public var percentCoordinate: PercentCoordinate {
        return self.pixelCoordinate.percentCoordinate
    }
    
// MARK: Converting To Relative Coordinates

    /// Convert this coordinate to a `RelativeCoordinate`.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `self`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Returns: When successful, this function returns the
    /// `RelativeCoordinate` representing the object in the image at the pixel
    /// `self`. If unable to calculate the `RelativeCoordinate` then this
    /// function returns `nil`.
    ///
    /// - SeeAlso: `CameraPivot`.
    /// - SeeAlso: `Camera`.
    public func relativeCoordinate(cameraPivot: CameraPivot, camera: Int) -> RelativeCoordinate? {
        return self.percentCoordinate.relativeCoordinate(cameraPivot: cameraPivot, camera: camera)
    }
    
    /// Convert this coordinate to a `RelativeCoordinate`.
    ///
    /// - Parameter cameraPivot: The `CameraPivot` detailing the configuration
    /// of the pivot point in which the camera is placed, as well as detailing
    /// the cameras attached to the pivot point.
    ///
    /// - Parameter camera: The index of the camera which recorded the image
    /// containing the pixel represented by `self`. This index should reference
    /// a valid `Camera` within the `cameras` array within
    /// `cameraPivot.cameras`.
    ///
    /// - Returns: The `RelativeCoordinate` representing the object in the image
    /// at the pixel `self`. If the pixel represents an object that is not on
    /// the ground then a maximum value for the distance is used.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `self` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `CameraPivot`.
    /// - SeeAlso: `Camera`.
    public func unsafeRelativeCoordinate(cameraPivot: CameraPivot, camera: Int) -> RelativeCoordinate {
        return self.percentCoordinate.unsafeRelativeCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

}

extension CameraCoordinate: Equatable, Hashable, Codable {}
