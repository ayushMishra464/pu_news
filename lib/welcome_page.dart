import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pu_news/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;
import 'package:pu_news/login.dart';
import 'package:pu_news/news_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class WelcomePage extends StatefulWidget {
  final String userName;
  final String userId;

  WelcomePage({required this.userName, required this.userId});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ScrollController _scrollController = ScrollController();
  List<NewsItem> allNewsItems = []; // Stores all fetched news
  List<NewsItem> displayedNewsItems = []; // Stores currently displayed news
  bool isLoadingMore = false;
  bool hasMore = true; // Indicates if more news is available to load
  int _selectedIndex = 0;
  final int itemsPerPage = 10; // Number of items to load per batch
  String _selectedSource = 'Google News'; // Default selected source

  // RSS Feed URLs
  final String googleNewsUrl = 'https://rss.app/feeds/bwB8W4hIbZ1HUyI8.xml';
  final String hindustanTimesUrl = 'https://rss.app/feeds/9XDIbkYWEdI3KQSC.xml';
  final String puOfficialsUrl = 'https://rss.app/feeds/eU6xBdoyuofvETHU.xml';
  final String chandigarhNewsUrl = 'https://rss.app/feeds/lgOBqGmB0pEy1nRU.xml';
  final String india = 'https://rss.app/feeds/y1x1BLAhvoZjZKq7.xml';
  final String world = 'https://rss.app/feeds/ftnJdOzeTQsl3skB.xml';




  @override
  void initState() {
    super.initState();
    _fetchAllNews(); // Fetch all news on initialization
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          _loadMoreNews();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch news based on the selected source
  Future<void> _fetchAllNews() async {
    String url;
    switch (_selectedSource) {
      case 'World':
        url = world;
        break;
      case 'All India':
        url = india;
        break;
      case 'PU Hindustan Times':
        url = hindustanTimesUrl;
        break;
      case 'PU Academic':
        url = puOfficialsUrl;
        break;
      case 'Chandigarh News':
        url = chandigarhNewsUrl;
        break;
      case 'PU Google News':
      default:
        url = googleNewsUrl;
        break;
    }

    try {
      List<NewsItem> fetchedNews = await fetchRssNews(url);
      setState(() {
        allNewsItems = fetchedNews;
        // Initially display the first 'itemsPerPage' news items
        displayedNewsItems = allNewsItems.take(itemsPerPage).toList();
        // Determine if more items are available to load
        hasMore = allNewsItems.length > displayedNewsItems.length;
      });
    } catch (e) {
      // Handle errors appropriately in your app
      print('Error fetching news: $e');
      // You might want to show an error message to the user here
    }
  }

  // Fetch news items from the specified RSS feed
  Future<List<NewsItem>> fetchRssNews(String url) async {
    final response = await http.get(Uri.parse(url));

    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      print('Number of items fetched: ${items.length}');

      return items.map((item) {
        final title = item.findElements('title').single.text;
        final link = item.findElements('link').single.text;
        final imageUrl = item.findElements('media:content').isNotEmpty
            ? item.findElements('media:content').single.getAttribute('url') ?? ''
            : ''; // Fallback to empty string if no image

        print('News item: $title');
        return NewsItem(title: title, link: link, imageUrl: imageUrl);
      }).toList();
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  // Load more news items when the user scrolls to the bottom
  Future<void> _loadMoreNews() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate a delay for fetching data
    await Future.delayed(Duration(seconds: 2));

    // Calculate the next set of items to display
    int currentLength = displayedNewsItems.length;
    int nextLength = currentLength + itemsPerPage;
    if (nextLength > allNewsItems.length) {
      nextLength = allNewsItems.length;
    }

    setState(() {
      displayedNewsItems.addAll(allNewsItems.getRange(currentLength, nextLength));
      isLoadingMore = false;
      hasMore = allNewsItems.length > displayedNewsItems.length;
    });
  }

  // Handle bottom navigation taps
  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Logout function with confirmation dialog
  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Sign out the user
                try {
                  await FirebaseAuth.instance.signOut();
                  print("User signed out successfully");

                  // Navigate to the login page and clear the back stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }



  // Build the news list with incremental loading
  Widget _buildNewsList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: displayedNewsItems.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayedNewsItems.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final newsItem = displayedNewsItems[index];
        return GestureDetector(
          onTap: () async {
            var url = newsItem.link;

            // Log the URL to the console for debugging
            print('Attempting to launch URL: $url');

            // Check if the URL starts with a valid scheme
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              print('Invalid URL scheme, adding "https://" prefix');
              url = 'https://$url';
            }

            // Attempt to launch the URL
            try {
              final uri = Uri.parse(url);
              if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                print('URL launched successfully');
              } else {
                throw 'Could not launch $url';
              }
            } catch (e) {
              print('Error launching URL: $e');
              // Show a SnackBar or any other UI element to inform the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch the URL')),
              );
            }
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (newsItem.imageUrl.isNotEmpty)
                    Image.network(
                      newsItem.imageUrl,
                      height: 190, // Reduced image height
                    )
                  else
                    Image.asset(
                      'assets/placeholder.png',
                      height: 190, // Reduced image height
                    ),
                  SizedBox(height: 8),
                  Text(
                    newsItem.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Click to read more.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          Share.share(newsItem.link);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Build the public chat section
  Widget _buildPublicChat() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('public_chat').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;
        final currentUser = FirebaseAuth.instance.currentUser;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;

            final String content = data['content'] ?? 'No content';
            final String userName = data['userName'] ?? 'Anonymous';
            final int upvotes = data['upvotes'] ?? 0;
            final int downvotes = data['downvotes'] ?? 0;
            final Map<String, dynamic> userInteractions = Map<String, dynamic>.from(data['userInteractions'] ?? {});

            bool isUpvoted = userInteractions[currentUser!.uid] == true;
            bool isDownvoted = userInteractions[currentUser.uid] == false;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Posted by $userName',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up_alt_outlined,
                                color: isUpvoted ? Colors.blue : null,
                              ),
                              onPressed: () => _handleUpvote(post.id, upvotes, userInteractions),
                            ),
                            Text(upvotes.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down_alt_outlined,
                                color: isDownvoted ? Colors.red : null,
                              ),
                              onPressed: () => _handleDownvote(post.id, downvotes, userInteractions),
                            ),
                            Text(downvotes.toString()),
                          ],
                        ),
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

  void _handleUpvote(String postId, int currentUpvotes, Map<String, dynamic> userInteractions) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!userInteractions.containsKey(currentUser!.uid) || userInteractions[currentUser.uid] == false) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance.collection('public_chat').doc(postId);
        final snapshot = await transaction.get(postRef);

        if (snapshot.exists) {
          int newUpvotes = currentUpvotes;
          int newDownvotes = snapshot['downvotes'];

          if (userInteractions.containsKey(currentUser.uid)) {
            newDownvotes--;
          }

          userInteractions[currentUser.uid] = true;
          newUpvotes++;

          transaction.update(postRef, {
            'upvotes': newUpvotes,
            'downvotes': newDownvotes,
            'userInteractions': userInteractions,
          });
        }
      });
    }
  }

  void _handleDownvote(String postId, int currentDownvotes, Map<String, dynamic> userInteractions) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!userInteractions.containsKey(currentUser!.uid) || userInteractions[currentUser.uid] == true) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance.collection('public_chat').doc(postId);
        final snapshot = await transaction.get(postRef);

        if (snapshot.exists) {
          int newDownvotes = currentDownvotes;
          int newUpvotes = snapshot['upvotes'];

          if (userInteractions.containsKey(currentUser.uid)) {
            newUpvotes--;
          }

          userInteractions[currentUser.uid] = false;
          newDownvotes++;

          transaction.update(postRef, {
            'downvotes': newDownvotes,
            'upvotes': newUpvotes,
            'userInteractions': userInteractions,
          });
        }
      });
    }
  }

  // Show dialog for creating a new post
  void _showCreatePostDialog() {
    final TextEditingController postController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Post'),
          content: TextField(
            controller: postController,
            decoration: InputDecoration(hintText: 'Write your post here...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Post'),
              onPressed: () {
                if (postController.text.isNotEmpty) {
                  _createPost(postController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Create a new post in Firestore
  Future<void> _createPost(String content) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Fetch the latest user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userName = userDoc.data()?['userName'] ?? 'Anonymous'; // Fetch the 'name' field from Firestore

        // Add the post to Firestore with the up-to-date username
        await FirebaseFirestore.instance.collection('public_chat').add({
          'content': content,
          'userName': userName, // Use the fetched username
          'timestamp': FieldValue.serverTimestamp(),
          'userInteractions': {}, // Initialize with an empty map to track user interactions
          'upvotes': 0,           // Initialize upvotes count to 0
          'downvotes': 0,         // Initialize downvotes count to 0
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    final currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFFA00202), // Set the color of the drawer icon here
        ),
        title: Text(
        'PU NEWS',
        style: TextStyle(
        color: Colors.white,  // Set the title text color to white
    )),
        backgroundColor:Colors.black,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedSource = value;
                _fetchAllNews(); // Fetch news based on selected source
              });
            },
            itemBuilder: (BuildContext context) {
              return {
                'PU Google News',
                'PU Hindustan Times',
                'PU Academic',
                'Chandigarh News',
                'All India',
                'World'
              }.map((String source) {
                return PopupMenuItem<String>(
                  value: source,
                  child: Text(source),
                );
              }).toList();
            },
            icon: Icon(Icons.filter_list,color: Color(0xFFA00202)),
          ),
        ],
      ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading indicator while waiting for data
                    return Container(
                      color: Colors.black,
                      padding: EdgeInsets.all(16.0),
                      child: DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/profile_pic.jpg'),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Welcome!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  var userDoc = snapshot.data!;
                  return Container(
                    color: Colors.black,
                    padding: EdgeInsets.all(16.0),
                    child: DrawerHeader(
                      margin: EdgeInsets.only(top: 70.0),
                      padding: EdgeInsets.only(top: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/profile_pic.jpg'),
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (userDoc['userName']?.split(' ').first ?? 'No Name'),
                                style: TextStyle(
                                  color: Color(0xFFA00202),
                                  fontSize: 21,
                                ),
                                maxLines: 1, // Ensures the text does not overflow into multiple lines
                                overflow: TextOverflow.ellipsis, // Adds '...' if the text is too long
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.home, color: Colors.black),
                  title: Text('Home', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title: Text('Profile', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        userName: widget.userName ?? 'Default Name',  // Provide a default value if necessary
                        email: FirebaseAuth.instance.currentUser!.email ?? 'No email',
                      ),
                    ),
                  );
                },
              ),

              Spacer(), // Pushes the logout item to the bottom
              ListTile(
                leading: Icon(Icons.logout, color: Colors.black),
                title: Text('Logout', style: TextStyle(color: Colors.black)),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildNewsList(),
          _buildPublicChat(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: Icon(Icons.add , color: Color(0xFFA00202)),
        tooltip: 'Create Post',
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article,color: Color(0xFFA00202)),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat , color: Color(0xFFA00202)),
            label: 'Public Chat',
          ),
        ],
      ),
    );
  }
}
