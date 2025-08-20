import 'package:flutter/material.dart';

class GlassesTimeline extends StatelessWidget {
  final int currentStep;

  GlassesTimeline({required this.currentStep});

  final List<String> labels = [
    "Prescription Issued",
    "Lenses in Progress",
    "Quality Check",
    "Ready for Pickup",
    "Picked Up"
  ];

  final List<IconData> icons = [
    Icons.visibility,
    Icons.precision_manufacturing,
    Icons.search,
    Icons.shopping_bag,
    Icons.check_circle,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final iconSize = isWide ? 60.0 : 48.0;
        final fontSize = isWide ? 18.0 : 14.0;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connector line with dots aligned under icons
              SizedBox(
                height: 24,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final stepCount = labels.length;
                    final columnWidth = totalWidth / stepCount;
                    final dotDiameter = 12.0;

                    return Stack(
                      children: [
                        // Connector line between dots
                        Positioned(
                          top: 12,
                          left: dotDiameter / 2,
                          right: dotDiameter / 2,
                          child: Row(
                            children: List.generate(stepCount - 0, (index) {
                              // Fill line segments up to and including currentStep
                              bool isFilled = index < currentStep;
                              // Also fill the segment leading into current dot if possible
                              if (index == currentStep && currentStep < stepCount - 1) {
                                isFilled = true;
                              }
                              return Expanded(
                                child: Container(
                                  height: 4,
                                  color: isFilled ? Colors.black : Colors.grey[300],
                                ),
                              );
                            }),
                          ),
                        ),

                        // Dots centered in each column
                        for (int i = 0; i < stepCount; i++)
                          Positioned(
                            left: columnWidth * i + columnWidth / 2 - dotDiameter / 2,
                            top: 6,
                            child: Container(
                              width: dotDiameter,
                              height: dotDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i <= currentStep ? Colors.black : Colors.grey[300],
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Icon row
              Row(
                children: List.generate(labels.length, (index) {
                  bool isCompleted = index < currentStep;
                  bool isCurrent = index == currentStep;
                  Color iconColor = isCompleted || isCurrent ? Colors.black : Colors.grey;

                  return Expanded(
                    child: Center(
                      child: Icon(icons[index], color: iconColor, size: iconSize),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // Label row
              Row(
                children: List.generate(labels.length, (index) {
                  bool isCurrent = index == currentStep;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.black : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                }),
              ),

            ],
          ),
        );
      },
    );
  }
}
