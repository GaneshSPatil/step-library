var tagsInputOptions = {
  'width': '75%',
  'height': '30px',
  'interactive': true,
  'defaultText': '',
  'delimiter': [' '],
  'removeWithBackspace': true
};

var tagsInputOptionsIsbn = {
  'width': '75%',
  'height': '65px',
  'interactive': true,
  'defaultText': '',
  'delimiter': [' '],
  'removeWithBackspace': true
};

var setTagInput= function() {
  $('#tags_confirm').tagsInput(tagsInputOptionsIsbn);
  $('#manual_tags_confirm').tagsInput(tagsInputOptions);
};

var editTagInput= function(height,width) {
    $('#tags_confirm').tagsInput({
        'width': width,
        'height': height,
        'interactive': true,
        'defaultText': '',
        'delimiter': [' '],
        'removeWithBackspace': true
    });
}

var hideAlert = function () {
    jQuery('#no_book_error').hide();
    jQuery('#no_book_error_message').text("");
};

var showNoBooksFoundError = function (isbn) {
    jQuery('#no_book_error_message').text("Invalid ISBN : \'" + isbn + "\'");
    jQuery('#no_book_error').show();
};

var getImageThumbnailURL = function (image_links) {
    var thumbnail = image_links && image_links.thumbnail;
    return thumbnail || '/assets/default-book.png';
};

var setBookDetails = function (response, isbn) {
    var volumeInfo = response.items[0].volumeInfo;
    var image_links = volumeInfo.imageLinks;
    var thumbnail = getImageThumbnailURL(image_links);

    jQuery('#isbn_confirm').val(isbn);
    jQuery('#title_confirm').val(volumeInfo.title);
    jQuery('#author_confirm').val(volumeInfo.authors);
    if (image_links)
        jQuery('#image_confirm').val(thumbnail);
    jQuery('#book_image_confirm').attr('src', thumbnail);
    jQuery('#page_count').val(volumeInfo.pageCount);
    jQuery('#publisher').val(volumeInfo.publisher);
    jQuery('#description').val(volumeInfo.description);
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
var getBookDetails = function () {
    var isbn = jQuery('#isbn_fetch').val().trim();
    var isbnInputBox = jQuery('#isbn_fetch')[0];
    var isbnError = jQuery('#no_isbn_error')[0];
    isbnInputBox.className = "isbn_text_box";
    isbnError.hidden = true;
    if (isbn === '') {
        isbnInputBox.className = "isbn_text_box error_box";
        isbnError.hidden = false;
        return;
    }
    setTagInput();
    jQuery.get("/books/" + isbn + "/details", function (book) {
        if (!book) {
            //check if book is not present in library.
            jQuery('#add_book_copies_modal').hide();
            fetchBookDetails();
        }
        else {
            jQuery('#isbn_copy_confirm').val(book.isbn);
            jQuery('#title_copy_confirm').val(book.title);
            jQuery('#author_copy_confirm').val(book.author);
            jQuery('#image_copy_confirm').val(book.image_link);
            jQuery('#book_image_copy_confirm').attr('src', getImageThumbnailURL(book.image_link));
            jQuery('#modal_opener').click();
            jQuery('#confirm_book_modal').hide();
        }

    });
};

var addBookCopies = function () {
    jQuery('#confirm_add_more_copies_modal').hide();
    jQuery('#add_book_copies_modal').show();
};

var fetchBookDetails = function () {
    var isbn = jQuery('#isbn_fetch').val().trim();
    var googleApiUrl = "https://www.googleapis.com/books/v1/volumes?key=AIzaSyBObJg4MnFUJMDqM4z5x3FJcTcCdycAPQU&q=isbn:" + isbn;

    jQuery.get(googleApiUrl, function (response) {
            processBookDetails(response, isbn)
    });
};

var rejectNewBook = function () {
    jQuery('#confirm_book_modal').hide();
    jQuery("#add_book_copies_modal").hide();
    jQuery('#add_book_modal').show();
};

var fetchCopyLogs = function (bookCopyId) {
    if (bookCopyId == 0)
        hideTableRows();

    var bookId = jQuery('#book_id').val();
    var book_copy_id = bookId+'-'+bookCopyId;
    jQuery.get("/book-copy/" + book_copy_id + "/logs", function (records) {
        showBookCopyLogs(records);
    });
};

var showBookCopyLogs = function (records) {
    var table = document.getElementById('book_copy');
    table.style.display = "table";
    var tableBody = document.getElementById('logs');
    tableBody.innerHTML = "";
    table.appendChild(tableBody);
    showTableRows(records.reverse(), getDateOptions(), tableBody);
};

var hideTableRows = function () {
    var table = document.getElementById('book_copy');
    table.style.display = "none";
};

var showTableRows = function (records, dateOptions, tableBody) {
    tableBody.removeAttribute("class", "no-records");
    if (records.length == 0) {
        var trNoRecords = document.createElement('TR');
        tableBody.setAttribute("class", "no-records");
        trNoRecords.appendChild(document.createTextNode("No logs available for this copy."));
        tableBody.appendChild(trNoRecords);
    }
    for (var i = 0; i < records.length; i++) {
        var tr = document.createElement('TR');
        var tdName = document.createElement('TD');
        var tdBorrow = document.createElement('TD');
        var tdReturn = document.createElement('TD');
        tdName.appendChild(document.createTextNode(records[i].user.name));
        var borrowDate = records[i].borrow_date;
        tdBorrow.appendChild(document.createTextNode(new Date(borrowDate).toLocaleTimeString("en-us", dateOptions)));
        var date = "Not returned yet.";
        if (records[i].return_date != null) {
            date = new Date(records[i].return_date).toLocaleTimeString("en-us", dateOptions);
        }
        tdReturn.appendChild(document.createTextNode(date));
        tr.appendChild(tdName);
        tr.appendChild(tdBorrow);
        tr.appendChild(tdReturn);
        tableBody.appendChild(tr);
    }
};

var editDetails = function () {
    jQuery('#edit_form').attr('hidden', false);
    jQuery('#borrow_form').attr('hidden', true);
    editTagInput('80px','100%');
    tags.forEach(function(item){$("#tags_confirm").addTag(item)})
};

var cancelDetails = function () {
  jQuery('#edit_form').attr('hidden', true);
  jQuery('#borrow_form').attr('hidden', false);
};

var getDateOptions = function () {
    return {
        year: "numeric", month: "short",
        day: "numeric", hour: "2-digit", minute: "2-digit"
    };
};

var checkConfirmation = function() {
    if($('#isbn_manual_confirm').val() == '') {
        var modal = $('#add_book_manually');
        modal.modal({show:true});
        return;
    }
    addBookManually();
};

var addBookManually = function() {
  $('#add_book_manually_submit').click();
};