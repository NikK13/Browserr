import 'dart:typed_data';

class Bookmark{
  final int? id;
  final String? title;
  final String? url;
  final int? timestamp;
  final Uint8List? image;

  const Bookmark({
    this.id,
    this.title,
    this.url,
    this.image,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    "id": this.id,
    "title": this.title,
    "date": this.timestamp,
    "url": this.url,
    "image": this.image,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
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