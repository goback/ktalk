import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  File? image;

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
        ],
      ),
    );
  }
}
