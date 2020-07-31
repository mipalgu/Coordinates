/*
 * CameraPivot.swift 
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

/// A `CameraPivot` represents the pivot point which a `Camera` is attached to.
///
/// If a camera is on the ground, then there is no pivot point. If the camera
/// is on the end of a stick then the pivot point is the bottom of the stick.
/// If the camera is on the head of the robot, then the pivot point is the
/// neck of the robot.
public struct CameraPivot: CTypeWrapper {

// MARK: Properties
    
    /// The vertical orientation of the pivot point.
    public var pitch: Angle

    /// The horizontal orientation of the pivot point.
    public var yaw: Angle

    /// The vertical distance from the ground to the pivot point.
    public var height: Distance

    /// The `Camera`s attached to this pivot point.
    public var cameras: [Camera]

// MARK: Converting to/from the Underlying C Type
    
    /// Represent this coordinate using the underlying C type `gu_camera_pivot`.
    public var rawValue: gu_camera_pivot {
        var cameraPivot = gu_camera_pivot()
        cameraPivot.pitch = self.pitch.degrees_d.rawValue
        cameraPivot.yaw = self.yaw.degrees_d.rawValue
        cameraPivot.height = self.height.centimetres_d.rawValue
        for (index, camera) in self.cameras.enumerated() where index < GU_CAMERA_PIVOT_NUM_CAMERAS {
            withUnsafeMutablePointer(to: &cameraPivot.cameras.0) {
                $0[index] = camera.rawValue
            }
        }
        cameraPivot.numCameras = min(CInt(self.cameras.count), GU_CAMERA_PIVOT_NUM_CAMERAS)
        return cameraPivot
    }
    
    /// Create a new `CameraPivot` by copying the values from the
    /// underlying c type `gu_camera_pivot`.
    ///
    /// - Parameter other: An instance of `gu_camera_pivot` which contains
    /// the values that will be copied.
    public init(_ other: gu_camera_pivot) {
        var other = other
        self.init(
            pitch: Angle(Degrees_d(rawValue: other.pitch)),
            yaw: Angle(Degrees_d(rawValue: other.yaw)),
            height: Distance(Centimetres_d(rawValue: other.height)),
            cameras: withUnsafePointer(to: &other.cameras.0) {
                let buffer = UnsafeBufferPointer(start: $0, count: Int(min(other.numCameras, GU_CAMERA_PIVOT_NUM_CAMERAS)))
                return buffer.map { Camera($0) }
            }
        )
    }
    
// MARK: Creating a CameraPivot

    /// Create a new `CameraPivot`.
    ///
    /// - Parameter pitch: The vertical orientation of the pivot point.
    ///
    /// - Parameter yaw: The horizontal orientation of the pivot point.
    ///
    /// - Parameter height: The vertical distance from the ground to the pivot
    /// point.
    ///
    /// - Parameter cameras: The `Camera`s attached to this pivot
    /// point.
    public init(pitch: Angle = 0, yaw: Angle = 0, height: Distance = 0.0, cameras: [Camera] = []) {
        self.pitch = pitch
        self.yaw = yaw
        self.height = height
        self.cameras = cameras
    }
    
// MARK: - Checking Whether Conversions Are Possible
    
    /// Is the object represent by the pixel in the image taken from the camera
    /// on the ground?
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter camera: The camera index for the camera in the `cameras`
    /// array.
    ///
    /// - Returns: True if the pixel represents an object that is on the ground.
    /// Otherwise, False.
    public func objectOnGround(_ coord: CameraCoordinate, forCamera camera: Int) -> Bool {
        return self.objectOnGround(coord.percentCoordinate, forCamera: camera)
    }
    
    /// Is the object represent by the pixel in the image taken from the camera
    /// on the ground?
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter camera: The camera index for the camera in the `cameras`
    /// array.
    ///
    /// - Returns: True if the pixel represents an object that is on the ground.
    /// Otherwise, False.
    public func objectOnGround(_ coord: PixelCoordinate, forCamera camera: Int) -> Bool {
        return self.objectOnGround(coord.percentCoordinate, forCamera: camera)
    }
    
    /// Is the object represent by the pixel in the image taken from the camera
    /// on the ground?
    ///
    /// - Parameter coord: The pixel in the image representing the object.
    ///
    /// - Parameter camera: The camera index for the camera in the `cameras`
    /// array.
    ///
    /// - Returns: True if the pixel represents an object that is on the ground.
    /// Otherwise, False.
    public func objectOnGround(_ coord: PercentCoordinate, forCamera camera: Int) -> Bool {
        return gu_camera_pivot_object_on_ground(self.rawValue, CInt(camera), coord.rawValue)
    }
    
    /// Can the camera see the object?
    ///
    /// - Parameter coord: The location of the object in relation to the camera.
    ///
    /// - Parameter camera: The camera index for the camera in the `cameras`
    /// array.
    ///
    /// - Returns: True if the specified camera can see the object, False
    /// otherwise.
    public func canSee(object coord: RelativeCoordinate, inCamera camera: Int) -> Bool {
        return gu_camera_pivot_can_see_object(self.rawValue, CInt(camera), coord.rawValue)
    }

}

extension CameraPivot: Equatable, Hashable, Codable {}
