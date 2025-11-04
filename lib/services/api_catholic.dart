import 'package:dio/dio.dart';
import 'package:async/async.dart';
import 'package:pmsn2025_2/models/series_dao.dart';
import 'package:pmsn2025_2/utils/app_strings.dart';

class ApiCatholic {
  Dio dio = Dio();

  Future<List<SeriesDao>> getCategory(int idCategory) async {
    String URL = "${AppStrings.urlBase}/json/categories/$idCategory.json";
    final response = await dio.get(URL);
    final res = response.data['series'] as List;
    return res.map((serie) => SeriesDao.fromMap(serie)).toList();
  }

  Future<List<SeriesDao>> getAllCategories() async {
    final FutureGroup<List<SeriesDao>> futureGroup = FutureGroup();
    futureGroup.add(getCategory(2));
    futureGroup.add(getCategory(3));
    futureGroup.add(getCategory(4));
    futureGroup.add(getCategory(5));
    futureGroup.add(getCategory(6));
    futureGroup.close();

    List<SeriesDao> listSeries = List<SeriesDao>.empty(growable: true);
    final List<List<SeriesDao>> results = await futureGroup.future;
    for (var series in results) {
      listSeries.addAll(series);
    }
    return listSeries;
  }
}
