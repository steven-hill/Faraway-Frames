//
//  PersistentContainerProtocol.swift
//  Faraway Frames
//
//  Created by Steven Hill on 27/05/2026.
//

import Foundation
import CoreData

protocol PersistentContainerProtocol {
    func makePersistentContainer() -> NSPersistentContainer
}
