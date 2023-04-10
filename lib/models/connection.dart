import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project2/models/post_model.dart';
import 'package:project2/models/user_model.dart';

// Connection Constants

const Mongo_url = "mongodb+srv://project2:project2@pickabookdata.es9jtrh.mongodb.net/pickabook?retryWrites=true&w=majority";

// Collections
const userdata = "Users";
const books = "bookdata";
const post = "PostDetails";

final Fireuser = FirebaseAuth.instance.currentUser!;




class MongoDatabase{

  static var db, userCollection, bookCollection, postCollection;

  static connect() async{

    db = await Db.create(Mongo_url);

    await db.open();
    inspect(db);
    bookCollection = db.collection(books);
    userCollection = db.collection(userdata);
    postCollection = db.collection(post);
  }

  // Functions

  static Future<String> adduser(Usermap data) async{
    try{
      var results = await userCollection.insertOne(data.toJson());
      if(results.isSuccess){
        return "data inserted";
      }
      else{
        return "Something went wrong";
      }
    }catch(e){
      print(e.toString());
      return e.toString();
    }
  }

  static Future<String> addPost(PostDisplay data) async{
    try {
      var results = await postCollection.insertOne(data.toJson());
      if(results.isSuccess){
        return "data inserted";
      }
      else{
        return "data not inserted";
      }
    }catch(e){
      print(e.toString());
      return e.toString();
    }


  }
  static Future<List<Map<String, dynamic>>> fetchbooks() async
  {
    final result = await bookCollection.find(where.eq('book_average_rating', 3.5).limit(50)).toList();
    return result;
  }
  
  static Future<List<Map<String, dynamic>>> fetchnewbooks() async
  {
    final result = await bookCollection.find(where.gte('publication_year',2017).limit(50)).toList();
    return result;
  }
  
  static Future<List<Map<String, dynamic>>> fetchtopratedbooks() async
  {
    final result = await bookCollection.find(where.gte('book_average_rating',4.8)).toList();
    return result;
  }
  static Future<List<Map<String, dynamic>>> fetchtrendbooks() async
  {
    final result = await bookCollection.find(where.gte('book_average_rating',4).gte('ratings_count', 1000).limit(100)).toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchmarvelbooks() async
  {
    final result = await bookCollection.find(where.eq("publisher","Marvel")).toList();
    return result;
  }


  static Future<List<Map<String, dynamic>>> fetchRomancebooks() async
  {
    final result = await bookCollection.find(where.eq("genre","Romance").limit(50)).toList();
    return result;
  }
  static Future<List<Map<String, dynamic>>> fetchComicbooks() async
  {
    final result = await bookCollection.find(where.eq("genre","Comic").gte('book_average_rating', 4).ne('publisher','Marvel' ).limit(50)).toList();
    return result;
  }
  static Future<List<Map<String, dynamic>>> fetchFantbooks() async
  {
    final result = await bookCollection.find(where.eq("genre","Fantasy & Paranormal").gte('book_average_rating', 4).gt('ratings_count', 500).limit(50)).toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchYoungadultbooks() async
  {
    final result = await bookCollection.find(where.eq("genre","Young Adult").gte('book_average_rating', 4).gt('ratings_count', 500).limit(50)).toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchscholasticbooks() async
  {
    final result = await bookCollection.find(where.eq('publisher','Scholastic Inc').gt('book_average_rating', 3.7).limit(50)).toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> fetchChildrenbooks() async
  {
    final result = await bookCollection.find(where.eq("genre","Children").gt('book_average_rating', 3.6).gt('ratings_count', 500).limit(30)).toList();
    return result;
  }

  static Future<Map<String, dynamic>> fetchUserData() async
  {
    final result = await userCollection.findOne(where.eq("uid", Fireuser.uid));
    return result;
  }
  static Future<List<Map<String, dynamic>>> fetchPost() async{

    final pipeline = AggregationPipelineBuilder().addStage(Lookup(from: "Users", localField: "uid", foreignField: "uid", as: "Res")).build();

    final results = await DbCollection(db, "PostDetails").aggregateToStream(pipeline).toList();
    // print(results);
    results.forEach(print);
    return results;
  }
}

