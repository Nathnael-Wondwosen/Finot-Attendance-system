import 'package:flutter/material.dart';
import 'theme.dart';
import 'responsive_layout.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.isOutlined = false,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    if (isOutlined) {
      button = OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: style,
      );
    } else {
      button = ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: style,
      );
    }
    
    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    
    return button;
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final ShapeBorder? shape;
  final bool isResponsive;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.onTap,
    this.shape,
    this.isResponsive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets effectivePadding = padding ??
        (isResponsive
            ? EdgeInsets.symmetric(
                horizontal: ScreenSize.isSmallScreen(context) ? 12.0 : 16.0,
                vertical: ScreenSize.isSmallScreen(context) ? 12.0 : 16.0,
              )
            : const EdgeInsets.all(16.0));
    
    return Card(
      color: color,
      elevation: elevation ?? 2,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final EdgeInsets padding;
  final double? fontSize;

  const StatusChip({
    Key? key,
    required this.text,
    required this.color,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 12,
        ),
      ),
    );
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1100) {
      return desktop;
    } else if (screenWidth >= 650) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}