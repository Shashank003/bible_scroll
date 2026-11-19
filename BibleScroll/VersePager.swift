import SwiftUI
import UIKit

/// UIKit's vertical page controller asks only for the immediate neighbors.
/// A completed pan can therefore move one verse, never a momentum-sized jump.
struct VersePager<Page: View>: UIViewControllerRepresentable {
    let count: Int
    @Binding var index: Int
    let revision: String
    var onSwipeCompleted: ((Int, Int) -> Void)? = nil
    let page: (Int) -> Page

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.clipsToBounds = true
        context.coordinator.show(index, in: controller)
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        let coordinator = context.coordinator
        let changed = coordinator.parent.revision != revision
        coordinator.parent = self
        if changed {
            for (index, host) in coordinator.hosts {
                host.rootView = page(index)
            }
        }
        if coordinator.currentIndex != index {
            if coordinator.transitioning {
                coordinator.pendingIndex = index
            } else {
                coordinator.show(index, in: controller)
            }
        }
    }

    final class Host: UIHostingController<Page> {
        let verseIndex: Int
        init(index: Int, content: Page) {
            verseIndex = index
            super.init(rootView: content)
            view.backgroundColor = .clear
            view.clipsToBounds = true
        }
        @MainActor required dynamic init?(coder: NSCoder) { fatalError("Not used") }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: VersePager
        var hosts: [Int: Host] = [:]
        var currentIndex = -1
        var transitioning = false
        var pendingIndex: Int?
        private let feedback = UISelectionFeedbackGenerator()

        init(_ parent: VersePager) { self.parent = parent }

        func host(_ index: Int) -> Host? {
            guard (0..<parent.count).contains(index) else { return nil }
            if let existing = hosts[index] { return existing }
            let host = Host(index: index, content: parent.page(index))
            hosts[index] = host
            return host
        }

        func show(_ index: Int, in controller: UIPageViewController) {
            guard let target = host(index) else { return }
            controller.setViewControllers([target], direction: index >= currentIndex ? .forward : .reverse, animated: false)
            currentIndex = index
            prepareNeighbors()
        }

        func prepareNeighbors() {
            hosts = hosts.filter { abs($0.key - currentIndex) <= 1 }
            _ = host(currentIndex - 1)
            _ = host(currentIndex + 1)
        }

        func pageViewController(_ controller: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let host = viewController as? Host else { return nil }
            guard abs((host.verseIndex - 1) - currentIndex) <= 1 else { return nil }
            return self.host(host.verseIndex - 1)
        }

        func pageViewController(_ controller: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let host = viewController as? Host else { return nil }
            guard abs((host.verseIndex + 1) - currentIndex) <= 1 else { return nil }
            return self.host(host.verseIndex + 1)
        }

        func pageViewController(_ controller: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            feedback.prepare()
            transitioning = true
        }

        func pageViewController(_ controller: UIPageViewController, didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            transitioning = false
            if let requested = pendingIndex {
                pendingIndex = nil
                show(requested, in: controller)
                return
            }
            if completed, let visible = controller.viewControllers?.first as? Host {
                let previousIndex = currentIndex
                if visible.verseIndex != currentIndex { feedback.selectionChanged() }
                currentIndex = visible.verseIndex
                parent.index = currentIndex
                if currentIndex != previousIndex {
                    parent.onSwipeCompleted?(previousIndex, currentIndex)
                }
            }
            prepareNeighbors()
        }
    }
}
