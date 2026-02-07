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
  final List<Movie> movies = [
    Movie(
      title: "Inception",
      length: 148,
      genre: "Sci-Fi",
      description: "A thief enters dreams to steal secrets.",
      year: 2010,
    ),
    Movie(
      title: "The Dark Knight",
      length: 152,
      genre: "Action",
      description: "Batman faces the Joker in Gotham.",
      year: 2008,
    ),
    Movie(
      title: "Parasite",
      length: 132,
      genre: "Drama",
      description: "A poor family infiltrates a wealthy home.",
      year: 2019,
    ),
    Movie(
      title: "Get Out",
      length: 104,
      genre: "Horror",
      description: "A chilling visit to a girlfriend’s family.",
      year: 2017,
    ),
    Movie(
      title: "La La Land",
      length: 128,
      genre: "Romance",
      description: "A jazz musician and actress chase dreams.",
      year: 2016,
    ),
  ];
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedGenre = "Action";
  int? editingIndex;
  int? selectedIndex;
  bool isSelecting = false;

  final List<String> genres = [
    "Action",
    "Comedy",
    "Drama",
    "Horror",
    "Sci-Fi",
    "Romance",
  ];
  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();
    if (movies.isNotEmpty) {
      selectedIndex = 0;
      selectedImage = movies.first.thumbnail;
    }
  }

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
        description: descriptionController.text,
        year: int.tryParse(yearController.text) ?? 0,
        thumbnail: selectedImage,
      );

      if (editingIndex != null) {
        movies[editingIndex!] = updatedMovie;
        if (selectedIndex == editingIndex) {
          selectedIndex = editingIndex;
        }
      } else {
        movies.add(updatedMovie);
        selectedIndex = movies.length - 1;
      }

      titleController.clear();
      lengthController.clear();
      descriptionController.clear();
      yearController.clear();
      selectedImage = null;
      selectedGenre = genres.first;
      editingIndex = null;
    });
  }

  Future<void> selectMovie(int index) async {
    setState(() {
      isSelecting = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      selectedIndex = index;
      selectedImage = movies[index].thumbnail;
      isSelecting = false;
    });
  }

  void editMovie(int index) {
    final movie = movies[index];
    setState(() {
      editingIndex = index;
      titleController.text = movie.title;
      lengthController.text = movie.length.toString();
      descriptionController.text = movie.description;
      yearController.text = movie.year == 0 ? "" : movie.year.toString();
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
          descriptionController.clear();
          yearController.clear();
          selectedImage = null;
          selectedGenre = genres.first;
          editingIndex = null;
        } else if (editingIndex! > index) {
          editingIndex = editingIndex! - 1;
        }
      }
      if (selectedIndex != null) {
        if (selectedIndex == index) {
          selectedIndex = movies.isEmpty ? null : 0;
          selectedImage = movies.isEmpty
              ? null
              : movies[selectedIndex!].thumbnail;
        } else if (selectedIndex! > index) {
          selectedIndex = selectedIndex! - 1;
          if (selectedIndex != null && movies.isNotEmpty) {
            selectedImage = movies[selectedIndex!].thumbnail;
          }
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
        child: Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: isSelecting
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(
                                    color: netflixRed,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selected Movie",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (selectedIndex == null)
                                    const Text(
                                      "No movie selected",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  else ...[
                                    Text(
                                      movies[selectedIndex!].title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Genre: ${movies[selectedIndex!].genre}",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    Text(
                                      "Length: ${movies[selectedIndex!].length} min",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    Text(
                                      "Year: ${movies[selectedIndex!].year}",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      movies[selectedIndex!].description.isEmpty
                                          ? "No description"
                                          : movies[selectedIndex!].description,
                                      style: TextStyle(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
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
                            prefixIcon: Icon(
                              Icons.movie_outlined,
                              color: netflixRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: lengthController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Length (minutes)",
                            prefixIcon: Icon(
                              Icons.timer_outlined,
                              color: netflixRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: yearController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Year",
                            prefixIcon: Icon(
                              Icons.event_outlined,
                              color: netflixRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Description",
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: netflixRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey(selectedGenre),
                          initialValue: selectedGenre,
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
                            icon: Icon(
                              editingIndex == null ? Icons.add : Icons.save,
                            ),
                            label: Text(
                              editingIndex == null
                                  ? "ADD MOVIE"
                                  : "SAVE CHANGES",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
            ),
            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
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
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => editMovie(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: netflixRed),
                            onPressed: () => deleteMovie(index),
                          ),
                        ],
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
  String description;
  int year;
  Uint8List? thumbnail;

  Movie({
    required this.title,
    this.length = 0,
    this.genre = "",
    this.description = "",
    this.year = 0,
    this.thumbnail,
  });
}
