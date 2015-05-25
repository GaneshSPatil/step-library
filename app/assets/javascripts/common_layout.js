var set_current_tab = function () {
    var current_tab_name = $("#current_tab_name").text();
    $("#" + current_tab_name).addClass('active');
};

$(document).ready(set_current_tab);
$(document).on('page:load', set_current_tab);