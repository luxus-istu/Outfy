import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:outfy/Managers/ClothManager.dart';
import 'package:path_provider/path_provider.dart';

import '../Managers/types/types.dart';
import '../utils/Constants.dart';
import '../utils/theme.dart';

class Outfits extends StatefulWidget {
  const Outfits({super.key});

  @override
  State<Outfits> createState() => _OutfitsState();
}

class _OutfitsState extends State<Outfits> {
  final _clothManager = const ClothManager();
  final _nameController = TextEditingController();
  final _weatherRecomendController = TextEditingController();
  final _outfitTypeController = TextEditingController();

  String _seasonType = seasonTypeList.first;

  File? _image;
  double _minTemp = -10;
  double _maxTemp = 6;
  List<ClothingItem> _selectedClothes = [];

  Future<void> _saveOutfit() async {
    if (_image == null ||
        _outfitTypeController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _selectedClothes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Заполните все поля")));
      return;
    }

    final newOutfit = Outfit(
      name: _nameController.text,
      itemIds: _selectedClothes.map((e) => e.id).toList(),
      imagePath: _image!.path,
      outfitType: _outfitTypeController.text,
      seasonType: _seasonType,
      weatherRecommendation: _weatherRecomendController.text,
    );

    await _clothManager.SaveOutfit(newOutfit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Предмет одежды сохранен!")),
    );

    Navigator.of(context).pop();
  }

  Future<File?> _generateOutfitImage() async {
    if (_selectedClothes.isEmpty) return null;

    const double width = 640.0;
    const double height = 480.0;
    const double bottomPadding = 6.0;
    const int itemsPerRow = 3;
    const int maxItems = 6;

    final double cellWidth = width / itemsPerRow;
    final double maxImageHeight = height / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    final itemsToDisplay = _selectedClothes.take(maxItems).toList();

    try {
      for (int i = 0; i < itemsToDisplay.length; i++) {
        final item = itemsToDisplay[i];

        final ui.Image image = await _loadUiImage(item.imagePath);
        final imgWidth = image.width.toDouble();
        final imgHeight = image.height.toDouble();
        final aspectRatio = imgWidth / imgHeight;

        double drawHeight = cellWidth / aspectRatio;
        if (drawHeight > maxImageHeight) drawHeight = maxImageHeight;
        final double drawWidth = drawHeight * aspectRatio;

        final int row = i ~/ itemsPerRow;
        final int col = i % itemsPerRow;

        final double offsetX = col * cellWidth + (cellWidth - drawWidth) / 2;
        final double cellHeight = drawHeight + bottomPadding;
        final double offsetY = row * cellHeight + (cellHeight - drawHeight) / 2;

        final Rect cropRect = _centerCropRect(
          imgWidth,
          imgHeight,
          drawWidth,
          drawHeight,
          cellWidth,
          maxImageHeight,
        );

        final dstRect = Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight);
        canvas.drawImageRect(image, cropRect, dstRect, Paint());
        image.dispose();
      }

      final picture = recorder.endRecording();
      final ui.Image finalImage =
          await picture.toImage(width.toInt(), height.toInt());
      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/outfit_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(buffer);

      return tempFile;
    } catch (e) {
      print('Error generating outfit image: $e');
      return null;
    }
  }

  Future<ui.Image> _loadUiImage(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Rect _centerCropRect(
    double imgWidth,
    double imgHeight,
    double drawWidth,
    double drawHeight,
    double cellWidth,
    double maxImageHeight,
  ) {
    return Rect.fromLTWH(
      (imgWidth - imgWidth * (drawWidth / cellWidth)) / 2,
      (imgHeight - imgHeight * (drawHeight / maxImageHeight)) / 2,
      imgWidth * (drawWidth / cellWidth),
      imgHeight * (drawHeight / maxImageHeight),
    );
  }

  void _showWeatherDialog() {
    RangeValues tempRange = RangeValues(_minTemp, _maxTemp);

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
                title: const Text("Выберите диапазон температуры"),
                backgroundColor: const Color(0xffF8F8F8),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minTemp = tempRange.start;
                        _maxTemp = tempRange.end;
                        _weatherRecomendController.text =
                            "${_minTemp.round()}° / ${_maxTemp.round()}°";
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "ОК",
                      style: twardrobetext,
                    ),
                  ),
                ],
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${tempRange.start.round()}° / ${tempRange.end.round()}°",
                        style: twardrobedatetext,
                      ),
                      RangeSlider(
                        values: tempRange,
                        min: -30,
                        max: 40,
                        divisions: 70,
                        activeColor: const Color(0xff101010),
                        onChanged: (values) {
                          setStateDialog(() {
                            tempRange = values;
                          });
                        },
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  void _showOutfitTypeDialog() {
    final _outfitDialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
              title: const Text("Введите тип образа"),
              backgroundColor: const Color(0xffF8F8F8),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _outfitTypeController.text = _outfitDialogController.text;
                    });
                    _outfitDialogController.dispose();
                    Navigator.pop(context);
                    print(_outfitTypeController.text);
                  },
                  child: const Text("ОК", style: twardrobetext),
                ),
              ],
              content: Container(
                child: FutureBuilder<List<String>>(
                  future: _clothManager.GetExistingOutfitTypes(),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final options = snapshot.data!;
                    return Autocomplete<String>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return [
                          ...options.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          }),
                          textEditingValue.text
                        ];
                      },
                      onSelected: (selection) {
                        _outfitDialogController.text = selection;
                        print(_outfitDialogController.text);
                      },
                      optionsViewBuilder: (ltext, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 100, maxWidth: 232),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(option),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      fieldViewBuilder: (_, textEditingController, focusNode,
                          onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onTap: onFieldSubmitted,
                          style: twardrobedatetext,
                          decoration: const InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)))),
                        );
                      },
                    );
                  },
                ),
              ));
        });
      },
    );
  }

  Widget _getImage() {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color(0xffF8F8F8),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 4), color: Color(0x1a000000), blurRadius: 4)
          ]),
      child: _image != null
          ? Image.file(
              _image!,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
            )
          : Container(
              width: 200,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Image.asset(
                    "assets/images/image-icon.png",
                    width: 40,
                  ),
                  const Text(
                    "Выбрать\nфотографию",
                    style: twardrobetext,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: taddingfieldname,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          underline: const SizedBox(),
          style: twardrobedatetext,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Image.asset(
              "assets/images/arrow-right-icon.png",
              width: 5,
            ),
          ),
          value: value,
          onChanged: onChanged,
          items: items
              .map<DropdownMenuItem<String>>(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWeatherSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Погода",
            style: taddingfieldname,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _showWeatherDialog,
          child: Row(
            children: [
              Text(
                _weatherRecomendController.text.isEmpty
                    ? "Выбрать диапазон"
                    : _weatherRecomendController.text,
                style: twardrobedatetext,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  "assets/images/arrow-right-icon.png",
                  width: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Тип образа",
            style: taddingfieldname,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _showOutfitTypeDialog,
          child: Row(
            children: [
              Text(
                _outfitTypeController.text.isEmpty
                    ? "Выбрать тип"
                    : _outfitTypeController.text,
                style: twardrobedatetext,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  "assets/images/arrow-right-icon.png",
                  width: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClothingSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Выберите одежду"),
              backgroundColor: const Color(0xffF8F8F8),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: FutureBuilder<List<ClothingItem>>(
                  future: _clothManager.LoadClothingItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка загрузки: ${snapshot.error}',
                          style: twardrobedatetext,
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Нет доступной одежды',
                            style: twardrobedatetext),
                      );
                    }

                    final availableClothes = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableClothes.length,
                      itemBuilder: (context, index) {
                        final item = availableClothes[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.file(
                              File(item.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(item.name, style: twardrobedatetext),
                          subtitle: Text(item.clothType,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () async {
                            setStateDialog(() {
                              _selectedClothes.add(item);
                            });
                            final newImage = await _generateOutfitImage();
                            setState(() {
                              _image = newImage;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ОК", style: twardrobetext),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getParametrs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 16,
        children: [
          _buildDropdown(
            label: "Сезон",
            value: _seasonType,
            items: seasonTypeList,
            onChanged: (value) => setState(() => _seasonType = value!),
          ),
          _buildOutfitTypeSelector(),
          _buildWeatherSelector(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Одежда в образе",
                style: taddingfieldname,
              ),
              SizedBox(height: 8),
              GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _selectedClothes.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _showClothingSelectionDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffF8F8F8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 4),
                                color: Color(0x1a000000),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add,
                                  size: 30, color: Color(0xff101010)),
                              SizedBox(height: 4),
                              Text(
                                "Добавить",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xff101010)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final item = _selectedClothes[index - 1];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 4),
                            color: Color(0x1a000000),
                            blurRadius: 4,
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(File(item.imagePath)),
                          fit: BoxFit.cover,
                        ),
                        color: const Color(0xffF8F8F8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withValues(alpha: .3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _selectedClothes.removeAt(index - 1);
                                    final newImage =
                                        await _generateOutfitImage();
                                    setState(() {
                                      _image = newImage;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2,
                                          color: Colors.black,
                                          offset: Offset(0.5, 0.5),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.clothType,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2,
                                          color: Colors.black,
                                          offset: Offset(0.5, 0.5),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 26,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width / 5,
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xffc5c5c5), width: 2))),
            ),
            _getImage(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                        color: Color(0xffF8F8F8),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 4),
                              color: Color(0x1a000000),
                              blurRadius: 4)
                        ]),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Название",
                          border: InputBorder.none,
                          hintStyle: twardrobedatetext),
                    ),
                  ),
                ],
              ),
            ),
            _getParametrs(),
            GestureDetector(
              onTap: () async => await _saveOutfit(),
              child: Container(
                decoration: const BoxDecoration(
                    color: Color(0xffF2F2F2),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                child: const Text(
                  "Сохранить",
                  style: twardrobetext,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _outfitTypeController.dispose();
    _weatherRecomendController.dispose();
    super.dispose();
  }
}
