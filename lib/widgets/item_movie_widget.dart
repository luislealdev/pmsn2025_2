import 'package:flutter/material.dart';
import 'package:pmsn2025_2/models/api_movie_dao.dart';

class ItemApiMovie extends StatelessWidget {
  ItemApiMovie({super.key, required this.apiMovieDao});

  ApiMovieDao apiMovieDao;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: FadeInImage(
        placeholder: AssetImage('assets/loading.gif'),
        image: NetworkImage(
          'https://image.tmdb.org/t/p/w500/${apiMovieDao.posterPath}',
        ),
      ),
    );
  }
}
