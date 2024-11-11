import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:myapp/screens/add_task.dart';
import 'package:myapp/screens/folder.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/task.dart';
import 'package:myapp/screens/transaction.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FileScreen extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const FileScreen({required this.userId, required this.projectDocId});
  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  String activeButton = 'File';
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> photoData = [];
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photosRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('projects')
        .doc(widget.projectDocId)
        .collection('files');

    final snapshot = await photosRef.get();
    setState(() {
      photoData = snapshot.docs.map((doc) => {
            'id': doc.id,
            'url': doc['url'] as String,
          }).toList();
      isLoading = false;
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isUploading = true;
      });

      final File file = File(pickedFile.path);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${widget.userId}/projects/${widget.projectDocId}/files/$fileName');
      
      await storageRef.putFile(file);
      final String downloadUrl = await storageRef.getDownloadURL();

      final photosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .doc(widget.projectDocId)
          .collection('files');

      final docRef = await photosRef.add({'url': downloadUrl});

      setState(() {
        photoData.add({
          'id': docRef.id,
          'url': downloadUrl,
        });
        isUploading = false;
      });
    }
  }

  Future<void> _deletePhoto(String id, String url) async {
    final photosRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('projects')
        .doc(widget.projectDocId)
        .collection('files')
        .doc(id);

    final storageRef = FirebaseStorage.instance.refFromURL(url);

    await photosRef.delete();
    await storageRef.delete();

    setState(() {
      photoData.removeWhere((photo) => photo['id'] == id);
    });
  }

  void _showDeleteConfirmation(String id, String url) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePhoto(id, url);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProjectScreen(userId: widget.userId,)),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 4, 63, 132),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.05, left: screenWidth * 0.00),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectScreen(userId: widget.userId,),
                              ),
                            );
                          },
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(left: screenWidth * 0.30)),
                        const Text(
                          'Files',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Transactionscreen(
                                userId: widget.userId,
                                projectDocId: widget.projectDocId,
                              ),
                            ),
                          );
                          setState(() {
                            activeButton = 'Transaction';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: activeButton == 'Transaction'
                              ? Color.fromRGBO(1, 42, 86, 1)
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          'asset/transaction.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskScreen(
                                userId: widget.userId,
                                projectDocId: widget.projectDocId,
                              ),
                            ),
                          );
                          setState(() {
                            activeButton = 'Task';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: activeButton == 'Task'
                              ? Color.fromRGBO(1, 42, 86, 1)
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          'asset/task logo.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Materialscreen(
                                userId: widget.userId,
                                projectDocId: widget.projectDocId,
                              ),
                            ),
                          );
                          setState(() {
                            activeButton = 'Material';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: activeButton == 'Material'
                              ? Color.fromRGBO(1, 42, 86, 1)
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          'asset/material.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            activeButton = 'File';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: activeButton == 'File'
                              ? Color.fromRGBO(1, 42, 86, 1)
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          'asset/file.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.02, left: screenWidth * 0.05),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadPhoto,
                    child: Container(
                      width: screenWidth * 0.41,
                      height: screenWidth * 0.15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromARGB(255, 4, 63, 132),
                          )),
                      child: Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Color.fromARGB(255, 4, 63, 132),
                              size: screenWidth * 0.05,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.02),
                            ),
                            Text(
                              'Add photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.07),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: screenWidth * 0.03)),
            Container(
              width: screenWidth * 0.9, // Set the width of the divider
              child: Divider(
                color: Color.fromARGB(255, 4, 63, 132),
                thickness: 1.0, // Optional: Set the thickness of the divider
              ),
            ),
            if (isUploading) // Show loader while uploading photo
              Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),)),
            Expanded(
              child: isLoading // Show loader while loading data
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),))
                  : GridView.builder(
                      padding: EdgeInsets.all(10.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: photoData.length,
                      itemBuilder: (context, index) {
                        final photo = photoData[index];
                        return GestureDetector(
                          onLongPress: () => _showDeleteConfirmation(photo['id']!, photo['url']!),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewScreen(imageUrl: photo['url']!),
                              ),
                            );
                          },
                          child: Image.network(photo['url']!),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View',
        style: TextStyle(color: Colors.white,)),
        backgroundColor: Color.fromARGB(255, 4, 63, 132),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
