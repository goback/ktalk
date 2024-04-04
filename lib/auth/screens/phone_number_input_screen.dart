import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneNumberInputScreen extends ConsumerStatefulWidget {
  const PhoneNumberInputScreen({super.key});

  @override
  ConsumerState<PhoneNumberInputScreen> createState() =>
      _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState
    extends ConsumerState<PhoneNumberInputScreen> {
  final countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전화번호를 입력해주세요'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'K톡에서 당신의 계정을 인증합니다.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 250,
              child: TextFormField(
                controller: countryController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: () => showCountryPicker(
                  context: context,
                  onSelect: (Country country) {
                    countryController.text = country.name;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
