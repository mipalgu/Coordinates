/*
 * RelativeCoordinate.swift 
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

/**
 *  A `RelativeCoordinate` represents a coordinate that is relative to some
 *  other coordinate.
 *
 *  This coordinate describes the distance and direction that one coordinate
 *  is from another. We categorise these two coordinates as the source and
 *  the target. The target is where the `RelativeCoordinate` is pointing
 *  towards and the source is where the `RelativeCoordinate` is pointing from.
 *  `RelativeCoordiante` is a polar coordinate in the form of phi, r where phi
 *  is the direction and r is the distance to the coordinate.
 *
 *  The direction is an angle in degrees. A positive value for direction
 *  indicates that the target is on the left. A negative value indicates that
 *  the target is on the right. A value of zero indicates that the target is
 *  directly in front of source.
 */
public struct RelativeCoordinate: CTypeWrapper {

    /**
     * The heading towards the target.
     *
     * A positive value for direction indicates that the target is on
     * the left. A negative value indicates that the target is on the
     * right. A value of zero indicates that the target is pointing
     * straight ahead.
     */
    public var direction: degrees_t

    /**
     * The distance to the target.
     */
    public var distance: centimetres_u

    /**
     *  Convert this coordinate to a `CartesianCoordinate`.
     *
     *  This assumes that source is the (0, 0) point facing 0 degrees.
     */
    public var cartesianCoordinate: CartesianCoordinate {
        return CartesianCoordinate(rr_coord_to_cartesian_coord(self.rawValue))
    }

    /**
     *  Represent this coordinate using the underlying C type
     *  `gu_relative_coordinate`.
     */
    public var rawValue: gu_relative_coordinate {
        return gu_relative_coordinate(direction: self.direction, distance: self.distance)
    }

    /**
     *  Create a new `RelativeCoordinate`.
     *
     *  - Parameter direction: The direction to the target.
     *
     *  - Parameter distance: The distance to the target.
     */
    public init(direction: degrees_t = 0, distance: centimetres_u = 0) {
        self.direction = direction
        self.distance = distance
    }

    /**
     *  Create a new `RelativeCoordinate` by copying the values from the
     *  underlying c type `gu_relative_coordinate`.
     *
     *  - Parameter other: An instance of `gu_relative_coordinate` which contains
     *  the values that will be copied.
     */
    public init(_ other: gu_relative_coordinate) {
        self.direction = other.direction
        self.distance = other.distance
    }

    /**
     *  Convert this coordinate to a `CameraCoordinate`.
     *
     *  This allows us to place the target within a specific image taken from a
     *  specific camera. This is only possible if the camera can actually see
     *  the target.
     *
     *  - Parameter cameraPivot: The `CameraPivot` detailing the configuration
     *  of the pivot point in which the camera is placed, as well as detailing
     *  the cameras attached to the pivot point.
     *
     *  - Parameter camera: The index of the camera which we are placing
     *  the target. This index should reference a valid `Camera` within the
     *  `cameras` array within `cameraPivot.cameras`.
     *
     *  - Parameter resWidth: The width of the resolution of the image that
     *  we are placing the target in.
     *
     *  - Parameter resHeight: The height of the resolution of the image that
     *  we are placing the target in.
     *
     *  - Returns: When successful, this function returns the
     *  `PixelCoordinate` representing the target in the image at a specific
     *  pixel. If unable to calculate the `CameraCoordinate` (for example
     *  when the camera cannot actually see the target) then this
     *  function returns `nil`.
     *
     *  - SeeAlso: `CameraPivot`.
     *  - SeeAlso: `Camera`.
     *  - SeeAlso: `CameraCoordinate`.
     */
    public func cameraCoordinate(cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> CameraCoordinate? {
        return self.percentCoordinate(cameraPivot: cameraPivot, camera: camera)?.cameraCoordinate(resWidth: resWidth, resHeight: resHeight)
    }

    /**
     *  Convert this coordinate to a `PixelCoordinate`.
     *
     *  This allows us to place the target within a specific image taken from a
     *  specific camera. This is only possible if the camera can actually see
     *  the target.
     *
     *  - Parameter cameraPivot: The `CameraPivot` detailing the configuration
     *  of the pivot point in which the camera is placed, as well as detailing
     *  the cameras attached to the pivot point.
     *
     *  - Parameter camera: The index of the camera which we are placing
     *  the target. This index should reference a valid `Camera` within the
     *  `cameras` array within `cameraPivot.cameras`.
     *
     *  - Parameter resWidth: The width of the resolution of the image that
     *  we are placing the target in.
     *
     *  - Parameter resHeight: The height of the resolution of the image that
     *  we are placing the target in.
     *
     *  - Returns: When successful, this function returns the
     *  `PixelCoordinate` representing the target in the image at a specific
     *  pixel. If unable to calculate the `PixelCoordinate` (for example
     *  when the camera cannot actually see the target) then this
     *  function returns `nil`.
     *
     *  - SeeAlso: `CameraPivot`.
     *  - SeeAlso: `Camera`.
     *  - SeeAlso: `PixelCoordinate`.
     */
    public func pixelCoordinate(cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> PixelCoordinate? {
        return self.percentCoordinate(cameraPivot: cameraPivot, camera: camera)?.pixelCoordinate(resWidth: resWidth, resHeight: resHeight)
    }

    /**
     *  Convert this coordinate to a `PercentCoordinate`.
     *
     *  This allows us to place the target within a specific camera. This is
     *  only possible if the camera can actually see the target.
     *
     *  - Parameter cameraPivot: The `CameraPivot` detailing the configuration
     *  of the pivot point in which the camera is placed, as well as detailing
     *  the cameras attached to the pivot point.
     *
     *  - Parameter camera: The index of the camera which we are placing
     *  the target. This index should reference a valid `Camera` within the
     *  `cameras` array within `cameraPivot.cameras`.
     *
     *  - Returns: When successful, this function returns the
     *  `PercentCoordinate` representing the target in the image at a specific
     *  point. If unable to calculate the `PercentCoordinate` (for example
     *  when the camera cannot actually see the target) then this
     *  function returns `nil`.
     *
     *  - SeeAlso: `CameraPivot`.
     *  - SeeAlso: `Camera`.
     *  - SeeAlso: `PercentCoordinate`.
     */
    public func percentCoordinate(cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate? {
        var percentCoordinate = gu_percent_coordinate();
        guard rr_coord_to_pct_coord(self.rawValue, cameraPivot.rawValue, CInt(camera), &percentCoordinate) else {
            return nil
        }
        return PercentCoordinate(percentCoordinate)
    }

    /**
     *  Calculate a relative coordinate to a coordinate in relation to the
     *  target.
     *
     *  In other words, this function calculates trajectories between two
     *  coordinates. Let's say we have two coordinate A (`source -> target`)
     *  and B (`source -> coord`), then this function calculates
     *  C (`target -> coord`):
     *  ```
     *  
     *  
     *  
     *                       A(0 degrees, 30cm)
     *            source * ------------------> * target
     *                    \                   /
     *                     \                 /
     *                      \               /
     *                       \             /
     *   B(-45 degrees, 60cm) \           / C (-74 degrees, 44cm)
     *                         \         /
     *                          \       /
     *                           \     /
     *                            \   /
     *                             \ /
     *                              V
     *                              * coord 
     *  
     *  
     *  
     *  ```
     *
     *  - Parameter coord: The coordinate which will be the target of the new
     *  `RelativeCoordinate`.
     *
     *  - Returns: The `RelativeCoordinate` from the target (`self`) to the
     *  new target (`coord`).
     */
    public func relativeCoordinate(to coord: RelativeCoordinate) -> RelativeCoordinate {
        return self.cartesianCoordinate.relativeCoordinate(to: coord.cartesianCoordinate)
    }

    /**
     *  Convert this coordinate to a `FieldCoordinate`.
     *
     *  This assumes that source is the (0, 0) point facing 0 degrees.
     *
     *  - Parameter heading: The heading of the resulting `FieldCoordinate`.
     *
     *  - Returns: The target converted to a `FieldCoordinate`.
     */
    public func fieldCoordinate(heading: degrees_t) -> FieldCoordinate {
        return FieldCoordinate(rr_coord_to_field_coord(self.rawValue, heading))
    }

}

extension RelativeCoordinate: Equatable, Hashable, Codable {}
