import 'package:flutter/material.dart';

Widget textInformative() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Text(
      'Les informations affichées ici pourraient différer des informations affichées sur le produit en magasin. Veuillez vous référez aux informations affichées sur le produit que vous recevrez.',
      style: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    ),
  );
}
