import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage_prac/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final results = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg'],
                );

                if (results == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No file selected.'),
                    ),
                  );
                  return null;
                }

                final path = results?.files.single.path!;
                final fileName = results.files.single.name;

                storage
                    .uploadFile(path!, fileName)
                    .then((value) => print('Done'));
              },
              child: Text('Upload File'),
            ),
          ),
          FutureBuilder(
              future: storage.listFiles(),
              builder: (BuildContext context,
                  AsyncSnapshot<firebase_storage.ListResult> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 100,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                snapshot.data!.items[index].name,
                              ),
                            ),
                          );
                        }),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return Container();
              }),
          FutureBuilder(
              future: storage.downloadURL('maronne.png'),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    width: 300,
                    height: 250,
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Container();
              }),
        ],
      ),
    );
  }
}
