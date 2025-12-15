//
//  PhysicsCategories.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation

struct PhysicsCategories
{
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0       // 1 (İkili sistemde: 0001)
    static let obstacle: UInt32 = 0x1 << 1     // 2 (İkili sistemde: 0010)
    static let ground: UInt32 = 0x1 << 2       // 4 (İkili sistemde: 0100)
}
