import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MoviePage(),
    );
  }
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final List<Movie> movies = [];
  final TextEditingController controller = TextEditingController();
  Uint8List? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  void addMovie() {
    if (controller.text.isEmpty) return;

    setState(() {
      movies.add(
        Movie(
          title: controller.text,
          thumbnail: selectedImage,
        ),
      );
      controller.clear();
      selectedImage = null;
    });
  }

  void deleteMovie(int index) {
    setState(() {
      movies.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie List (Web)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Movie Title",
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Pick Thumbnail"),
                ),
                const SizedBox(width: 10),
                if (selectedImage != null)
                  Image.memory(
                    selectedImage!,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addMovie,
              child: const Text("Add Movie"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Card(
                    child: ListTile(
                      leading: movie.thumbnail != null
                          ? Image.memory(
                              movie.thumbnail!,
                              width: 50,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.movie, size: 40),
                      title: Text(movie.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteMovie(index),
                      ),
                    ),
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

class Movie {
  String title;
  Uint8List? thumbnail;

  Movie({required this.title, this.thumbnail});
}
