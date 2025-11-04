import 'package:flutter/material.dart';
import 'package:pmsn2025_2/services/api_catholic.dart';
import 'package:pmsn2025_2/utils/app_strings.dart';

class ListSeriesScreen extends StatefulWidget {
  const ListSeriesScreen({super.key});

  @override
  State<ListSeriesScreen> createState() => _ListSeriesScreenState();
}

class _ListSeriesScreenState extends State<ListSeriesScreen> {
  ApiCatholic apiCatholic = ApiCatholic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Series")),
      body: FutureBuilder(
        future: apiCatholic.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              itemCount: snapshot.data!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "${AppStrings.urlBase}${snapshot.data![index].thumbUrl}",
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            if (snapshot.hasError) {
              return Center(child: Text("Something was wrong!"));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
        },
      ),
    );
  }
}
