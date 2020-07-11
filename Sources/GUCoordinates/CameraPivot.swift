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

/**
 *  A `CameraPivot` represents the pivot point which a `Camera` is attached to.
 *
 *  If a camera is on the ground, then there is no pivot point. If the camera
 *  is on the end of a stick then the pivot point is the bottom of the stick.
 *  If the camera is on the head of the robot, then the pivot point is the
 *  neck of the robot.
 */
public struct CameraPivot: CTypeWrapper {

    /**
     *  `CameraPivot.Camera` provides a convenient structre which makes dealing
     *  with `gu_camera` object easier. This is because the underlying C
     *  structure of `gu_camera_pivot` contains two parallel arrays --- one
     *  containing the actual `gu_camera` instances, and the other for
     *  containing the relative heights from the pivot point to the camera.
     *  This structure therefore hides the fact that there are parrallel arrays
     *  and provides an interface for a single entry in each of these arrays.
     */
    public struct Camera: CTypeWrapper, Equatable, Hashable, Codable {

        /**
         *  The `Camera`.
         */
        public var camera: GUCoordinates.Camera

        /**
         *  The vertical distance from the pivot point to the center of the
         *  camera.
         */
        public var heightOffset: centimetres_f

        /**
         *  Represent this coordinate using the underlying type
         *  `gu_camera_pivot.camera`.
         */
        public var rawValue: gu_camera_pivot.camera {
            return gu_camera_pivot.camera(camera: self.camera.rawValue, heightOffset: self.heightOffset)
        }

        /**
         *  Create a new `CameraPivot.Camera`.
         *
         *  - Parameter camera: The `Camera`.
         *
         *  - Parameter heightOffset: The vertical distance from the pivot
         *  point to the center of the camera.
         */
        public init(camera: GUCoordinates.Camera, heightOffset: centimetres_f) {
            self.camera = camera
            self.heightOffset = heightOffset
        }

        /**
         *  Create a new `CameraPivot.Camera` by copying the values from the
         *  underlying type `gu_camera_pivot.camera`.
         *
         *  - Parameter other: An instance of `gu_camera_pivot.camera` which
         *  contains the values that will be copied.
         */
        public init(_ other: gu_camera_pivot.camera) {
            self.camera = GUCoordinates.Camera(other.camera)
            self.heightOffset = other.heightOffset
        }

    }

    /**
     *  The vertical orientation of the pivot point.
     */
    public var pitch: degrees_f

    /**
     *  The horizontal orientation of the pivot point.
     */
    public var yaw: degrees_f

    /**
     *  The `CameraPivot.Camera`s attached to this pivot point.
     */
    public var cameras: [CameraPivot.Camera]

    /**
     *  Represent this coordinate using the underlying C type `gu_camera_pivot`.
     */
    public var rawValue: gu_camera_pivot {
        var cameraPivot = gu_camera_pivot()
        cameraPivot.pitch = self.pitch
        cameraPivot.yaw = self.yaw
        for (index, camera) in self.cameras.enumerated() where index < GU_CAMERA_PIVOT_NUM_CAMERAS {
            withUnsafeMutablePointer(to: &cameraPivot.cameras.0) {
                $0[index] = camera.camera.rawValue
            }
            withUnsafeMutablePointer(to: &cameraPivot.cameraHeightOffsets.0) {
                $0[index] = camera.heightOffset
            }
        }
        cameraPivot.numCameras = min(CInt(self.cameras.count), GU_CAMERA_PIVOT_NUM_CAMERAS)
        return cameraPivot
    }

    /**
     *  Create a new `CameraPivot`.
     *
     *  - Parameter pitch: The vertical orientation of the pivot point.
     *
     *  - Parameter yaw: The horizontal orientation of the pivot point.
     *
     *  - Parameter cameras: The `CameraPivot.Camera`s attached to this pivot
     *  point.
     */
    public init(pitch: degrees_f = 0, yaw: degrees_f = 0, cameras: [CameraPivot.Camera] = []) {
        self.pitch = pitch
        self.yaw = yaw
        self.cameras = cameras
    }

    /**
     *  Create a new `CameraPivot` by copying the values from the
     *  underlying c type `gu_camera_pivot`.
     *
     *  - Parameter other: An instance of `gu_camera_pivot` which contains
     *  the values that will be copied.
     */
    public init(_ other: gu_camera_pivot) {
        var other = other
        self.pitch = other.pitch
        self.yaw = other.yaw
        let cameras = withUnsafePointer(to: &other.cameras.0) {
            return Array(UnsafeBufferPointer(start: $0, count: Int(min(other.numCameras, GU_CAMERA_PIVOT_NUM_CAMERAS))))
        }
        let cameraHeightOffsets = withUnsafePointer(to: &other.cameraHeightOffsets.0) {
            return Array(UnsafeBufferPointer(start: $0, count: Int(min(other.numCameras, GU_CAMERA_PIVOT_NUM_CAMERAS))))
        }
        self.cameras = zip(cameras, cameraHeightOffsets).map { CameraPivot.Camera(camera: GUCoordinates.Camera($0), heightOffset: $1) }
    }

}

extension CameraPivot: Equatable, Hashable, Codable {}
