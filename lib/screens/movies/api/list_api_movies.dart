import 'package:flutter/material.dart';
import 'package:pmsn2025_2/services/api_movies.dart';
import 'package:pmsn2025_2/widgets/item_movie_widget.dart';

class ListApiMovies extends StatefulWidget {
  const ListApiMovies({super.key});

  @override
  State<ListApiMovies> createState() => _ListApiMoviesState();
}

class _ListApiMoviesState extends State<ListApiMovies> {
  ApiMovies? apiMovies = ApiMovies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Api Movies')),
      body: FutureBuilder(
        future: apiMovies!.getMovies(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                SliverGrid.builder(
                  itemCount: snapshot.data!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return ItemApiMovie(apiMovieDao: snapshot.data![index]);
                  },
                ),
              ],
            );

            // GridView.builder(
            //   itemCount: snapshot.data!.length,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //   ),
            //   itemBuilder: (context, index) {
            //     return ItemApiMovie(apiMovieDao: snapshot.data![index]);
            //   },
            // );
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
        },
      ),
    );
  }
}
