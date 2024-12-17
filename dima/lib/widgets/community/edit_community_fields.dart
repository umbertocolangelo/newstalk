import 'dart:async';
import 'dart:io';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/services/image_service.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/location_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateCommunityFields extends StatefulWidget {
  final String communityId;
  final String name;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final List<String> selectedCategories;
  String? profileImagePath;
  String? backgroundImagePath;
  LatLng position;
  final void Function(List<String>, String, LatLng position, String, String)
      onSubmit;

  CreateCommunityFields({
    Key? key,
    required this.communityId,
    required this.name,
    required this.nameController,
    required this.bioController,
    required this.selectedCategories,
    this.profileImagePath,
    this.backgroundImagePath,
    required this.position,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CreateCommunityFieldsState createState() => _CreateCommunityFieldsState();
}

class _CreateCommunityFieldsState extends State<CreateCommunityFields> {
  String nameErrorText =
      ""; // with empty string, icon will not be shown, with " ", green icon else error
  String bioErrorText = "";

  CommunityController communityController = CommunityController();
  Color nameBorderColor =
      Palette.grey; // used to signal name availability and format
  Color bioBorderColor =
      Palette.grey; // used to signal bio availability and format
  IconData nameIcon = Icons.check; // icon to show for name availability
  Timer? _debounce;

  bool _isNameValid = false;
  bool _isBioValid = false;
  bool _isCategoriesValid = false;
  bool get _isFormValid =>
      _isNameValid &&
      _isBioValid &&
      _isCategoriesValid &&
      _selectedLocation != null;
  bool _isProfileImageLoading = false;
  bool _isBackgroundImageLoading = false;

  String _type = 'private';
  final List<Map<String, String>> _categories = [
    {'emoji': '🌐', 'name': 'Attualità'},
    {'emoji': '🏅', 'name': 'Sport'},
    {'emoji': '🎬', 'name': 'Intrattenimento'},
    {'emoji': '💪', 'name': 'Salute'},
    {'emoji': '💼', 'name': 'Economia'},
    {'emoji': '💻', 'name': 'Tecnologia'}
  ];
  final List<String> _selectedCategories = [];

  LatLng? _selectedLocation;

  @override
  void dispose() {
    // Cancel timer if still active
    _debounce?.cancel();
    super.dispose();
  }

  void checkName(String name) async {
    RegExp regex = RegExp(
        r'^(?! )[a-zA-Z0-9,._\s]*(?<! )(?=.*[a-zA-Z])[a-zA-Z0-9,._\s]*$');
    if (name.isEmpty) {
      setState(() {
        nameBorderColor = Colors.red;
        nameErrorText = "Per favore inserisci un nome valido";
        nameIcon = Icons.error;
        _isNameValid = false;
      });
      return;
    }
    if (!regex.hasMatch(name)) {
      setState(() {
        nameBorderColor = Colors.red;
        nameErrorText = "Solo lettere, numeri, '.' e '_' sono ammessi";
        nameIcon = Icons.error;
        _isNameValid = false;
      });
    } else {
      if (widget.name != name) {
        bool available = !(await communityController.doesCommunityExist(name));
        setState(() {
          nameBorderColor = available ? Colors.green : Colors.red;
          nameIcon = available ? Icons.check_box_rounded : Icons.error;
          nameErrorText = available ? " " : "Username non disponibile";
          _isNameValid = available;
        });
      } else {
        setState(() {
          nameBorderColor = Colors.grey;
          nameErrorText = "";
          _isNameValid = true;
        });
      }
    }
  }

  void onNameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      checkName(value);
    });
  }

  void onBioChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _isBioValid = false;
        bioErrorText = "Per favore inserisci una bio valida";
        bioBorderColor = Colors.red;
      });
    } else {
      setState(() {
        _isBioValid = true;
        bioErrorText = "";
        bioBorderColor = Colors.grey;
      });
    }
  }

  void checkCategories() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleziona almeno una categoria')),
      );
      _isCategoriesValid = false;
    } else {
      _isCategoriesValid = true;
    }
  }

  void _selectLocation() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.8,
                child: LocationSelection(
                  onLocationSelected: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  initialLocation: widget.position,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage(String communityId) async {
    ImageService imageService = ImageService();
    File? imageFile = await imageService.pickImageFromGallery();
    if (imageFile != null) {
      String? imageUrl = await imageService.uploadImage(
          imageFile, 'community_profiles/$communityId/profile_image');
      if (imageUrl != null && mounted) {
        setState(() {
          widget.profileImagePath = imageUrl;
        });
      }
    }
  }

  Future<void> _pickBackgroundImage(String communityId) async {
    ImageService imageService = ImageService();
    File? imageFile = await imageService.pickImageFromGallery();
    if (imageFile != null) {
      String? imageUrl = await imageService.uploadImage(
          imageFile, 'community_backgrounds/$communityId/background_image');
      if (imageUrl != null && mounted) {
        setState(() {
          widget.backgroundImagePath = imageUrl;
        });
      }
    }
  }

  Future<void> _handleProfileImagePick() async {
    setState(() {
      _isProfileImageLoading = true;
    });

    await _pickProfileImage(widget.communityId);

    setState(() {
      _isProfileImageLoading = false;
    });
  }

  Future<void> _handleBackgroundImagePick() async {
    setState(() {
      _isBackgroundImageLoading = true;
    });

    await _pickBackgroundImage(widget.communityId);

    setState(() {
      _isBackgroundImageLoading = false;
    });
  }

  void _navigateToCommunityHomePage() async {
    CommunityController communityController = CommunityController();
    var community =
        await communityController.getCommunityById(widget.communityId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityHomePage(community: community),
      ),
    );
  }

  void onButtonPressed() {
    if (widget.profileImagePath == null || widget.profileImagePath!.isEmpty) {
      widget.profileImagePath =
          "https://img.freepik.com/free-photo/2d-graphic-wallpaper-with-colorful-grainy-gradients_23-2151001558.jpg?size=626&ext=jpg&ga=GA1.1.1141335507.1718409600&semt=ais_user";
    }
    if (widget.backgroundImagePath == null ||
        widget.backgroundImagePath!.isEmpty) {
      widget.backgroundImagePath =
          "https://img.freepik.com/free-photo/2d-graphic-wallpaper-with-colorful-grainy-gradients_23-2151001558.jpg?size=626&ext=jpg&ga=GA1.1.1141335507.1718409600&semt=ais_user";
    }
    widget.onSubmit(
      _selectedCategories,
      _type,
      _selectedLocation!,
      widget.profileImagePath!,
      widget.backgroundImagePath!,
    );
    //_navigateToCommunityHomePage();
  }

  @override
  void initState() {
    super.initState();
    if (widget.name.isNotEmpty) {
      // community already exists
      _selectedLocation = widget.position;
      onNameChanged(widget.nameController.text);
      onBioChanged(widget.bioController.text);
      _selectedCategories.addAll(widget.selectedCategories);
      checkCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return GestureDetector(
        onTap: () {
          // Close keyboard when clicking out of inputs
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Palette.offWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: widget.nameController,
                decoration: InputDecoration(
                  labelText: nameErrorText != "" && nameErrorText != " "
                      ? nameErrorText
                      : "Nome della Community",
                  labelStyle: TextStyle(color: nameBorderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: nameBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: nameBorderColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: nameErrorText.isNotEmpty
                      ? Tooltip(
                          message: nameErrorText,
                          child: Icon(nameIcon, color: nameBorderColor),
                        )
                      : null,
                ),
                onChanged: onNameChanged,
                onTap: () {
                  if (nameErrorText.isEmpty) {
                    setState(() {
                      nameBorderColor = Palette.grey;
                    });
                  }
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  if (nameErrorText.isEmpty) {
                    setState(() {
                      nameBorderColor = Palette.grey;
                    });
                  }
                },
              ),

              SizedBox(height: 16.sp),

              // select categories
              Text(
                'Seleziona le categorie della Community',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                children: _categories.map((category) {
                  bool isSelected =
                      _selectedCategories.contains(category['name']);
                  return ChoiceChip(
                    label: Text('${category['emoji']} ${category['name']}'),
                    selected: isSelected,
                    selectedColor: Palette.beige,
                    backgroundColor: Colors.white,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category['name']!);
                        } else {
                          _selectedCategories.remove(category['name']);
                        }
                        checkCategories();
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 16.sp),

              // bio
              TextFormField(
                controller: widget.bioController,
                decoration: InputDecoration(
                  labelText: bioErrorText != "" && bioErrorText != " "
                      ? bioErrorText
                      : "Bio",
                  labelStyle: TextStyle(color: bioBorderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: bioBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: bioBorderColor),
                  ),
                  filled:
                      true, // Aggiungi questa proprietà per abilitare il colore di sfondo
                  fillColor: Colors.white, // Colore di sfondo bianco
                ),
                maxLines: 3,
                onChanged: onBioChanged,
                onTap: () {
                  if (bioErrorText.isEmpty) {
                    setState(() {
                      bioBorderColor = Palette.grey;
                    });
                  }
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  if (bioErrorText.isEmpty) {
                    setState(() {
                      bioBorderColor = Palette.grey;
                    });
                  }
                },
              ),

              SizedBox(height: 16.sp),

              // Background Image Picker
              Text(
                'Immagine di sfondo della Community',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.sp),
              ElevatedButton.icon(
                onPressed: () => _handleBackgroundImagePick(),
                icon: Icon(Icons.photo),
                label: Text('Seleziona Immagine di Sfondo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.beige,
                  foregroundColor: Palette.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 16.sp, horizontal: 24.sp),
                ),
              ),
              if (widget.backgroundImagePath != null &&
                  widget.backgroundImagePath!.isNotEmpty)
                Padding(
                  padding:  EdgeInsets.only(top: 16.sp),
                  child: _isBackgroundImageLoading
                      ? Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8.sp),
                              Text(
                                'Caricamento dell\'immagine di sfondo in corso, per favore attendere...',
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 150.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: NetworkImage(widget.backgroundImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),

              SizedBox(height: 16.sp),

              // Profile Image Picker
              Text(
                'Immagine di profilo della Community',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.sp),
              ElevatedButton.icon(
                onPressed: () => _handleProfileImagePick(),
                icon: Icon(Icons.photo),
                label: Text('Seleziona Immagine Profilo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.beige,
                  foregroundColor: Palette.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 16.sp, horizontal: 24.sp),
                ),
              ),
              if (widget.profileImagePath != null &&
                  widget.profileImagePath!.isNotEmpty)
                Padding(
                  padding:  EdgeInsets.only(top: 16.sp),
                  child: _isProfileImageLoading
                      ? Center(
                          child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8.sp),
                            Text(
                              'Caricamento dell\'immagine del profilo in corso, per favore attendere...',
                            ),
                          ],
                        ))
                      : Container(
                          height: 150.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: NetworkImage(widget.profileImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),

              SizedBox(height: 16.sp),

              // Location Picker
              Text(
                'Posizione della Community',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.sp),
              ElevatedButton.icon(
                onPressed: () {
                  _selectLocation();
                },
                icon: Icon(Icons.location_on),
                label: Text('Seleziona Posizione'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedLocation == null
                      ? Palette.beige
                      : Colors.green[500],
                  foregroundColor: Palette.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 16.sp, horizontal: 24.sp),
                ),
              ),
              SizedBox(height: 8.sp),
              if (_selectedLocation != null)
                Text(
                  'Posizione selezionata correttamente: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                  style: TextStyle(fontSize: 14.sp),
                ),

              SizedBox(height: 16.sp),

              // private/public
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: [
                  {'emoji': '🌍', 'value': 'public'},
                  {'emoji': '🔒', 'value': 'private'},
                ].map((Map<String, String> item) {
                  return DropdownMenuItem<String>(
                    value: item['value'],
                    child: Text('${item['emoji']} ${item['value']}'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _type = newValue!;
                  });
                },
              ),

              // Confirm button
              SizedBox(height: 20.sp),
              ConfirmButton(),
            ],
          ),
        ));
  }

  Widget ConfirmButton() {
    return ElevatedButton(
      onPressed: _isFormValid ? onButtonPressed : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          _isFormValid ? Palette.red : Colors.grey,
        ),
        elevation: MaterialStateProperty.all(_isFormValid ? 5.0 : 0.0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 16.sp, horizontal: 64.sp),
        ),
      ),
      child: Text(
        "Conferma",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }
}
