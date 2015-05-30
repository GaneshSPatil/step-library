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
    var isbnInputBox = jQuery('#isbn_fetch')[0];
    var isbnError = jQuery('#no_isbn_error')[0];
    if (isbn === '') {
        isbnInputBox.className = "isbn_text_box error_box";
        isbnError.hidden = false;
    }
    else {
        isbnInputBox.className = "isbn_text_box";
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

var fetchCopyLogs = function (bookCopyId) {
    if (bookCopyId==0)
        hideTableRows();
    jQuery.get("/book-copy/" + bookCopyId + "/logs", function (records) {
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

var hideTableRows =function(){
    var table = document.getElementById('book_copy');
    table.style.display = "none";
};

var showTableRows = function (records, dateOptions, tableBody) {
    tableBody.removeAttribute("class", "no-records");
    if(records.length == 0) {
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

var getDateOptions = function () {
    return {
        year: "numeric", month: "short",
        day: "numeric", hour: "2-digit", minute: "2-digit"
    };
};