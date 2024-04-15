import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/logger.dart';

class OTPScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';

  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('전화번호 인증 중'),
        ),
        body: Center(
          child: Column(
            children: [
              const Text('인증 번호를 전송했습니다'),
              Container(
                width: 240,
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Colors.green),
                )),
                child: OtpTextField(
                  margin: EdgeInsets.zero,
                  numberOfFields: 6,
                  fieldWidth: 35,
                  textStyle: const TextStyle(fontSize: 20),
                  hasCustomInputDecoration: true,
                  decoration: const InputDecoration(
                    hintText: '-',
                    counterText: '',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSubmit: (value) async {
                    try {
                      await ref
                          .read(authProvider.notifier)
                          .verifyOTP(userOTP: value);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } catch (e, stackTrace) {
                      GlobalNavigator.showAlertDialog(text: e.toString());
                      logger.d(stackTrace);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
