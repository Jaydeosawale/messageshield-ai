# Responsive UI implementation

## Breakpoints
- Under 520px: quick cards stack vertically.
- Under 700px: mobile bottom navigation.
- 700px and above: NavigationRail.
- 1050px and above: expanded desktop sidebar.

## Fix applied
The old design used layout constraints that could squeeze text/cards. The new screen has no fixed mobile content width. The page uses LayoutBuilder, dynamic horizontal padding, `double.infinity` only inside constrained parents, `Expanded` for text rows, and `ConstrainedBox` for desktop max width.
