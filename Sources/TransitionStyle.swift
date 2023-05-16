/// Transition styles available when pushing screens.
///
/// Use this options when calling method `push`.
/// ```
///   navigationController.push(screenName: "ScreenB", transition: .coverHorizontal)
/// ```
public enum TransitionStyle {
    /// The transition between two screens will be instant, no animation will be applied.
    case none
    /// The transition will cover the entire screen and a cross-disolve animation will be executed.
    case coverFullscreen
    /// The transition will cover the entire screen and a cross-disolve animation will be executed. The previous screen will be kept in the view hiearchy beneath the newly pushed screen.
    case coverOverFullscreen
    /// The transition will cover the entire screen from the bottom to the top on pushing, and reverse on popping.
    case coverVertical
    /// The transition will cover the entire screen from the right to the left on pushing, and reverse on popping.
    case coverHorizontal
    /// The transition will partially covers the underlying content.
    case sheet
}
