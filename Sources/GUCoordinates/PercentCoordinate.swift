/*
 * PercentCoordinate.swift 
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

/// A `PercentCoordinate` represents coordinates within an image
/// as points in centered percentage coordinates. This coordinate systems is
/// defined using 2 fields: (x, y) where the (0, 0) point is in the center.
/// This would infer that the coordinate system is the normal cartesian
/// coordinate system, however, the x and y fields must conform to the following
/// constraints:
///     `-1.0 <= x <= 1.0`, `-1.0 <= y <= 1.0`.
///
/// The coordinate system can be depicted graphically as follows:
/// ```
///                   1.0
///                   ---
///                    ^
///                    |
///                   y|
///                    |
///           -x       |(0,0)   x
///   -1.0 |<----------*---------->| 1.0
///                    |
///                    |
///                  -y|
///                    |
///                    V
///                   ---
///                  -1.0
/// ```
/// This coordinate system can be used to simplify calculations that do not
/// require the resolution of the image.
public struct PercentCoordinate: CTypeWrapper {

// MARK: Properties
    
    /// The x coordinate of the point within the image as a percentage.
    ///
    /// - Attention: The x coordinate must be in the range of:
    ///     `-1.0 <= x <= 1.0`
    public var x: percent_f

    /// The y coordinate of the point within the image as a percentage.
    ///
    /// - Attention: The y coordinate must be in the range of:
    ///     `-1.0 <= y <= 1.0`
    public var y: percent_f

// MARK: Converting to/from the Underlying C Type
    
    /// Represent this coordinate using the underlying C type
    /// `gu_percent_coordinate`.
    public var rawValue: gu_percent_coordinate {
        return gu_percent_coordinate(x: self.x, y: self.y)
    }
    
    /// Create a new `PercentCoordinate` by copying the values from the
    /// underlying c type `gu_percent_coordinate`.
    ///
    /// - Parameter other: An instance of `gu_percent_coordinate` which contains
    /// the values that will be copied.
    public init(_ other: gu_percent_coordinate) {
        self.x = other.x
        self.y = other.y
    }
    
// MARK: Creating a PercentCoordinate

    /// Create a new `PercentCoordinate`.
    ///
    /// - Parameter x: The x coordinate of the point within the image.
    ///
    /// - Parameter y: The y coordinate of the point within the image.
    public init(x: percent_f = 0.0, y: percent_f = 0.0) {
        self.x = x
        self.y = y
    }
    
// MARK: Converting To Other Image Coordinates

    /// Convert this coordinate to a `CameraCoordinate`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that we
    /// are converting to.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that we
    /// are converting to.
    ///
    /// - Returns: A new `CameraCoordinate` representing `self` in camera
    /// coordinates.
    public func cameraCoordinate(resWidth: pixels_u, resHeight: pixels_u) -> CameraCoordinate {
        return self.pixelCoordinate(resWidth: resWidth, resHeight: resHeight).cameraCoordinate
    }

    /// Convert this coordinate to a `PixelCoordinate`.
    ///
    /// - Parameter resWidth: The width of the resolution of the image that we
    /// are converting to.
    ///
    /// - Parameter resHeight: The height of the resolution of the image that we
    /// are converting to.
    ///
    /// - Returns: A new `PixelCoordinate` representing `self` in centered
    /// pixel coordinates.
    public func pixelCoordinate(resWidth: pixels_u, resHeight: pixels_u) -> PixelCoordinate {
        return PixelCoordinate(pct_coord_to_px_coord(self.rawValue, resWidth, resHeight))
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
    /// `RelativeCoordinate` representing the object in the image at the point
    /// `self`. If unable to calculate the `RelativeCoordinate` then this
    /// function returns `nil`.
    ///
    /// - SeeAlso: `CameraPivot`.
    /// - SeeAlso: `Camera`.
    public func relativeCoordinate(cameraPivot: CameraPivot, camera: Int) -> RelativeCoordinate? {
        var relativeCoordinate = gu_relative_coordinate()
        guard pct_coord_to_rr_coord(self.rawValue, cameraPivot.rawValue, &relativeCoordinate, CInt(camera)) else {
            return nil
        }
        return RelativeCoordinate(relativeCoordinate)
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
    /// at the point `self`. If the point represents an object that is not on
    /// the ground then a maximum value for the distance is used.
    ///
    /// - Warning: Only use this function if you are positive that the point in
    /// the image represented by `self` is representing an object on the ground.
    /// If this is not the case, then the maximum value for the distance will
    /// be used.
    ///
    /// - SeeAlso: `CameraPivot`.
    /// - SeeAlso: `Camera`.
    public func unsafeRelativeCoordinate(cameraPivot: CameraPivot, camera: Int) -> RelativeCoordinate {
        return RelativeCoordinate(unsafe_pct_coord_to_rr_coord(self.rawValue, cameraPivot.rawValue, CInt(camera)))
    }

}

extension PercentCoordinate: Equatable, Hashable, Codable {}
