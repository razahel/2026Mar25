//
//  GitProbeApp.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import SwiftUI
import SwiftData

struct AppComponent: RepositorySearchDependency {
  let httpClient: HTTPClient
  let localDataClient: SwiftDataLocalDataClient
}

@main
struct GitProbeApp: App {
  private let appComponent: AppComponent
  private let sharedModelContainer: ModelContainer
  
  init() {
    let schema = Schema([RecentSearchSchema.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      self.sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      self.appComponent = AppComponent(httpClient: URLSessionHTTPClient(session: URLSession(configuration: .default)),
                    localDataClient: SwiftDataLocalDataClient(modelContext: sharedModelContainer.mainContext))
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }
    
  var body: some Scene {
    WindowGroup {
      RepositorySearchScreen(dependency: self.appComponent)
    }
    .modelContainer(sharedModelContainer)
  }
}

