import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfy/Managers/ClothManager.dart';
import 'package:uuid/uuid.dart';

import '../Managers/types/types.dart';
import '../utils/Constants.dart';
import '../utils/theme.dart';

class AddingItem extends StatefulWidget {
  const AddingItem({super.key});

  @override
  State<AddingItem> createState() => _AddingItemState();
}

class _AddingItemState extends State<AddingItem> {
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _weatherRecomendController = TextEditingController();
  final _outfitTypeController = TextEditingController();
  final _clothManager = const ClothManager();

  File? _image;
  String _clothstype = clothstypeList.first;
  String _seasonType = seasonTypeList.first;
  String _sizeType = sizeTypeList.first;

  double _minTemp = -10;
  double _maxTemp = 6;

  Future<void> _saveClothingItem() async {
    final imagePath = await _clothManager.SaveImagePermanently(_image!);
    final clothingItem = ClothingItem(
      id: Uuid().v4(),
      name: _nameController.text,
      clothType: _clothstype,
      seasonType: _seasonType,
      outfitType: _outfitTypeController.text,
      sizeType: _sizeType,
      weatherRecommendation: _weatherRecomendController.text,
      imagePath: imagePath,
    );

    await _clothManager.SaveClothingItem(clothingItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Предмет одежды сохранен!")),
    );

    setState(() {
      _nameController.clear();
      _outfitTypeController.clear();
      _weatherRecomendController.clear();
      _image = null;
      _clothstype = clothstypeList.first;
      _seasonType = seasonTypeList.first;
      _sizeType = sizeTypeList.first;
      _minTemp = -10;
      _maxTemp = 6;
    });
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
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final file = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (file != null) {
                            setState(() {
                              _image = File(file.path);
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: (MediaQuery.sizeOf(context).width - 60) / 2,
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: Color(0xffF2F2F2),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 4),
                                    color: Color(0x1a000000),
                                    blurRadius: 4)
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                "assets/images/image-icon.png",
                                width: 30,
                              ),
                              const Text(
                                "Выбрать\nв галерее",
                                style: taddingtopbar,
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final file = await _picker.pickImage(
                              source: ImageSource.camera);
                          if (file != null) {
                            setState(() {
                              _image = File(file.path);
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: (MediaQuery.sizeOf(context).width - 60) / 2,
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: Color(0xffF2F2F2),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 4),
                                    color: Color(0x1a000000),
                                    blurRadius: 4)
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                "assets/images/camera-icon.png",
                                width: 30,
                              ),
                              const Text(
                                "Сделать\nфото",
                                style: taddingtopbar,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ));
            });
      },
      child: _image != null
          ? Container(
              width: 200,
              height: 150,
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Color(0xffF8F8F8),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 4),
                        color: Color(0x1a000000),
                        blurRadius: 4)
                  ]),
              child: Column(
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

  Widget _getParametrs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 16,
        children: [
          _buildDropdown(
            label: "Тип одежды",
            value: _clothstype,
            items: clothstypeList,
            onChanged: (value) => setState(() => _clothstype = value!),
          ),
          _buildDropdown(
            label: "Сезон",
            value: _seasonType,
            items: seasonTypeList,
            onChanged: (value) => setState(() => _seasonType = value!),
          ),
          _buildOutfitTypeSelector(),
          _buildDropdown(
            label: "Размер",
            value: _sizeType,
            items: sizeTypeList,
            onChanged: (value) => setState(() => _sizeType = value!),
          ),
          _buildWeatherSelector(),
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
              onTap: () async {
                if (_image == null ||
                    _clothstype == clothstypeList.first ||
                    _outfitTypeController.text.isEmpty ||
                    _nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text("Заполните все поля")));
                  return;
                }
                await _saveClothingItem();
                Navigator.of(context).pop();
              },
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
