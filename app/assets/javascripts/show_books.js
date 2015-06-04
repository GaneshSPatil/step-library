var readMoreCallBack = function () {
    var charactersToShow = 400;  // How many characters are shown by default
    var ellipsestext = "...";
    var moretext = "show more";
    var lesstext = "show less";


    jQuery('#description p').each(function() {
        var content = jQuery(this).html();

        if(content.length > charactersToShow) {

            var contentToShow = content.substr(0, charactersToShow);
            var contentToHide = content.substr(charactersToShow, content.length - charactersToShow);

            var html = contentToShow + '<span class="moreellipses">' + ellipsestext+ '&nbsp;</span>' +
                       '<span class="morecontent"><span>' + contentToHide + '</span>&nbsp;&nbsp;' +
                       '<a href="" class="morelink">' + moretext + '</a></span>';

            jQuery(this).html(html);
        }

    });

    jQuery(".morelink").click(function(){
        if(jQuery(this).hasClass("less")) {
            jQuery(this).removeClass("less");
            jQuery(this).html(moretext);
        } else {
            jQuery(this).addClass("less");
            jQuery(this).html(lesstext);
        }
        jQuery(this).parent().prev().toggle();
        jQuery(this).prev().toggle();
        return false;
    });
};
jQuery(document).ready(readMoreCallBack);
jQuery(document).on('page:load', readMoreCallBack);