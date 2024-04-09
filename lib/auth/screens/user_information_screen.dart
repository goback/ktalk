import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 정보'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text('이름과 프로필 사진을 입력해 주세요'),
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
                    decoration: const InputDecoration(
                      hintText: '이름을 입력해주세요',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이름을 입력해주세요';
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
              text: '다음',
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final form = globalKey.currentState;

                if (form == null || !form.validate()) {
                  return;
                }

                await _saveUserData();
              },
            ),
          ),
        ],
      ),
    );
  }
}
