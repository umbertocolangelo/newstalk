import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Funzione per selezionare un'immagine dalla galleria
  Future<File?> pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Funzione per caricare un'immagine su Firebase Storage
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      Reference storageReference = _storage.ref().child(path);
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Errore nel caricamento dell\'immagine: $e');
      return null;
    }
  }
}
