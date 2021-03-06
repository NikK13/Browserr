import 'dart:typed_data';

class History{
  final int? id;
  final String? title;
  final String? url;
  final int? timestamp;
  final Uint8List? image;

  const History({
    this.id,
    this.title,
    this.url,
    this.timestamp,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    //This will be used to convert Todo objects that
    //are to be stored into the datbase in a form of JSON
    "id": this.id,
    "title": this.title,
    "date": this.timestamp,
    "url": this.url,
    "image": this.image,
  };

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] as int?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      timestamp: json['date'] as int?,
      image: json['image'] as Uint8List?
    );
  }

  /*static Map<String, dynamic> toMap(Place place) => {
    'id': place.id,
    'name': place.name,
    'latitude': place.lat,
    'longitude': place.longt,
    'description': place.desc,
    'image': place.image,
    'url': place.url,
    'location': place.location,
    'type': place.type,
    'new': place.isNew,
    'popular': place.isPopular,
  };*/


}