// display badge preview after image upload
$('.badge-image-upload').change(function () {
  var file = this.files[0];
  var imageType = /^image\//;

    if (imageType.test(file.type)) {
      var previewWrapper = $('.preview-wrapper');
      var previewImg = $('.preview-wrapper .icon-preview .img-cropper img');
      var reader = new FileReader();

      reader.addEventListener( 'load', function() {
        previewImg.attr('src', reader.result);
      }, false);
      reader.readAsDataURL(file);
      previewWrapper.removeClass('hidden');
  }
});

// display media image preview after image upload
$('.media-image-upload').change(function () {
  var file = this.files[0];
  var imageType = /^image\//;

    if (imageType.test(file.type)) {
      var previewImg = $('.image-preview');
      var reader = new FileReader();

      reader.addEventListener( 'load', function() {
        previewImg.css('background-image', 'url('+ reader.result +')');
      }, false);
      reader.readAsDataURL(file);
  }
});
