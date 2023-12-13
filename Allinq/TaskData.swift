//
//  TaskData.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 12/12/2023.
//

import SwiftUI

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
    var description: String
    var imageName: String
    var assignment: [[String]]
}

/// Array containing task data.
var tasks: [Task] = [
    Task(
        title: "Cable Swap",
        icon: "cable.coaxial",
        description: "Replacing A FibreOptic Cable",
        imageName: "cableSwap",
        assignment: [["Cable", "Unplug the cable from the switch"], ["Cable", "Plug-in new cable to the switch"], ["Cabinets", "Close the cabinet"]]

    ),
    Task(
        title: "Patch Panel",
        icon: "xserve",
        description: "Installation of Patch Panel",
        imageName: "patchPanelInstall",
        assignment: [["Cabinets", "Open the cabinet"], ["PowerSupply", "Turn off powersupply and remove plug"], ["Cable", "Plug-in cables to the switch"], ["Cabinets", "Close the cabinet"]]
    ),
    Task(
        title: "Fibre Switch",
        icon: "server.rack",
        description: "Adding Fibre Switch",
        imageName: "fibreSwitch",
        assignment: [["Cable", "Unplug the cable from the switch"], ["PowerModule", "Replace the module with the replacement"], ["Cable", "Plug-in new cable to the switch"], ["Cabinets", "Close the cabinet"]]
    ),
    Task(
        title: "Cabinet",
        icon: "power.circle",
        description: "Turn Off Cabinet For Maintenance",
        imageName: "psuRack",
        assignment: [["PowerSupply", "Turn off powersupply and remove plug"], ["Cabinets", "Close the cabinet"]]
    ),
    Task(
        title: "Power Strip",
        icon: "poweroutlet.strip",
        description: "Connect Module to Power Grid",
        imageName: "powerStrip",
        assignment: [["Cabinets", "Open the cabinet"], ["PowerSupply", "Turn off powersupply and remove plug"], ["Cable", "Unplug the cable from the switch"], ["Cable", "Plug-in cables to the switch"], ["Cabinets", "Close the cabinet"]]
    ),
]
