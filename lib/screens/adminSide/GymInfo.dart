// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:gymvisa/widgets/EditPopup.dart';

class GymInfo extends StatefulWidget {
  Gym gym;

  GymInfo({
    required this.gym,
    super.key,
  });

  @override
  State<GymInfo> createState() => _GymInfoState();
}

class _GymInfoState extends State<GymInfo> {
  bool _isDeleting = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Database_Service.updateGymById(
                    widget.gym.gymID, widget.gym);
                Get.back();

              } catch (e) {
                // Handle error (e.g., show a snackbar or alert dialog)
                print('Update failed: $e');
              }
            },
            child: Text(
              "Save",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              child: Image.network(
                widget.gym.imageUrl1,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => EditPopup(
                              label: "Name",
                              initialText: widget.gym.name,
                              onSave: (newText) {
                                setState(() {
                                  widget.gym.name = newText;
                                });
                              },
                            ),
                          );
                        },
                        child: Text(
                          widget.gym.name,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.w400,
                            color: AppColors.appNeon,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => EditPopup(
                            label: "Description",
                            initialText: widget.gym.description,
                            onSave: (newText) {
                              setState(() {
                                widget.gym.description = newText;
                              });
                            },
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: Size(double.infinity, screenHeight * 0.08),
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                            horizontal: screenWidth * 0.05),
                      ),
                      child: Container(
                        alignment:
                            Alignment.centerLeft, // Align text to the left
                        child: Text(
                          widget.gym.description,
                          softWrap: true,
                          textAlign: TextAlign
                              .left, // Ensure text starts from the left
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildEditableDropdownButton(
                    context: context,
                    label: "Subscriptions",
                    value: widget.gym.subscription,
                    items: ["Standard", "Premium"],
                    onSave: (newText) {
                      setState(() {
                        widget.gym.subscription = newText;
                      });
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  _buildEditableDropdownButton(
                    context: context,
                    label: "City",
                    value: widget.gym.city,
                    items: ["Lahore", "Karachi"],
                    onSave: (newText) {
                      setState(() {
                        widget.gym.city = newText;
                      });
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  ..._buildEditableTextButton(
                    context: context,
                    label: "Phone No",
                    value: widget.gym.phoneNo,
                    onSave: (newText) {
                      setState(() {
                        widget.gym.phoneNo = newText;
                      });
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  ..._buildEditableTextButton(
                    context: context,
                    label: "Email",
                    value: widget.gym.email,
                    onSave: (newText) {
                      setState(() {
                        widget.gym.email = newText;
                      });
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  ..._buildEditableTextButton(
                    context: context,
                    label: "Address",
                    value: widget.gym.address,
                    onSave: (newText) {
                      setState(() {
                        widget.gym.address = newText;
                      });
                    },
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text(
                                  'Are you sure you want to delete this gym permanently?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Get.back(result: false), 
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                    child: Text('Delete'),
                                    onPressed: () async {
                                      await Database_Service.deleteGymById(
                                          widget.gym.gymID);
                                      Get.toNamed('/adminHome');
                                    }),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          setState(() {
                            _isDeleting = true;
                          });

                          try {
                            await Database_Service.deleteGymById(
                                widget.gym.gymID);
                           Get.back();
                          } catch (e) {
                            // Handle the error (e.g., show a message to the user)
                          } finally {
                            setState(() {
                              _isDeleting = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.3,
                        ),
                      ),
                      child: _isDeleting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            )
                          : Text(
                              "Remove Gym",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableDropdownButton({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onSave,
    required double screenHeight,
    required double screenWidth,
  }) {
    // Ensure initial value is in the list
    if (!items.contains(value)) {
      value = items.first;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color.fromARGB(255, 57, 57, 57),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onSave(newValue);
              }
            },
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEditableTextButton({
    required BuildContext context,
    required String label,
    required String value,
    required Function(String) onSave,
    required double screenHeight,
    required double screenWidth,
  }) {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => EditPopup(
                label: label,
                initialText: value,
                onSave: (newText) {
                  onSave(newText);
                },
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 57, 57, 57),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            minimumSize:
                Size(double.infinity, screenHeight * 0.065), // Decreased height
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015, // Adjusted padding
              horizontal: screenWidth * 0.05,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "$label: $value",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
