import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MovieBookingApp());
}

class Movie {
  final String id;
  final String title;
  final String description;
  final String genre;
  final int duration;
  final String posterUrl;

  Movie({
    required this.title,
    required this.description,
    required this.genre,
    required this.duration,
    required this.posterUrl,
  }) : id = Uuid().v4();
}

class Showtime {
  final String id;
  final Movie movie;
  final DateTime time;
  final int totalSeats;
  List<int> availableSeats;
  List<Booking> bookings;

  Showtime({
    required this.movie,
    required this.time,
    this.totalSeats = 50,
  })  : id = Uuid().v4(),
        availableSeats = List.generate(50, (index) => index + 1),
        bookings = [];
}

class Booking {
  final String id;
  final Showtime showtime;
  final int seatNumber;
  final String userName;

  Booking({
    required this.showtime,
    required this.seatNumber,
    required this.userName,
  }) : id = Uuid().v4();
}

class MovieBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<Movie> movies = [
    Movie(
      title: 'Avengers: Endgame',
      description: 'Epic superhero finale',
      genre: 'Action',
      duration: 181,
      posterUrl: 'https://example.com/avengers.jpg',
    ),
    Movie(
      title: 'Inception',
      description: 'Mind-bending sci-fi thriller',
      genre: 'Sci-Fi',
      duration: 148,
      posterUrl: 'https://example.com/inception.jpg',
    ),
  ];

  final List<Showtime> showtimes = [];

  @override
  void initState() {
    super.initState();
    // Generate sample showtimes
    movies.forEach((movie) {
      showtimes.add(Showtime(
        movie: movie,
        time: DateTime.now().add(Duration(days: 1, hours: 18)),
      ));
      showtimes.add(Showtime(
        movie: movie,
        time: DateTime.now().add(Duration(days: 1, hours: 21)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Booking'),
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(
            movie: movie,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowtimesScreen(
                    movie: movie,
                    showtimes: showtimes
                        .where((st) => st.movie.id == movie.id)
                        .toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(movie.title),
        subtitle: Text(
          '${movie.genre} | ${movie.duration} mins',
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class ShowtimesScreen extends StatelessWidget {
  final Movie movie;
  final List<Showtime> showtimes;

  const ShowtimesScreen({
    Key? key,
    required this.movie,
    required this.showtimes,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return const Scaffold(); // or any other widget
  }
}

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;

  const SeatSelectionScreen({
    Key? key,
    required this.showtime,
  }) : super(key: key);

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  int? selectedSeat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Seat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.5,
              ),
              itemCount: widget.showtime.totalSeats,
              itemBuilder: (context, index) {
                final seatNumber = index + 1;
                final isAvailable =
                    widget.showtime.availableSeats.contains(seatNumber);
                final isSelected = selectedSeat == seatNumber;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          setState(() {
                            selectedSeat = seatNumber;
                          });
                        }
                      : null,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green
                          : isAvailable
                              ? Colors.blue[200]
                              : Colors.red[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        seatNumber.toString(),
                        style: TextStyle(
                          color: isAvailable ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedSeat != null
                  ? () {
                      _showBookingDialog(context);
                    }
                  : null,
              child: Text('Book Seat'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Create booking
                  final booking = Booking(
                    showtime: widget.showtime,
                    seatNumber: selectedSeat!,
                    userName: nameController.text,
                  );

                  // Remove seat from available seats
                  widget.showtime.availableSeats.remove(selectedSeat);
                  widget.showtime.bookings.add(booking);

                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Booking successful! Seat $selectedSeat booked for ${nameController.text}',
                      ),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
