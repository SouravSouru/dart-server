import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

MySqlConnection? con;

// Configure routes.
final _router = Router()
  ..get('/getNotes', getNotes)
  ..post('/addNotes', addNotes)
  ..get('/getdata', getData)
  ..post('/logindata', logindata)
  ..put("/putdata", putdata)
  ..post('/updateNotes', updateNotes)
  ..post('/removeNotes', removeNotes)
  ..post('/userid', userid)
  ..get('/echo/<message>', _echoHandler);


// to do ap i

Future<Response> getNotes(Request req) async {
  Results res = await con!.query("select *from notes");
  return Response.ok(
      jsonEncode({"message": res.map((e) => e.fields).toList()}));
  //return Response.ok(jsonEncode({'asdf':'body'}));
}
Future<Response> addNotes(Request req) async {
  final message = jsonDecode(await req.readAsString());
  String title = message["title"];
  String content = message["content"];
  Results res = await con!
      .query("insert into notes(title,content) values('$title','$content')");
  return Response.ok(jsonEncode({"message": "inserted"}));
}
Future<Response> removeNotes(Request req) async {
  final message = jsonDecode(await req.readAsString());
  int id = message["id"];

  Results res = await con!.query("delete from notes where id='$id'");
  return Response.ok(jsonEncode({"message": "deleted"}));
}  

Future<Response> updateNotes(Request req)async{
  final message = jsonDecode(await req.readAsString());
  final titles =message["title"];
  final contents =message["content"];
  final id = message['id'];

  Results res = await con!.query("update notes set title='$titles',content='$contents' where id='$id'");
  return Response.ok(jsonEncode({"message":"note updated"}));
}



// examples

Future<Response> userid(Request req) async {

 final message = jsonDecode(await req.readAsString());
  String title = message["id"];
  if(title =="2"){
   return Response.ok(jsonEncode({"message": "sucess","data": [
        {
            "id": "${title}",
            "email": "michael.lawson@reqres.in",
            "first_name": "Michael",
            "last_name": "Lawson",
            "avatar": "https://reqres.in/img/faces/7-image.jpg"
        },
        {
            "id": "${title}",
            "email": "lindsay.ferguson@reqres.in",
            "first_name": "Lindsay",
            "last_name": "Ferguson",
            "avatar": "https://reqres.in/img/faces/8-image.jpg"
        },
        {
            "id": "${title}",
            "email": "tobias.funke@reqres.in",
            "first_name": "Tobias",
            "last_name": "Funke",
            "avatar": "https://reqres.in/img/faces/9-image.jpg"
        },
        {
            "id": "${title}",
            "email": "byron.fields@reqres.in",
            "first_name": "Byron",
            "last_name": "Fields",
            "avatar": "https://reqres.in/img/faces/10-image.jpg"
        },
        {
            "id": "${title}",
            "email": "george.edwards@reqres.in",
            "first_name": "George",
            "last_name": "Edwards",
            "avatar": "https://reqres.in/img/faces/11-image.jpg"
        },
        {
            "id": "${title}",
            "email": "rachel.howell@reqres.in",
            "first_name": "Rachel",
            "last_name": "Howell",
            "avatar": "https://reqres.in/img/faces/12-image.jpg"
        }
    ],
   }));

  }else{
       return Response.ok(jsonEncode({"message": "falid",}));

  }
  
 
}



Future<Response> putdata(Request req) async {

 final message = jsonDecode(await req.readAsString());
  String title = message["name"];
  String content = message["job"];
   return Response.ok(jsonEncode({"message": "updated","name":title,"job":content}));
   
 
}



Future<Response> logindata(Request req) async {
  final message = jsonDecode(await req.readAsString());
  String title = message["email"];
  String content = message["password"];
  //Results res = await con!.query("insert into notes(title,content) values('$title','$content')");

  if (title == "futuralab" && content == "123456") {
    return Response.ok(jsonEncode({"message": "success"}));
  }
  return Response.notFound(jsonEncode({"message":"falid"}));
}

Future<Response> getData(Request req) async {
  return Response.ok(jsonEncode({'Message': 'body'}));
}



Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<void> startDB() async {
  con = await MySqlConnection.connect(ConnectionSettings(
    host: "127.0.0.1",
    port: 3306,
    user: "root",
    db: "sample",
  ));
}

void main(List<String> args) async {
  await startDB();
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, '0.0.0.0', port);
  print('Server listening on port ${server.port}');
}
