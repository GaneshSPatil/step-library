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

$(document).ready(function () {
    jQuery("#dialog_form").hide();
    jQuery("#uplaod_single").change(showBookForm);
    jQuery('#reject_button').click(rejectNewBook);
})