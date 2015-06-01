var createUserLink = function (user) {
    var userLink = document.createElement('a');
    userLink["href"] = "users/" + user.id;
    userLink["className"] = "list-group-item";
    var userName = document.createElement('h4');
    userName["innerText"] = user.name;
    userLink.appendChild(userName);
    return userLink;
};

var appendUsersLinkTo = function(listOfUsers) {
    return function (user) {
        listOfUsers.appendChild(createUserLink(user))
    };
};

var createUsersList = function (usersList, result) {
    usersList.textContent = "";
    result.map(appendUsersLinkTo(usersList));
};

var searchDisabledUsers = function () {
    var disabledUsersList = $(".list-group")[1];
    var userName = $("#search_disabled").val();
    $.ajax({
        url: '/users/disabled/list.json?search_disabled=' + userName, success: function (result) {
            deleteOldList();
            if(result.length == 0) {
                showNoUsersFoundErrorIn("#disabled-users-list");
                return;
            }
            createUsersList(disabledUsersList, result)
        }
    });
};

var showNoUsersFoundErrorIn = function(locator) {
    $(locator).html("<h4>No User Found..!!</h4>");
};

var deleteOldList = function() {
    $("#disabled-users-list").html("");
};

var searchUsers = function () {
    var usersList = $(".list-group")[0];
    var userName = $("#search").val();
    $.ajax({
        url: '/users.json?search=' + userName, success: function (result) {
          if(result.length == 0) {
            showNoUsersFoundErrorIn("#users-list");
            return;
          }
          createUsersList(usersList, result)
        }
    });
};

var searchDisabledUsersOnEnter = function(e) {
    var key = e.which;
    if(key == 13)  // the enter key code
        searchDisabledUsers();
};