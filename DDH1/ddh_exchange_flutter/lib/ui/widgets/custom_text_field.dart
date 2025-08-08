import 'package:flutter/material.dart';
import '../../utils/color_scheme_manager.dart';

/// 自定义文本输入框组件
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.borderRadius = 8.0,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultBorderColor = widget.borderColor ?? 
        (isDark ? Colors.grey[600] : Colors.grey[300]);
    final defaultBackgroundColor = widget.backgroundColor ?? 
        (isDark ? BackgroundColors.darkSecondary : BackgroundColors.primary);
    final defaultTextColor = widget.textColor ?? 
        (isDark ? TextColors.white : TextColors.primary);
    final defaultLabelColor = widget.labelColor ?? 
        (isDark ? TextColors.white : TextColors.primary);
    final defaultHintColor = widget.hintColor ?? 
        (isDark ? TextColors.tertiary : TextColors.secondary);

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: TextStyle(
        color: defaultTextColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: defaultHintColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
        contentPadding: widget.contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: defaultBorderColor!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: BrandColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: BrandColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: BrandColors.error, width: 2),
        ),
        filled: true,
        fillColor: defaultBackgroundColor,
        labelStyle: TextStyle(color: defaultLabelColor),
        hintStyle: TextStyle(color: defaultHintColor),
        errorStyle: TextStyle(color: BrandColors.error),
      ),
    );
  }
}

/// 搜索输入框
class SearchTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: hintText ?? '搜索...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      borderRadius: 24.0,
    );
  }
}

/// 多行文本输入框
class CustomTextArea extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool enabled;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double? height;

  const CustomTextArea({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.enabled = true,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: labelText,
      hintText: hintText,
      initialValue: initialValue,
      controller: controller,
      enabled: enabled,
      maxLines: null,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.all(16),
      borderRadius: 12.0,
    );
  }
}
