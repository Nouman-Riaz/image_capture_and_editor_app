import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_capture/widgets/filters.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../model/filter.dart';
import '../widgets/image_provider.dart';

class FilterScreen extends StatefulWidget {
  final File? currentImage;
  const FilterScreen({Key? key, required this.currentImage}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Filter currentFilter;
  late List<Filter> filters;
  ScreenshotController screenshotController = ScreenshotController();
  late PicProvider imageProvider;

  @override
  void initState() {
    filters = Filters().filterList();
    currentFilter = filters[0];
    super.initState();
    imageProvider = Provider.of<PicProvider>(context,listen:false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Filters'),
          centerTitle: true,
          backgroundColor: Colors.orange,
          leading: CloseButton(),
          actions: [
            IconButton(
                onPressed: () async {
                  Uint8List? bytes = await screenshotController.capture();
                      imageProvider.changeImage(File.fromRawPath(bytes!));
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.done_outlined)),
          ],
        ),
        body: Center(
          child: Consumer<PicProvider>(
            builder: (BuildContext context, value, Widget? child) {
              return Screenshot(
                controller: screenshotController,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(currentFilter.matrix),
                  child: Image.file(widget.currentImage!),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 100,
          color: Colors.black,
          child: SafeArea(child: Consumer<PicProvider>(
              builder: (BuildContext context, value, Widget? child) {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (BuildContext context, int index) {
                  Filter filter = filters[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  currentFilter = filter;
                                });
                              },
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix(filter.matrix),
                                child: Image.file(widget.currentImage!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(filter.filterName,
                            style: const TextStyle(
                              color: Colors.white,
                            ))
                      ],
                    ),
                  );
                });
          })),
        ));
  }
}
