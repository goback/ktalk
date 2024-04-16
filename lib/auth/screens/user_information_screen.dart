import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/common/widgets/custom_button_widget.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final globalKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Widget _profileWidget() {
    return image == null
        ? GestureDetector(
            onTap: _selectImage,
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.7),
              radius: 60,
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.black,
                size: 30,
              ),
            ),
          )
        : GestureDetector(
            onTap: _selectImage,
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: FileImage(image!),
                  radius: 60,
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    onPressed: () => setState(() {
                      image = null;
                    }),
                    icon: const Icon(Icons.remove_circle),
                  ),
                ),
              ],
            ),
          );
  }

  _selectImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    final name = nameController.text.trim();
    await ref.watch(authProvider.notifier).saveUserData(
          name: name,
          profileImage: image,
        );

    ref.invalidate(authStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.userInformationScreenText1),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(S.current.userInformationScreenText2),
          const SizedBox(height: 30),
          _profileWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                width: 300,
                child: Form(
                  key: globalKey,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: S.current.userInformationScreenText3,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return S.current.userInformationScreenText3;
                      }
                      return null;
                    },
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButtonWidget(
              text: S.current.next,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final form = globalKey.currentState;

                if (form == null || !form.validate()) {
                  return;
                }

                try {
                  await _saveUserData();
                } catch (e, stackTrace) {
                  GlobalNavigator.showAlertDialog(text: e.toString());
                  logger.d(stackTrace);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
