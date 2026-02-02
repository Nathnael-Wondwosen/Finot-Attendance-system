import 'package:flutter/material.dart';
import 'theme.dart';
import 'typography.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final ShapeBorder? shape;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.elevation,
    this.onTap,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? AppTheme.surfaceCard,
      elevation: elevation ?? 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            side: BorderSide(color: AppTheme.neutralLight, width: 0.6),
          ),
      clipBehavior: Clip.hardEdge,
      child: Padding(padding: padding, child: child),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            elevation: 2,
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing + 4,
              vertical: AppTheme.spacingSm + 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shadowColor: AppTheme.primaryColor.withOpacity(0.25),
          ),
      child: isLoading
          ? Semantics(
              label: 'Loading $text',
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  semanticsLabel: text,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
    );

    // Gradient wrapper for premium look
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor.withOpacity(0.92),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg + 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: btn,
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final IconData? icon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style:
          style ??
          ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppTheme.primaryColor),
            side: WidgetStateProperty.all(
              BorderSide(color: AppTheme.primaryColor.withOpacity(0.7)),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(
                horizontal: AppTheme.spacing + 2,
                vertical: AppTheme.spacingSm + 2,
              ),
            ),
          ),
      child:
          isLoading
              ? Semantics(
                label: 'Loading $text',
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Semantics(
                      label: icon != null ? '$text button with icon' : text,
                      child: Icon(icon, size: 18, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(color: AppTheme.primaryColor),
                    semanticsLabel: text,
                  ),
                ],
              ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomInputField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textColorPrimary,
            fontWeight: FontWeight.w500,
          ),
          semanticsLabel: label,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: BorderSide(color: AppTheme.neutralDark, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: BorderSide(color: AppTheme.neutralDark, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const CustomListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.neutralLight, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: leading,
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textColorPrimary,
          ),
          semanticsLabel: title,
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textColorSecondary,
                  ),
                  semanticsLabel: subtitle,
                )
                : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.textColorPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
              : leading,
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppTheme.textColorPrimary,
        ),
      ),
      actions: actions,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Soft gradient background with subtle blobs for depth
class SoftGradientBackground extends StatelessWidget {
  final Widget child;
  final bool enableBlobs;

  const SoftGradientBackground({
    super.key,
    required this.child,
    this.enableBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withOpacity(0.10),
                surface,
                primary.withOpacity(0.06),
              ],
            ),
          ),
        ),
        if (enableBlobs) ...[
          Positioned(
            top: -60,
            right: -40,
            child: _Blob(color: primary.withOpacity(0.08), size: 180),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: _Blob(color: primary.withOpacity(0.06), size: 200),
          ),
        ],
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

// Minimalist Chip component
class CustomChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const CustomChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.neutralLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neutralDark, width: 0.5),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor ?? AppTheme.textColorSecondary,
          ),
          semanticsLabel: label,
        ),
      ),
    );
  }
}

// Minimalist Divider
class CustomDivider extends StatelessWidget {
  final double height;
  final Color color;

  const CustomDivider({
    super.key,
    this.height = 0.5,
    this.color = AppTheme.neutralMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(height: height, thickness: height, color: color);
  }
}
