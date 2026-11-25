//
//  StillwordWidgetsBundle.swift
//  StillwordWidgets
//
//  Created by Admin on 25/11/26.
//

import WidgetKit
import SwiftUI

@main
struct StillwordWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StillwordWidgets()
        StillwordWidgetsControl()
        StillwordWidgetsLiveActivity()
    }
}
