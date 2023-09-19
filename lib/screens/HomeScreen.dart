import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:image_capture/screens/filter_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_capture/widgets/image_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../utils/utils.dart';
import 'package:share/share.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  late PicProvider imageProvider;
  final imagePicker = ImagePicker();
  Future<void> _shareImage() async {
    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File('${tempDir.path}/temp.png').create();
      await tempFile.writeAsBytes(bytes);

      await Share.shareFiles([tempFile.path], text: 'Check out this image:');
    } else {
      Utils().toastMessage('Please capture the image');
    }
  }
  Future getImage() async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    imageProvider.changeImage(File(image!.path));
    if (image != null) {
      setState(() {
        _image = imageProvider.getCurrentImage!;
      });

    }
  }
  Future<void> _saveImageToGallery() async {
    if (_image != null) {
      final result = await ImageGallerySaver.saveFile(_image!.path);
      Utils().toastMessage('Successfully saved to gallery');
    }else{
      Utils().toastMessage('Please capture the image');
    }
  }
@override
  void initState() {
    super.initState();
    imageProvider = Provider.of<PicProvider>(context,listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.grey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Center(
                child: _image != null
                    ? Column(
                  children: [
                    Image.file(_image!),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () async {
                              CroppedFile? croppedFile =
                              await ImageCropper().cropImage(
                                sourcePath: _image!.path,
                                aspectRatioPresets: [
                                  CropAspectRatioPreset.square,
                                  CropAspectRatioPreset.ratio3x2,
                                  CropAspectRatioPreset.original,
                                  CropAspectRatioPreset.ratio4x3,
                                  CropAspectRatioPreset.ratio16x9
                                ],
                                uiSettings: [
                                  AndroidUiSettings(
                                      toolbarTitle: 'Cropper',
                                      toolbarColor: Colors.deepOrange,
                                      toolbarWidgetColor: Colors.white,
                                      initAspectRatio:
                                      CropAspectRatioPreset.original,
                                      lockAspectRatio: false),
                                  IOSUiSettings(
                                    title: 'Cropper',
                                  ),
                                  WebUiSettings(
                                    context: context,
                                  ),
                                ],
                              );
                              setState(() {
                                _image = File(croppedFile!.path);
                              });
                            },

                            icon: const Icon(Icons.crop_rotate_outlined,color: Colors.white,)),
                        const SizedBox(
                          width: 30,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FilterScreen(currentImage: _image,)));
                            },
                            icon: const Icon(Icons.filter_vintage_outlined,color: Colors.white)),
                      ],
                    ),
                  ],
                )
                    : const Text('No Image Captured')),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 150,
            child: ElevatedButton(
              onPressed: _saveImageToGallery,
              child: const Row(
                children: [
                  Icon(Icons.save_alt_outlined),
                  SizedBox(width: 12),
                  Center(child: Text('save')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 1),
          //Divider(color: Colors.black,thickness: 1.0,),
          const SizedBox(height: 1),
          Container(
            width: 150,
            child: ElevatedButton(
              onPressed: _shareImage,
              child: const Row(
                children: [
                  Icon(Icons.share_outlined),
                  SizedBox(width: 12),
                  Center(child: Text('share')),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }
}