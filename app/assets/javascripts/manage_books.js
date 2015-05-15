var showBookForm = function () {
    var isUploadSingle = jQuery('#uplaod_single_book').is(':checked');
    if (isUploadSingle) {
        jQuery("#add_book_modal").show();
    }
    else
        jQuery("#add_book_modal").hide();
};

var extractBookDetails = function (response, isbn) {
    jQuery('.alert').hide();
    if (response.totalItems === 0) {
        jQuery('#no_book_error_message').text("There is no book with isbn:-" + isbn);
        jQuery('#no_book_error').show();
        return;
    }
    var volumeInfo = response.items[0].volumeInfo;
    var title = volumeInfo.title;
    var authors = volumeInfo.authors;
    var image_links = volumeInfo.imageLinks;
    var thumbnail = image_links && image_links.thumbnail;
    thumbnail = thumbnail || '/assets/default-book.png';
    jQuery('#isbn_confirm').val(isbn);
    jQuery('#title_confirm').val(title);
    jQuery('#author_confirm').val(authors[0]);
    if (image_links)
        jQuery('#image_confirm').val(thumbnail);
    jQuery('#book_image_confirm').attr('src', thumbnail);
    jQuery('#confirm_book_modal').show();
    jQuery('#add_book_modal').hide();
    jQuery('#add_book_controls').hide();
};

var fetchBookDetails = function () {
    var isbn = jQuery('#isbn_fetch').val().trim();
    var googleApiUrl = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
    jQuery.get(googleApiUrl, function (response) {
        extractBookDetails(response, isbn)
    });
};

var rejectNewBook = function () {
    jQuery('#uplaod_single_book').prop('checked', false);
    jQuery('#confirm_book_modal').hide();
    jQuery('#add_book_modal').hide();
    jQuery('#add_book_controls').show();
};