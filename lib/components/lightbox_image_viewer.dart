import 'dart:typed_data';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/record_attendance_page/attendance_helper.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class LightBoxImageViewer extends StatefulWidget {
  final Uint8List imageBytes;
  final List<StudentFace> faceBoxes;
  final double imageOriginalWidth;
  final double imageOriginalHeight;
  final bool showFaceLabels;

  const LightBoxImageViewer({
    super.key,
    required this.imageBytes,
    required this.faceBoxes,
    required this.imageOriginalWidth,
    required this.imageOriginalHeight,
    this.showFaceLabels = true,
  });

  @override
  State<LightBoxImageViewer> createState() => _LightBoxImageViewerState();
}

class _LightBoxImageViewerState extends State<LightBoxImageViewer> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  void _zoomIn() {
    _applyZoom(1.2);
  }

  void _zoomOut() {
    _applyZoom(0.8);
  }

  void _resetView() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }


  void _applyZoom(double scaleFactor) {
    final matrix = _transformationController.value;

    // Current scale
    final currentScale = matrix.getMaxScaleOnAxis();

    // Clamp between min and max
    final newScale = (currentScale * scaleFactor).clamp(0.5, 5.0);

    // Calculate center of the viewer
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final center = size.center(Offset.zero);

    // Translate to center → scale → translate back
    final Matrix4 zoomed = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(newScale / currentScale)
      ..translate(-center.dx, -center.dy)
      ..multiply(matrix);

    setState(() {
      _transformationController.value = zoomed;
    });
  }

  // Draws the image and detected faces, labels them, and allows image download
  void drawAndDownloadImageWithBoxes({
    required Uint8List imageBytes,
    required List<Map<String, dynamic>> faceBoxes,
    required double originalWidth,
    required double originalHeight,
  })
  {
    final image = html.ImageElement();
    final canvas = html.CanvasElement(width: originalWidth.toInt(), height: originalHeight.toInt());
    final ctx = canvas.context2D;
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    image.src = url;

    image.onLoad.listen((_) {
      ctx.drawImage(image, 0, 0);
      for (final face in faceBoxes) {
        final x = face['x'] as num;
        final y = face['y'] as num;
        final w = face['width'] as num;
        final h = face['height'] as num;
        final label = face['label'] as String;
        final isAuth = face['isAuth'] as bool;
        final borderColor = isAuth ? 'lime' : 'red';
        final labelData = isAuth ? label : 'UnAuthorized';

        // Draw border
        ctx
          ..lineWidth = 2
          ..strokeStyle = borderColor
          ..beginPath()
          ..moveTo(x + 4, y)
          ..lineTo(x + w - 4, y)
          ..quadraticCurveTo(x + w, y, x + w, y + 4)
          ..lineTo(x + w, y + h - 4)
          ..quadraticCurveTo(x + w, y + h, x + w - 4, y + h)
          ..lineTo(x + 4, y + h)
          ..quadraticCurveTo(x, y + h, x, y + h - 4)
          ..lineTo(x, y + 4)
          ..quadraticCurveTo(x, y, x + 4, y)
          ..closePath()
          ..stroke();

        // Draw label box
        ctx
          ..fillStyle = 'rgba(0, 0, 0, 0.7)'
          ..fillRect(x, y - 18, labelData.length * 7.5, 16);

        // Draw label text
        ctx
          ..fillStyle = 'white'
          ..font = '12px sans-serif'
          ..fillText(labelData, x.toDouble() + 4, y.toDouble() - 6);
      }

      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : now.hour;
      final period = now.hour >= 12 ? 'pm' : 'am';
      final timestamp = 'FaceMark_${now.year}-${now.month}-${now.day}_$hour:${now.minute}:${now.second}_$period.png';

      final dataUrl = canvas.toDataUrl("image/png");
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute("download", timestamp)
        ..click();
      html.Url.revokeObjectUrl(url);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Removes the default border radius
      ),
      backgroundColor: Colors.black.withOpacity(0.6),
      insetPadding: EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.all(25.0),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final containerWidth = constraints.maxWidth;
                  final containerHeight = constraints.maxHeight;

                  final imageAspectRatio = widget.imageOriginalWidth / widget.imageOriginalHeight;
                  final containerAspectRatio = containerWidth / containerHeight;

                  double displayWidth;
                  double displayHeight;
                  double offsetX = 0;
                  double offsetY = 0;

                  if (containerAspectRatio > imageAspectRatio) {
                    // Fit height
                    displayHeight = containerHeight;
                    displayWidth = widget.imageOriginalWidth * displayHeight / widget.imageOriginalHeight;
                    offsetX = (containerWidth - displayWidth) / 2;
                  } else {
                    // Fit width
                    displayWidth = containerWidth;
                    displayHeight = widget.imageOriginalHeight * displayWidth / widget.imageOriginalWidth;
                    offsetY = (containerHeight - displayHeight) / 2;
                  }

                  final scaleX = displayWidth / widget.imageOriginalWidth;
                  final scaleY = displayHeight / widget.imageOriginalHeight;

                  return InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 5,
                    child: Stack(
                      children: [
                        Positioned(
                          left: offsetX,
                          top: offsetY,
                          width: displayWidth,
                          height: displayHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              widget.imageBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        ...widget.faceBoxes.map((face) {
                          return Positioned(
                            left: offsetX + (face.x * scaleX) - 2,
                            top: offsetY + (face.y * scaleY) - 2,
                            width: (face.width * scaleX) + 4,
                            height: (face.height * scaleY) + 4,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (widget.showFaceLabels)
                                  Positioned(
                                    top: face.isAuth ? -32 : -15,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        face.isAuth ?
                                        face.label:
                                        "UnAuthorized",
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    border:  Border.all(color: face.isAuth? Colors.greenAccent : Colors.redAccent, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    _buildCircleIcon(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 30),
                    _buildCircleIcon(
                      icon: Icons.zoom_out_map,
                      onTap: _resetView,
                    ),
                    const SizedBox(height: 10),
                    _buildCircleIcon(
                      icon: Icons.zoom_in,
                      onTap: _zoomIn,
                    ),
                    const SizedBox(height: 10),
                    _buildCircleIcon(
                      icon: Icons.zoom_out,
                      onTap: _zoomOut,
                    ),
                    const SizedBox(height: 10),
                    _buildCircleIcon(
                      icon: Icons.download,
                      onTap:(){
                        drawAndDownloadImageWithBoxes(
                          imageBytes: widget.imageBytes,
                          faceBoxes: widget.faceBoxes.map((face) => {
                            "x": face.x,
                            "y": face.y,
                            "width": face.width,
                            "height": face.height,
                            "label": widget.showFaceLabels ? face.label : '',
                            "isAuth": face.isAuth,
                          }).toList(),
                          originalWidth: widget.imageOriginalWidth,
                          originalHeight: widget.imageOriginalHeight,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

}
