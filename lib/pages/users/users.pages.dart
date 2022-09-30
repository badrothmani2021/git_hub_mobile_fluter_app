import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:git_hub_mobile_app/pages/repositories/git.repo.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
   UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? query;
  bool notvisible = false;
  TextEditingController querytextEditingController = new TextEditingController();
  //object dynamic
  dynamic? data;
  int currentPage=0;
  int totalPages=0;
  int pagesize=20;
  List<dynamic> items= [];
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      if(scrollController.position.pixels==scrollController.position.maxScrollExtent){
        setState(() {
          if(currentPage<totalPages-1) {
            ++currentPage;
            _search(query);
          }
        });
      }
    });
  }

  void _search(String? query) {
        //cette methode nous permet d'envoiyez une requete http au backend
        String url = "https://api.github.com/search/users?q=${query}&per_page=${pagesize}&page=${currentPage}";
        http.get(Uri.parse(url))
            .then((response){
              setState(() {
                this.data = json.decode(response.body);
                //cette ligne nous permet d'ajouter la liste des items json dans notre liste qu'est sous le nom items
                items.addAll(data['items']);
                //cette condition nous permet de calculer le nombre de page qui exsite pour notre recherche
                  //totalPages = data['total_count']~/pagesize;
                if(data['total_count'] % pagesize == 0){
                  this.totalPages = this.data['total_count']~/pagesize;
                }else this.totalPages = (this.data['total_count']~/pagesize).floor() + 1;
                print(totalPages);

              });
              print(response.body);
        })
        .catchError((err){
          print(err);
        });


  }

  @override
  Widget build(BuildContext context) {
      print("building page.....");
    return Scaffold(
      appBar: AppBar(
        title: Text("User => ${query} => $currentPage / $totalPages"),
      ),
      body: Center(
        child:Column(
          children: [
            Row(
              children: [
               Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    obscureText: notvisible,
                    onChanged: (value){
                      setState(() {
                        query=value;
                      });
                    },
                    controller: querytextEditingController,
                  decoration: InputDecoration(
                    //icon: Icon(Icons.logout),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          notvisible = !notvisible;
                        });
                      },
                      icon: Icon(notvisible==true?
                          Icons.visibility:Icons.visibility_off),
                    ),
                    contentPadding: EdgeInsets.only(left: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        width:1,
                        color: Colors.deepOrange
                      )
                    )
                  ),
                  ),
                ),
              ),
                IconButton(
                    icon: Icon(Icons.search, color: Colors.deepOrange),
                    onPressed: () {
                      setState(() {
                        // instead of writing items.clear() we put items = []; to clear the old data
                        items = [];
                        currentPage = 0;
                        query = querytextEditingController.text;
                        _search(query);
                      });
                    }
                ),
              ],
            ),
            SizedBox(height: 10,),
            
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                Divider(height: 2,color: Colors.deepOrange,),
                controller:  scrollController,
                itemCount: items.length,
                  itemBuilder: (context,index){
                    return ListTile(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>
                                GitRepo(login: items[index]['login'],avatarpic: items[index]['avatar_url'],))
                        );
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(items[index]['avatar_url']),
                              radius: 40,
                            ),
                            SizedBox(width: 20,),
                            Text("${items[index]['login']}"),
                          ],
                        ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  child: Text("${items[index]['followers_url'].length}"),
                                ),
                                SizedBox(width: 15,),
                                CircleAvatar(
                                  child: Text("${items[index]['score']}"),
                                ),
                              ],
                            ),

                        ],
                      ),
                    );
                  }
              ),
            )
          ],
        )
      ),

    );
  }
}



