
import 'package:flutter/material.dart';

class CurvedBottomNavBar extends StatefulWidget {
  int currentIndex;
  final ValueChanged<int> onTabItemSelected;

  CurvedBottomNavBar({required this.currentIndex, required this.onTabItemSelected});

  @override
  _CurvedBottomNavBarState createState() => _CurvedBottomNavBarState();
}

class _CurvedBottomNavBarState extends State<CurvedBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Curved shape for selected item
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: (MediaQuery.of(context).size.width / 4) * widget.currentIndex +
              (MediaQuery.of(context).size.width / 8) - 44.5,  // Adjusted for symmetry
          bottom: -12,
          child: CustomPaint(
            painter: SymmetricCurvedItemPainter(),
            child: Container(
              height: 89,  // Height of the curved container
              width: 89,  // Width of the curved container
            ),
          ),
        ),
        // BottomNavigationBar
        BottomNavigationBar(

          currentIndex: widget.currentIndex,
          onTap: (index) {
            widget.onTabItemSelected(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,  // Black color for unselected items
          backgroundColor: Colors.transparent,  // Make it transparent to show curve
          elevation: 0,  // No elevation to match curve
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Save Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter to create a symmetric curved shape for the selected item
class SymmetricCurvedItemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1F5882)  // Color of the selected item background
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)  // Start at bottom-left
      ..quadraticBezierTo(size.width / 2, -50, size.width, size.height);  // Adjusted curve

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


// class SymmetricCurvedItemPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(0xFF1F5882)  // Color of the selected item background
//       ..style = PaintingStyle.fill;
//
//     final path = Path()
//       ..moveTo(0, size.height)  // Start at bottom-left
//       ..lineTo(0, size.height * 0.5)  // Left side up
//       ..quadraticBezierTo(size.width * 0.5, -30, size.width, size.height * 0.5)  // Curved top resembling water
//       ..lineTo(size.width, size.height)  // Right side down to bottom-right
//       ..close();  // Close the path for the flat bottom
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

// class SymmetricCurvedItemPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(0xFF1F5882)  // Color of the selected item background
//       ..style = PaintingStyle.fill;
//
//     final path = Path()
//       ..moveTo(0, size.height)  // Start at bottom-left
//       ..lineTo(0, size.height * 0.2)  // Left side up
//       ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.2)  // Curved top
//       ..lineTo(size.width, size.height)  // Right side down to bottom-right
//       ..close();  // Close the path for the flat bottom
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }


