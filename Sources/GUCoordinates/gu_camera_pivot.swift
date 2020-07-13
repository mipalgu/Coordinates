/*
 * gu_camera_pivot.swift 
 * GUCoordinates 
 *
 * Created by Callum McColl on 10/07/2020.
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

extension gu_camera_pivot {

    var cameraList: [gu_camera] {
        get {
            if self.numCameras == 0 {
                return []
            }
            var cameras = self.cameras
            return withUnsafePointer(to: &cameras.0) {
                let buffer = UnsafeBufferPointer(start: $0, count: Int(min(self.numCameras, GU_CAMERA_PIVOT_NUM_CAMERAS)))
                return Array(buffer)
            }
        } set {
            if newValue.isEmpty {
                self.numCameras = 0
                return
            }
            if newValue.count > GU_CAMERA_PIVOT_NUM_CAMERAS {
                fatalError("Attempting to assign to gu_camera_pivot.cameraList when the number of values being assigned exceed the maximum number of cameras \(GU_CAMERA_PIVOT_NUM_CAMERAS).")
            }
            withUnsafeMutableBytes(of: &self.cameras.0) { cameraPointer in
                _ = newValue.withUnsafeBytes {
                    memcpy(cameraPointer.baseAddress, $0.baseAddress, MemoryLayout<gu_camera>.size * newValue.count)
                }
            }
            self.numCameras = CInt(newValue.count)
        }
    }

    public init(pitch: degrees_f, yaw: degrees_f, height: centimetres_f, cameraList: [gu_camera]) {
        self.init()
        self.pitch = pitch
        self.yaw = yaw
        self.height = height
        self.cameraList = cameraList
    }

}

extension gu_camera_pivot: Equatable {

    public static func == (lhs: gu_camera_pivot, rhs: gu_camera_pivot) -> Bool {
        return lhs.pitch != rhs.pitch
            || lhs.yaw != rhs.yaw
            || lhs.numCameras != rhs.numCameras
            || lhs.cameraList == rhs.cameraList
    }

}

extension gu_camera_pivot: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.pitch)
        hasher.combine(self.yaw)
        hasher.combine(self.height)
        hasher.combine(self.cameraList)
        hasher.combine(self.numCameras)
    }

}

extension gu_camera_pivot: Codable {

    enum CodingKeys: String, CodingKey {
        case pitch
        case yaw
        case height
        case cameraList
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let pitch = try values.decode(degrees_f.self, forKey: .pitch)
        let yaw = try values.decode(degrees_f.self, forKey: .yaw)
        let height = try values.decode(centimetres_f.self, forKey: .height)
        let cameraList = try values.decode([gu_camera].self, forKey: .cameraList)
        self.init(pitch: pitch, yaw: yaw, height: height, cameraList: cameraList)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.pitch, forKey: .pitch)
        try container.encode(self.yaw, forKey: .yaw)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.cameraList, forKey: .cameraList)
    }

}
