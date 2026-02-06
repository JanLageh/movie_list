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
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  String selectedGenre = "Action";

  final List<String> genres = [
    "Action",
    "Comedy",
    "Drama",
    "Horror",
    "Sci-Fi",
    "Romance",
  ];
  Uint8List? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  void addMovie() {
    if (titleController.text.isEmpty || lengthController.text.isEmpty) {
      return;
    }

    setState(() {
      movies.add(
        Movie(
          title: titleController.text,
          length: int.parse(lengthController.text),
          genre: selectedGenre,
          thumbnail: selectedImage,
        ),
      );

      titleController.clear();
      lengthController.clear();
      selectedImage = null;
      selectedGenre = genres.first;
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
              controller: titleController,
              decoration: const InputDecoration(labelText: "Movie Title"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: lengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Length (minutes)"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedGenre,
              items: genres
                  .map(
                    (genre) =>
                        DropdownMenuItem(value: genre, child: Text(genre)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGenre = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Genre"),
            ),
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
            ElevatedButton(onPressed: addMovie, child: const Text("Add Movie")),

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
                      subtitle: Text("${movie.genre} • ${movie.length} min"),
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
  int length;
  String genre;
  Uint8List? thumbnail;

  Movie({
    required this.title,
    this.length = 0,
    this.genre = "",
    this.thumbnail,
  });
}
