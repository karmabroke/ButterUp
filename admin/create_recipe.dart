import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart'show kIsWeb;
import 'dart:io'; // Required for mobile
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../background_widget.dart';
import '../firestore.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String? selectedCategory = 'Cakes';
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController recipeImageController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  final String cloudName = 'drvuahkye';  // Replace with your Cloudinary cloud name
  final String uploadPreset = '257924675766715';  // Replace with your unsigned upload preset
  final String apiKey = 'N6usb3pwGb-OQrqlt2VZvy_h6Xg';  // Replace with your Cloudinary API key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            const home_background(),
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      const Text(
                        'Create Recipe',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Category Dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DropdownButtonHideUnderline(
                              child: Container(
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEA192),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategory = newValue;
                                      });
                                    },
                                    dropdownColor: const Color(0xFFFEA192),
                                    items: <String>['Cakes', 'Cupcakes', 'Cookies']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // TextFields
                      _buildTextField(
                        controller: recipeNameController,
                        label: 'Recipe Name',
                        hintText: 'Enter recipe name',
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        controller: descriptionController,
                        label: 'Description',
                        hintText: 'Enter description',
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        controller: ingredientsController,
                        label: 'Ingredients',
                        hintText: 'Enter ingredients',
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        controller: instructionsController,
                        label: 'Instructions',
                        hintText: 'Enter instructions',
                      ),
                      const SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recipe Image',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickAndUploadImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text('Upload Image'),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    recipeImageController.text.isEmpty
                                        ? 'No image selected'
                                        : recipeImageController.text,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Go back to the previous page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),

                          // Save Button
                          ElevatedButton(
                            onPressed: _saveRecipe, // Call save function
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEA192),
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Lexend',
                color: Colors.grey,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // Function to save the recipe to Firestore
  Future<void> _saveRecipe() async {
    if (selectedCategory != null &&
        recipeNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        ingredientsController.text.isNotEmpty &&
        instructionsController.text.isNotEmpty &&
        recipeImageController.text.isNotEmpty) {
      // Save the image URL in Firestore
      await firestoreService.addRecipe(
        selectedCategory!,
        recipeNameController.text,
        descriptionController.text,
        ingredientsController.text,
        instructionsController.text,
        recipeImageController.text, // Store image URL from Cloudinary
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully!')),
      );
      Navigator.pop(context); // Go back after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
    }
  }

  // Function to pick and upload image to Cloudinary
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // Web-specific code
        html.FormData formData = html.FormData();
        formData.appendBlob('file', html.File([await image.readAsBytes()], image.name));
        formData.append('upload_preset', uploadPreset);
        formData.append('api_key', apiKey);

        // Using html.HttpRequest instead of http.post
        var request = await html.HttpRequest.request(
          'https://api.cloudinary.com/v1_1/$cloudName/upload',
          method: 'POST',
          sendData: formData,
        );

        if (request.status == 200) {
          var data = json.decode(request.responseText!);
          setState(() {
            recipeImageController.text = data['secure_url'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Please try again.')),
          );
        }
      }
      else {
        // Mobile-specific code
        File imageFile = File(image.path);

        // Prepare the Cloudinary upload URL
        var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
        var request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', imageFile.path))
          ..fields['api_key'] = apiKey;

        // Send the request to Cloudinary
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        if (response.statusCode == 200) {
          setState(() {
            recipeImageController.text = data['secure_url'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Please try again.')),
          );
        }
      }
    }
  }
}
