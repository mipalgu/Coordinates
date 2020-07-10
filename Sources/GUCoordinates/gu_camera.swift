/*
 * gu_camera.swift 
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

extension gu_camera: Equatable {

    public static func == (lhs: gu_camera, rhs: gu_camera) -> Bool {
        return lhs.height == rhs.height
            && lhs.centerOffset == rhs.centerOffset
            && lhs.vDirection == rhs.vDirection
            && lhs.vFov == rhs.vFov
            && lhs.hFov == rhs.hFov
    }

}

extension gu_camera: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.height)
        hasher.combine(self.centerOffset)
        hasher.combine(self.vDirection)
        hasher.combine(self.vFov)
        hasher.combine(self.hFov)
    }

}

extension gu_camera: Codable {

    enum CodingKeys: String, CodingKey {
        case height
        case centerOffset
        case vDirection
        case vFov
        case hFov
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let height = try values.decode(centimetres_f.self, forKey: .height)
        let centerOffset = try values.decode(centimetres_f.self, forKey: .centerOffset)
        let vDirection = try values.decode(degrees_f.self, forKey: .vDirection)
        let vFov = try values.decode(degrees_f.self, forKey: .vFov)
        let hFov = try values.decode(degrees_f.self, forKey: .hFov)
        self.init(height: height, centerOffset: centerOffset, vDirection: vDirection, vFov: vFov, hFov: hFov)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.centerOffset, forKey: .centerOffset)
        try container.encode(self.vDirection, forKey: .vDirection)
        try container.encode(self.vFov, forKey: .vFov)
        try container.encode(self.hFov, forKey: .hFov)
    }

}
