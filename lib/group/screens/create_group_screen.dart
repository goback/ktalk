import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/friend/providers/friend_provider.dart';
import 'package:ktalk/group/providers/group_provider.dart';
import 'package:ktalk/group/screens/group_screen.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group-screen';

  const CreateGroupScreen({super.key});

  @override
  ConsumerState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController textEditingController = TextEditingController();
  List<Contact> selectedFriendList = [];
  File? image;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  _selectFriend({
    required Contact contact,
    required int index,
  }) {
    if (index != -1) {
      selectedFriendList.removeAt(index);
    } else {
      selectedFriendList.add(contact);
    }
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

  Widget _friendListWidget() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withOpacity(0.7),
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        child: ref.watch(getFriendListProvider).when(
          data: (data) {
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final contact = data[index];
                final selectedFriendIndex = selectedFriendList.indexOf(contact);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectFriend(
                        contact: contact,
                        index: selectedFriendIndex,
                      );
                    });
                  },
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: contact.photo == null
                              ? const ExtendedAssetImageProvider(
                                  'assets/images/profile.png')
                              : ExtendedMemoryImageProvider(contact.photo!)
                                  as ImageProvider,
                          radius: 25,
                        ),
                        Opacity(
                          opacity: selectedFriendIndex != -1 ? 0.5 : 0,
                          child: const CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: 25,
                            child: Icon(
                              Icons.done,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          error: (err, stack) {
            logger.e(err);
            logger.e(stack);
            context.loaderOverlay.hide();
            GlobalNavigator.showAlertDialog(text: err.toString());
            return null;
          },
          loading: () {
            context.loaderOverlay.show();
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = selectedFriendList.length >= 2 &&
        textEditingController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.createGroupScreenText1),
      ),
      body: Center(
        child: Column(
          children: [
            _profileWidget(),
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: S.current.createGroupScreenText2,
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            _friendListWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isEnabled
            ? () {
                try {
                  ref.read(groupProvider.notifier).createGroup(
                        groupName: textEditingController.text.trim(),
                        groupImage: image,
                        selectedFriendList: selectedFriendList,
                      );

                  Navigator.pushReplacementNamed(
                    context,
                    GroupScreen.routeName,
                  );
                } catch (e, stackTrace) {
                  GlobalNavigator.showAlertDialog(text: e.toString());
                  logger.e(e);
                  logger.e(stackTrace);
                }
              }
            : null,
        backgroundColor: isEnabled ? null : Colors.grey,
        child: const Icon(Icons.done),
      ),
    );
  }
}
