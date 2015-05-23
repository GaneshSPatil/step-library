
var hideAlert = function(){
    jQuery('#no_book_error').hide();
    jQuery('#no_book_error_message').text("");
};

var showNoBooksFoundError =function(isbn) {
    jQuery('#no_book_error_message').text("Invalid ISBN : \'" + isbn + "\'");
    jQuery('#no_book_error').show();
};

var getImageThumbnailURL = function(image_links) {
    var thumbnail = image_links && image_links.thumbnail;
    return thumbnail || '/assets/default-book.png';
};

var setBookDetails = function(response, isbn) {
    var volumeInfo = response.items[0].volumeInfo;
    var image_links = volumeInfo.imageLinks;
    var thumbnail = getImageThumbnailURL(image_links);

    jQuery('#isbn_confirm').val(isbn);
    jQuery('#title_confirm').val(volumeInfo.title);
    jQuery('#author_confirm').val(volumeInfo.authors);
    if (image_links)
        jQuery('#image_confirm').val(thumbnail);
    jQuery('#book_image_confirm').attr('src', thumbnail);
    jQuery('#confirm_book_modal').show();
};

var processBookDetails = function (response, isbn) {
    jQuery('.alert').hide();
    if (response.totalItems === 0) {
        showNoBooksFoundError(isbn);
        rejectNewBook();
        return;
    }
    setBookDetails(response, isbn);
};

var fetchBookDetails = function () {
    var isbn = jQuery('#isbn_fetch').val().trim();
    var googleApiUrl = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn;
    var isbnInpuBox = jQuery('#isbn_fetch')[0];
    var isbnError = jQuery('#no_isbn_error')[0];
    if(isbn === '') {
        isbnInpuBox.className = "isbn_text_box error_box";
        isbnError.hidden = false;
    }
    else {
      isbnInpuBox.className = "isbn_text_box";
      isbnError.hidden = true;
      jQuery.get(googleApiUrl, function (response) {
        processBookDetails(response, isbn)
      });
    }
};

var rejectNewBook = function () {
    jQuery('#confirm_book_modal').hide();
    jQuery('#add_book_modal').show();
};