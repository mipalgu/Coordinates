/*
 * PixelCoordinate.swift 
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

/// A `PixelCoordinate` represents the coordinate of a pixel within an image
/// in centered pixel coordinates. This coordinate system is defined using
/// 4 fields: (x, y, resWidth, resHeight). The x and y fields must conform to
/// the following constraint:
///     `-floor((resWidth - 1) / 2) <= x <= ceil((resWidth - 1) / 2)`,
///     `-floor((resHeight - 1) / 2) <= y <= ceil((resHeight - 1) / 2)`.
/// This places the (0, 0) point in the center of the image. The coordinate
/// system can be depicted graphically as follows:
/// ```
///                            ceil((resHeight - 1) / 2)
///                                       ---
///                                        ^
///                                        |
///                                       y|
///                                        |
///                               -x       |        x
/// -floor((resWidth - 1) / 2) |<----------|---------->| ceil((resWidth - 1) / 2)
///                                  (0,0)*|
///                                        |
///                                      -y|
///                                        |
///                                        V
///                                       ---
///                           -floor((resHeight - 1) / 2)
/// ```
/// Importantly here, the (0, 0) pixel is in the 3rd quadrant. This is because
/// when even numbers are used for resWidth and resHeight, the (0, 0) point
/// would be between pixels. Below is a table detailing the bounds for common
/// resolutions:
///
///            Resolution      |                    left/rightmost pixel                |               bottom/topmost pixel
///      (resWidth, resHeight) | (-floor((resWidth - 1) / 2), ceil((resWidth - 1) / 2)) | (-floor((resHeight - 1) / 2), ceil(resHeight - 1) / 2)
///     -----------------------+--------------------------------------------------------+--------------------------------------------------------
///      (640, 480)            | (-319, 320)                                            | (-239, 240)
///      (800, 600)            | (-399, 400)                                            | (-299, 300)
///      (1280, 720)           | (-639, 640)                                            | (-359, 360)
///      (1920, 1080)          | (-959, 960)                                            | (-539, 540)
public struct PixelCoordinate: CTypeWrapper {

// MARK: Properties
    
    /// The x coordinate of the pixel within the image.
    ///
    /// - Attention: The x coordinate must be in the range of:
    ///     `-floor((resWidth - 1) / 2) <= x <= ceil((resWidth - 1) / 2)`
    public var x: Pixels_t

    /// The y coordinate of the pixel within the image.
    ///
    /// - Attention: The y coordinate must be in the range of:
    ///     `-floor((resHeight - 1) / 2) <= y <= ceil((resHeight - 1) / 2)`
    public var y: Pixels_t

    /// The width of the resolution of the image. For example: 1920.
    public var resWidth: Pixels_u

    /// The height of the resolution of the image. For example: 1080.
    public var resHeight: Pixels_u
    
// MARK: Bounds
    
    /// The lowest possible value of `x` that is within the image.
    public var xLowerBound: Pixels_t {
        return Pixels_t(rawValue: gu_pixel_coordinate_x_lower_bound(self.rawValue))
    }
    
    /// The highest possible value of `x` that is within the image.
    public var xUpperBound: Pixels_t {
        return Pixels_t(rawValue: gu_pixel_coordinate_x_upper_bound(self.rawValue))
    }
    
    /// The lowest possible value of `y` that is within the image.
    public var yLowerBound: Pixels_t {
        return Pixels_t(rawValue: gu_pixel_coordinate_y_lower_bound(self.rawValue))
    }
    
    /// The highest possible value of `y` that is within the image.
    public var yUpperBound: Pixels_t {
        return Pixels_t(rawValue: gu_pixel_coordinate_y_upper_bound(self.rawValue))
    }
    
// MARK: Converting to/from the Underlying C Type

    /// Represent this coordinate using the underlying C type
    /// `gu_pixel_coordinate`.
    public var rawValue: gu_pixel_coordinate {
        return gu_pixel_coordinate(
            x: self.x.rawValue,
            y: self.y.rawValue,
            res_width: self.resWidth.rawValue,
            res_height: self.resHeight.rawValue
        )
    }
    
    /// Create a new `PixelCoordinate` by copying the values from the
    /// underlying c type `gu_pixel_coordinate`.
    ///
    /// - Parameter other: An instance of `gu_pixel_coordinate` which contains
    /// the values that will be copied.
    public init(_ other: gu_pixel_coordinate) {
        self.init(
            x: Pixels_t(rawValue: other.x),
            y: Pixels_t(rawValue: other.y),
            resWidth: Pixels_u(rawValue: other.res_width),
            resHeight: Pixels_u(rawValue: other.res_height)
        )
    }

// MARK: Creating a PixelCoordinate

    /// Create a new `PixelCoordinate`.
    ///
    /// - Parameter x: The x coordinate of the pixel within the image.
    ///
    /// - Parameter y: The y coordinate of the pixel within the image.
    ///
    /// - Parameter resWidth: The width of the resolution of the image.
    ///
    /// - Parameter resHeight: The height of the resolution of the image.
    public init(x: Pixels_t = 0, y: Pixels_t = 0, resWidth: Pixels_u = 0, resHeight: Pixels_u = 0) {
        self.x = x
        self.y = y
        self.resWidth = resWidth
        self.resHeight = resHeight
    }
    
// MARK: Converting To Other Image Coordinates
    
    /// Convert this coordinate to a `CameraCoordinate`.
    ///
    /// This creates a new `CameraCoordinate` which represents this pixel
    /// in camera coordinates.
    ///
    /// - SeeAlso: `CameraCoordinate`.
    public var cameraCoordinate: CameraCoordinate {
        return CameraCoordinate(px_coord_to_cam_coord(self.rawValue))
    }

    /// Convert this coordinate to a `PercentCoordinate`.
    ///
    /// This creates a new `PercentCoordinate` which represents this pixel
    /// in centered percentage coordinates.
    ///
    /// - SeeAlso: `PercentCoordinate`.
    public var percentCoordinate: PercentCoordinate {
        return PercentCoordinate(px_coord_to_pct_coord(self.rawValue))
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
    /// - Returns: This function returns the
    /// `RelativeCoordinate` representing the object in the image at the pixel
    /// `self`.
    ///
    /// - Warning: Only use this function if you are positive that the pixel in
    /// the image represented by `self` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `CameraPivot`.
    /// - SeeAlso: `Camera`.
    public func relativeCoordinate(cameraPivot: CameraPivot, camera: Int) -> RelativeCoordinate {
        return self.percentCoordinate.relativeCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

}

extension PixelCoordinate: Equatable, Hashable, Codable {}
