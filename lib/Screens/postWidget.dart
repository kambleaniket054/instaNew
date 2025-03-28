import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import '../../domain/entities/post_entity.dart';

class PostWidget extends StatelessWidget {
  // final PostEntity post;
  // const PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFeyZkw9fTgBSL8bRSTWhqtex0fvjYwFhaNA&s",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              "post.caption",
              style: TextStyle(color: Colors.white, fontSize: 18, shadows: [
                Shadow(color: Colors.black, blurRadius: 4),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}