var showBookForm = function () {
    var isChecked = $(this).is(':checked');
    if(isChecked)
        jQuery("#dialog_form").show();
    else
        jQuery("#dialog_form").hide();
}

var rejectNewBook = function () {
    window.location.href = '/books/manage';
}

jQuery(document).ready(function () {
    jQuery("#uplaod_single").change(showBookForm);
})