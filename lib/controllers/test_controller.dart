

class TestController{
  testMediaId(String mediaId){
    var idAlbumArtist = mediaId.split('|');
    if(idAlbumArtist[0] == "artist"){
      return true;
    }else {
      //play album
      return false;
    }
  }
}

