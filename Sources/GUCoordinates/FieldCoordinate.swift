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

public struct FieldCoordinate {

    public var position: CartesianCoordinate

    public var heading: degrees_t

    public var rawValue: gu_field_coordinate {
        return gu_field_coordinate(position: self.position.rawValue, heading: self.heading)
    }

    public init(position: CartesianCoordinate = CartesianCoordinate(), heading: degrees_t = 0) {
        self.position = position
        self.heading = heading
    }

    public init(_ other: gu_field_coordinate) {
        self.position = CartesianCoordinate(other.position)
        self.heading = other.heading
    }

    public func cartesianCoordinate(at coord: RelativeCoordinate) -> CartesianCoordinate {
        return CartesianCoordinate(rr_coord_to_cartesian_coord_from_field(coord.rawValue, self.rawValue))
    }

    public func fieldCoordinate(at coord: RelativeCoordinate, heading: degrees_t) -> FieldCoordinate {
        return FieldCoordinate(rr_coord_to_field_coord_from_source(coord.rawValue, self.rawValue, heading))
    }

    public func relativeCoordinate(to coord: CartesianCoordinate) -> RelativeCoordinate {
        return RelativeCoordinate(field_coord_to_rr_coord_to_target(self.rawValue, coord.rawValue))
    }

    public func relativeCoordinate(to coord: FieldCoordinate) -> RelativeCoordinate {
        return self.relativeCoordinate(to: coord.position)
    }

    public func cartesianCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
    }

    public func cartesianCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
    }

    public func cartesianCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int) -> CartesianCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.cartesianCoordinate(at: rel)
    }

    public func fieldCoordinate(at coord: CameraCoordinate, cameraPivot: CameraPivot, camera: Int, heading: degrees_t) -> FieldCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.fieldCoordinate(at: rel, heading: heading)
    }

    public func fieldCoordinate(at coord: PixelCoordinate, cameraPivot: CameraPivot, camera: Int, heading: degrees_t) -> FieldCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.fieldCoordinate(at: rel, heading: heading)
    }

    public func fieldCoordinate(at coord: PercentCoordinate, cameraPivot: CameraPivot, camera: Int, heading: degrees_t) -> FieldCoordinate? {
        guard let rel = coord.relativeCoordinate(cameraPivot: cameraPivot, camera: camera) else {
            return nil
        }
        return self.fieldCoordinate(at: rel, heading: heading)
    }

    public func cameraCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    public func cameraCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> CameraCoordinate? {
        return self.relativeCoordinate(to: coord).cameraCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    public func pixelCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    public func pixelCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int, resWidth: pixels_u, resHeight: pixels_u) -> PixelCoordinate? {
        return self.relativeCoordinate(to: coord).pixelCoordinate(cameraPivot: cameraPivot, camera: camera, resWidth: resWidth, resHeight: resHeight)
    }

    public func percentCoordinate(to coord: CartesianCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate? {
        self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

    public func percentCoordinate(to coord: FieldCoordinate, cameraPivot: CameraPivot, camera: Int) -> PercentCoordinate? {
        self.relativeCoordinate(to: coord).percentCoordinate(cameraPivot: cameraPivot, camera: camera)
    }

}

extension FieldCoordinate: Equatable, Hashable {}
