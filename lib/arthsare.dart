import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void main() {
  runApp(ArtShareApp());
}

class Artwork {
  final int id;
  final String artist;
  final String username;
  final String title;
  final String imageUrl;
  int likes;
  final String description;

  Artwork({
    required this.id,
    required this.artist,
    required this.username,
    required this.title,
    required this.imageUrl,
    required this.likes,
    required this.description,
  });
}

class ArtShareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtShare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ArtworkGalleryPage(username: 'SampleUser', fullName: 'Sample User'), // Provide a username
    );
  }
}

class ArtworkGalleryPage extends StatefulWidget {
  final String username;
  final String fullName;

  ArtworkGalleryPage({required this.username, required this.fullName});

  @override
  _ArtworkGalleryPageState createState() => _ArtworkGalleryPageState();
}

class _ArtworkGalleryPageState extends State<ArtworkGalleryPage> {
  List<Artwork> artworks = [];
  TextEditingController _searchController = TextEditingController();
  File? _pickedImage;
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArtworks();
  }

  void _fetchArtworks() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('artworks').get();
    final List<Artwork> fetchedArtworks = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Artwork(
        id: data['id'],
        artist: data['artist'],
        username: data['username'],
        title: data['title'],
        imageUrl: data['imageUrl'],
        likes: data['likes'],
        description: data['description'],
      );
    }).toList();

    setState(() {
      artworks = fetchedArtworks;
    });
  }

  void _filterArtworks(String query) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('artworks')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final List<Artwork> filteredArtworks = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Artwork(
        id: data['id'],
        artist: data['artist'],
        username: data['username'],
        title: data['title'],
        imageUrl: data['imageUrl'],
        likes: data['likes'],
        description: data['description'],
      );
    }).toList();

    setState(() {
      artworks = filteredArtworks;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      _showUploadConfirmation();
    }
  }

  Future<void> _uploadArtwork() async {
    if (_pickedImage == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image and provide a description")),
      );
      return;
    }

    final storageRef = FirebaseStorage.instance.ref().child('artworks/${DateTime.now().toString()}');
    final uploadTask = storageRef.putFile(_pickedImage!);
    final snapshot = await uploadTask;

    final imageUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('artworks').add({
      'title': 'New Artwork',
      'artist': widget.fullName,
      'username': widget.username,
      'imageUrl': imageUrl,
      'description': _descriptionController.text,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _pickedImage = null;
      _descriptionController.clear();
    });

    // Call _fetchArtworks() after state change to update the artwork list
    _fetchArtworks();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Artwork uploaded successfully!')));
  }

  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Description'),
          content: TextField(
            controller: _descriptionController,
            decoration: InputDecoration(hintText: 'Add a description for your artwork'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _uploadArtwork,
              child: Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ArtShare',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mail, color: Colors.grey[500]),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("This feature isn't available at the moment")),
                      );
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterArtworks,
                decoration: InputDecoration(
                  hintText: 'Search artworks or artists...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: artworks.isNotEmpty
                  ? GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: artworks.length,
                itemBuilder: (context, index) {
                  return ArtworkCard(artwork: artworks[index]);
                },
              )
                  : Center(
                child: Text('No artworks found', style: TextStyle(color: Colors.grey[500])),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Gallery'),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.upload_outlined),
              onPressed: _pickImage, // Open gallery on press
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(username: widget.username, fullName: widget.fullName),
                  ),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ArtworkCard extends StatefulWidget {
  final Artwork artwork;

  const ArtworkCard({Key? key, required this.artwork}) : super(key: key);

  @override
  _ArtworkCardState createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  bool _isLiked = false;

  void _showArtworkDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.artwork.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.artwork.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('by ${widget.artwork.artist}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Text(widget.artwork.description, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                            color: _isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                        ),
                        Text('${widget.artwork.likes}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showArtworkDetails,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.artwork.imageUrl,
                height: 200,  // Ensuring uniform height
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.artwork.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'by ${widget.artwork.artist}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
