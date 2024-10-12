import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class GymInfoScreen2 extends StatefulWidget {
  final String name;
  final String subscription;
  final String phoneNo;
  final String email;
  final String description;

  const GymInfoScreen2({
    Key? key,
    required this.name,
    required this.subscription,
    required this.phoneNo,
    required this.email,
    required this.description,
  }) : super(key: key);

  @override
  _GymInfoScreen2State createState() => _GymInfoScreen2State();
}

class _GymInfoScreen2State extends State<GymInfoScreen2> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController googleMapsLinkController =
      TextEditingController();

  bool cityValid = true;
  bool countryValid = true;
  bool addressValid = true;
  bool googleMapsLinkValid = true;
  bool imagesValid = true;
  bool gymAdded = false;
  bool isLoading = false;

  List<File> _images = [];

  Future<void> _pickImage() async {
    // Check if already selected 2 images
    if (_images.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select only two images')),
      );
      return;
    }

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    for (var image in _images) {
      String fileName = image.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double moreInfoFontSize = 38;

    if (screenWidth < 400) {
      moreInfoFontSize = 35.0; // Ensure to add .0 for double values
    }
    if (screenWidth < 350) {
      moreInfoFontSize = 32.0;
    }
    if (screenWidth < 300) {
      moreInfoFontSize = 29.0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      cityValid = cityController.text.isNotEmpty;
                      countryValid = countryController.text.isNotEmpty;
                      addressValid = addressController.text.isNotEmpty;
                      googleMapsLinkValid =
                          googleMapsLinkController.text.isNotEmpty;
                      imagesValid = _images.isNotEmpty;
                      isLoading = true; // Show loading indicator
                    });

                    if (cityValid &&
                        countryValid &&
                        addressValid &&
                        googleMapsLinkValid &&
                        imagesValid) {
                      try {
                        // Upload images and get their URLs
                        List<String> imageUrls = await _uploadImages();
                        final gym = Gym(
                          name: widget.name,
                          subscription: widget.subscription,
                          phoneNo: widget.phoneNo,
                          email: widget.email,
                          description: widget.description,
                          city: cityController.text,
                          country: countryController.text,
                          address: addressController.text,
                          googleMapsLink: googleMapsLinkController.text,
                          imageUrl1: imageUrls.isNotEmpty ? imageUrls[0] : '',
                          imageUrl2: imageUrls.length > 1 ? imageUrls[1] : '',
                          gymID: '', 
                        );

                        await Database_Service.addGym(gym);
                        gymAdded = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gym added successfully!')),
                        );
                        Get.toNamed('/adminHome');

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding gym: $e')),
                        );
                      } finally {
                        setState(() {
                          isLoading = false; 
                        });
                      }
                    } else {
                      setState(() {
                        isLoading = false; 
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  color: AppColors.appTextColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.appBackground,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'More Information',
                          style: GoogleFonts.poppins(
                            color: AppColors.appNeon,
                            fontSize: moreInfoFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0,
                            10.0), // Ensure to use 15.0 instead of 15 for EdgeInsets
                        child: CustomTextField(
                          controller: cityController,
                          hintText: "City of the Gym",
                          labelText: "City",
                          isValid: cityValid,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: CustomTextField(
                          controller: countryController,
                          hintText: "Country of the Gym",
                          labelText: "Country",
                          isValid: countryValid,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: CustomTextField(
                          controller: addressController,
                          hintText: "Address of the Gym",
                          labelText: "Address",
                          isValid: addressValid,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: CustomTextField(
                          controller: googleMapsLinkController,
                          hintText: "Google Maps Link of the Gym",
                          labelText: "Google Maps Link",
                          isValid: googleMapsLinkValid,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload Images (Two images only)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text("Pick Image"),
                            ),
                            SizedBox(height: 10.0),
                            Wrap(
                              children: _images.map((image) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    image,
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.appNeon),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Adding Gym...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
