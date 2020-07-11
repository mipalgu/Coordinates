/*
 * CTypeWrapper.swift 
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

/**
 *  `CTypeWrapper` provides a common interface for swift types that convert
 *  and provide the functionality of underlying C types.
 *
 *  In such a case, some functionality needs to be provided. The swift type
 *  must be able to be converted from the underlying C type, but must also
 *  provide the ability to be converted to the underlying C type.
 *
 *  This protocol also requires that conforming types behave the same way
 *  when it comes to equality, hashing, encoding and decoding using the
 *  `Equatable`, `Hashable`, `Encodable` and `Decodable` protocols.
 */
public protocol CTypeWrapper: Hashable, Codable {

    /**
     *  The type of the underlying C type that the conforming type is wrapping.
     */
    associatedtype CType

    /**
     *  Convert `self` to the underlying C type.
     */
    var rawValue: CType { get }

    /**
     *  Initialise the conforming type from the underlying C type.
     */
    init(_: CType)

}

extension CTypeWrapper where Self: Equatable, CType: Equatable {

    /**
     *  Delegates equality to the underlying C type.
     */
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

extension CTypeWrapper where Self: Hashable, CType: Hashable {

    /**
     *  Delegates hashing functionality to the underlying C type.
     */
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }

}

extension CTypeWrapper where Self: Decodable, CType: Decodable {

    /**
     *  Delegates decoding to the underlying C type.
     */
    public init(from decoder: Decoder) throws {
        self.init(try CType.init(from: decoder))
    }
    
}

extension CTypeWrapper where Self: Encodable, CType: Encodable {

    /**
     *  Delegates encoding to the underlying C type.
     */
    public func encode(to encoder: Encoder) throws {
        try self.rawValue.encode(to: encoder)
    }

}
