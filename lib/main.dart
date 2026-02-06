import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color netflixRed = Color(0xFFE50914);
const Color netflixBlack = Color(0xFF141414);
const Color netflixDarkGrey = Color(0xFF1F1F1F);
const Color netflixGrey = Color(0xFF2B2B2B);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: netflixBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: netflixDarkGrey,
          foregroundColor: netflixRed,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: netflixRed, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: netflixGrey,
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: netflixRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: netflixDarkGrey,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        colorScheme: const ColorScheme.dark(
          primary: netflixRed,
          surface: netflixDarkGrey,
        ),
      ),
      home: const MoviePage(),
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
  int? editingIndex;

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
      final updatedMovie = Movie(
        title: titleController.text,
        length: int.parse(lengthController.text),
        genre: selectedGenre,
        thumbnail: selectedImage,
      );

      if (editingIndex != null) {
        movies[editingIndex!] = updatedMovie;
      } else {
        movies.add(updatedMovie);
      }

      titleController.clear();
      lengthController.clear();
      selectedImage = null;
      selectedGenre = genres.first;
      editingIndex = null;
    });
  }

  void selectMovie(int index) {
    final movie = movies[index];
    setState(() {
      editingIndex = index;
      titleController.text = movie.title;
      lengthController.text = movie.length.toString();
      selectedGenre = movie.genre;
      selectedImage = movie.thumbnail;
    });
  }

  void deleteMovie(int index) {
    setState(() {
      movies.removeAt(index);
      if (editingIndex != null) {
        if (editingIndex == index) {
          titleController.clear();
          lengthController.clear();
          selectedImage = null;
          selectedGenre = genres.first;
          editingIndex = null;
        } else if (editingIndex! > index) {
          editingIndex = editingIndex! - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "N",
              style: TextStyle(
                color: netflixRed,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: netflixRed.withAlpha(100), blurRadius: 12),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "NigFlix",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Thumbnail placeholder at the top
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: netflixGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedImage != null
                              ? netflixRed
                              : Colors.grey.shade700,
                          width: 2,
                        ),
                        boxShadow: selectedImage != null
                            ? [
                                BoxShadow(
                                  color: netflixRed.withAlpha(60),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: selectedImage != null
                          ? Image.memory(
                              selectedImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey,
                                  size: 36,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Thumbnail",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Movie Title",
                      prefixIcon: Icon(Icons.movie_outlined, color: netflixRed),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: lengthController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Length (minutes)",
                      prefixIcon: Icon(Icons.timer_outlined, color: netflixRed),
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedGenre,
                    dropdownColor: netflixGrey,
                    style: const TextStyle(color: Colors.white),
                    items: genres
                        .map(
                          (genre) => DropdownMenuItem(
                            value: genre,
                            child: Text(genre),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGenre = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Genre",
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: netflixRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addMovie,
                      icon: Icon(editingIndex == null ? Icons.add : Icons.save),
                      label: Text(
                        editingIndex == null ? "ADD MOVIE" : "SAVE CHANGES",
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My List",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (movies.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_filter_outlined,
                        size: 64,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No movies yet",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add your first movie above!",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = movies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      onTap: () => selectMovie(index),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: movie.thumbnail != null
                            ? Image.memory(
                                movie.thumbnail!,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 70,
                                color: netflixGrey,
                                child: const Icon(
                                  Icons.movie,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      title: Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${movie.genre} • ${movie.length} min",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: netflixRed),
                        onPressed: () => deleteMovie(index),
                      ),
                    ),
                  );
                }, childCount: movies.length),
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
