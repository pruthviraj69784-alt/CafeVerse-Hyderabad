import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFF452B19);
    final fg = foregroundColor ?? Colors.white;

    if (useGradient && backgroundColor == null) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6F4E37), Color(0xFF3B2010)],
                ),
          color: isLoading ? const Color(0xFFBCAAA4) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF452B19).withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withAlpha(30),
            child: Center(
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(fg),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Please wait...',
                          style: TextStyle(
                            color: fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // Fallback — plain ElevatedButton
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: isLoading
            ? const Text('Loading...')
            : Text(
                label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
