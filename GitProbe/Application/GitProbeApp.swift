//
//  GitProbeApp.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import SwiftUI
import SwiftData

struct AppComponent: RepositorySearchDependency {
  let httpClient: HTTPClient = {
    return URLSessionHTTPClient(session: URLSession(configuration: .default))
  }()
}

@main
struct GitProbeApp: App {
  private let appComponent = AppComponent()
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([RecentSearchSchema.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RepositorySearchScreen(
          component: RepositorySearchComponent(dependency: appComponent)
        )
      }
    }
    .modelContainer(sharedModelContainer)
  }
}

