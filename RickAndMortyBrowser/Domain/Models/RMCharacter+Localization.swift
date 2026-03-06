//
//  RMCharacter+Localization.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 25/2/26.
//

import Foundation

extension RMCharacter {
    var localizedStatus: String {
        switch status.lowercased() {
        case "alive":
            return String(localized: "status.alive")
        case "dead":
            return String(localized: "status.dead")
        default:
            return String(localized: "status.unknown")
        }
    }

    var localizedGender: String {
        switch gender.lowercased() {
        case "male":
            return String(localized: "gender.male")
        case "female":
            return String(localized: "gender.female")
        case "genderless":
            return String(localized: "gender.genderless")
        default:
            return String(localized: "gender.unknown")
        }
    }

    var localizedSpecies: String {
        switch species.lowercased() {
        case "human":
            return String(localized: "species.human")
        case "animal":
            return String(localized: "species.animal")
        case "alien":
            return String(localized: "species.alien")
        case "humanoid":
            return String(localized: "species.humanoid")
        case "robot":
            return String(localized: "species.robot")
        case "mythological creature":
            return String(localized: "species.mythologicalCreature")
        case "poopybutthole":
            return String(localized: "species.poopybutthole")
        case "disease":
            return String(localized: "species.disease")
        case "unknown":
            return String(localized: "species.unknown")
        default:
            // Fallback: no intentamos traducir especies raras, mostramos el valor tal cual
            return species
        }
    }

    var localizedOriginName: String {
        let raw = originName.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty { return String(localized: "origin.unknown") }
        if raw.lowercased() == "unknown" { return String(localized: "origin.unknown") }
        return originName
    }

    var localizedLocationName: String {
        let raw = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty { return String(localized: "location.unknown") }
        if raw.lowercased() == "unknown" { return String(localized: "location.unknown") }
        return locationName
    }

}
