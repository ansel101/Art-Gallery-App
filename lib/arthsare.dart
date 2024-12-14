import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
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
                        SnackBar(
                          content: Text("This feature isn't available at the moment"),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),

            // Search Bar
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

            // Artwork Grid
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
                child: Text(
                  'No artworks found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.upload_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("This feature isn't available at the moment"),
                  ),
                );
              },
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
                    // Artwork Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.artwork.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Title
                    Text(
                      widget.artwork.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Artist
                    Text(
                      'by ${widget.artwork.artist} (${widget.artwork.username})',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Description
                    Text(
                      widget.artwork.description,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Likes
                    Row(
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text('${widget.artwork.likes} likes'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                widget.artwork.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Artwork Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Like Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.artwork.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Like Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            _isLiked
                                ? widget.artwork.likes++
                                : widget.artwork.likes--;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${widget.artwork.likes}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Username
                  SizedBox(height: 4),
                  Text(
                    widget.artwork.username,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}