//
//  ContentView.swift
//  LayoutMeasurement
//
//  Created by Chris Eidhof on 09.08.22.
//

import SwiftUI

extension View {
    func logSizes(_ label: String) -> some View {
        LogSizes(label: label) { self }
    }
}

extension CGFloat {
    var pretty: String {
        String(format: "%.2f", self)
    }
}

extension CGSize {
    var pretty: String {
        "\(width.pretty)⨉\(height.pretty)"
    }
}

extension Optional where Wrapped == CGFloat {
    var pretty: String {
        self?.pretty ?? "nil"
    }
}

extension ProposedViewSize {
    var pretty: String {
        "\(width.pretty)⨉\(height.pretty)"
    }
}

struct LogSizes: Layout {
    var label: String
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        log("Propose \(label)", proposal.pretty)
        let result = subviews[0].sizeThatFits(proposal)
        log("Report \(label)", result.pretty)
        return result
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0].place(at: bounds.origin, proposal: proposal)
    }
}

struct ClearConsole: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        Console.shared.log.removeAll()
        return subviews[0].sizeThatFits(proposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0].place(at: bounds.origin, proposal: proposal)
    }
}

extension View {
    func clearConsole() -> some View {
        ClearConsole { self }
    }
}

final class Console: ObservableObject {
    @Published var log: [Item] = []
    
    struct Item: Identifiable {
        var id = UUID()
        var label: String
        var value: String
    }
    
    static let shared = Console()
        
}

func log(_ label: String, _ value: String) {
    Console.shared.log.append(.init(label: label, value: value))
}

struct ConsoleView: View {
    @ObservedObject var console = Console.shared
    
    var body: some View {
        List(console.log) { item in
            HStack {
                Text(item.label)
                Spacer()
                Text(item.value)
            }
        }
        .listStyle(.plain)
//        .frame(maxHeight: 300)
    }
}

struct ContentView: View {
    @State var proposedSize: CGSize = CGSize(width: 200, height: 100)
    
    @ViewBuilder var subject: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.orange)
                .logSizes("Orange")
            Text("Hello, world")
                .logSizes("Text")
                .layoutPriority(1)
            Rectangle()
                .fill(.blue)
                .logSizes("Blue")
        }
        .logSizes("HStack")
    }
    
    var body: some View {
        VStack {
           subject
                .clearConsole()
                .frame(width: proposedSize.width, height: proposedSize.height)
                .border(Color.green)
            Slider(value: $proposedSize.width, in: 0...300, label: { Text("Width")})
            ConsoleView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
