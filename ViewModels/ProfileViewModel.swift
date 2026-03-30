//
//  ProfileViewModel.swift
//  Scentdex
//
//  Created by macbook on 30/03/2026.
//

import Foundation
import Observation

@Observable
class ProfileViewModel {
    //MARK - Properties
    private(set) var profile: ScentProfile?
    
    //Mark - Intent
    func calculate(from perfumes: [Perfume]) {
        profile = ScentProfile.calculate(from: perfumes)
    }
}


