import SwiftUI

struct NavigationStackWithSwipeBack<Content: View>: UIViewControllerRepresentable {
    var rootView: Content

    func makeUIViewController(context: Context) -> UINavigationController {
        let hosting = UIHostingController(rootView: rootView)
        let nav = UINavigationController(rootViewController: hosting)
        nav.interactivePopGestureRecognizer?.delegate = context.coordinator
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if let hosting = uiViewController.viewControllers.first as? UIHostingController<Content> {
            hosting.rootView = rootView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}
