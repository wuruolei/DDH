import 'package:flutter/material.dart';
import '../../utils/color_scheme_manager.dart';

/// 客服二维码视图 - 精确对照iOS项目的CustomerServiceQRView
class CustomerServiceQRView extends StatelessWidget {
  const CustomerServiceQRView({super.key});

  @override
  Widget build(BuildContext context) {
    // final brightness = Theme.of(context).brightness; // 暂时注释掉未使用的变量
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BackgroundColors.adaptive(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // 标题
          Text(
            '客服二维码',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(context),
            ),
          ),
          const SizedBox(height: 20),
          
          // 二维码区域
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '客服二维码',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 说明文字
          Text(
            '扫描二维码添加客服微信',
            style: TextStyle(
              fontSize: 16,
              color: TextColors.adaptiveSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          
          // 关闭按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('关闭'),
            ),
          ),
        ],
      ),
    );
  }
}
