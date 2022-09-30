import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GitRepo extends StatefulWidget {

  String login;
  String avatarpic;

  GitRepo({required this.login,required this.avatarpic});

  @override
  State<GitRepo> createState() => _GitRepoState();
}

class _GitRepoState extends State<GitRepo> {
  dynamic dataRepositories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRepositories();
  }

  void loadRepositories() async{
    String url = "https://api.github.com/users/${widget.login}/repos";
    http.Response response = await http.get(Uri.parse(url));
    if(response.statusCode==200){
      setState(() {
        dataRepositories = json.decode(response.body);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarpic),
            ),
            SizedBox(width: 10,),
            Text(" ${widget.login}"),
          ],
        )
      ),
      body: Center(
        child: ListView.separated(
            itemBuilder: (context, index) => ListTile(

              title: Text("${dataRepositories[index]['name']}",
                style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.bold,
                ),),

            ),
            separatorBuilder: (context,index) =>
              Divider(height: 2,color: Colors.deepOrange,),
            itemCount: dataRepositories== null ? 0 : dataRepositories.length
        ),
      ),
    );
  }
}
